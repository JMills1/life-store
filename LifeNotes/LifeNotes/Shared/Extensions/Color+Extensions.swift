//
//  Color+Extensions.swift
//  LifePlanner
//

import SwiftUI

extension Color {
    func darker(by percentage: Double = 0.2) -> Color {
        return self.adjust(by: -abs(percentage))
    }
    
    func lighter(by percentage: Double = 0.2) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    private func adjust(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        #if canImport(UIKit)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        return Color(
            red: min(max(red + percentage, 0), 1),
            green: min(max(green + percentage, 0), 1),
            blue: min(max(blue + percentage, 0), 1),
            opacity: Double(alpha)
        )
    }
    
    var isDark: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        #if canImport(UIKit)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance < 0.5
    }
}

extension Event {
    func workspaceColor(from workspace: Workspace?) -> Color {
        guard let workspace = workspace else {
            return Color(hex: "4CAF50")
        }
        return Color(hex: workspace.color)
    }
}

