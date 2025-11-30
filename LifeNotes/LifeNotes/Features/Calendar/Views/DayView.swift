//
//  DayView.swift
//  LifePlanner
//

import SwiftUI

struct DayView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    @State private var selectedEvent: Event?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            daySelector
            
            if !allDayEvents.isEmpty {
                allDayEventsSection
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Text(String(format: "%02d:00", hour))
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .frame(width: 50)
                            
                            VStack(spacing: 4) {
                                ForEach(timedEventsForHour(hour)) { event in
                                    Button(action: { selectedEvent = event }) {
                                        EventRow(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                if timedEventsForHour(hour).isEmpty {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 60)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay(
                            Rectangle()
                                .fill(AppTheme.Colors.divider)
                                .frame(height: 1),
                            alignment: .top
                        )
                    }
                }
                .padding(.horizontal)
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
                            Text(event.title)
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
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
        eventsForSelectedDate.filter { $0.isAllDay }
    }
    
    private var timedEvents: [Event] {
        eventsForSelectedDate.filter { !$0.isAllDay }
    }
    
    private var daySelector: some View {
        HStack {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(selectedDate, format: .dateTime.month().day().weekday(.wide))
                .font(AppTheme.Fonts.headline)
            
            Spacer()
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .background(AppTheme.Colors.background)
    }
    
    private func timedEventsForHour(_ hour: Int) -> [Event] {
        timedEvents.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
    
    private var eventsForSelectedDate: [Event] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: selectedDate) }
    }
    
    private func previousDay() {
        if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextDay() {
        if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    DayView(selectedDate: .constant(Date()), events: [])
}

