//
//  MonthView.swift
//  LifePlanner
//

import SwiftUI

struct MonthView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let workspaces: [Workspace]
    
    @State private var showingEventList = false
    @State private var selectedEvent: Event?
    @State private var currentMonthIndex: Int = 0
    @State private var showingMonthYearPicker = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                Button(action: { showingMonthYearPicker = true }) {
                    HStack(spacing: 4) {
                        Text(monthYearString(for: monthsToDisplay[currentMonthIndex]))
                            .font(AppTheme.Fonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.background)
            
            weekdayHeader
            
            // Swipeable month pages
            TabView(selection: $currentMonthIndex) {
                ForEach(Array(monthsToDisplay.enumerated()), id: \.offset) { index, monthDate in
                    SingleMonthView(
                        monthDate: monthDate,
                        selectedDate: $selectedDate,
                        events: events,
                        todos: todos,
                        notes: notes,
                        workspaces: workspaces,
                        onDateTap: { date in
                            selectedDate = date
                            showingEventList = true
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .sheet(isPresented: $showingEventList) {
            EventListSheet(
                date: selectedDate,
                events: eventsForSelectedDate,
                todos: todosForSelectedDate,
                notes: notesForSelectedDate,
                workspaces: workspaces,
                onEventTap: { event in
                    selectedEvent = event
                    showingEventList = false
                }
            )
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(isPresented: $showingMonthYearPicker) {
            MonthYearPickerSheet(
                selectedDate: monthsToDisplay[currentMonthIndex],
                onDateSelected: { newDate in
                    jumpToMonth(newDate)
                    showingMonthYearPicker = false
                }
            )
            .presentationDetents([.height(300)])
        }
        .onAppear {
            // Set initial month to current month
            if let todayIndex = monthsToDisplay.firstIndex(where: { calendar.isDate($0, equalTo: Date(), toGranularity: .month) }) {
                currentMonthIndex = todayIndex
            }
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
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(AppTheme.Colors.background)
    }
    
    // Generate months from 12 months ago to 12 months ahead
    private var monthsToDisplay: [Date] {
        var months: [Date] = []
        let today = Date()
        
        for offset in -12...12 {
            if let monthDate = calendar.date(byAdding: .month, value: offset, to: today) {
                // Get first day of month
                if let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) {
                    months.append(firstDay)
                }
            }
        }
        
        return months
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        withAnimation {
            if currentMonthIndex > 0 {
                currentMonthIndex -= 1
            }
        }
    }
    
    private func nextMonth() {
        withAnimation {
            if currentMonthIndex < monthsToDisplay.count - 1 {
                currentMonthIndex += 1
            }
        }
    }
    
    private func jumpToMonth(_ date: Date) {
        if let index = monthsToDisplay.firstIndex(where: { calendar.isDate($0, equalTo: date, toGranularity: .month) }) {
            withAnimation {
                currentMonthIndex = index
            }
        }
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
}

// Single month view showing all weeks that overlap with the month
struct SingleMonthView: View {
    let monthDate: Date
    @Binding var selectedDate: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let workspaces: [Workspace]
    let onDateTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeksInMonth, id: \.self) { weekStart in
                CalendarWeekRow(
                    weekStart: weekStart,
                    selectedDate: selectedDate,
                    events: events,
                    todos: todos,
                    notes: notes,
                    workspaces: workspaces,
                    onDateTap: onDateTap
                )
            }
            
            Spacer()
        }
    }
    
    // Get all weeks that overlap with this month (including partial weeks)
    private var weeksInMonth: [Date] {
        var weeks: [Date] = []
        
        // Get the first day of the month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else {
            return []
        }
        
        // Get the last day of the month
        guard let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        // Get the start of the week containing the first day of the month
        guard let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthStart)?.start else {
            return []
        }
        
        // Get the start of the week containing the last day of the month
        guard let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthEnd)?.start else {
            return []
        }
        
        // Generate all weeks from first to last
        var currentWeek = firstWeekStart
        while currentWeek <= lastWeekStart {
            weeks.append(currentWeek)
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) else {
                break
            }
            currentWeek = nextWeek
        }
        
        return weeks
    }
}

struct EventListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let workspaces: [Workspace]
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
                                EventRow(event: event, workspaces: workspaces)
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

// Month and Year Picker Sheet
struct MonthYearPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    
    private let calendar = Calendar.current
    private let months = Calendar.current.monthSymbols
    private let years: [Int]
    
    init(selectedDate: Date, onDateSelected: @escaping (Date) -> Void) {
        self.selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        
        let currentYear = Calendar.current.component(.year, from: Date())
        self.years = Array((currentYear - 10)...(currentYear + 10))
        
        _selectedMonth = State(initialValue: Calendar.current.component(.month, from: selectedDate))
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: selectedDate))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month - 1])
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if let newDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1)) {
                            onDateSelected(newDate)
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    MonthView(selectedDate: .constant(Date()), events: [], todos: [], notes: [], workspaces: [])
}

