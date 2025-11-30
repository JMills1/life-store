//
//  TodoDetailView.swift
//  LifePlanner
//

import SwiftUI

struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    let todo: Todo
    @State private var localTodo: Todo
    @State private var showingEditSheet = false
    @State private var newSubtaskTitle = ""
    
    init(todo: Todo) {
        self.todo = todo
        _localTodo = State(initialValue: todo)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    taskHeader
                    
                    taskDetails
                    
                    if !localTodo.subtasks.isEmpty || !newSubtaskTitle.isEmpty {
                        subtasksSection
                    }
                    
                    addSubtaskSection
                }
                .padding()
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditTodoView(todo: localTodo)
            }
        }
    }
    
    private var taskHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { toggleComplete() }) {
                    Image(systemName: localTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(localTodo.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)
                
                Text(localTodo.title)
                    .font(AppTheme.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(localTodo.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                    .strikethrough(localTodo.isCompleted)
                
                Spacer()
            }
            
            if let description = localTodo.description, !description.isEmpty {
                Text(description)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if let dueDate = localTodo.dueDate {
                DetailRowView(
                    icon: "calendar",
                    label: "Due Date",
                    value: dueDate.formatted(date: .long, time: .omitted),
                    valueColor: dueDate < Date() && !localTodo.isCompleted ? AppTheme.Colors.error : AppTheme.Colors.textPrimary
                )
            }
            
            DetailRowView(
                icon: "flag.fill",
                label: "Priority",
                value: localTodo.priority.rawValue.capitalized,
                valueColor: Color(hex: localTodo.priority.color)
            )
            
            if let workspace = workspaceManager.availableWorkspaces.first(where: { $0.id == localTodo.workspaceId }) {
                DetailRowView(
                    icon: "folder.fill",
                    label: "Workspace",
                    value: workspace.name,
                    valueColor: Color(hex: workspace.color)
                )
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private var subtasksSection: some View {
        let activeSubtasks = localTodo.subtasks.filter { !$0.isCompleted }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        let completedSubtasks = localTodo.subtasks.filter { $0.isCompleted }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Checklist")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if !localTodo.subtasks.isEmpty {
                    Text("\(completedSubtasks.count)/\(localTodo.subtasks.count)")
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary)
                        .clipShape(Capsule())
                }
            }
            
            ForEach(activeSubtasks) { subtask in
                subtaskRow(for: subtask)
            }
            
            if !completedSubtasks.isEmpty && !activeSubtasks.isEmpty {
                Divider()
                    .padding(.vertical, 4)
            }
            
            ForEach(completedSubtasks) { subtask in
                subtaskRow(for: subtask)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private func subtaskRow(for subtask: Subtask) -> some View {
        Button(action: { toggleSubtaskById(subtask.id) }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(subtask.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                    .font(.system(size: 20))
                
                Text(subtask.title)
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(subtask.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                    .strikethrough(subtask.isCompleted)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.background)
            .cornerRadius(AppTheme.CornerRadius.small)
        }
        .buttonStyle(.plain)
    }
    
    private var addSubtaskSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppTheme.Colors.primary)
                    .font(.system(size: 20))
                
                TextField("Add checklist item", text: $newSubtaskTitle)
                    .font(AppTheme.Fonts.subheadline)
                    .onSubmit {
                        addSubtask()
                    }
            }
            .padding()
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
    
    private func toggleComplete() {
        localTodo.isCompleted.toggle()
        localTodo.completedAt = localTodo.isCompleted ? Date() : nil
        saveTodo()
    }
    
    private func toggleSubtask(at index: Int) {
        localTodo.subtasks[index].isCompleted.toggle()
        saveTodo()
    }
    
    private func toggleSubtaskById(_ id: String) {
        if let index = localTodo.subtasks.firstIndex(where: { $0.id == id }) {
            localTodo.subtasks[index].isCompleted.toggle()
            saveTodo()
        }
    }
    
    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        let newSubtask = Subtask(
            title: newSubtaskTitle,
            isCompleted: false
        )
        
        localTodo.subtasks.append(newSubtask)
        newSubtaskTitle = ""
        saveTodo()
    }
    
    private func saveTodo() {
        Task {
            do {
                guard localTodo.id != nil else { return }
                try await TodoViewModel().updateTodo(localTodo)
                print("Todo updated successfully")
            } catch {
                print("Error updating todo: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    TodoDetailView(todo: Todo(
        workspaceId: "test",
        title: "Sample Task",
        isCompleted: false,
        priority: .medium,
        createdBy: "user1"
    ))
    .environmentObject(WorkspaceManager.shared)
}

