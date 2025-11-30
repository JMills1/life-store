//
//  WorkspaceSelector.swift
//  LifePlanner
//

import SwiftUI

struct WorkspaceSelector: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @State private var showingWorkspaceSheet = false
    
    var body: some View {
        Button(action: { showingWorkspaceSheet = true }) {
            HStack(spacing: 6) {
                if workspaceManager.selectedWorkspaceIds.count > 1 {
                    ZStack(alignment: .leading) {
                        ForEach(0..<min(3, workspaceManager.selectedWorkspaceIds.count), id: \.self) { index in
                            if let workspace = workspaceManager.availableWorkspaces.first(where: { $0.id == workspaceManager.selectedWorkspaceIds[index] }) {
                                Circle()
                                    .fill(Color(hex: workspace.color))
                                    .frame(width: 8, height: 8)
                                    .offset(x: CGFloat(index) * 6)
                            }
                        }
                    }
                    .frame(width: 20, height: 8)
                    
                    Text("Multiple")
                        .font(AppTheme.Fonts.subheadline)
                } else if let workspace = workspaceManager.selectedWorkspace {
                    Circle()
                        .fill(Color(hex: workspace.color))
                        .frame(width: 8, height: 8)
                    Text(workspace.name)
                        .font(AppTheme.Fonts.subheadline)
                } else {
                    Text("Select Workspace")
                        .font(AppTheme.Fonts.subheadline)
                }
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .sheet(isPresented: $showingWorkspaceSheet) {
            WorkspaceSelectionSheet()
        }
    }
}

struct WorkspaceSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @State private var selectedIds: Set<String>
    @State private var workspaceToEdit: Workspace?
    @State private var showingCreateWorkspace = false
    
    init() {
        _selectedIds = State(initialValue: Set(WorkspaceManager.shared.selectedWorkspaceIds))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("My Workspaces") {
                    ForEach(workspaceManager.availableWorkspaces) { workspace in
                        HStack {
                            Button(action: { toggleWorkspace(workspace) }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: workspace.color))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(workspace.name)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedIds.contains(workspace.id ?? "") ? Color(hex: workspace.color).opacity(0.1) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(
                                            selectedIds.contains(workspace.id ?? "") ? Color(hex: workspace.color) : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { workspaceToEdit = workspace }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 8)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
                
                Section {
                    Button("Create New Workspace") {
                        showingCreateWorkspace = true
                    }
                }
            }
            .navigationTitle("Select Workspaces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        workspaceManager.selectedWorkspaceIds = Array(selectedIds)
                        dismiss()
                    }
                }
            }
            .sheet(item: $workspaceToEdit) { workspace in
                EditWorkspaceView(workspace: workspace)
            }
            .sheet(isPresented: $showingCreateWorkspace) {
                CreateWorkspaceView()
            }
        }
    }
    
    private func toggleWorkspace(_ workspace: Workspace) {
        guard let id = workspace.id else { return }
        
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}

#Preview {
    WorkspaceSelector()
        .environmentObject(WorkspaceManager.shared)
}

