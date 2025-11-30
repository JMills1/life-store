//
//  NotesViewModelTests.swift
//  LifeNotesTests
//

import XCTest
@testable import LifeNotes

@MainActor
final class NotesViewModelTests: XCTestCase {
    
    var sut: NotesViewModel!
    
    override func setUp() {
        super.setUp()
        sut = NotesViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPinnedNotesFiltering() {
        let note1 = Note(
            workspaceId: "test",
            title: "Pinned Note",
            isPinned: true,
            createdBy: "user1"
        )
        
        let note2 = Note(
            workspaceId: "test",
            title: "Regular Note",
            isPinned: false,
            createdBy: "user1"
        )
        
        sut.notes = [note1, note2]
        
        XCTAssertEqual(sut.pinnedNotes.count, 1, "Should have 1 pinned note")
        XCTAssertEqual(sut.pinnedNotes.first?.title, "Pinned Note")
    }
    
    func testNotePreview() {
        let shortContent = "Short note content"
        let note1 = Note(
            workspaceId: "test",
            title: "Short Note",
            content: shortContent,
            createdBy: "user1"
        )
        
        XCTAssertEqual(note1.preview, shortContent, "Preview should be full content for short notes")
        
        let longContent = String(repeating: "A", count: 200)
        let note2 = Note(
            workspaceId: "test",
            title: "Long Note",
            content: longContent,
            createdBy: "user1"
        )
        
        XCTAssertEqual(note2.preview.count, 100, "Preview should be truncated to 100 chars")
    }
    
    func testNotesSortedByUpdatedDate() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        let note1 = Note(
            workspaceId: "test",
            title: "Last Week",
            createdBy: "user1",
            createdAt: lastWeek,
            updatedAt: lastWeek
        )
        
        let note2 = Note(
            workspaceId: "test",
            title: "Yesterday",
            createdBy: "user1",
            createdAt: yesterday,
            updatedAt: yesterday
        )
        
        let note3 = Note(
            workspaceId: "test",
            title: "Today",
            createdBy: "user1",
            createdAt: now,
            updatedAt: now
        )
        
        sut.notes = [note1, note2, note3]
        
        XCTAssertEqual(sut.notes[0].title, "Today", "First should be most recent")
        XCTAssertEqual(sut.notes[1].title, "Yesterday", "Second should be yesterday")
        XCTAssertEqual(sut.notes[2].title, "Last Week", "Third should be oldest")
    }
}

