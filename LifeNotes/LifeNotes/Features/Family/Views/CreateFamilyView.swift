//
//  CreateFamilyView.swift
//  LifePlanner
//

import SwiftUI

struct CreateFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FamilyViewModel()
    
    @State private var familyName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Family Details") {
                    TextField("Family Name", text: $familyName)
                }
                
                Section {
                    Text("You can invite family members after creating the group")
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .navigationTitle("New Family Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createFamily()
                    }
                    .disabled(familyName.isEmpty)
                }
            }
        }
    }
    
    private func createFamily() {
        Task {
            try? await viewModel.createFamily(name: familyName)
            dismiss()
        }
    }
}

#Preview {
    CreateFamilyView()
}

