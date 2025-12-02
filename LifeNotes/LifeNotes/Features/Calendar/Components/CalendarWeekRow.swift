import SwiftUI

struct CalendarWeekRow: View {
    let weekStart: Date
    let selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let workspaces: [Workspace]
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
            .padding(.top, 4)
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
                // Show up to 4 events, then "..." if more
                ForEach(eventsForWeek.prefix(4), id: \.id) { event in
                    eventBar(for: event)
                }
                
                // Show "..." indicator if there are more events
                if eventsForWeek.count > 4 {
                    HStack {
                        Text("...")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    .frame(height: 12)
                }
            }
            .frame(minHeight: 40, maxHeight: 80)
            .padding(.horizontal, 4)
            
            // Subtle divider line between weeks
            Divider()
                .background(AppTheme.Colors.textSecondary.opacity(0.2))
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
                    ZStack {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14, weight: calendar.isDateInToday(date) ? .semibold : .regular))
                            .foregroundColor(
                                calendar.isDate(date, inSameDayAs: selectedDate) ? .white :
                                AppTheme.Colors.textPrimary
                            )
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color(hex: personalColor) : Color.clear)
                            )
                        
                        // Small grey dot for today (if not selected)
                        if calendar.isDateInToday(date) && !calendar.isDate(date, inSameDayAs: selectedDate) {
                            VStack {
                                Spacer()
                                Circle()
                                    .fill(AppTheme.Colors.textSecondary)
                                    .frame(width: 4, height: 4)
                                    .offset(y: -2)
                            }
                            .frame(width: 28, height: 28)
                        }
                    }
                    
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
            if let todo = todosOnDate.first {
                let color = ColorResolver.shared.colorForTodo(
                    todo,
                    workspace: ColorResolver.shared.findWorkspace(id: todo.workspaceId, in: workspaces)
                )
                items.append(("todo", color))
            }
        }
        
        let notesOnDate = notes.filter { note in
            guard let linkedDate = note.linkedDate else { return false }
            return calendar.isDate(linkedDate, inSameDayAs: date)
        }
        if !notesOnDate.isEmpty {
            if let note = notesOnDate.first {
                let color = ColorResolver.shared.colorForNote(
                    note,
                    workspace: ColorResolver.shared.findWorkspace(id: note.workspaceId, in: workspaces)
                )
                items.append(("note", color))
            }
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
        
        // Determine event color using ColorResolver
        let eventColor = ColorResolver.shared.colorHexForEvent(
            event,
            workspace: ColorResolver.shared.findWorkspace(id: event.workspaceId, in: workspaces)
        )
        
        return AnyView(
            GeometryReader { geometry in
                let cellWidth = geometry.size.width / 7
                let xOffset = CGFloat(startIndex) * cellWidth
                let width = CGFloat(endIndex - startIndex + 1) * cellWidth
                
                HStack(spacing: 0) {
                    if !event.isFirstDayOf(dates[startIndex]) {
                        Rectangle()
                            .fill(Color(hex: eventColor))
                            .frame(width: 3)
                    }
                    
                    Text(event.isFirstDayOf(dates[startIndex]) ? event.title : "")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: eventColor))
                    
                    if !event.isLastDayOf(dates[endIndex]) {
                        Rectangle()
                            .fill(Color(hex: eventColor))
                            .frame(width: 3)
                    }
                }
                .frame(width: width, height: 18)
                .cornerRadius(4)
                .offset(x: xOffset)
            }
            .frame(height: 18)
        )
    }
}

