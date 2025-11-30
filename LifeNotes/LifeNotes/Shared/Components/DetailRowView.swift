import SwiftUI

struct DetailRowView: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = AppTheme.Colors.textPrimary
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(value)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(valueColor)
            }
        }
    }
}

