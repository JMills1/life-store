//
//  WeekView.swift
//  LifePlanner
//

import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    let workspaces: [Workspace]
    @State private var selectedEvent: Event?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            weekSelector
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(daysInWeek, id: \.self) { day in
                        dayRow(for: day)
                        
                        Divider()
                    }
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    private var weekSelector: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            Spacer()
            
            Text(weekRange)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
    }
    
    private func dayRow(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let dayEvents = eventsForDay(date)
        
        return VStack(alignment: .leading, spacing: 0) {
            // Date header
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .center, spacing: 2) {
                    Text(date.formatted(.dateTime.weekday(.abbreviated)))
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(isToday ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                        .fontWeight(isToday ? .semibold : .regular)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(AppTheme.Fonts.title3)
                        .foregroundColor(isToday ? .white : AppTheme.Colors.textPrimary)
                        .fontWeight(isToday ? .bold : .regular)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isToday ? AppTheme.Colors.primary : Color.clear)
                        )
                }
                .frame(width: 60)
                
                // Events for this day
                if dayEvents.isEmpty {
                    Text("No events")
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, AppTheme.Spacing.lg)
                } else {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        ForEach(dayEvents) { event in
                            Button(action: {
                                selectedEvent = event
                            }) {
                                let eventColor = ColorResolver.shared.colorForEvent(
                                    event,
                                    workspace: ColorResolver.shared.findWorkspace(id: event.workspaceId, in: workspaces)
                                )
                                
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Rectangle()
                                        .fill(eventColor)
                                        .frame(width: 4)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(AppTheme.Fonts.body)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 8) {
                                            if event.isAllDay {
                                                Text("All day")
                                                    .font(AppTheme.Fonts.caption1)
                                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                            } else {
                                                Text(event.startDate.formatted(date: .omitted, time: .shortened))
                                                    .font(AppTheme.Fonts.caption1)
                                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                                
                                                Text("-")
                                                    .font(AppTheme.Fonts.caption1)
                                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                                
                                                Text(event.endDate.formatted(date: .omitted, time: .shortened))
                                                    .font(AppTheme.Fonts.caption1)
                                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                            }
                                            
                                            if let location = event.location {
                                                Text("•")
                                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                                Text(location)
                                                    .font(AppTheme.Fonts.caption1)
                                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                                .padding(AppTheme.Spacing.sm)
                                .background(eventColor.opacity(0.08))
                                .cornerRadius(AppTheme.CornerRadius.small)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, AppTheme.Spacing.md)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isToday ? AppTheme.Colors.primary.opacity(0.03) : Color.clear)
        }
    }
    
    private var daysInWeek: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekInterval.start)
        }
    }
    
    private var weekRange: String {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return ""
        }
        
        let start = weekInterval.start
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        
        if calendar.component(.month, from: start) == calendar.component(.month, from: end) {
            return start.formatted(.dateTime.month(.abbreviated).day())
        } else {
            return "\(start.formatted(.dateTime.month(.abbreviated).day())) - \(end.formatted(.dateTime.month(.abbreviated).day()))"
        }
    }
    
    private func eventsForDay(_ date: Date) -> [Event] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date) ||
            (event.startDate < date && event.endDate >= date)
        }
    }
    
    private func previousWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
}
