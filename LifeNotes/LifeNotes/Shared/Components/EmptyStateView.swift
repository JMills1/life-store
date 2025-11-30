import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(title)
                .font(AppTheme.Fonts.title3)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(subtitle)
                .font(AppTheme.Fonts.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxHeight: .infinity)
    }
}

