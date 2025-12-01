//
//  CreateTodoView.swift
//  LifePlanner
//

import SwiftUI

struct CreateTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = TodoViewModel()
    
    let prefilledDueDate: Date?
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Todo.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var subtasks: [Subtask] = []
    @State private var newSubtaskTitle = ""
    
    init(prefilledDueDate: Date? = nil) {
        self.prefilledDueDate = prefilledDueDate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace") {
                    Picker("Add to", selection: Binding(
                        get: { workspaceManager.selectedWorkspace?.id ?? "" },
                        set: { newId in
                            if let workspace = workspaceManager.availableWorkspaces.first(where: { $0.id == newId }) {
                                workspaceManager.selectWorkspace(workspace)
                            }
                        }
                    )) {
                        ForEach(workspaceManager.availableWorkspaces) { workspace in
                            HStack {
                                Circle()
                                    .fill(Color(hex: workspace.color))
                                    .frame(width: 8, height: 8)
                                Text(workspace.name)
                            }
                            .tag(workspace.id ?? "")
                        }
                    }
                }
                
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
                        CollapsibleDatePicker(
                            label: "Due date",
                            date: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
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
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(subtask.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                            Text(subtask.title)
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        subtasks.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTodo()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let prefilledDate = prefilledDueDate {
                    hasDueDate = true
                    dueDate = prefilledDate
                }
            }
        }
    }
    
    private func saveTodo() {
        guard let userId = AuthService.shared.currentUser?.id else {
            print("No user ID")
            return
        }
        
        Task {
            if workspaceManager.selectedWorkspace == nil {
                print("No workspace selected")
                return
            }
            
            guard let workspaceId = workspaceManager.selectedWorkspace?.id else {
                print("Still no workspace after creation attempt")
                return
            }
            
            let todo = Todo(
                workspaceId: workspaceId,
                title: title,
                description: description.isEmpty ? nil : description,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil,
                subtasks: subtasks,
                createdBy: userId
            )
            
            do {
                try await viewModel.createTodo(todo)
                print("Todo created successfully!")
                dismiss()
            } catch {
                print("Error creating todo: \(error.localizedDescription)")
            }
        }
    }
    
    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        
        let subtask = Subtask(title: newSubtaskTitle)
        subtasks.append(subtask)
        newSubtaskTitle = ""
    }
}

#Preview {
    CreateTodoView()
}

