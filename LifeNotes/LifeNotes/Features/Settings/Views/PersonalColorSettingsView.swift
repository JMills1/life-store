//
//  PersonalColorSettingsView.swift
//  LifePlanner
//

import SwiftUI
import FirebaseFirestore

struct PersonalColorSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var workspaceManager = WorkspaceManager.shared
    @State private var selectedColor: String
    @State private var isSaving = false
    
    init() {
        let currentColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
        _selectedColor = State(initialValue: currentColor)
    }
    
    var body: some View {
        Form {
            Section {
                Text("This color will be used for your personal workspace and UI accents throughout the app")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Section {
                ColorPickerView(selectedColor: $selectedColor, title: "My Personal Color")
            }
            
            Section {
                HStack {
                    Text("Preview")
                        .font(AppTheme.Fonts.headline)
                    
                    Spacer()
                    
                    Text("My Event")
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: selectedColor))
                        .cornerRadius(4)
                }
            }
            
            Section {
                Button(action: saveColor) {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Color")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("My Color")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveColor() {
        guard var preferences = authService.currentUser?.preferences else { return }
        guard let userId = authService.currentUser?.id else { return }
        
        preferences.personalColor = selectedColor
        isSaving = true
        
        Task {
            do {
                // Save personal color to user preferences
                try await authService.updateUserPreferences(preferences)
                print("Personal color saved: \(selectedColor)")
                
                // Update personal workspace color to match
                await updatePersonalWorkspaceColor(userId: userId, color: selectedColor)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error saving color: \(error.localizedDescription)")
            }
            isSaving = false
        }
    }
    
    private func updatePersonalWorkspaceColor(userId: String, color: String) async {
        // Find the user's personal workspace
        guard let personalWorkspace = workspaceManager.availableWorkspaces.first(where: { 
            $0.type == .personal && $0.ownerId == userId 
        }) else {
            print("No personal workspace found")
            return
        }
        
        guard let workspaceId = personalWorkspace.id else { return }
        
        // Update the workspace color in Firestore
        do {
            try await FirebaseFirestore.Firestore.firestore()
                .collection("workspaces")
                .document(workspaceId)
                .updateData([
                    "color": color,
                    "updatedAt": FirebaseFirestore.Timestamp(date: Date())
                ])
            print("Updated personal workspace color to: \(color)")
        } catch {
            print("Error updating workspace color: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PersonalColorSettingsView()
}

