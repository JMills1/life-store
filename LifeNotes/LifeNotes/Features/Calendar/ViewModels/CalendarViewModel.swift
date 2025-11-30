//
//  CalendarViewModel.swift
//  LifePlanner
//

import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var todos: [Todo] = []
    @Published var notes: [Note] = []
    @Published var selectedWorkspace: Workspace?
    @Published var selectedWorkspaces: [Workspace] = []
    @Published var isLoading = false
    @Published var isPremium = false
    
    private let eventsRepository = FirestoreRepository<Event>(collectionName: "events")
    private let todosRepository = FirestoreRepository<Todo>(collectionName: "todos")
    private let notesRepository = FirestoreRepository<Note>(collectionName: "notes")
    
    func loadData(workspaceIds: [String]) async {
        guard !workspaceIds.isEmpty else {
            print("CalendarViewModel: No workspace IDs provided")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await loadUserPremiumStatus()
        loadEvents(workspaceIds: workspaceIds)
        loadTodos(workspaceIds: workspaceIds)
        loadNotes(workspaceIds: workspaceIds)
    }
    
    private func loadUserPremiumStatus() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isPremium = await UserService.shared.getPremiumStatus(userId: userId)
    }
    
    private func loadEvents(workspaceIds: [String]) {
        eventsRepository.listen(field: "workspaceId", in: workspaceIds) { [weak self] events in
            self?.events = events
            print("CalendarViewModel: Loaded \(events.count) events")
        }
    }
    
    func createEvent(_ event: Event) async throws {
        _ = try await eventsRepository.create(event)
    }
    
    func updateEvent(_ event: Event) async throws {
        guard let eventId = event.id else { return }
        try await eventsRepository.update(event, documentId: eventId)
    }
    
    func deleteEvent(_ event: Event) async throws {
        guard let eventId = event.id else { return }
        try await eventsRepository.delete(documentId: eventId)
    }
    
    func eventsForDate(_ date: Date) -> [Event] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private func loadTodos(workspaceIds: [String]) {
        todosRepository.listen(field: "workspaceId", in: workspaceIds) { [weak self] todos in
            self?.todos = todos
            print("CalendarViewModel: Loaded \(todos.count) todos")
        }
    }
    
    func todosForDate(_ date: Date) -> [Todo] {
        let calendar = Calendar.current
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }
    
    private func loadNotes(workspaceIds: [String]) {
        notesRepository.listen(field: "workspaceId", in: workspaceIds) { [weak self] notes in
            self?.notes = notes.filter { $0.linkedDate != nil }
            print("CalendarViewModel: Loaded \(notes.count) notes")
        }
    }
    
    func notesForDate(_ date: Date) -> [Note] {
        let calendar = Calendar.current
        return notes.filter { note in
            guard let linkedDate = note.linkedDate else { return false }
            return calendar.isDate(linkedDate, inSameDayAs: date)
        }
    }
}

