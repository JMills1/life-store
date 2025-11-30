//
//  User.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var photoURL: String?
    var authProvider: AuthProvider
    var createdAt: Date
    var isPremium: Bool
    var preferences: UserPreferences
    var familyMemberships: [String] // Array of familyIds
    
    enum AuthProvider: String, Codable {
        case apple
        case email
    }
    
    init(
        id: String? = nil,
        email: String,
        displayName: String,
        photoURL: String? = nil,
        authProvider: AuthProvider = .email,
        createdAt: Date = Date(),
        isPremium: Bool = false,
        preferences: UserPreferences = UserPreferences(),
        familyMemberships: [String] = []
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.authProvider = authProvider
        self.createdAt = createdAt
        self.isPremium = isPremium
        self.preferences = preferences
        self.familyMemberships = familyMemberships
    }
}

struct UserPreferences: Codable, Sendable {
    var notificationsEnabled: Bool
    var defaultWorkspaceId: String?
    var personalColor: String // User's personal color (for their events in shared workspaces)
    var themeColor: String // App theme color
    var defaultReminderMinutes: Int
    var weekStartsOn: Int // 0 = Sunday, 1 = Monday
    
    init(
        notificationsEnabled: Bool = true,
        defaultWorkspaceId: String? = nil,
        personalColor: String = "EF5350", // Red default
        themeColor: String = "4CAF50", // Green default
        defaultReminderMinutes: Int = 15,
        weekStartsOn: Int = 0
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.defaultWorkspaceId = defaultWorkspaceId
        self.personalColor = personalColor
        self.themeColor = themeColor
        self.defaultReminderMinutes = defaultReminderMinutes
        self.weekStartsOn = weekStartsOn
    }
}

