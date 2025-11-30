//
//  MonthGridView.swift
//  LifePlanner
//

import SwiftUI

struct MonthGridView: View {
    let currentMonth: Date
    let selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let onDateTap: (Date) -> Void
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeks, id: \.self) { week in
                weekRow(for: week)
            }
        }
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(AppTheme.Fonts.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    
    private func weekRow(for week: [Date?]) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                if let date = week[index] {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 60)
    }
    
    private func dayCell(for date: Date) -> some View {
        let isFirstOfMonth = calendar.component(.day, from: date) == 1
        let personalColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
        let itemsForDate = itemsForDate(date)
        
        return Button(action: { onDateTap(date) }) {
            VStack(spacing: 2) {
                if isFirstOfMonth {
                    Text(date.formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 8))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: calendar.isDateInToday(date) ? .bold : .regular))
                    .foregroundColor(
                        calendar.isDate(date, inSameDayAs: selectedDate) ? .white :
                        calendar.isDateInToday(date) ? Color(hex: personalColor) :
                        calendar.component(.month, from: date) == calendar.component(.month, from: currentMonth) ? AppTheme.Colors.textPrimary :
                        AppTheme.Colors.textTertiary
                    )
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color(hex: personalColor) : Color.clear)
                    )
                
                HStack(spacing: 2) {
                    ForEach(0..<min(itemsForDate.count, 3), id: \.self) { index in
                        Circle()
                            .fill(itemsForDate[index].color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func itemsForDate(_ date: Date) -> [(type: String, color: Color)] {
        var items: [(type: String, color: Color)] = []
        
        let eventsOnDate = events.filter { $0.spansDate(date) }
        for event in eventsOnDate {
            items.append(("event", Color(hex: event.color ?? "4CAF50")))
        }
        
        let todosOnDate = todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
        if !todosOnDate.isEmpty {
            let personalColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
            items.append(("todo", Color(hex: personalColor)))
        }
        
        let notesOnDate = notes.filter { note in
            guard let linkedDate = note.linkedDate else { return false }
            return calendar.isDate(linkedDate, inSameDayAs: date)
        }
        if !notesOnDate.isEmpty {
            items.append(("note", AppTheme.Colors.textSecondary))
        }
        
        return items
    }
    
    private func eventBar(for event: Event, in week: [Date?]) -> some View {
        let validDates = week.compactMap { $0 }
        guard let firstDate = validDates.first,
              let lastDate = validDates.last else {
            return AnyView(EmptyView())
        }
        
        let eventStart = max(event.startDate, firstDate)
        let eventEnd = min(event.endDate, lastDate)
        
        guard event.spansDate(firstDate) || event.spansDate(lastDate) ||
              (event.startDate <= lastDate && event.endDate >= firstDate) else {
            return AnyView(EmptyView())
        }
        
        let startIndex = validDates.firstIndex { calendar.isDate($0, inSameDayAs: eventStart) || $0 > eventStart } ?? 0
        let endIndex = validDates.lastIndex { calendar.isDate($0, inSameDayAs: eventEnd) || $0 < eventEnd } ?? 6
        
        return AnyView(
            GeometryReader { geometry in
                let cellWidth = geometry.size.width / 7
                let xOffset = CGFloat(startIndex) * cellWidth
                let width = CGFloat(endIndex - startIndex + 1) * cellWidth
                
                HStack(spacing: 0) {
                    if !event.isFirstDayOf(validDates[startIndex]) {
                        Rectangle()
                            .fill(Color(hex: event.color ?? "4CAF50"))
                            .frame(width: 3)
                    }
                    
                    Text(event.isFirstDayOf(validDates[startIndex]) ? event.title : "")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: event.color ?? "4CAF50"))
                    
                    if !event.isLastDayOf(validDates[endIndex]) {
                        Rectangle()
                            .fill(Color(hex: event.color ?? "4CAF50"))
                            .frame(width: 3)
                    }
                }
                .frame(width: width, height: 16)
                .cornerRadius(3)
                .offset(x: xOffset)
            }
            .frame(height: 16)
        )
    }
    
    private func eventsForWeek(_ week: [Date?]) -> [Event] {
        let validDates = week.compactMap { $0 }
        guard let firstDate = validDates.first,
              let lastDate = validDates.last else {
            return []
        }
        
        return events.filter { event in
            event.startDate <= lastDate && event.endDate >= firstDate
        }
    }
    
    private var weeks: [[Date?]] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastDay = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)
        else { return [] }
        
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []
        let startDate = monthFirstWeek.start
        
        var offset = 0
        var shouldContinue = true
        
        while shouldContinue {
            if let date = calendar.date(byAdding: .day, value: offset, to: startDate) {
                currentWeek.append(date)
                
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    
                    if date >= monthLastDay {
                        shouldContinue = false
                    }
                    
                    currentWeek = []
                }
            }
            offset += 1
            
            if offset > 42 {
                shouldContinue = false
            }
        }
        
        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }
        
        return Array(weeks.prefix(5))
    }
}

#Preview {
    MonthGridView(
        currentMonth: Date(),
        selectedDate: Date(),
        events: [],
        todos: [],
        notes: [],
        onDateTap: { _ in }
    )
}

