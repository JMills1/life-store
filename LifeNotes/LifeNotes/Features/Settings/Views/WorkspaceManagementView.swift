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

#Preview {
    WorkspaceManagementView()
        .environmentObject(WorkspaceManager.shared)
}

