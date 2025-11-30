//
//  CreateWorkspaceView.swift
//  LifePlanner
//

import SwiftUI

struct CreateWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    @State private var name = ""
    @State private var selectedColor = "4CAF50"
    @State private var workspaceType: Workspace.WorkspaceType = .personal
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $workspaceType) {
                        Text("Personal").tag(Workspace.WorkspaceType.personal)
                        Text("Shared").tag(Workspace.WorkspaceType.shared)
                    }
                }
                
                Section("Color") {
                    let colors = ["4CAF50", "2196F3", "FF9800", "E91E63", "9C27B0",
                                  "00BCD4", "FFEB3B", "FF5722", "795548", "607D8B"]
                    
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
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createWorkspace()
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func createWorkspace() {
        isLoading = true
        
        Task {
            do {
                _ = try await workspaceManager.createWorkspace(
                    name: name,
                    type: workspaceType,
                    color: selectedColor
                )
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error creating workspace: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}

#Preview {
    CreateWorkspaceView()
        .environmentObject(WorkspaceManager.shared)
}

