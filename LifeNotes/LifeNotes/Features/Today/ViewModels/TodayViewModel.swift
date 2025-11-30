//
//  TodayViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class TodayViewModel: ObservableObject {
    @Published var upcomingEvents: [Event] = []
    @Published var todayTasks: [Todo] = []
    @Published var pinnedNotes: [Note] = []
    @Published var familyUpdates: [FamilyUpdate] = []
    @Published var isLoading: Bool = false
    
    @Published var currentStreak: Int = 0
    @Published var tasksCompletedThisWeek: Int = 0
    @Published var eventsThisWeek: Int = 0
    
    private let db = Firestore.firestore()
    private let calendar = Calendar.current
    
    var userName: String {
        AuthService.shared.currentUser?.displayName.split(separator: " ").first.map(String.init) ?? "User"
    }
    
    var totalTasksToday: Int {
        todayTasks.count
    }
    
    var completedTasksToday: Int {
        todayTasks.filter { $0.isCompleted }.count
    }
    
    var taskProgress: Double {
        guard totalTasksToday > 0 else { return 0 }
        return Double(completedTasksToday) / Double(totalTasksToday)
    }
    
    func loadData(workspaceIds: [String]) async {
        guard !workspaceIds.isEmpty else {
            print("TodayViewModel: No workspace IDs")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await loadUpcomingEvents(workspaceIds: workspaceIds)
        await loadTodayTasks(workspaceIds: workspaceIds)
        await loadPinnedNotes(workspaceIds: workspaceIds)
        await loadStats(workspaceIds: workspaceIds)
        await loadFamilyUpdates()
    }
    
    private func loadUpcomingEvents(workspaceIds: [String]) async {
        let now = Date()
        let twoHoursLater = now.addingTimeInterval(2 * 3600)
        
        do {
            let snapshot = try await db.collection("events")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("startDate", isGreaterThanOrEqualTo: now)
                .whereField("startDate", isLessThanOrEqualTo: twoHoursLater)
                .order(by: "startDate")
                .limit(to: 3)
                .getDocuments()
            
            let loadedEvents: [Event] = snapshot.documents.compactMap { doc in
                try? doc.data(as: Event.self)
            }
            upcomingEvents = loadedEvents
            print("TodayViewModel: Loaded \(upcomingEvents.count) upcoming events")
        } catch {
            print("Error loading upcoming events: \(error.localizedDescription)")
        }
    }
    
    private func loadTodayTasks(workspaceIds: [String]) async {
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let snapshot = try await db.collection("todos")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("dueDate", isGreaterThanOrEqualTo: startOfDay)
                .whereField("dueDate", isLessThan: endOfDay)
                .order(by: "dueDate")
                .getDocuments()
            
            let loadedTasks: [Todo] = snapshot.documents.compactMap { doc in
                try? doc.data(as: Todo.self)
            }
            todayTasks = loadedTasks
            print("TodayViewModel: Loaded \(todayTasks.count) tasks for today")
        } catch {
            print("Error loading today tasks: \(error.localizedDescription)")
        }
    }
    
    private func loadPinnedNotes(workspaceIds: [String]) async {
        do {
            let snapshot = try await db.collection("notes")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("isPinned", isEqualTo: true)
                .order(by: "updatedAt", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let loadedNotes: [Note] = snapshot.documents.compactMap { doc in
                try? doc.data(as: Note.self)
            }
            pinnedNotes = loadedNotes
            print("TodayViewModel: Loaded \(pinnedNotes.count) pinned notes")
        } catch {
            print("Error loading pinned notes: \(error.localizedDescription)")
        }
    }
    
    private func loadFamilyUpdates() async {
        familyUpdates = []
    }
    
    private func loadStats(workspaceIds: [String]) async {
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        do {
            let tasksSnapshot = try await db.collection("todos")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("completedAt", isGreaterThanOrEqualTo: weekStart)
                .whereField("completedAt", isLessThan: weekEnd)
                .getDocuments()
            
            let completedCount: Int = tasksSnapshot.documents.count
            tasksCompletedThisWeek = completedCount
            
            let eventsSnapshot = try await db.collection("events")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("startDate", isGreaterThanOrEqualTo: weekStart)
                .whereField("startDate", isLessThan: weekEnd)
                .getDocuments()
            
            let eventCount: Int = eventsSnapshot.documents.count
            eventsThisWeek = eventCount
            
            print("TodayViewModel: Stats - \(tasksCompletedThisWeek) tasks, \(eventsThisWeek) events this week")
        } catch {
            print("Error loading stats: \(error.localizedDescription)")
        }
        
        let streakCount: Int = 0
        currentStreak = streakCount
    }
}

struct FamilyUpdate: Identifiable {
    let id: String
    let memberName: String
    let action: String
    let timestamp: Date
}

