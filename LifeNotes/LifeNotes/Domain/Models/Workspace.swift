//
//  Workspace.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct Workspace: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var type: WorkspaceType
    var ownerId: String
    var familyId: String? // Only for shared workspaces
    var color: String // Hex color
    var icon: String // SF Symbol name
    var members: [WorkspaceMember]
    var inviteLink: WorkspaceInviteLink? // Current active invite link
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    
    enum WorkspaceType: String, Codable {
        case personal
        case shared
    }
    
    init(
        id: String? = nil,
        name: String,
        type: WorkspaceType = .personal,
        ownerId: String,
        familyId: String? = nil,
        color: String = "4CAF50",
        icon: String = "calendar",
        members: [WorkspaceMember] = [],
        inviteLink: WorkspaceInviteLink? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.ownerId = ownerId
        self.familyId = familyId
        self.color = color
        self.icon = icon
        self.members = members
        self.inviteLink = inviteLink
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
    
    /// Get the display color for this workspace
    /// - Personal workspaces: uses the user's personal color
    /// - Shared workspaces: uses the member's custom color if set, otherwise workspace default color
    func displayColor(personalColor: String?, currentUserId: String? = nil) -> String {
        // Personal workspaces use personal color
        if type == .personal, let personalColor = personalColor {
            return personalColor
        }
        
        // Shared workspaces: check if current user has a custom color preference
        if type == .shared, let userId = currentUserId {
            if let member = members.first(where: { $0.userId == userId }),
               let customColor = member.customColor {
                return customColor
            }
        }
        
        // Default to workspace color
        return color
    }
}

struct WorkspaceMember: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var role: MemberRole
    var permissions: MemberPermissions
    var joinedAt: Date
    var customColor: String? // Optional custom color for this member's view of the workspace
    
    enum MemberRole: String, Codable {
        case owner
        case admin
        case editor
        case viewer
    }
    
    init(
        userId: String,
        role: MemberRole = .editor,
        permissions: MemberPermissions = MemberPermissions(),
        joinedAt: Date = Date(),
        customColor: String? = nil
    ) {
        self.userId = userId
        self.role = role
        self.permissions = permissions
        self.joinedAt = joinedAt
        self.customColor = customColor
    }
}

struct MemberPermissions: Codable {
    var canCreateEvents: Bool
    var canEditEvents: Bool
    var canDeleteEvents: Bool
    var canCreateTodos: Bool
    var canEditTodos: Bool
    var canDeleteTodos: Bool
    var canCreateNotes: Bool
    var canEditNotes: Bool
    var canDeleteNotes: Bool
    var canInviteMembers: Bool
    
    init(
        canCreateEvents: Bool = true,
        canEditEvents: Bool = true,
        canDeleteEvents: Bool = true,
        canCreateTodos: Bool = true,
        canEditTodos: Bool = true,
        canDeleteTodos: Bool = true,
        canCreateNotes: Bool = true,
        canEditNotes: Bool = true,
        canDeleteNotes: Bool = true,
        canInviteMembers: Bool = false
    ) {
        self.canCreateEvents = canCreateEvents
        self.canEditEvents = canEditEvents
        self.canDeleteEvents = canDeleteEvents
        self.canCreateTodos = canCreateTodos
        self.canEditTodos = canEditTodos
        self.canDeleteTodos = canDeleteTodos
        self.canCreateNotes = canCreateNotes
        self.canEditNotes = canEditNotes
        self.canDeleteNotes = canDeleteNotes
        self.canInviteMembers = canInviteMembers
    }
    
    static func forRole(_ role: WorkspaceMember.MemberRole) -> MemberPermissions {
        switch role {
        case .owner, .admin:
            return MemberPermissions(canInviteMembers: true)
        case .editor:
            return MemberPermissions()
        case .viewer:
            return MemberPermissions(
                canCreateEvents: false,
                canEditEvents: false,
                canDeleteEvents: false,
                canCreateTodos: false,
                canEditTodos: false,
                canDeleteTodos: false,
                canCreateNotes: false,
                canEditNotes: false,
                canDeleteNotes: false
            )
        }
    }
}

/// Workspace invitation link that expires after 24 hours
struct WorkspaceInviteLink: Codable {
    var code: String // Unique invite code
    var createdAt: Date
    var expiresAt: Date
    var createdBy: String // userId who generated the link
    var usageCount: Int // Track how many times it's been used
    
    init(
        code: String = UUID().uuidString,
        createdBy: String,
        expiresAt: Date? = nil
    ) {
        self.code = code
        self.createdBy = createdBy
        self.createdAt = Date()
        self.expiresAt = expiresAt ?? Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        self.usageCount = 0
    }
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var isValid: Bool {
        !isExpired
    }
}

