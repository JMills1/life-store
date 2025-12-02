//
//  WorkspaceInvitationService.swift
//  LifePlanner
//
//  Handles workspace invitation link generation and joining
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class WorkspaceInvitationService: ObservableObject {
    static let shared = WorkspaceInvitationService()
    
    private let db = Firestore.firestore()
    private let baseURL = "lifeplanner://join" // Deep link URL scheme
    
    private init() {}
    
    // MARK: - Generate Invite Link
    
    /// Generates a new invite link for a workspace (automatically expires old one)
    func generateInviteLink(for workspace: Workspace) async throws -> String {
        guard let workspaceId = workspace.id else {
            throw WorkspaceError.invalidWorkspace
        }
        
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw WorkspaceError.notAuthenticated
        }
        
        // Check if user is owner or has permission to invite
        guard workspace.ownerId == currentUserId ||
              workspace.members.first(where: { $0.userId == currentUserId })?.permissions.canInviteMembers == true else {
            throw WorkspaceError.insufficientPermissions
        }
        
        // Create new invite link
        let inviteLink = WorkspaceInviteLink(createdBy: currentUserId)
        
        // Update workspace with new invite link
        var updatedWorkspace = workspace
        updatedWorkspace.inviteLink = inviteLink
        updatedWorkspace.updatedAt = Date()
        
        try await db.collection("workspaces").document(workspaceId).updateData([
            "inviteLink": try Firestore.Encoder().encode(inviteLink),
            "updatedAt": Timestamp(date: Date())
        ])
        
        // Return the full invite URL
        return "\(baseURL)/\(inviteLink.code)"
    }
    
    // MARK: - Join Workspace
    
    /// Joins a workspace using an invite code
    func joinWorkspace(inviteCode: String) async throws -> Workspace {
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw WorkspaceError.notAuthenticated
        }
        
        // Find workspace with this invite code
        let snapshot = try await db.collection("workspaces")
            .whereField("inviteLink.code", isEqualTo: inviteCode)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw WorkspaceError.invalidInviteCode
        }
        
        var workspace = try document.data(as: Workspace.self)
        
        // Check if invite link is still valid
        guard let inviteLink = workspace.inviteLink, inviteLink.isValid else {
            throw WorkspaceError.inviteLinkExpired
        }
        
        // Check if user is already a member
        if workspace.members.contains(where: { $0.userId == currentUserId }) {
            return workspace // Already a member
        }
        
        // Add user as a member
        let newMember = WorkspaceMember(
            userId: currentUserId,
            role: .editor,
            permissions: MemberPermissions.forRole(.editor)
        )
        
        workspace.members.append(newMember)
        
        // Update usage count
        var updatedInviteLink = inviteLink
        updatedInviteLink.usageCount += 1
        workspace.inviteLink = updatedInviteLink
        workspace.updatedAt = Date()
        
        // Save to Firestore
        guard let workspaceId = workspace.id else {
            throw WorkspaceError.invalidWorkspace
        }
        
        try await db.collection("workspaces").document(workspaceId).updateData([
            "members": workspace.members.map { try! Firestore.Encoder().encode($0) },
            "inviteLink.usageCount": updatedInviteLink.usageCount,
            "updatedAt": Timestamp(date: Date())
        ])
        
        return workspace
    }
    
    // MARK: - Refresh Invite Link
    
    /// Checks if invite link needs refresh and regenerates if expired
    func refreshInviteLinkIfNeeded(for workspace: Workspace) async throws -> String? {
        // Personal workspaces don't have invite links
        guard workspace.type == .shared else {
            return nil
        }
        
        // If no invite link or expired, generate new one
        if workspace.inviteLink == nil || workspace.inviteLink?.isExpired == true {
            return try await generateInviteLink(for: workspace)
        }
        
        // Return existing valid link
        if let inviteLink = workspace.inviteLink {
            return "\(baseURL)/\(inviteLink.code)"
        }
        
        return nil
    }
    
    // MARK: - Get Workspace Members
    
    /// Fetches detailed information about workspace members
    func getWorkspaceMembers(for workspace: Workspace) async throws -> [WorkspaceMemberInfo] {
        var memberInfos: [WorkspaceMemberInfo] = []
        
        for member in workspace.members {
            do {
                let userDoc = try await db.collection("users").document(member.userId).getDocument()
                if let user = try? userDoc.data(as: User.self) {
                    memberInfos.append(WorkspaceMemberInfo(
                        member: member,
                        user: user,
                        isOwner: member.userId == workspace.ownerId
                    ))
                }
            } catch {
                print("Error fetching user \(member.userId): \(error)")
            }
        }
        
        return memberInfos.sorted { $0.isOwner && !$1.isOwner }
    }
    
    // MARK: - Remove Member
    
    /// Removes a member from a workspace (owner only)
    func removeMember(userId: String, from workspace: Workspace) async throws {
        guard let workspaceId = workspace.id else {
            throw WorkspaceError.invalidWorkspace
        }
        
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw WorkspaceError.notAuthenticated
        }
        
        // Only owner can remove members
        guard workspace.ownerId == currentUserId else {
            throw WorkspaceError.insufficientPermissions
        }
        
        // Can't remove the owner
        guard userId != workspace.ownerId else {
            throw WorkspaceError.cannotRemoveOwner
        }
        
        // Remove member
        var updatedWorkspace = workspace
        updatedWorkspace.members.removeAll { $0.userId == userId }
        updatedWorkspace.updatedAt = Date()
        
        try await db.collection("workspaces").document(workspaceId).updateData([
            "members": updatedWorkspace.members.map { try! Firestore.Encoder().encode($0) },
            "updatedAt": Timestamp(date: Date())
        ])
    }
}

// MARK: - Supporting Types

struct WorkspaceMemberInfo: Identifiable {
    let member: WorkspaceMember
    let user: User
    let isOwner: Bool
    
    var id: String { member.userId }
}

enum WorkspaceError: LocalizedError {
    case invalidWorkspace
    case notAuthenticated
    case insufficientPermissions
    case invalidInviteCode
    case inviteLinkExpired
    case cannotRemoveOwner
    
    var errorDescription: String? {
        switch self {
        case .invalidWorkspace:
            return "Invalid workspace"
        case .notAuthenticated:
            return "You must be signed in"
        case .insufficientPermissions:
            return "You don't have permission to perform this action"
        case .invalidInviteCode:
            return "Invalid or expired invite link"
        case .inviteLinkExpired:
            return "This invite link has expired"
        case .cannotRemoveOwner:
            return "Cannot remove workspace owner"
        }
    }
}

