//
//  TodoViewModel.swift
//  LifePlanner
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var selectedWorkspace: Workspace?
    @Published var isLoading = false
    @Published var isPremium = false
    
    private let db = Firestore.firestore()
    private var todosListener: ListenerRegistration?
    
    var activeTodos: [Todo] {
        todos.filter { !$0.isCompleted }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }
    
    var completedTodos: [Todo] {
        todos.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }
    
    func loadData(workspaceId: String?) async {
        guard let workspaceId = workspaceId else {
            print("TodoViewModel: No workspace ID provided")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        await loadUserPremiumStatus()
        await loadTodos(workspaceId: workspaceId)
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
    
    private func loadTodos(workspaceId: String) async {
        todosListener?.remove()
        
        print("TodoViewModel: Loading todos for workspace: \(workspaceId)")
        
        todosListener = db.collection("todos")
            .whereField("workspaceId", isEqualTo: workspaceId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to todos: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("TodoViewModel: No documents in snapshot")
                    return
                }
                
                self.todos = documents.compactMap { doc in
                    try? doc.data(as: Todo.self)
                }
                
                print("TodoViewModel: Loaded \(self.todos.count) todos")
            }
    }
    
    func createTodo(_ todo: Todo) async throws {
        let docRef = try db.collection("todos").addDocument(from: todo)
        print("TodoViewModel: Created todo with ID: \(docRef.documentID)")
    }
    
    func updateTodo(_ todo: Todo) async throws {
        guard let todoId = todo.id else { return }
        try db.collection("todos").document(todoId).setData(from: todo)
    }
    
    func deleteTodo(_ todo: Todo) async throws {
        guard let todoId = todo.id else { return }
        try await db.collection("todos").document(todoId).delete()
    }
    
    deinit {
        todosListener?.remove()
    }
}

