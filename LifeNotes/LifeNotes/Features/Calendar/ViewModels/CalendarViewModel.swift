//
//  CalendarViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
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
    
    private let db = Firestore.firestore()
    private var eventsListener: ListenerRegistration?
    private var todosListener: ListenerRegistration?
    private var notesListener: ListenerRegistration?
    
    func loadData(workspaceIds: [String]) async {
        guard !workspaceIds.isEmpty else {
            print("CalendarViewModel: No workspace IDs provided")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await loadUserPremiumStatus()
        await loadEvents(workspaceIds: workspaceIds)
        await loadTodos(workspaceIds: workspaceIds)
        await loadNotes(workspaceIds: workspaceIds)
    }
    
    private func loadUserPremiumStatus() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            if let user = try? doc.data(as: User.self) {
                isPremium = user.isPremium
            }
        } catch {
            print("Error loading premium status: \(error.localizedDescription)")
        }
    }
    
    private func loadEvents(workspaceIds: [String]) async {
        eventsListener?.remove()
        
        print("CalendarViewModel: Loading events for \(workspaceIds.count) workspaces")
        
        eventsListener = db.collection("events")
            .whereField("workspaceId", in: workspaceIds)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to events: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.events = documents.compactMap { doc in
                    try? doc.data(as: Event.self)
                }
            }
    }
    
    func createEvent(_ event: Event) async throws {
        _ = try db.collection("events").addDocument(from: event)
    }
    
    func updateEvent(_ event: Event) async throws {
        guard let eventId = event.id else { return }
        try db.collection("events").document(eventId).setData(from: event)
    }
    
    func deleteEvent(_ event: Event) async throws {
        guard let eventId = event.id else { return }
        try await db.collection("events").document(eventId).delete()
    }
    
    func eventsForDate(_ date: Date) -> [Event] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private func loadTodos(workspaceIds: [String]) async {
        todosListener?.remove()
        
        print("CalendarViewModel: Loading todos for \(workspaceIds.count) workspaces")
        
        todosListener = db.collection("todos")
            .whereField("workspaceId", in: workspaceIds)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to todos: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.todos = documents.compactMap { doc in
                    try? doc.data(as: Todo.self)
                }
            }
    }
    
    func todosForDate(_ date: Date) -> [Todo] {
        let calendar = Calendar.current
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }
    
    private func loadNotes(workspaceIds: [String]) async {
        notesListener?.remove()
        
        print("CalendarViewModel: Loading notes for \(workspaceIds.count) workspaces")
        
        notesListener = db.collection("notes")
            .whereField("workspaceId", in: workspaceIds)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to notes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.notes = documents.compactMap { doc in
                    try? doc.data(as: Note.self)
                }.filter { $0.linkedDate != nil }
            }
    }
    
    func notesForDate(_ date: Date) -> [Note] {
        let calendar = Calendar.current
        return notes.filter { note in
            guard let linkedDate = note.linkedDate else { return false }
            return calendar.isDate(linkedDate, inSameDayAs: date)
        }
    }
    
    deinit {
        eventsListener?.remove()
        todosListener?.remove()
        notesListener?.remove()
    }
}

