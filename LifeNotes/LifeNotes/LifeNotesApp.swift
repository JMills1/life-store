//
//  LifeNotesApp.swift
//  LifePlanner
//

import SwiftUI
import SwiftData
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
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
        .modelContainer(sharedModelContainer)
    }
}
