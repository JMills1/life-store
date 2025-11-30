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
    
    @State private var showingEventList = false
    @State private var selectedEvent: Event?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            weekdayHeader
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(weeksToDisplay.enumerated()), id: \.offset) { index, weekStart in
                            WeekView(
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
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let todayWeekIndex = weeksToDisplay.firstIndex(where: { weekStart in
                            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
                            return Date() >= weekStart && Date() <= weekEnd
                        }) {
                            proxy.scrollTo(todayWeekIndex, anchor: .top)
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
    
    private var weeksToDisplay: [Date] {
        var weeks: [Date] = []
        let today = Date()
        
        guard let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        let startWeek = calendar.date(byAdding: .weekOfYear, value: -26, to: todayWeekStart)!
        
        for offset in 0..<104 {
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: startWeek) {
                weeks.append(weekStart)
            }
        }
        
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
                TodoDetailView(todo: todo)
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

