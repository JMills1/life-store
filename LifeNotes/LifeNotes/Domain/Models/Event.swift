//
//  Event.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var workspaceId: String
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var color: String? // Event-specific color override
    var useCreatorColor: Bool // If true, use creator's personal color
    var recurrence: RecurrenceRule?
    var reminders: [Reminder]
    var createdBy: String // userId
    var createdAt: Date
    var updatedAt: Date
    var attachments: [String] // URLs to Firebase Storage
    
    init(
        id: String? = nil,
        workspaceId: String,
        title: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        location: String? = nil,
        color: String? = nil,
        useCreatorColor: Bool = true,
        recurrence: RecurrenceRule? = nil,
        reminders: [Reminder] = [],
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        attachments: [String] = []
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.color = color
        self.useCreatorColor = useCreatorColor
        self.recurrence = recurrence
        self.reminders = reminders
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attachments = attachments
    }
}

struct RecurrenceRule: Codable {
    var frequency: Frequency
    var interval: Int // e.g., every 2 weeks
    var endDate: Date?
    var daysOfWeek: [Int]? // 0 = Sunday, 1 = Monday, etc.
    
    enum Frequency: String, Codable {
        case daily
        case weekly
        case monthly
        case yearly
    }
    
    init(
        frequency: Frequency,
        interval: Int = 1,
        endDate: Date? = nil,
        daysOfWeek: [Int]? = nil
    ) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
        self.daysOfWeek = daysOfWeek
    }
}

struct Reminder: Codable, Identifiable {
    var id: String
    var minutesBefore: Int
    var isEnabled: Bool
    
    init(
        id: String = UUID().uuidString,
        minutesBefore: Int = 15,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.minutesBefore = minutesBefore
        self.isEnabled = isEnabled
    }
    
    static let presets: [Reminder] = [
        Reminder(minutesBefore: 0), // At time of event
        Reminder(minutesBefore: 5),
        Reminder(minutesBefore: 15),
        Reminder(minutesBefore: 30),
        Reminder(minutesBefore: 60),
        Reminder(minutesBefore: 1440) // 1 day
    ]
}

