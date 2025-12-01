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
        print("============================================")
        print("LIFEPLANNER APP STARTING")
        print("============================================")
        
        FirebaseConfig.shared.configure()
        print("✅ Firebase configured")
        
        MobileAds.shared.start { status in
            print("✅ Google Mobile Ads started")
        }
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(workspaceManager)
                    .task {
                        await workspaceManager.initialize()
                    }
                    .onAppear {
                        print("📱 MainTabView appeared - User is authenticated")
                    }
            } else {
                LoginView()
                    .onAppear {
                        print("🔐 LoginView appeared - User is NOT authenticated")
                    }
            }
        }
    }
}
