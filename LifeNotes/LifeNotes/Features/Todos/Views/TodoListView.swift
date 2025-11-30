//
//  TodoListView.swift
//  LifePlanner
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingCreateTodo = false
    @State private var showingWorkspaceSelector = false
    @State private var selectedTodoForEdit: Todo?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !viewModel.todos.isEmpty {
                    List {
                        Section("Active") {
                            ForEach(viewModel.activeTodos) { todo in
                                TodoRowView(todo: todo, viewModel: viewModel)
                            }
                        }
                        
                        if !viewModel.completedTodos.isEmpty {
                            Section("Completed") {
                                ForEach(viewModel.completedTodos) { todo in
                                    TodoRowView(todo: todo, viewModel: viewModel)
                                }
                            }
                        }
                    }
                } else {
                    emptyState
                }
                
                if !viewModel.isPremium {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle("To Do")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    WorkspaceSelector()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTodo = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateTodo) {
                CreateTodoView()
            }
            .sheet(isPresented: $showingWorkspaceSelector) {
                WorkspaceSelectorView()
            }
            .sheet(item: $selectedTodoForEdit) { todo in
                TodoDetailView(todo: todo)
            }
            .task {
                if let workspaceId = workspaceManager.selectedWorkspace?.id {
                    await viewModel.loadData(workspaceId: workspaceId)
                }
            }
            .onChange(of: workspaceManager.selectedWorkspaceIds) { oldValue, newValue in
                Task {
                    if let workspaceId = workspaceManager.selectedWorkspace?.id {
                        await viewModel.loadData(workspaceId: workspaceId)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "checklist",
            title: "No tasks yet",
            subtitle: "Tap + to create your first task"
        )
    }
}

struct TodoRowView: View {
    let todo: Todo
    let viewModel: TodoViewModel
    @State private var isExpanded = false
    @State private var showingEditSheet = false
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    private var workspace: Workspace? {
        workspaceManager.availableWorkspaces.first(where: { $0.id == todo.workspaceId })
    }
    
    private var borderColor: Color {
        workspace.map { Color(hex: $0.color).darker() } ?? AppTheme.Colors.divider
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { showingEditSheet = true }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                        .font(.system(size: 24))
                        .onTapGesture {
                            toggleComplete()
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(todo.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                            .strikethrough(todo.isCompleted)
                        
                        HStack(spacing: 8) {
                            if let dueDate = todo.dueDate {
                                Label(
                                    dueDate.formatted(date: .abbreviated, time: .omitted),
                                    systemImage: "calendar"
                                )
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(dueDate < Date() && !todo.isCompleted ? AppTheme.Colors.error : AppTheme.Colors.textSecondary)
                            }
                            
                            Circle()
                                .fill(Color(hex: todo.priority.color))
                                .frame(width: 8, height: 8)
                            Text(todo.priority.rawValue.capitalized)
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            if !todo.subtasks.isEmpty {
                                HStack(spacing: 4) {
                                    Text("\(todo.subtasks.filter { $0.isCompleted }.count)/\(todo.subtasks.count)")
                                        .font(AppTheme.Fonts.caption1)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                    
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .font(.system(size: 12))
                                        .onTapGesture {
                                            isExpanded.toggle()
                                        }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded && !todo.subtasks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(todo.subtasks.enumerated()), id: \.element.id) { index, subtask in
                        HStack(spacing: 8) {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundColor(subtask.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                                .font(.system(size: 16))
                                .onTapGesture {
                                    toggleSubtask(at: index)
                                }
                            
                            Text(subtask.title)
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(subtask.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                                .strikethrough(subtask.isCompleted)
                            
                            Spacer()
                        }
                        .padding(.leading, 32)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
        .cornerRadius(AppTheme.CornerRadius.small)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 2)
        .sheet(isPresented: $showingEditSheet) {
            EditTodoView(todo: todo)
        }
    }
    
    private func toggleComplete() {
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()
        updatedTodo.completedAt = updatedTodo.isCompleted ? Date() : nil
        
        Task {
            try? await viewModel.updateTodo(updatedTodo)
        }
    }
    
    private func toggleSubtask(at index: Int) {
        var updatedTodo = todo
        updatedTodo.subtasks[index].isCompleted.toggle()
        
        Task {
            try? await viewModel.updateTodo(updatedTodo)
        }
    }
}

#Preview {
    TodoListView()
}

