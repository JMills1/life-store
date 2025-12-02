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
    @StateObject private var deepLinkHandler = DeepLinkHandler.shared
    
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
                    .environmentObject(deepLinkHandler)
                    .task {
                        await workspaceManager.initialize()
                    }
                    .onAppear {
                        print("📱 MainTabView appeared - User is authenticated")
                    }
                    .onOpenURL { url in
                        deepLinkHandler.handleURL(url)
                    }
            } else {
                LoginView()
                    .environmentObject(deepLinkHandler)
                    .onAppear {
                        print("🔐 LoginView appeared - User is NOT authenticated")
                    }
                    .onOpenURL { url in
                        deepLinkHandler.handleURL(url)
                    }
            }
        }
    }
}
