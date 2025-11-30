//
//  EventComment.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore

struct EventComment: Identifiable, Codable {
    @DocumentID var id: String?
    var eventId: String
    var userId: String
    var userName: String
    var userColor: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isEdited: Bool
    
    init(
        id: String? = nil,
        eventId: String,
        userId: String,
        userName: String,
        userColor: String = "4CAF50",
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isEdited: Bool = false
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.userName = userName
        self.userColor = userColor
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isEdited = isEdited
    }
}

