//
//  WeekView.swift
//  LifePlanner
//

import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    @State private var selectedEvent: Event?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            weekSelector
            
            if !allDayEvents.isEmpty {
                allDayEventsSection
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HourRow(
                            hour: hour,
                            daysInWeek: daysInWeek,
                            events: timedEventsForHour(hour),
                            onEventTap: { event in
                                selectedEvent = event
                            }
                        )
                    }
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    private var allDayEventsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("All Day")
                .font(AppTheme.Fonts.caption1)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allDayEvents) { event in
                        Button(action: { selectedEvent = event }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(AppTheme.Fonts.caption1)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                if event.spansDays > 0 {
                                    Text("\(event.spansDays + 1) days")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(hex: event.color ?? "4CAF50"))
                            .cornerRadius(AppTheme.CornerRadius.small)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var allDayEvents: [Event] {
        eventsForWeek.filter { $0.isAllDay }
    }
    
    private var timedEvents: [Event] {
        eventsForWeek.filter { !$0.isAllDay }
    }
    
    private var eventsForWeek: [Event] {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
            return []
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        return events.filter { event in
            event.startDate < weekEnd && event.endDate >= weekStart
        }
    }
    
    private var weekSelector: some View {
        HStack(spacing: 0) {
            ForEach(daysInWeek, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(date, format: .dateTime.weekday(.abbreviated))
                        .font(AppTheme.Fonts.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : AppTheme.Colors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? AppTheme.Colors.primary : Color.clear)
                        )
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var daysInWeek: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekInterval.start)
        }
    }
    
    private func timedEventsForHour(_ hour: Int) -> [Event] {
        timedEvents.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
}

struct HourRow: View {
    let hour: Int
    let daysInWeek: [Date]
    let events: [Event]
    let onEventTap: (Event) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(String(format: "%02d:00", hour))
                .font(AppTheme.Fonts.caption1)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(width: 50)
            
            ForEach(daysInWeek, id: \.self) { day in
                VStack(spacing: 2) {
                    ForEach(eventsForDay(day)) { event in
                        Button(action: { onEventTap(event) }) {
                            Text(event.title)
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .padding(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: event.color ?? "4CAF50"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if eventsForDay(day).isEmpty {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 60)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(
            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1),
            alignment: .top
        )
    }
    
    private func eventsForDay(_ day: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: day)
        }
    }
}

#Preview {
    WeekView(selectedDate: .constant(Date()), events: [])
}

