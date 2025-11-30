//
//  EditWorkspaceView.swift
//  LifePlanner
//

import SwiftUI
import FirebaseFirestore

struct EditWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    let workspace: Workspace
    
    @State private var name: String
    @State private var selectedColor: String
    @State private var isLoading = false
    @State private var showingDeleteAlert = false
    
    init(workspace: Workspace) {
        self.workspace = workspace
        _name = State(initialValue: workspace.name)
        _selectedColor = State(initialValue: workspace.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace Details") {
                    TextField("Name", text: $name)
                    
                    ColorPickerRow(selectedColor: $selectedColor)
                }
                
                Section("Members") {
                    ForEach(workspace.members) { member in
                        HStack {
                            Circle()
                                .fill(AppTheme.Colors.primary)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading) {
                                Text(member.userId)
                                    .font(AppTheme.Fonts.body)
                                Text(member.role.rawValue.capitalized)
                                    .font(AppTheme.Fonts.caption1)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Delete Workspace")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkspace()
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
            .alert("Delete Workspace", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteWorkspace()
                }
            } message: {
                Text("Are you sure you want to delete this workspace? This action cannot be undone.")
            }
        }
    }
    
    private func saveWorkspace() {
        guard let workspaceId = workspace.id else { return }
        
        isLoading = true
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("workspaces")
                    .document(workspaceId)
                    .updateData([
                        "name": name,
                        "color": selectedColor,
                        "updatedAt": Date()
                    ])
                
                await workspaceManager.loadWorkspaces()
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error updating workspace: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    private func deleteWorkspace() {
        guard let workspaceId = workspace.id else { return }
        
        isLoading = true
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("workspaces")
                    .document(workspaceId)
                    .delete()
                
                await workspaceManager.loadWorkspaces()
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error deleting workspace: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}

struct ColorPickerRow: View {
    @Binding var selectedColor: String
    
    let colors = [
        "4CAF50", "2196F3", "FF9800", "E91E63", "9C27B0",
        "00BCD4", "FFEB3B", "FF5722", "795548", "607D8B"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(AppTheme.Fonts.caption1)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Button(action: { selectedColor = color }) {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .strokeBorder(AppTheme.Colors.primary, lineWidth: 3)
                                    .opacity(selectedColor == color ? 1 : 0)
                            )
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EditWorkspaceView(workspace: Workspace(
        name: "Personal",
        ownerId: "user1",
        color: "4CAF50",
        members: []
    ))
    .environmentObject(WorkspaceManager.shared)
}

