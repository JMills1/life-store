//
//  Todo.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct Todo: Identifiable, Codable {
    @DocumentID var id: String?
    var workspaceId: String
    var title: String
    var description: String?
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date? // Shows on calendar when set
    var assignedTo: String? // userId
    var tags: [String]
    var subtasks: [Subtask]
    var createdBy: String // userId
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var reminders: [Reminder]
    
    enum Priority: String, Codable, CaseIterable {
        case low
        case medium
        case high
        case urgent
        
        var color: String {
            switch self {
            case .low: return "9E9E9E" // Gray
            case .medium: return "64B5F6" // Blue
            case .high: return "FFA726" // Orange
            case .urgent: return "EF5350" // Red
            }
        }
    }
    
    init(
        id: String? = nil,
        workspaceId: String,
        title: String,
        description: String? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        assignedTo: String? = nil,
        tags: [String] = [],
        subtasks: [Subtask] = [],
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        reminders: [Reminder] = []
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.assignedTo = assignedTo
        self.tags = tags
        self.subtasks = subtasks
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.reminders = reminders
    }
    
    var progress: Double {
        guard !subtasks.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
}

struct Subtask: Codable, Identifiable {
    var id: String
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

