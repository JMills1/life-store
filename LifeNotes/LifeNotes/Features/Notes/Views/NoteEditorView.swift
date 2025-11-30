//
//  NoteEditorView.swift
//  LifePlanner
//

import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = NotesViewModel()
    
    let note: Note?
    
    @State private var title: String
    @State private var content: String
    @State private var hasLinkedDate = false
    @State private var linkedDate: Date
    @State private var isPinned: Bool
    
    init(note: Note?) {
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _isPinned = State(initialValue: note?.isPinned ?? false)
        _hasLinkedDate = State(initialValue: note?.linkedDate != nil)
        _linkedDate = State(initialValue: note?.linkedDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                    
                    Section {
                        TextField("Title", text: $title)
                            .font(AppTheme.Fonts.title3)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .font(AppTheme.Fonts.body)
                    }
                    
                    Section {
                        Toggle("Pin note", isOn: $isPinned)
                        
                        Toggle("Link to calendar", isOn: $hasLinkedDate)
                        
                        if hasLinkedDate {
                            DatePicker("Date", selection: $linkedDate, displayedComponents: [.date])
                        }
                    }
                }
                
                if !viewModel.isPremium {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
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
            
            if var existingNote = note {
                existingNote.title = title
                existingNote.content = content
                existingNote.isPinned = isPinned
                existingNote.linkedDate = hasLinkedDate ? linkedDate : nil
                existingNote.updatedAt = Date()
                existingNote.lastEditedBy = userId
                
                do {
                    try await viewModel.updateNote(existingNote)
                    print("Note updated successfully!")
                    dismiss()
                } catch {
                    print("Error updating note: \(error.localizedDescription)")
                }
            } else {
                let newNote = Note(
                    workspaceId: workspaceId,
                    title: title,
                    content: content,
                    linkedDate: hasLinkedDate ? linkedDate : nil,
                    isPinned: isPinned,
                    createdBy: userId
                )
                
                do {
                    try await viewModel.createNote(newNote)
                    print("Note created successfully!")
                    dismiss()
                } catch {
                    print("Error creating note: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    NoteEditorView(note: nil)
}

