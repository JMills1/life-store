//
//  AppConfig.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation

/// App-wide configuration constants
enum AppConfig {
    
    // MARK: - App Info
    static let appName = "LifePlanner"
    static let version = "1.0.0"
    static let bundleIdentifier = "com.jaymills.lifeplanner"
    
    // MARK: - AdMob IDs (Replace with your actual IDs from AdMob console)
    enum Ads {
        #if DEBUG
        static let appID = "ca-app-pub-3940256099942544~1458002511" // Test App ID
        static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716" // Test Banner
        #else
        static let appID = "YOUR_PRODUCTION_ADMOB_APP_ID" // TODO: Replace
        static let bannerAdUnitID = "YOUR_PRODUCTION_BANNER_AD_UNIT_ID" // TODO: Replace
        #endif
    }
    
    // MARK: - In-App Purchase IDs
    enum InAppPurchase {
        static let premiumMonthly = "com.jaymills.lifeplanner.premium.monthly"
        static let premiumYearly = "com.jaymills.lifeplanner.premium.yearly"
    }
    
    // MARK: - Feature Flags
    enum Features {
        static let enableAppleWatch = true
        static let enableAndroid = false // Future
        static let enableOfflineMode = true
        static let maxFreeWorkspaces = 3
        static let maxPremiumWorkspaces = 100
    }
    
    // MARK: - Notifications
    enum Notifications {
        static let enabledByDefault = true
        static let defaultReminderMinutes = 15
    }
    
    // MARK: - API Endpoints (if needed beyond Firebase)
    enum API {
        static let baseURL = "https://your-api-endpoint.com" // Optional
    }
}

