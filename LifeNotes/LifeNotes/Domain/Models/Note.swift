//
//  Note.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var workspaceId: String
    var title: String
    var content: String // Rich text as HTML or Markdown
    var linkedDate: Date? // Optional - shows on calendar when set
    var isPinned: Bool
    var tags: [String]
    var collaborators: [String] // Array of userIds who can edit
    var attachments: [String] // URLs to Firebase Storage
    var createdBy: String // userId
    var createdAt: Date
    var updatedAt: Date
    var lastEditedBy: String? // userId
    
    init(
        id: String? = nil,
        workspaceId: String,
        title: String,
        content: String = "",
        linkedDate: Date? = nil,
        isPinned: Bool = false,
        tags: [String] = [],
        collaborators: [String] = [],
        attachments: [String] = [],
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastEditedBy: String? = nil
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.title = title
        self.content = content
        self.linkedDate = linkedDate
        self.isPinned = isPinned
        self.tags = tags
        self.collaborators = collaborators
        self.attachments = attachments
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastEditedBy = lastEditedBy
    }
    
    var preview: String {
        // First 100 characters of content without HTML/Markdown
        let plainText = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return String(plainText.prefix(100))
    }
}

