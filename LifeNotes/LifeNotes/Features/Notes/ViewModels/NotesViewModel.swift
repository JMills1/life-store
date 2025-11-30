//
//  NotesViewModel.swift
//  LifePlanner
//

import Foundation
import Combine

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedWorkspace: Workspace?
    @Published var isLoading = false
    @Published var isPremium = false
    
    private let repository = FirestoreRepository<Note>(collectionName: "notes")
    
    var pinnedNotes: [Note] {
        notes.filter { $0.isPinned }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func loadData(workspaceId: String?) async {
        guard let workspaceId = workspaceId else {
            print("NotesViewModel: No workspace ID provided")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await loadUserPremiumStatus()
        loadNotes(workspaceId: workspaceId)
    }
    
    private func loadUserPremiumStatus() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isPremium = await UserService.shared.getPremiumStatus(userId: userId)
    }
    
    private func loadNotes(workspaceId: String) {
        repository.listen(field: "workspaceId", isEqualTo: workspaceId) { [weak self] notes in
            self?.notes = notes.sorted { $0.updatedAt > $1.updatedAt }
            print("NotesViewModel: Loaded \(notes.count) notes")
        }
    }
    
    func createNote(_ note: Note) async throws {
        _ = try await repository.create(note)
    }
    
    func updateNote(_ note: Note) async throws {
        guard let noteId = note.id else { return }
        try await repository.update(note, documentId: noteId)
    }
    
    func deleteNote(_ note: Note) async throws {
        guard let noteId = note.id else { return }
        try await repository.delete(documentId: noteId)
    }
}

