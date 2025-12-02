//
//  WorkspaceManagementView.swift
//  LifePlanner
//
//  View for managing all workspaces (personal and shared)
//

import SwiftUI

struct WorkspaceManagementView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @ObservedObject private var authService = AuthService.shared
    @State private var showingCreateWorkspace = false
    @State private var showingShareWorkspace: Workspace?
    
    private var personalWorkspaces: [Workspace] {
        workspaceManager.availableWorkspaces.filter { $0.type == .personal }
    }
    
    private var sharedWorkspaces: [Workspace] {
        workspaceManager.availableWorkspaces.filter { $0.type == .shared }
    }
    
    private var ownedSharedWorkspaces: [Workspace] {
        sharedWorkspaces.filter { $0.ownerId == authService.currentUser?.id }
    }
    
    private var joinedSharedWorkspaces: [Workspace] {
        sharedWorkspaces.filter { $0.ownerId != authService.currentUser?.id }
    }
    
    var body: some View {
        List {
            // Personal Workspace Section
            Section {
                ForEach(personalWorkspaces) { workspace in
                    workspaceRow(workspace, showShareButton: false)
                }
            } header: {
                Text("Personal Workspace")
            } footer: {
                Text("Your personal workspace uses your personal color and is private to you.")
                    .font(AppTheme.Fonts.caption1)
            }
            
            // Owned Shared Workspaces
            if !ownedSharedWorkspaces.isEmpty {
                Section {
                    ForEach(ownedSharedWorkspaces) { workspace in
                        workspaceRow(workspace, showShareButton: true)
                    }
                } header: {
                    Text("My Shared Workspaces")
                } footer: {
                    Text("Workspaces you created and can share with others.")
                        .font(AppTheme.Fonts.caption1)
                }
            }
            
            // Joined Shared Workspaces
            if !joinedSharedWorkspaces.isEmpty {
                Section {
                    ForEach(joinedSharedWorkspaces) { workspace in
                        workspaceRow(workspace, showShareButton: false)
                    }
                } header: {
                    Text("Joined Workspaces")
                } footer: {
                    Text("Workspaces shared with you by others.")
                        .font(AppTheme.Fonts.caption1)
                }
            }
            
            // Create New Workspace Button
            Section {
                Button(action: { showingCreateWorkspace = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.Colors.personalColor(from: authService))
                        Text("Create Shared Workspace")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
        .navigationTitle("Workspaces")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCreateWorkspace) {
            CreateWorkspaceView()
        }
        .sheet(item: $showingShareWorkspace) { workspace in
            WorkspaceShareView(workspace: workspace)
        }
    }
    
    private func workspaceRow(_ workspace: Workspace, showShareButton: Bool) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Workspace icon and color
            ZStack {
                Circle()
                    .fill(Color(hex: workspace.displayColor(
                        personalColor: authService.currentUser?.preferences.personalColor,
                        currentUserId: authService.currentUser?.id
                    )))
                    .frame(width: 40, height: 40)
                
                Image(systemName: workspace.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            
            // Workspace info
            VStack(alignment: .leading, spacing: 4) {
                Text(workspace.name)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 8) {
                    if workspace.type == .personal {
                        Label("Personal", systemImage: "lock.fill")
                            .font(AppTheme.Fonts.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    } else {
                        Label("\(workspace.members.count) members", systemImage: "person.2")
                            .font(AppTheme.Fonts.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Share button for owned workspaces
            if showShareButton {
                Button(action: {
                    showingShareWorkspace = workspace
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(Color(hex: workspace.color))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        WorkspaceManagementView()
            .environmentObject(WorkspaceManager.shared)
    }
}
