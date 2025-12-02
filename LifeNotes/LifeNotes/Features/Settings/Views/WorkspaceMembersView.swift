//
//  WorkspaceMembersView.swift
//  LifePlanner
//
//  View for managing workspace members (owner can remove members)
//

import SwiftUI

struct WorkspaceMembersView: View {
    let workspace: Workspace
    @Environment(\.dismiss) private var dismiss
    @StateObject private var invitationService = WorkspaceInvitationService.shared
    @ObservedObject private var authService = AuthService.shared
    @State private var members: [WorkspaceMemberInfo] = []
    @State private var isLoading = true
    @State private var showingRemoveAlert = false
    @State private var memberToRemove: WorkspaceMemberInfo?
    @State private var errorMessage: String?
    
    private var isOwner: Bool {
        workspace.ownerId == authService.currentUser?.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading members...")
                    .padding()
            } else if members.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(members) { memberInfo in
                        memberRow(memberInfo)
                    }
                }
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove Member?", isPresented: $showingRemoveAlert, presenting: memberToRemove) { member in
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                Task {
                    await removeMember(member)
                }
            }
        } message: { member in
            Text("Are you sure you want to remove \(member.user.displayName) from this workspace?")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
            Button("OK") {
                errorMessage = nil
            }
        } message: { message in
            Text(message)
        }
        .onAppear {
            Task {
                await loadMembers()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("No Members Yet")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Share this workspace to add members")
                .font(AppTheme.Fonts.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func memberRow(_ memberInfo: WorkspaceMemberInfo) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: workspace.color).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(memberInfo.user.displayName.prefix(1).uppercased())
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(Color(hex: workspace.color))
            }
            
            // Member info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(memberInfo.user.displayName)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if memberInfo.isOwner {
                        Text("Owner")
                            .font(AppTheme.Fonts.caption1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: workspace.color))
                            .cornerRadius(4)
                    }
                }
                
                Text(memberInfo.user.email)
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text("Joined \(memberInfo.member.joinedAt, style: .relative)")
                    .font(AppTheme.Fonts.caption2)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            
            Spacer()
            
            // Remove button (only for owner, and can't remove themselves)
            if isOwner && !memberInfo.isOwner {
                Button(action: {
                    memberToRemove = memberInfo
                    showingRemoveAlert = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
    
    private func loadMembers() async {
        isLoading = true
        
        do {
            members = try await invitationService.getWorkspaceMembers(for: workspace)
        } catch {
            errorMessage = "Failed to load members: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func removeMember(_ memberInfo: WorkspaceMemberInfo) async {
        do {
            try await invitationService.removeMember(userId: memberInfo.user.id ?? "", from: workspace)
            
            // Remove from local list
            members.removeAll { $0.id == memberInfo.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationView {
        WorkspaceMembersView(workspace: Workspace(
            id: "test",
            name: "Family Calendar",
            type: .shared,
            ownerId: "user1",
            color: "64B5F6",
            members: [
                WorkspaceMember(userId: "user1", role: .owner),
                WorkspaceMember(userId: "user2", role: .editor),
                WorkspaceMember(userId: "user3", role: .editor)
            ]
        ))
    }
}

