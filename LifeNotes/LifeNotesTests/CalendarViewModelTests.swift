//
//  CalendarViewModelTests.swift
//  LifeNotesTests
//

import XCTest
@testable import LifeNotes

@MainActor
final class CalendarViewModelTests: XCTestCase {
    
    var sut: CalendarViewModel!
    
    override func setUp() {
        super.setUp()
        sut = CalendarViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.events.isEmpty, "Events should be empty initially")
        XCTAssertNil(sut.selectedWorkspace, "No workspace selected initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
    }
    
    func testLoadData() async {
        await sut.loadData()
        
        XCTAssertFalse(sut.isLoading, "Should finish loading")
    }
    
    func testEventsForDate() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let event1 = Event(
            workspaceId: "test",
            title: "Today Event",
            startDate: today,
            endDate: today,
            createdBy: "user1"
        )
        
        let event2 = Event(
            workspaceId: "test",
            title: "Tomorrow Event",
            startDate: tomorrow,
            endDate: tomorrow,
            createdBy: "user1"
        )
        
        sut.events = [event1, event2]
        
        let todayEvents = sut.eventsForDate(today)
        XCTAssertEqual(todayEvents.count, 1, "Should have 1 event today")
        XCTAssertEqual(todayEvents.first?.title, "Today Event")
        
        let tomorrowEvents = sut.eventsForDate(tomorrow)
        XCTAssertEqual(tomorrowEvents.count, 1, "Should have 1 event tomorrow")
        XCTAssertEqual(tomorrowEvents.first?.title, "Tomorrow Event")
    }
}

