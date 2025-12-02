//
//  EditTodoView.swift
//  LifePlanner
//

import SwiftUI

struct EditTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TodoViewModel()
    
    let todo: Todo
    
    @State private var title: String
    @State private var description: String
    @State private var priority: Todo.Priority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var subtasks: [Subtask]
    @State private var newSubtaskTitle = ""
    @State private var showingDeleteAlert = false
    
    init(todo: Todo) {
        self.todo = todo
        _title = State(initialValue: todo.title)
        _description = State(initialValue: todo.description ?? "")
        _priority = State(initialValue: todo.priority)
        _hasDueDate = State(initialValue: todo.dueDate != nil)
        _dueDate = State(initialValue: todo.dueDate ?? Date())
        _subtasks = State(initialValue: todo.subtasks)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Todo.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(hex: priority.color))
                                    .frame(width: 8, height: 8)
                                Text(priority.rawValue.capitalized)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Checklist Items") {
                    HStack {
                        TextField("Add item...", text: $newSubtaskTitle)
                            .onSubmit {
                                addSubtask()
                            }
                        
                        if !newSubtaskTitle.isEmpty {
                            Button(action: addSubtask) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                    
                    ForEach(subtasks) { subtask in
                        HStack {
                            Button(action: { toggleSubtask(subtask) }) {
                                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(subtask.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                            
                            Text(subtask.title)
                                .strikethrough(subtask.isCompleted)
                                .foregroundColor(subtask.isCompleted ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        subtasks.remove(atOffsets: indexSet)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Delete Task", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTask()
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
        }
    }
    
    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        let subtask = Subtask(title: newSubtaskTitle)
        subtasks.append(subtask)
        newSubtaskTitle = ""
    }
    
    private func toggleSubtask(_ subtask: Subtask) {
        if let index = subtasks.firstIndex(where: { $0.id == subtask.id }) {
            subtasks[index].isCompleted.toggle()
        }
    }
    
    private func saveChanges() {
        var updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.description = description.isEmpty ? nil : description
        updatedTodo.priority = priority
        updatedTodo.dueDate = hasDueDate ? dueDate : nil
        updatedTodo.subtasks = subtasks
        updatedTodo.updatedAt = Date()
        
        print("📝 EditTodoView: Saving todo \(updatedTodo.id ?? "no-id")")
        print("   - Title: '\(updatedTodo.title)'")
        print("   - Has due date: \(hasDueDate)")
        print("   - Due date: \(updatedTodo.dueDate?.formatted() ?? "none")")
        print("   - Priority: \(updatedTodo.priority.rawValue)")
        
        Task {
            do {
                try await viewModel.updateTodo(updatedTodo)
                print("✅ EditTodoView: Task updated successfully")
                dismiss()
            } catch {
                print("❌ EditTodoView: Error updating task: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteTask() {
        Task {
            do {
                try await viewModel.deleteTodo(todo)
                print("Task deleted successfully")
                dismiss()
            } catch {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EditTodoView(todo: Todo(
        workspaceId: "test",
        title: "Shopping",
        createdBy: "user1"
    ))
}

