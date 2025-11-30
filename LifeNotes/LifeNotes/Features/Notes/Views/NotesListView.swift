//
//  NotesListView.swift
//  LifePlanner
//

import SwiftUI

struct NotesListView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingCreateNote = false
    @State private var showingWorkspaceSelector = false
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.notes
        }
        return viewModel.notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !viewModel.notes.isEmpty {
                    List {
                        if !viewModel.pinnedNotes.isEmpty {
                            Section("Pinned") {
                                ForEach(viewModel.pinnedNotes) { note in
                                    NavigationLink(destination: NoteEditorView(note: note)) {
                                        NoteRowView(note: note)
                                    }
                                }
                            }
                        }
                        
                        Section("All Notes") {
                            ForEach(filteredNotes.filter { !$0.isPinned }) { note in
                                NavigationLink(destination: NoteEditorView(note: note)) {
                                    NoteRowView(note: note)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search notes")
                } else {
                    emptyState
                }
                
                if !viewModel.isPremium {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    WorkspaceSelector()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingCreateNote) {
                NoteEditorView(note: nil)
            }
            .sheet(isPresented: $showingWorkspaceSelector) {
                WorkspaceSelectorView()
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
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("No notes yet")
                .font(AppTheme.Fonts.title3)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Tap + to create your first note")
                .font(AppTheme.Fonts.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxHeight: .infinity)
    }
}

struct NoteRowView: View {
    let note: Note
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    private var workspace: Workspace? {
        workspaceManager.availableWorkspaces.first(where: { $0.id == note.workspaceId })
    }
    
    private var borderColor: Color {
        workspace.map { Color(hex: $0.color).darker() } ?? AppTheme.Colors.divider
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            
            if !note.preview.isEmpty {
                Text(note.preview)
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 8) {
                Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                
                if let linkedDate = note.linkedDate {
                    Label(
                        linkedDate.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.primary)
                }
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
    }
}

#Preview {
    NotesListView()
}

