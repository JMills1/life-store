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
    
    @State private var currentMonth: Date
    @State private var showingEventList = false
    @State private var selectedEvent: Event?
    
    private let calendar = Calendar.current
    
    init(selectedDate: Binding<Date>, events: [Event], todos: [Todo] = [], notes: [Note] = []) {
        self._selectedDate = selectedDate
        self.events = events
        self.todos = todos
        self.notes = notes
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            weekdayHeader
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(monthsToDisplay, id: \.self) { month in
                            MonthGridView(
                                currentMonth: month,
                                selectedDate: selectedDate,
                                events: events,
                                todos: todos,
                                notes: notes,
                                onDateTap: { date in
                                    selectedDate = date
                                    showingEventList = true
                                }
                            )
                            .id(month)
                        }
                    }
                }
                .onAppear {
                    let today = Date()
                    
                    let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: today)?.start ?? today
                    let monthOfWeek = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfWeek))!
                    
                    if let targetMonth = monthsToDisplay.first(where: { 
                        calendar.isDate($0, equalTo: monthOfWeek, toGranularity: .month)
                    }) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(targetMonth, anchor: .top)
                        }
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
    
    private var monthsToDisplay: [Date] {
        var months: [Date] = []
        let today = Date()
        
        let weekOfYear = calendar.component(.weekOfYear, from: today)
        let year = calendar.component(.year, from: today)
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.weekOfYear = weekOfYear
        dateComponents.weekday = 1
        
        guard let startOfWeek = calendar.date(from: dateComponents) else {
            let startMonth = calendar.date(byAdding: .month, value: -6, to: today)!
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startMonth))!
            
            for offset in 0..<24 {
                if let month = calendar.date(byAdding: .month, value: offset, to: startOfMonth) {
                    months.append(month)
                }
            }
            return months
        }
        
        let monthOfWeek = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfWeek))!
        let startMonth = calendar.date(byAdding: .month, value: -6, to: monthOfWeek)!
        
        for offset in 0..<24 {
            if let month = calendar.date(byAdding: .month, value: offset, to: startMonth) {
                months.append(month)
            }
        }
        
        return months
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

struct EventListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let events: [Event]
    let todos: [Todo]
    let notes: [Note]
    let onEventTap: (Event) -> Void
    
    @State private var selectedTodoForEdit: Todo?
    @State private var selectedNoteForEdit: Note?
    
    var body: some View {
        NavigationView {
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
                EditTodoView(todo: todo)
            }
            .sheet(item: $selectedNoteForEdit) { note in
                NoteEditorView(note: note)
            }
        }
    }
}


#Preview {
    MonthView(selectedDate: .constant(Date()), events: [])
}

