//
//  PersonalColorSettingsView.swift
//  LifePlanner
//

import SwiftUI

struct PersonalColorSettingsView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedColor: String
    @State private var isSaving = false
    
    init() {
        let currentColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
        _selectedColor = State(initialValue: currentColor)
    }
    
    var body: some View {
        Form {
            Section {
                Text("Your events in shared calendars will appear in this color")
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
        
        preferences.personalColor = selectedColor
        isSaving = true
        
        Task {
            do {
                try await authService.updateUserPreferences(preferences)
                print("Personal color saved: \(selectedColor)")
            } catch {
                print("Error saving color: \(error.localizedDescription)")
            }
            isSaving = false
        }
    }
}

#Preview {
    PersonalColorSettingsView()
}

