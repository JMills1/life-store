//
//  FirebaseConfig.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import Foundation
import Firebase

/// Firebase configuration and initialization
class FirebaseConfig {
    static let shared = FirebaseConfig()
    
    private init() {}
    
    func configure() {
        FirebaseApp.configure()
        
        #if DEBUG
        print("Firebase configured for DEBUG")
        #else
        print("Firebase configured for PRODUCTION")
        #endif
    }
}

