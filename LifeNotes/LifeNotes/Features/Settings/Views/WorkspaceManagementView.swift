//
//  WorkspaceManagementView.swift
//  LifePlanner
//

import SwiftUI

struct WorkspaceManagementView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @State private var showingCreateWorkspace = false
    
    var body: some View {
        List {
            ForEach(workspaceManager.availableWorkspaces) { workspace in
                HStack {
                    Circle()
                        .fill(Color(hex: workspace.color))
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading) {
                        Text(workspace.name)
                            .font(AppTheme.Fonts.body)
                        Text(workspace.type == .personal ? "Personal" : "Shared")
                            .font(AppTheme.Fonts.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .navigationTitle("Workspaces")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateWorkspace = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateWorkspace) {
            CreateWorkspaceView()
        }
    }
}

struct CreateWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @State private var name = ""
    @State private var selectedColor = "4CAF50"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace Details") {
                    TextField("Name", text: $name)
                }
                
                Section("Color") {
                    ColorPickerView(selectedColor: $selectedColor, title: "Workspace Color")
                }
            }
            .navigationTitle("New Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createWorkspace()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createWorkspace() {
        Task {
            do {
                var newWorkspace = try await workspaceManager.createWorkspace(name: name, type: .personal)
                newWorkspace.color = selectedColor
                print("Workspace created: \(name)")
                dismiss()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    WorkspaceManagementView()
}

