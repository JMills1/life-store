//
//  TodoViewModel.swift
//  LifePlanner
//

import Foundation
import Combine

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var selectedWorkspace: Workspace?
    @Published var isLoading = false
    @Published var isPremium = false
    
    private let repository = FirestoreRepository<Todo>(collectionName: "todos")
    
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
        loadTodos(workspaceId: workspaceId)
    }
    
    private func loadUserPremiumStatus() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isPremium = await UserService.shared.getPremiumStatus(userId: userId)
    }
    
    private func loadTodos(workspaceId: String) {
        repository.listen(field: "workspaceId", isEqualTo: workspaceId) { [weak self] todos in
            self?.todos = todos
            print("TodoViewModel: Loaded \(todos.count) todos")
        }
    }
    
    func createTodo(_ todo: Todo) async throws {
        let docId = try await repository.create(todo)
        print("TodoViewModel: Created todo with ID: \(docId)")
    }
    
    func updateTodo(_ todo: Todo) async throws {
        guard let todoId = todo.id else { return }
        try await repository.update(todo, documentId: todoId)
    }
    
    func deleteTodo(_ todo: Todo) async throws {
        guard let todoId = todo.id else { return }
        try await repository.delete(documentId: todoId)
    }
}

