//
//  MonthView.swift
//  LifePlanner
//

import SwiftUI

struct VisibleWeekPreferenceKey: PreferenceKey {
    static var defaultValue: Date?
    
    static func reduce(value: inout Date?, nextValue: () -> Date?) {
        if value == nil {
            value = nextValue()
        }
    }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    
    @State private var showingEventList = false
    @State private var selectedEvent: Event?
    @State private var currentVisibleMonth: String = ""
    @State private var hasScrolledToInitialPosition = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            if !currentVisibleMonth.isEmpty {
                HStack {
                    Text(currentVisibleMonth)
                        .font(AppTheme.Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    Spacer()
                }
                .background(AppTheme.Colors.background)
            }
            
            weekdayHeader
            
            ScrollViewReader { proxy in
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(weeksToDisplay.enumerated()), id: \.offset) { index, weekStart in
                                CalendarWeekRow(
                                    weekStart: weekStart,
                                    selectedDate: selectedDate,
                                    events: events,
                                    todos: todos,
                                    notes: notes,
                                    onDateTap: { date in
                                        selectedDate = date
                                        showingEventList = true
                                    }
                                )
                                .id(index)
                                .background(
                                    GeometryReader { itemGeometry in
                                        Color.clear.preference(
                                            key: VisibleWeekPreferenceKey.self,
                                            value: itemGeometry.frame(in: .named("scroll")).minY < 100 && itemGeometry.frame(in: .named("scroll")).maxY > 0 ? weekStart : nil
                                        )
                                    }
                                )
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(VisibleWeekPreferenceKey.self) { weekStart in
                        if let weekStart = weekStart {
                            updateVisibleMonth(for: weekStart)
                        }
                    }
                }
                .onAppear {
                    if !hasScrolledToInitialPosition {
                        scrollToToday(proxy: proxy)
                        hasScrolledToInitialPosition = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEventList) {
            EventListSheet(
                date: selectedDate,
                events: eventsForSelectedDate,
                todos: todosForSelectedDate,
                notes: notesForSelectedDate,
                onEventTap: { event in
                    selectedEvent = event
                    showingEventList = false
                }
            )
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(AppTheme.Fonts.caption2)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.background)
    }
    
    private var weeksToDisplay: [Date] {
        var weeks: [Date] = []
        let today = Date()
        
        print("🗓️ Today's date: \(today.formatted(date: .long, time: .omitted))")
        
        guard let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            print("🔴 Failed to get week start for today")
            return []
        }
        
        print("🗓️ Today's week starts: \(todayWeekStart.formatted(date: .long, time: .omitted))")
        
        let startWeek = calendar.date(byAdding: .weekOfYear, value: -26, to: todayWeekStart)!
        print("🗓️ Calendar starts from: \(startWeek.formatted(date: .long, time: .omitted))")
        
        for offset in 0..<104 {
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: startWeek) {
                weeks.append(weekStart)
            }
        }
        
        print("🗓️ Generated \(weeks.count) weeks")
        print("🗓️ First week: \(weeks.first?.formatted(date: .long, time: .omitted) ?? "none")")
        print("🗓️ Last week: \(weeks.last?.formatted(date: .long, time: .omitted) ?? "none")")
        
        return weeks
    }
    
    private var eventsForSelectedDate: [Event] {
        events.filter { $0.spansDate(selectedDate) }
    }
    
    private var todosForSelectedDate: [Todo] {
        todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }
    
    private var notesForSelectedDate: [Note] {
        notes.filter { note in
            guard let linkedDate = note.linkedDate else { return false }
            return calendar.isDate(linkedDate, inSameDayAs: selectedDate)
        }
    }
    
    private func scrollToToday(proxy: ScrollViewProxy) {
        let today = Date()
        
        guard let todayWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return
        }
        
        for (index, weekStart) in weeksToDisplay.enumerated() {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else { continue }
            
            if calendar.isDate(todayWeekInterval.start, equalTo: weekInterval.start, toGranularity: .day) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(index, anchor: .top)
                }
                return
            }
        }
    }
    
    private func updateVisibleMonth(for weekStart: Date) {
        let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        
        if let firstDayOfMonth = weekDates.first(where: { calendar.component(.day, from: $0) == 1 }) {
            let monthYear = firstDayOfMonth.formatted(.dateTime.month(.wide).year())
            if currentVisibleMonth != monthYear {
                currentVisibleMonth = monthYear
            }
        } else if let middleDate = weekDates.first {
            let monthYear = middleDate.formatted(.dateTime.month(.wide).year())
            if currentVisibleMonth != monthYear {
                currentVisibleMonth = monthYear
            }
        }
    }
}

struct EventListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let onEventTap: (Event) -> Void
    
    @State private var selectedTodoForEdit: Todo?
    @State private var selectedNoteForEdit: Note?
    @State private var showingCreateEvent = false
    @State private var showingCreateTodo = false
    @State private var showingCreateNote = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                if !events.isEmpty {
                    Section("Events") {
                        ForEach(events) { event in
                            Button(action: { onEventTap(event) }) {
                                EventRow(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if !todos.isEmpty {
                    Section("To Do") {
                        ForEach(todos) { todo in
                            Button(action: { selectedTodoForEdit = todo }) {
                                HStack(spacing: 12) {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                                    
                                    Text(todo.title)
                                        .font(AppTheme.Fonts.body)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                        .strikethrough(todo.isCompleted)
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if !notes.isEmpty {
                    Section("Notes") {
                        ForEach(notes) { note in
                            Button(action: { selectedNoteForEdit = note }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "note.text")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(note.title)
                                            .font(AppTheme.Fonts.body)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        if !note.preview.isEmpty {
                                            Text(note.preview)
                                                .font(AppTheme.Fonts.caption1)
                                                .foregroundColor(AppTheme.Colors.textSecondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                    if events.isEmpty && todos.isEmpty && notes.isEmpty {
                        Text("No events, tasks, or notes on this day")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .sheet(item: $selectedTodoForEdit) { todo in
                    TodoDetailView(todo: todo)
                }
                .sheet(item: $selectedNoteForEdit) { note in
                    NoteEditorView(note: note)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        QuickAddButtonForSheet(
                            selectedDate: date,
                            showingCreateEvent: $showingCreateEvent,
                            showingCreateTodo: $showingCreateTodo,
                            showingCreateNote: $showingCreateNote
                        )
                        .padding()
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView(selectedDate: date)
            }
            .sheet(isPresented: $showingCreateTodo) {
                CreateTodoView(prefilledDueDate: date)
            }
            .sheet(isPresented: $showingCreateNote) {
                NoteEditorView(note: nil, prefilledDate: date)
            }
        }
    }
}

struct QuickAddButtonForSheet: View {
    let selectedDate: Date
    @Binding var showingCreateEvent: Bool
    @Binding var showingCreateTodo: Bool
    @Binding var showingCreateNote: Bool
    
    @State private var showingOptions = false
    
    var body: some View {
        ZStack {
            if showingOptions {
                VStack(spacing: AppTheme.Spacing.md) {
                    Spacer()
                    
                    QuickAddOption(
                        icon: "calendar.badge.plus",
                        title: "Event",
                        color: AppTheme.Colors.primary
                    ) {
                        showingCreateEvent = true
                        showingOptions = false
                    }
                    
                    QuickAddOption(
                        icon: "checklist",
                        title: "Task",
                        color: AppTheme.Colors.secondary
                    ) {
                        showingCreateTodo = true
                        showingOptions = false
                    }
                    
                    QuickAddOption(
                        icon: "note.text.badge.plus",
                        title: "Note",
                        color: AppTheme.Colors.accent
                    ) {
                        showingCreateNote = true
                        showingOptions = false
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if !showingOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingOptions = true
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(AppTheme.Colors.personalColor)
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    MonthView(selectedDate: .constant(Date()), events: [], todos: [], notes: [])
}

