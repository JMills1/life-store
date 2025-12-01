import SwiftUI

struct CalendarWeekRow: View {
    let weekStart: Date
    let selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let onDateTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                        dayCell(for: date)
                    }
                }
            }
            .frame(height: 60)
            .overlay(alignment: .bottom) {
                if let monthBoundaryIndex = monthBoundaryDayIndex {
                    GeometryReader { geometry in
                        let cellWidth = geometry.size.width / 7
                        let xPosition = CGFloat(monthBoundaryIndex) * cellWidth
                        let personalColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
                        
                        Path { path in
                            // Start at bottom left
                            path.move(to: CGPoint(x: 0, y: geometry.size.height))
                            // Go to the boundary position at bottom
                            path.addLine(to: CGPoint(x: xPosition, y: geometry.size.height))
                            // Go up to top at boundary
                            path.addLine(to: CGPoint(x: xPosition, y: 0))
                            // Go to top right
                            path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        }
                        .stroke(Color(hex: personalColor).opacity(0.5), lineWidth: 2)
                    }
                }
            }
            
            VStack(spacing: 2) {
                ForEach(eventsForWeek.prefix(3), id: \.id) { event in
                    eventBar(for: event)
                }
            }
            .frame(height: 30)
            .padding(.horizontal, 4)
        }
    }
    
    private var monthBoundaryDayIndex: Int? {
        for (index, date) in weekDates.enumerated() {
            if calendar.component(.day, from: date) == 1 {
                return index
            }
        }
        return nil
    }
    
    private func dayCell(for date: Date) -> some View {
        let personalColor = AuthService.shared.currentUser?.preferences.personalColor ?? "EF5350"
        let itemsForDate = itemsForDate(date)
        let isFirstOfMonth = calendar.component(.day, from: date) == 1
        
        return Button(action: { onDateTap(date) }) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 2) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 14, weight: calendar.isDateInToday(date) ? .bold : .regular))
                        .foregroundColor(
                            calendar.isDate(date, inSameDayAs: selectedDate) ? .white :
                            calendar.isDateInToday(date) ? Color(hex: personalColor) :
                            AppTheme.Colors.textPrimary
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
                
                if isFirstOfMonth {
                    Text(date.formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 8))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, 2)
                        .padding(.trailing, 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func itemsForDate(_ date: Date) -> [(type: String, color: Color)] {
        var items: [(type: String, color: Color)] = []
        
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
    
    private var weekDates: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    private var eventsForWeek: [Event] {
        let dates = weekDates
        guard let firstDate = dates.first,
              let lastDate = dates.last else {
            return []
        }
        
        return events.filter { event in
            event.startDate <= lastDate && event.endDate >= firstDate
        }
    }
    
    private func eventBar(for event: Event) -> some View {
        let dates = weekDates
        guard let firstDate = dates.first,
              let lastDate = dates.last else {
            return AnyView(EmptyView())
        }
        
        let eventStart = max(event.startDate, firstDate)
        let eventEnd = min(event.endDate, lastDate)
        
        let startIndex = dates.firstIndex { calendar.isDate($0, inSameDayAs: eventStart) || $0 > eventStart } ?? 0
        let endIndex = dates.lastIndex { calendar.isDate($0, inSameDayAs: eventEnd) || $0 < eventEnd } ?? 6
        
        return AnyView(
            GeometryReader { geometry in
                let cellWidth = geometry.size.width / 7
                let xOffset = CGFloat(startIndex) * cellWidth
                let width = CGFloat(endIndex - startIndex + 1) * cellWidth
                
                HStack(spacing: 0) {
                    if !event.isFirstDayOf(dates[startIndex]) {
                        Rectangle()
                            .fill(Color(hex: event.color ?? "4CAF50"))
                            .frame(width: 3)
                    }
                    
                    Text(event.isFirstDayOf(dates[startIndex]) ? event.title : "")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: event.color ?? "4CAF50"))
                    
                    if !event.isLastDayOf(dates[endIndex]) {
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
}

