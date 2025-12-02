//
//  DayView.swift
//  LifePlanner
//

import SwiftUI

struct DayView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    let workspaces: [Workspace]
    @State private var selectedEvent: Event?
    @State private var showingDatePicker = false
    @State private var currentDayIndex: Int = 0
    
    private let calendar = Calendar.current
    
    // Generate 60 days: 30 days back, today, 29 days forward
    private var daysToDisplay: [Date] {
        var days: [Date] = []
        let today = Date()
        
        for offset in -30...29 {
            if let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today)) {
                days.append(day)
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            daySelector
            
            // Swipeable day pages
            TabView(selection: $currentDayIndex) {
                ForEach(Array(daysToDisplay.enumerated()), id: \.offset) { index, day in
                    SingleDayView(
                        date: day,
                        events: eventsForDate(day),
                        workspaces: workspaces,
                        onEventTap: { event in
                            selectedEvent = event
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentDayIndex) { oldValue, newValue in
                selectedDate = daysToDisplay[newValue]
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                selectedDate: selectedDate,
                onDateSelected: { newDate in
                    jumpToDate(newDate)
                    showingDatePicker = false
                }
            )
            .presentationDetents([.height(400)])
        }
        .onAppear {
            // Set initial day to selected date
            if let todayIndex = daysToDisplay.firstIndex(where: { calendar.isDate($0, inSameDayAs: selectedDate) }) {
                currentDayIndex = todayIndex
            }
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
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
            
            Button(action: { showingDatePicker = true }) {
                HStack(spacing: 4) {
                    Text(selectedDate, format: .dateTime.month().day().weekday(.wide))
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
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
        withAnimation {
            if currentDayIndex > 0 {
                currentDayIndex -= 1
            }
        }
    }
    
    private func nextDay() {
        withAnimation {
            if currentDayIndex < daysToDisplay.count - 1 {
                currentDayIndex += 1
            }
        }
    }
    
    private func jumpToDate(_ date: Date) {
        if let index = daysToDisplay.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            withAnimation {
                currentDayIndex = index
            }
        } else {
            // If date is outside range, just update selectedDate
            selectedDate = calendar.startOfDay(for: date)
        }
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { $0.spansDate(date) }
    }
}

// Single day view showing hourly schedule
struct SingleDayView: View {
    let date: Date
    let events: [Event]
    let workspaces: [Workspace]
    let onEventTap: (Event) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !allDayEvents.isEmpty {
                    allDayEventsSection
                }
                
                LazyVStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Text(String(format: "%02d:00", hour))
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .frame(width: 50)
                            
                            VStack(spacing: 4) {
                                ForEach(timedEventsForHour(hour)) { event in
                                    Button(action: { onEventTap(event) }) {
                                        EventRow(event: event, workspaces: workspaces)
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
                        Button(action: { onEventTap(event) }) {
                            Text(event.title)
                                .font(AppTheme.Fonts.caption1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(ColorResolver.shared.colorForEvent(event, workspace: ColorResolver.shared.findWorkspace(id: event.workspaceId, in: workspaces)))
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
        events.filter { $0.isAllDay }
    }
    
    private var timedEvents: [Event] {
        events.filter { !$0.isAllDay }
    }
    
    private func timedEventsForHour(_ hour: Int) -> [Event] {
        timedEvents.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
}

// Date Picker Sheet for Day View
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    @State private var pickedDate: Date
    
    init(selectedDate: Date, onDateSelected: @escaping (Date) -> Void) {
        self.selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        _pickedDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $pickedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDateSelected(pickedDate)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    DayView(selectedDate: .constant(Date()), events: [], workspaces: [])
}

