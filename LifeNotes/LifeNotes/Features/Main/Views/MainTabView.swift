//
//  MainTabView.swift
//  LifePlanner
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @ObservedObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "house.fill")
                    }
                    .tag(0)
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)
                
                TodoListView()
                    .tabItem {
                        Label("To Do", systemImage: "checklist")
                    }
                    .tag(2)
                
                NotesListView()
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
                    .tag(3)
                
                FamilyView()
                    .tabItem {
                        Label("Family", systemImage: "person.3.fill")
                    }
                    .tag(4)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(5)
            }
            .accentColor(AppTheme.Colors.personalColor(from: authService))
            
            if selectedTab != 5 {
                QuickAddButton()
                    .environmentObject(workspaceManager)
                    .padding()
                    .padding(.bottom, 60)
            }
        }
        .alert("Workspace Joined!", isPresented: $deepLinkHandler.showingJoinWorkspace) {
            Button("OK") {
                deepLinkHandler.dismissJoinAlert()
            }
        } message: {
            if let workspace = deepLinkHandler.joinedWorkspace {
                Text("You've successfully joined \"\(workspace.name)\"!")
            } else if let error = deepLinkHandler.joinError {
                Text(error)
            }
        }
        .task {
            // Process any pending invites after login
            await deepLinkHandler.processPendingInvite()
        }
    }
}

#Preview {
    MainTabView()
}

