//
//  ColorResolver.swift
//  LifePlanner
//
//  Centralized color resolution for all workspace items
//

import SwiftUI

/// Centralized service for resolving colors for workspace items (events, todos, notes)
class ColorResolver {
    static let shared = ColorResolver()
    
    private init() {}
    
    // MARK: - Color Resolution
    
    /// Get the display color for an event
    /// Priority: 1. Event's custom color, 2. Workspace color (personal/shared logic), 3. Default green
    func colorForEvent(_ event: Event, workspace: Workspace?) -> Color {
        // If event has custom color, use it
        if let customColor = event.color {
            return Color(hex: customColor)
        }
        
        // Otherwise use workspace color - CRITICAL: Must pass workspace, not fall back to personal color
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            let resolvedColor = workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
            print("🎨 ColorResolver: Event '\(event.title)' in workspace '\(workspace.name)' (type: \(workspace.type.rawValue)) -> color: \(resolvedColor)")
            return Color(hex: resolvedColor)
        }
        
        // Fallback to default green (should rarely happen)
        print("⚠️ ColorResolver: Event '\(event.title)' has no workspace - using fallback color")
        return Color(hex: "4CAF50")
    }
    
    /// Get the display color for a todo
    /// Uses workspace color (personal/shared logic)
    func colorForTodo(_ todo: Todo, workspace: Workspace?) -> Color {
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            let resolvedColor = workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
            print("🎨 ColorResolver: Todo '\(todo.title)' in workspace '\(workspace.name)' (type: \(workspace.type.rawValue)) -> color: \(resolvedColor)")
            return Color(hex: resolvedColor)
        }
        
        // Fallback (should rarely happen)
        print("⚠️ ColorResolver: Todo '\(todo.title)' has no workspace - using fallback color")
        return Color(hex: "EF5350")
    }
    
    /// Get the display color for a note
    /// Uses workspace color (personal/shared logic)
    func colorForNote(_ note: Note, workspace: Workspace?) -> Color {
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            let resolvedColor = workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
            print("🎨 ColorResolver: Note '\(note.title)' in workspace '\(workspace.name)' (type: \(workspace.type.rawValue)) -> color: \(resolvedColor)")
            return Color(hex: resolvedColor)
        }
        
        // Fallback (should rarely happen)
        print("⚠️ ColorResolver: Note '\(note.title)' has no workspace - using fallback color")
        return Color(hex: "FFA726")
    }
    
    /// Get the display color hex string for an event
    func colorHexForEvent(_ event: Event, workspace: Workspace?) -> String {
        // If event has custom color, use it
        if let customColor = event.color {
            return customColor
        }
        
        // Otherwise use workspace color - CRITICAL: Must use workspace color, not personal
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            return workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
        }
        
        // Fallback to default green (should rarely happen)
        return "4CAF50"
    }
    
    /// Get the display color hex string for a todo
    func colorHexForTodo(_ todo: Todo, workspace: Workspace?) -> String {
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            return workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
        }
        
        // Fallback (should rarely happen)
        return "EF5350"
    }
    
    /// Get the display color hex string for a note
    func colorHexForNote(_ note: Note, workspace: Workspace?) -> String {
        if let workspace = workspace {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor
            let currentUserId = AuthService.shared.currentUser?.id
            return workspace.displayColor(personalColor: personalColor, currentUserId: currentUserId)
        }
        
        // Fallback (should rarely happen)
        return "FFA726"
    }
    
    // MARK: - Convenience Methods
    
    /// Find workspace by ID from a list
    func findWorkspace(id: String?, in workspaces: [Workspace]) -> Workspace? {
        guard let id = id else { return nil }
        return workspaces.first(where: { $0.id == id })
    }
}

// MARK: - SwiftUI Extensions

extension Event {
    /// Get the display color for this event
    func displayColor(workspaces: [Workspace]) -> Color {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorForEvent(self, workspace: workspace)
    }
    
    /// Get the display color hex for this event
    func displayColorHex(workspaces: [Workspace]) -> String {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorHexForEvent(self, workspace: workspace)
    }
}

extension Todo {
    /// Get the display color for this todo
    func displayColor(workspaces: [Workspace]) -> Color {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorForTodo(self, workspace: workspace)
    }
    
    /// Get the display color hex for this todo
    func displayColorHex(workspaces: [Workspace]) -> String {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorHexForTodo(self, workspace: workspace)
    }
}

extension Note {
    /// Get the display color for this note
    func displayColor(workspaces: [Workspace]) -> Color {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorForNote(self, workspace: workspace)
    }
    
    /// Get the display color hex for this note
    func displayColorHex(workspaces: [Workspace]) -> String {
        let workspace = ColorResolver.shared.findWorkspace(id: workspaceId, in: workspaces)
        return ColorResolver.shared.colorHexForNote(self, workspace: workspace)
    }
}

