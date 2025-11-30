//
//  FamilyView.swift
//  LifePlanner
//

import SwiftUI

struct FamilyView: View {
    @StateObject private var viewModel = FamilyViewModel()
    @State private var showingCreateFamily = false
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.families.isEmpty {
                    ForEach(viewModel.families) { family in
                        Section(family.name) {
                            ForEach(family.members) { member in
                                Text("Member: \(member.userId)")
                            }
                            
                            Button("Invite Members") {
                                
                            }
                        }
                    }
                } else {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text("No family groups yet")
                            .font(AppTheme.Fonts.title3)
                        
                        Button("Create Family Group") {
                            showingCreateFamily = true
                        }
                        .primaryButton()
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Family")
            .toolbar {
                if !viewModel.families.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingCreateFamily = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateFamily) {
                CreateFamilyView()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    FamilyView()
}

