//
//  CreateWorkspaceView.swift
//  LifePlanner
//
//  View for creating a new shared workspace
//

import SwiftUI

struct CreateWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @ObservedObject private var authService = AuthService.shared
    
    @State private var workspaceName = ""
    @State private var selectedColor = "64B5F6" // Default blue
    @State private var selectedIcon = "calendar"
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    private let availableColors = [
        "64B5F6", // Blue
        "4CAF50", // Green
        "FF8A65", // Coral
        "AB47BC", // Purple
        "EC407A", // Pink
        "26C6DA", // Cyan
        "FFCA28", // Amber
        "78909C"  // Blue Gray
    ]
    
    private let availableIcons = [
        "calendar", "house.fill", "briefcase.fill", "heart.fill",
        "star.fill", "flag.fill", "book.fill", "gamecontroller.fill"
    ]
    
    var body: some View {
        Form {
                Section("Workspace Details") {
                    TextField("Workspace Name", text: $workspaceName)
                        .font(AppTheme.Fonts.body)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: {
                                    print("Selected color: \(color)")
                                    selectedColor = color
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 50, height: 50)
                                        
                                        if selectedColor == color {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    print("Selected icon: \(icon)")
                                    selectedIcon = icon
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor) : AppTheme.Colors.background)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .foregroundColor(selectedIcon == icon ? .white : AppTheme.Colors.textSecondary)
                                            .font(.title3)
                                    }
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(AppTheme.Colors.error)
                            .font(AppTheme.Fonts.caption1)
                    }
                    
                    Button(action: createWorkspace) {
                        if isSaving {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Create Workspace")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    .disabled(workspaceName.isEmpty || isSaving)
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
        }
        .dismissKeyboardOnTap()
    }
    
    private func createWorkspace() {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "You must be signed in"
            return
        }
        
        guard !workspaceName.isEmpty else {
            errorMessage = "Please enter a workspace name"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let workspace = Workspace(
                    name: workspaceName,
                    type: .shared,
                    ownerId: userId,
                    color: selectedColor,
                    icon: selectedIcon,
                    members: [WorkspaceMember(userId: userId, role: .owner)]
                )
                
                try await workspaceManager.createWorkspace(workspace)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    CreateWorkspaceView()
        .environmentObject(WorkspaceManager.shared)
}
