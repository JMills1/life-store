//
//  ModelTests.swift
//  LifeNotesTests
//

import XCTest
@testable import LifeNotes

final class ModelTests: XCTestCase {
    
    //MARK: - User Tests
    
    func testUserInitialization() {
        let user = User(
            email: "test@example.com",
            displayName: "Test User",
            authProvider: .email
        )
        
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertEqual(user.authProvider, .email)
        XCTAssertFalse(user.isPremium, "Default should be free tier")
        XCTAssertTrue(user.familyMemberships.isEmpty, "Should have no families initially")
    }
    
    // MARK: - Workspace Tests
    
    func testWorkspacePermissions() {
        let ownerPerms = MemberPermissions.forRole(.owner)
        XCTAssertTrue(ownerPerms.canCreateEvents)
        XCTAssertTrue(ownerPerms.canEditEvents)
        XCTAssertTrue(ownerPerms.canDeleteEvents)
        XCTAssertTrue(ownerPerms.canInviteMembers)
        
        let viewerPerms = MemberPermissions.forRole(.viewer)
        XCTAssertFalse(viewerPerms.canCreateEvents)
        XCTAssertFalse(viewerPerms.canEditEvents)
        XCTAssertFalse(viewerPerms.canDeleteEvents)
        XCTAssertFalse(viewerPerms.canInviteMembers)
    }
    
    // MARK: - Event Tests
    
    func testEventDuration() {
        let start = Date()
        let end = start.addingTimeInterval(3600) // 1 hour
        
        let event = Event(
            workspaceId: "test",
            title: "Meeting",
            startDate: start,
            endDate: end,
            createdBy: "user1"
        )
        
        XCTAssertEqual(event.endDate.timeIntervalSince(event.startDate), 3600)
    }
    
    func testRecurringEvent() {
        let rule = RecurrenceRule(
            frequency: .weekly,
            interval: 1,
            daysOfWeek: [1, 3, 5] // Mon, Wed, Fri
        )
        
        XCTAssertEqual(rule.frequency, .weekly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertEqual(rule.daysOfWeek?.count, 3)
    }
    
    // MARK: - Todo Tests
    
    func testTodoPriority() {
        let lowPrio = Todo.Priority.low
        let highPrio = Todo.Priority.high
        
        XCTAssertEqual(lowPrio.color, "9E9E9E")
        XCTAssertEqual(highPrio.color, "FFA726")
    }
    
    func testTodoProgress() {
        var todo = Todo(
            workspaceId: "test",
            title: "Test Todo",
            createdBy: "user1"
        )
        
        todo.subtasks = [
            Subtask(title: "Task 1", isCompleted: true),
            Subtask(title: "Task 2", isCompleted: true),
            Subtask(title: "Task 3", isCompleted: false),
            Subtask(title: "Task 4", isCompleted: false)
        ]
        
        XCTAssertEqual(todo.progress, 0.5, "50% complete")
    }
    
    // MARK: - Family Tests
    
    func testInviteCodeGeneration() {
        let code1 = InviteCode.generateCode()
        let code2 = InviteCode.generateCode()
        
        XCTAssertEqual(code1.count, 8, "Code should be 8 characters")
        XCTAssertNotEqual(code1, code2, "Codes should be unique")
        XCTAssertTrue(code1.allSatisfy { $0.isUppercase || $0.isNumber }, "Code should be uppercase alphanumeric")
    }
    
    func testInviteCodeValidity() {
        let validCode = InviteCode(
            createdBy: "user1",
            expiresAt: Date().addingTimeInterval(3600), // 1 hour from now
            maxUses: 5,
            currentUses: 3,
            isActive: true
        )
        
        XCTAssertTrue(validCode.isValid, "Should be valid")
        
        let expiredCode = InviteCode(
            createdBy: "user1",
            expiresAt: Date().addingTimeInterval(-3600), // 1 hour ago
            maxUses: 5,
            currentUses: 3,
            isActive: true
        )
        
        XCTAssertFalse(expiredCode.isValid, "Should be invalid (expired)")
        
        let maxedCode = InviteCode(
            createdBy: "user1",
            expiresAt: Date().addingTimeInterval(3600),
            maxUses: 5,
            currentUses: 5,
            isActive: true
        )
        
        XCTAssertFalse(maxedCode.isValid, "Should be invalid (max uses reached)")
    }
}

