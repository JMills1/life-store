//
//  NotesViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedWorkspace: Workspace?
    @Published var isLoading = false
    @Published var isPremium = false
    
    private let db = Firestore.firestore()
    private var notesListener: ListenerRegistration?
    
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
        await loadNotes(workspaceId: workspaceId)
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
    
    private func loadNotes(workspaceId: String) async {
        notesListener?.remove()
        
        print("NotesViewModel: Loading notes for workspace: \(workspaceId)")
        
        notesListener = db.collection("notes")
            .whereField("workspaceId", isEqualTo: workspaceId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to notes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.notes = documents.compactMap { doc in
                    try? doc.data(as: Note.self)
                }.sorted { $0.updatedAt > $1.updatedAt }
            }
    }
    
    func createNote(_ note: Note) async throws {
        _ = try db.collection("notes").addDocument(from: note)
    }
    
    func updateNote(_ note: Note) async throws {
        guard let noteId = note.id else { return }
        try db.collection("notes").document(noteId).setData(from: note)
    }
    
    func deleteNote(_ note: Note) async throws {
        guard let noteId = note.id else { return }
        try await db.collection("notes").document(noteId).delete()
    }
    
    deinit {
        notesListener?.remove()
    }
}

