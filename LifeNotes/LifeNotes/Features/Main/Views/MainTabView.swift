//
//  MainTabView.swift
//  LifePlanner
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
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
            .accentColor(AppTheme.Colors.personalColor)
            
            if selectedTab != 5 {
                QuickAddButton()
                    .environmentObject(workspaceManager)
                    .padding()
                    .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    MainTabView()
}

