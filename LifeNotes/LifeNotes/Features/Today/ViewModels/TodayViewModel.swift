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
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let snapshot = try await db.collection("events")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("startDate", isGreaterThanOrEqualTo: startOfDay)
                .whereField("startDate", isLessThan: endOfDay)
                .order(by: "startDate")
                .getDocuments()
            
            let loadedEvents: [Event] = snapshot.documents.compactMap { doc in
                try? doc.data(as: Event.self)
            }
            upcomingEvents = loadedEvents
            print("TodayViewModel: Loaded \(upcomingEvents.count) events for today")
        } catch {
            print("Error loading today's events: \(error.localizedDescription)")
        }
    }
    
    private func loadTodayTasks(workspaceIds: [String]) async {
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let snapshot = try await db.collection("todos")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("isCompleted", isEqualTo: false)
                .getDocuments()
            
            let loadedTasks: [Todo] = snapshot.documents.compactMap { doc in
                try? doc.data(as: Todo.self)
            }.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate <= endOfDay
            }.sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            
            todayTasks = loadedTasks
            print("TodayViewModel: Loaded \(todayTasks.count) tasks for today and overdue")
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
        
        // Load completed tasks this week
        do {
            // Fetch all completed todos and filter in memory to avoid index requirements
            let tasksSnapshot = try await db.collection("todos")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("isCompleted", isEqualTo: true)
                .getDocuments()
            
            let completedTodos = tasksSnapshot.documents.compactMap { doc -> Todo? in
                try? doc.data(as: Todo.self)
            }
            
            // Filter for this week
            let completedThisWeek = completedTodos.filter { todo in
                guard let completedAt = todo.completedAt else { return false }
                return completedAt >= weekStart && completedAt < weekEnd
            }
            
            tasksCompletedThisWeek = completedThisWeek.count
            print("TodayViewModel: Loaded \(tasksCompletedThisWeek) completed tasks this week")
        } catch {
            print("Error loading completed tasks stats: \(error.localizedDescription)")
            tasksCompletedThisWeek = 0
        }
        
        // Load events this week
        do {
            let eventsSnapshot = try await db.collection("events")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("startDate", isGreaterThanOrEqualTo: weekStart)
                .whereField("startDate", isLessThan: weekEnd)
                .getDocuments()
            
            eventsThisWeek = eventsSnapshot.documents.count
            print("TodayViewModel: Loaded \(eventsThisWeek) events this week")
        } catch {
            print("Error loading events stats: \(error.localizedDescription)")
            eventsThisWeek = 0
        }
        
        // Calculate streak
        await calculateStreak(workspaceIds: workspaceIds)
    }
    
    private func calculateStreak(workspaceIds: [String]) async {
        do {
            // Fetch all completed todos
            let snapshot = try await db.collection("todos")
                .whereField("workspaceId", in: workspaceIds)
                .whereField("isCompleted", isEqualTo: true)
                .getDocuments()
            
            let completedTodos = snapshot.documents.compactMap { doc -> Todo? in
                try? doc.data(as: Todo.self)
            }
            
            // Group by day and calculate streak
            var streak = 0
            var currentDate = calendar.startOfDay(for: Date())
            
            while true {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                let hasCompletedTask = completedTodos.contains { todo in
                    guard let completedAt = todo.completedAt else { return false }
                    return completedAt >= currentDate && completedAt < nextDay
                }
                
                if hasCompletedTask {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
                
                // Safety limit
                if streak > 365 {
                    break
                }
            }
            
            currentStreak = streak
            print("TodayViewModel: Current streak is \(streak) days")
        } catch {
            print("Error calculating streak: \(error.localizedDescription)")
            currentStreak = 0
        }
    }
}

struct FamilyUpdate: Identifiable {
    let id: String
    let memberName: String
    let action: String
    let timestamp: Date
}

