//
//  DeepLinkHandler.swift
//  LifePlanner
//
//  Handles deep links for workspace invitations and other features
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DeepLinkHandler: ObservableObject {
    static let shared = DeepLinkHandler()
    
    @Published var pendingInviteCode: String?
    @Published var showingJoinWorkspace = false
    @Published var joinedWorkspace: Workspace?
    @Published var joinError: String?
    
    private let invitationService = WorkspaceInvitationService.shared
    
    private init() {}
    
    /// Handles incoming deep link URLs
    func handleURL(_ url: URL) {
        print("🔗 Deep link received: \(url)")
        
        // Check if it's a workspace invite link
        // Format: lifeplanner://join/{inviteCode}
        if url.scheme == "lifeplanner" && url.host == "join" {
            let inviteCode = url.pathComponents.dropFirst().joined(separator: "/")
            
            if !inviteCode.isEmpty {
                print("📨 Workspace invite code: \(inviteCode)")
                handleWorkspaceInvite(inviteCode: inviteCode)
            }
        }
    }
    
    /// Handles workspace invitation
    private func handleWorkspaceInvite(inviteCode: String) {
        // Check if user is authenticated
        guard AuthService.shared.isAuthenticated else {
            // Store invite code to process after login
            pendingInviteCode = inviteCode
            print("⏳ User not authenticated, storing invite code for later")
            return
        }
        
        // Process invite immediately
        Task {
            await joinWorkspace(inviteCode: inviteCode)
        }
    }
    
    /// Joins a workspace using invite code
    func joinWorkspace(inviteCode: String) async {
        do {
            print("🚀 Attempting to join workspace with code: \(inviteCode)")
            let workspace = try await invitationService.joinWorkspace(inviteCode: inviteCode)
            
            print("✅ Successfully joined workspace: \(workspace.name)")
            joinedWorkspace = workspace
            showingJoinWorkspace = true
            pendingInviteCode = nil
            
            // Refresh workspace manager to show new workspace
            await WorkspaceManager.shared.loadWorkspaces()
            
        } catch {
            print("❌ Failed to join workspace: \(error.localizedDescription)")
            joinError = error.localizedDescription
            showingJoinWorkspace = true
        }
    }
    
    /// Processes any pending invite after user logs in
    func processPendingInvite() async {
        guard let inviteCode = pendingInviteCode else { return }
        
        print("🔄 Processing pending invite: \(inviteCode)")
        await joinWorkspace(inviteCode: inviteCode)
    }
    
    /// Dismisses the join workspace alert
    func dismissJoinAlert() {
        showingJoinWorkspace = false
        joinedWorkspace = nil
        joinError = nil
    }
}

