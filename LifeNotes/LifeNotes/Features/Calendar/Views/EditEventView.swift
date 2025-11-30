//
//  EditEventView.swift
//  LifePlanner
//

import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CalendarViewModel()
    
    let event: Event
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var location: String
    @State private var showingDeleteAlert = false
    
    init(event: Event) {
        self.event = event
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description ?? "")
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    DatePicker("Starts", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                        .onChange(of: startDate) { oldValue, newStart in
                            if newStart > endDate {
                                endDate = newStart.addingTimeInterval(3600)
                            }
                        }
                    DatePicker("Ends", selection: $endDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                        .onChange(of: endDate) { oldValue, newEnd in
                            if newEnd < startDate {
                                endDate = startDate.addingTimeInterval(3600)
                            }
                        }
                }
                
                Section("Location") {
                    TextField("Location (optional)", text: $location)
                }
                
                Section {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Delete Event")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Delete Event", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteEvent()
                }
            } message: {
                Text("Are you sure you want to delete this event?")
            }
        }
    }
    
    private func saveChanges() {
        var updatedEvent = event
        updatedEvent.title = title
        updatedEvent.description = description.isEmpty ? nil : description
        updatedEvent.startDate = startDate
        updatedEvent.endDate = endDate
        updatedEvent.isAllDay = isAllDay
        updatedEvent.location = location.isEmpty ? nil : location
        updatedEvent.updatedAt = Date()
        
        Task {
            do {
                try await viewModel.updateEvent(updatedEvent)
                print("Event updated successfully")
                dismiss()
            } catch {
                print("Error updating event: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteEvent() {
        Task {
            do {
                try await viewModel.deleteEvent(event)
                print("Event deleted successfully")
                dismiss()
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EditEventView(event: Event(
        workspaceId: "test",
        title: "Team Meeting",
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600),
        createdBy: "user1"
    ))
}

