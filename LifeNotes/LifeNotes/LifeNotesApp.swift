//
//  LifeNotesApp.swift
//  LifePlanner
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct LifePlannerApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var workspaceManager = WorkspaceManager.shared
    
    init() {
        FirebaseConfig.shared.configure()
        MobileAds.shared.start { _ in }
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(workspaceManager)
                    .task {
                        await workspaceManager.initialize()
                    }
            } else {
                LoginView()
            }
        }
    }
}
