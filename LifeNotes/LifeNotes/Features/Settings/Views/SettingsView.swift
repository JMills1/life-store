//
//  SettingsView.swift
//  LifePlanner
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingUpgrade = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if let user = authService.currentUser {
                    Section("Account") {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.displayName)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        HStack {
                            Text("Status")
                            Spacer()
                            if user.isPremium {
                                Label("Premium", systemImage: "crown.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                            } else {
                                Text("Free")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                
                if !(authService.currentUser?.isPremium ?? false) {
                    Section {
                        Button(action: { showingUpgrade = true }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(AppTheme.Colors.accent)
                                
                                VStack(alignment: .leading) {
                                    Text("Upgrade to Premium")
                                        .font(AppTheme.Fonts.headline)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Text("$2.99/month - Remove ads & unlock features")
                                        .font(AppTheme.Fonts.caption1)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Preferences") {
                    NavigationLink("My Color") {
                        PersonalColorSettingsView()
                    }
                    
                    NavigationLink("Notifications") {
                        NotificationSettingsView()
                    }
                    
                    NavigationLink("Workspaces") {
                        WorkspaceManagementView()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConfig.version)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showingSignOutAlert = true }) {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingUpgrade) {
                PremiumUpgradeView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    SettingsView()
}

