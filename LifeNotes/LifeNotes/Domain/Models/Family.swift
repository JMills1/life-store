//
//  Family.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct Family: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var createdBy: String // userId
    var createdAt: Date
    var members: [FamilyMember]
    var inviteCodes: [InviteCode]
    
    init(
        id: String? = nil,
        name: String,
        createdBy: String,
        createdAt: Date = Date(),
        members: [FamilyMember] = [],
        inviteCodes: [InviteCode] = []
    ) {
        self.id = id
        self.name = name
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.members = members
        self.inviteCodes = inviteCodes
    }
}

struct FamilyMember: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var role: FamilyRole
    var joinedAt: Date
    var nickname: String? // Optional family-specific nickname
    
    enum FamilyRole: String, Codable {
        case admin
        case member
    }
    
    init(
        userId: String,
        role: FamilyRole = .member,
        joinedAt: Date = Date(),
        nickname: String? = nil
    ) {
        self.userId = userId
        self.role = role
        self.joinedAt = joinedAt
        self.nickname = nickname
    }
}

struct InviteCode: Codable, Identifiable {
    var id: String
    var code: String
    var createdBy: String // userId
    var createdAt: Date
    var expiresAt: Date
    var maxUses: Int
    var currentUses: Int
    var isActive: Bool
    
    init(
        id: String = UUID().uuidString,
        code: String = InviteCode.generateCode(),
        createdBy: String,
        createdAt: Date = Date(),
        expiresAt: Date = Date().addingTimeInterval(7 * 24 * 60 * 60), // 7 days
        maxUses: Int = 10,
        currentUses: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.code = code
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.maxUses = maxUses
        self.currentUses = currentUses
        self.isActive = isActive
    }
    
    static func generateCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Excluding ambiguous characters
        return String((0..<8).map { _ in characters.randomElement()! })
    }
    
    var isValid: Bool {
        isActive && currentUses < maxUses && expiresAt > Date()
    }
}

