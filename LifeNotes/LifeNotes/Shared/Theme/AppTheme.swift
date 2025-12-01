//
//  AppTheme.swift
//  LifePlanner
//
//  Created by Jay Mills on 30/11/2025.
//

import SwiftUI

/// App-wide theme and color system
enum AppTheme {
    
    // MARK: - Primary Colors
    enum Colors {
        // Primary (Mint Green - Family Friendly)
        static let primary = Color(hex: "4CAF50")
        static let primaryLight = Color(hex: "81C784")
        static let primaryDark = Color(hex: "388E3C")
        
        // Secondary (Soft Blue)
        static let secondary = Color(hex: "64B5F6")
        static let secondaryLight = Color(hex: "90CAF9")
        static let secondaryDark = Color(hex: "42A5F5")
        
        // Accent (Warm Coral)
        static let accent = Color(hex: "FF8A65")
        static let accentLight = Color(hex: "FFAB91")
        static let accentDark = Color(hex: "FF7043")
        
        // Neutral
        static let background = Color(hex: "F5F5F5")
        static let surface = Color.white
        static let divider = Color(hex: "E0E0E0")
        
        // Text
        static let textPrimary = Color(hex: "212121")
        static let textSecondary = Color(hex: "757575")
        static let textTertiary = Color(hex: "9E9E9E")
        
        // Status
        static let success = Color(hex: "66BB6A")
        static let warning = Color(hex: "FFA726")
        static let error = Color(hex: "EF5350")
        static let info = Color(hex: "42A5F5")
        
        // Workspace Colors (for user customization)
        static let workspaceColors: [Color] = [
            primary,
            secondary,
            accent,
            Color(hex: "AB47BC"), // Purple
            Color(hex: "EC407A"), // Pink
            Color(hex: "26C6DA"), // Cyan
            Color(hex: "FFCA28"), // Amber
            Color(hex: "78909C")  // Blue Gray
        ]
    }
    
    // MARK: - Typography
    enum Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let small = Shadow(radius: 2, y: 1)
        static let medium = Shadow(radius: 4, y: 2)
        static let large = Shadow(radius: 8, y: 4)
    }
}

// MARK: - Supporting Types
struct Shadow {
    let radius: CGFloat
    let y: CGFloat
    let opacity: Double
    
    init(radius: CGFloat, y: CGFloat, opacity: Double = 0.1) {
        self.radius = radius
        self.y = y
        self.opacity = opacity
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Personal Color Helper
extension AppTheme.Colors {
    static var personalColor: Color {
        if let hexColor = AuthService.shared.currentUser?.preferences.personalColor {
            return Color(hex: hexColor)
        }
        return primary // Fallback to default
    }
}

// MARK: - View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(radius: AppTheme.Shadows.small.radius, y: AppTheme.Shadows.small.y)
    }
    
    func primaryButton() -> some View {
        self
            .font(AppTheme.Fonts.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.personalColor)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    func secondaryButton() -> some View {
        self
            .font(AppTheme.Fonts.headline)
            .foregroundColor(AppTheme.Colors.personalColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.personalColor, lineWidth: 2)
            )
    }
}

