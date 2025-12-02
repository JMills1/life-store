//
//  WorkspaceShareView.swift
//  LifePlanner
//
//  View for sharing a workspace via invite link
//

import SwiftUI

struct WorkspaceShareView: View {
    let workspace: Workspace
    @Environment(\.dismiss) private var dismiss
    @StateObject private var invitationService = WorkspaceInvitationService.shared
    @State private var inviteLink: String?
    @State private var isGenerating = false
    @State private var showCopiedAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: workspace.color))
                        .padding()
                    
                    Text("Share \"\(workspace.name)\"")
                        .font(AppTheme.Fonts.title2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Anyone with this link can join this workspace")
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, AppTheme.Spacing.xl)
                
                // Invite Link Section
                if let inviteLink = inviteLink {
                    VStack(spacing: AppTheme.Spacing.md) {
                        // Link display
                        HStack {
                            Text(inviteLink)
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.Colors.background)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            
                            Button(action: copyLink) {
                                Image(systemName: "doc.on.doc")
                                    .font(.title3)
                                    .foregroundColor(Color(hex: workspace.color))
                                    .padding()
                                    .background(Color(hex: workspace.color).opacity(0.1))
                                    .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Expiration info
                        if let expiresAt = workspace.inviteLink?.expiresAt {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("Expires \(expiresAt, style: .relative)")
                                    .font(AppTheme.Fonts.caption1)
                            }
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        // Action buttons
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Button(action: shareLink) {
                                Label("Share Link", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .primaryButton()
                            .padding(.horizontal)
                            
                            Button(action: regenerateLink) {
                                Label("Generate New Link", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .secondaryButton()
                            .padding(.horizontal)
                        }
                    }
                } else if isGenerating {
                    ProgressView("Generating link...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.Colors.error)
                        
                        Text(errorMessage)
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            Task {
                                await generateLink()
                            }
                        }
                        .primaryButton()
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Members section link
                NavigationLink(destination: WorkspaceMembersView(workspace: workspace)) {
                    HStack {
                        Image(systemName: "person.3")
                        Text("View Members")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Share Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Link Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The invite link has been copied to your clipboard")
            }
            .onAppear {
                Task {
                    await generateLink()
                }
            }
    }
    
    private func generateLink() async {
        isGenerating = true
        errorMessage = nil
        
        do {
            inviteLink = try await invitationService.refreshInviteLinkIfNeeded(for: workspace)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    private func regenerateLink() {
        Task {
            isGenerating = true
            errorMessage = nil
            
            do {
                inviteLink = try await invitationService.generateInviteLink(for: workspace)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isGenerating = false
        }
    }
    
    private func copyLink() {
        guard let inviteLink = inviteLink else { return }
        UIPasteboard.general.string = inviteLink
        showCopiedAlert = true
    }
    
    private func shareLink() {
        guard let inviteLink = inviteLink else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [
                "Join my \"\(workspace.name)\" workspace on LifePlanner!",
                URL(string: inviteLink)!
            ],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    WorkspaceShareView(workspace: Workspace(
        id: "test",
        name: "Family Calendar",
        type: .shared,
        ownerId: "user1",
        color: "64B5F6"
    ))
}

