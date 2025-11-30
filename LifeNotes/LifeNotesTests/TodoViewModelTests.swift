//
//  TodoViewModelTests.swift
//  LifeNotesTests
//

import XCTest
@testable import LifeNotes

@MainActor
final class TodoViewModelTests: XCTestCase {
    
    var sut: TodoViewModel!
    
    override func setUp() {
        super.setUp()
        sut = TodoViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testActiveTodosFiltering() {
        let todo1 = Todo(
            workspaceId: "test",
            title: "Active Todo",
            isCompleted: false,
            createdBy: "user1"
        )
        
        let todo2 = Todo(
            workspaceId: "test",
            title: "Completed Todo",
            isCompleted: true,
            createdBy: "user1"
        )
        
        sut.todos = [todo1, todo2]
        
        XCTAssertEqual(sut.activeTodos.count, 1, "Should have 1 active todo")
        XCTAssertEqual(sut.activeTodos.first?.title, "Active Todo")
    }
    
    func testCompletedTodosFiltering() {
        let todo1 = Todo(
            workspaceId: "test",
            title: "Active Todo",
            isCompleted: false,
            createdBy: "user1"
        )
        
        let todo2 = Todo(
            workspaceId: "test",
            title: "Completed Todo",
            isCompleted: true,
            completedAt: Date(),
            createdBy: "user1"
        )
        
        sut.todos = [todo1, todo2]
        
        XCTAssertEqual(sut.completedTodos.count, 1, "Should have 1 completed todo")
        XCTAssertEqual(sut.completedTodos.first?.title, "Completed Todo")
    }
    
    func testTodosSortedByDueDate() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        let todo1 = Todo(
            workspaceId: "test",
            title: "Next Week",
            dueDate: nextWeek,
            createdBy: "user1"
        )
        
        let todo2 = Todo(
            workspaceId: "test",
            title: "Tomorrow",
            dueDate: tomorrow,
            createdBy: "user1"
        )
        
        let todo3 = Todo(
            workspaceId: "test",
            title: "Today",
            dueDate: today,
            createdBy: "user1"
        )
        
        sut.todos = [todo1, todo2, todo3]
        
        let sorted = sut.activeTodos
        XCTAssertEqual(sorted[0].title, "Today", "First should be today")
        XCTAssertEqual(sorted[1].title, "Tomorrow", "Second should be tomorrow")
        XCTAssertEqual(sorted[2].title, "Next Week", "Third should be next week")
    }
    
    func testTodoProgress() {
        var todo = Todo(
            workspaceId: "test",
            title: "Test Todo",
            createdBy: "user1"
        )
        
        XCTAssertEqual(todo.progress, 0.0, "Progress should be 0 with no subtasks")
        
        todo.subtasks = [
            Subtask(title: "Subtask 1", isCompleted: true),
            Subtask(title: "Subtask 2", isCompleted: false),
            Subtask(title: "Subtask 3", isCompleted: true),
            Subtask(title: "Subtask 4", isCompleted: false)
        ]
        
        XCTAssertEqual(todo.progress, 0.5, "Progress should be 50% (2 of 4 complete)")
        
        todo.subtasks.forEach { subtask in
            var mutableSubtask = subtask
            mutableSubtask.isCompleted = true
        }
        
        XCTAssertEqual(todo.progress, 0.5, "Still 50% until we update the array")
    }
}

