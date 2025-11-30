//
//  ColorPickerView.swift
//  LifePlanner
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: String
    let title: String
    
    private let colorOptions = [
        ("Red", "EF5350"),
        ("Pink", "EC407A"),
        ("Purple", "AB47BC"),
        ("Blue", "42A5F5"),
        ("Cyan", "26C6DA"),
        ("Green", "66BB6A"),
        ("Yellow", "FFEB3B"),
        ("Orange", "FF7043"),
        ("Brown", "8D6E63"),
        ("Gray", "78909C")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(title)
                .font(AppTheme.Fonts.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                ForEach(colorOptions, id: \.1) { name, hex in
                    Button(action: { selectedColor = hex }) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(selectedColor == hex ? Color.primary : Color.clear, lineWidth: 3)
                                )
                            
                            Text(name)
                                .font(AppTheme.Fonts.caption2)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ColorPickerView(selectedColor: .constant("EF5350"), title: "Your Color")
}

