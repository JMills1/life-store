//
//  MockData.swift
//  LifeNotesTests
//

import Foundation
@testable import LifeNotes

struct MockData {
    
    // MARK: - Users
    
    static func createUser(
        email: String = "test@example.com",
        displayName: String = "Test User",
        isPremium: Bool = false
    ) -> User {
        User(
            id: UUID().uuidString,
            email: email,
            displayName: displayName,
            authProvider: .email,
            isPremium: isPremium
        )
    }
    
    // MARK: - Workspaces
    
    static func createWorkspace(
        name: String = "Test Workspace",
        type: Workspace.WorkspaceType = .personal,
        ownerId: String = "user1"
    ) -> Workspace {
        Workspace(
            id: UUID().uuidString,
            name: name,
            type: type,
            ownerId: ownerId,
            members: [
                WorkspaceMember(userId: ownerId, role: .owner)
            ]
        )
    }
    
    // MARK: - Events
    
    static func createEvent(
        title: String = "Test Event",
        workspaceId: String = "workspace1",
        startDate: Date = Date(),
        endDate: Date? = nil,
        isAllDay: Bool = false
    ) -> Event {
        Event(
            id: UUID().uuidString,
            workspaceId: workspaceId,
            title: title,
            startDate: startDate,
            endDate: endDate ?? startDate.addingTimeInterval(3600),
            isAllDay: isAllDay,
            createdBy: "user1"
        )
    }
    
    static func createEvents(count: Int, workspaceId: String = "workspace1") -> [Event] {
        (0..<count).map { index in
            createEvent(
                title: "Event \(index + 1)",
                workspaceId: workspaceId,
                startDate: Date().addingTimeInterval(Double(index) * 86400) // Daily events
            )
        }
    }
    
    // MARK: - Todos
    
    static func createTodo(
        title: String = "Test Todo",
        workspaceId: String = "workspace1",
        isCompleted: Bool = false,
        priority: Todo.Priority = .medium,
        dueDate: Date? = nil
    ) -> Todo {
        Todo(
            id: UUID().uuidString,
            workspaceId: workspaceId,
            title: title,
            isCompleted: isCompleted,
            priority: priority,
            dueDate: dueDate,
            createdBy: "user1"
        )
    }
    
    static func createTodos(count: Int, workspaceId: String = "workspace1") -> [Todo] {
        (0..<count).map { index in
            createTodo(
                title: "Todo \(index + 1)",
                workspaceId: workspaceId,
                priority: [.low, .medium, .high, .urgent][index % 4]
            )
        }
    }
    
    // MARK: - Notes
    
    static func createNote(
        title: String = "Test Note",
        content: String = "Test note content",
        workspaceId: String = "workspace1",
        isPinned: Bool = false
    ) -> Note {
        Note(
            id: UUID().uuidString,
            workspaceId: workspaceId,
            title: title,
            content: content,
            isPinned: isPinned,
            createdBy: "user1"
        )
    }
    
    static func createNotes(count: Int, workspaceId: String = "workspace1") -> [Note] {
        (0..<count).map { index in
            createNote(
                title: "Note \(index + 1)",
                content: "Content for note \(index + 1)",
                workspaceId: workspaceId,
                isPinned: index == 0
            )
        }
    }
    
    // MARK: - Families
    
    static func createFamily(
        name: String = "Test Family",
        createdBy: String = "user1",
        memberCount: Int = 1
    ) -> Family {
        var members = [FamilyMember(userId: createdBy, role: .admin)]
        
        for i in 1..<memberCount {
            members.append(FamilyMember(userId: "user\(i + 1)", role: .member))
        }
        
        return Family(
            id: UUID().uuidString,
            name: name,
            createdBy: createdBy,
            members: members
        )
    }
    
    // MARK: - Complete Test Datasets
    
    static func createCompleteDataset() -> (
        users: [User],
        workspaces: [Workspace],
        events: [Event],
        todos: [Todo],
        notes: [Note],
        families: [Family]
    ) {
        let users = [
            createUser(email: "user1@example.com", displayName: "User One"),
            createUser(email: "user2@example.com", displayName: "User Two", isPremium: true),
            createUser(email: "user3@example.com", displayName: "User Three")
        ]
        
        let workspaces = [
            createWorkspace(name: "Personal", type: .personal, ownerId: users[0].id!),
            createWorkspace(name: "Family", type: .shared, ownerId: users[0].id!),
            createWorkspace(name: "Work", type: .personal, ownerId: users[1].id!)
        ]
        
        let events = createEvents(count: 10, workspaceId: workspaces[0].id!)
        let todos = createTodos(count: 15, workspaceId: workspaces[0].id!)
        let notes = createNotes(count: 5, workspaceId: workspaces[0].id!)
        let families = [createFamily(memberCount: 3)]
        
        return (users, workspaces, events, todos, notes, families)
    }
}

