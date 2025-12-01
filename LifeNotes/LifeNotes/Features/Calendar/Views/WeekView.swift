//
//  WeekView.swift
//  LifePlanner
//

import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            weekSelector
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(daysInWeek, id: \.self) { day in
                        dayColumn(for: day)
                    }
                }
            }
        }
    }
    
    private var weekSelector: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(weekRange)
                .font(AppTheme.Fonts.headline)
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    private func dayColumn(for date: Date) -> some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
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
                .onTapGesture {
                    selectedDate = date
                }
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(eventsForDay(date)) { event in
                        EventCard(event: event)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
        .frame(width: UIScreen.main.bounds.width / 7)
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

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(AppTheme.Fonts.caption1)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if !event.isAllDay {
                Text(event.startDate.formatted(date: .omitted, time: .shortened))
                    .font(AppTheme.Fonts.caption2)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: event.color ?? "4CAF50").opacity(0.2))
        .cornerRadius(4)
    }
}

