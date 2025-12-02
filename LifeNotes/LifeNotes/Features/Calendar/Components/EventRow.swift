//
//  EventRow.swift
//  LifePlanner
//

import SwiftUI

struct EventRow: View {
    let event: Event
    var workspaces: [Workspace] = []
    
    private var eventColor: Color {
        ColorResolver.shared.colorForEvent(
            event,
            workspace: ColorResolver.shared.findWorkspace(id: event.workspaceId, in: workspaces)
        )
    }
    
    private var borderColor: Color {
        eventColor.darker()
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Rectangle()
                .fill(eventColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 8) {
                    Label(
                        event.startDate.formatted(date: .omitted, time: .shortened),
                        systemImage: "clock"
                    )
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    if let location = event.location {
                        Label(location, systemImage: "location")
                            .font(AppTheme.Fonts.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.sm)
        .background(eventColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
        .cornerRadius(AppTheme.CornerRadius.small)
        .padding(.horizontal)
    }
}

#Preview {
    EventRow(event: Event(
        workspaceId: "test",
        title: "Team Meeting",
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600),
        location: "Conference Room",
        createdBy: "user1"
    ))
}

