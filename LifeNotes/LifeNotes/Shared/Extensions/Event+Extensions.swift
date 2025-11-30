//
//  Event+Extensions.swift
//  LifePlanner
//

import Foundation
import SwiftUI
import FirebaseFirestore

extension Event {
    func displayColor(workspace: Workspace?, creatorColor: String?) -> String {
        if let customColor = color {
            return customColor
        }
        
        if useCreatorColor, let creatorColor = creatorColor {
            return creatorColor
        }
        
        return workspace?.color ?? "4CAF50"
    }
    
    func loadCreatorColor() async -> String? {
        let db = Firestore.firestore()
        
        do {
            let doc = try await db.collection("users").document(createdBy).getDocument()
            if let user = try? doc.data(as: User.self) {
                return user.preferences.personalColor
            }
        } catch {
            print("Error loading creator color: \(error.localizedDescription)")
        }
        
        return nil
    }
}

extension Todo {
    func displayColor(workspace: Workspace?, creatorColor: String?) -> String {
        if let creatorColor = creatorColor {
            return creatorColor
        }
        
        return workspace?.color ?? "4CAF50"
    }
}

