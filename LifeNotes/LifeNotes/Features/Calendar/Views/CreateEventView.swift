//
//  CreateEventView.swift
//  LifePlanner
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @StateObject private var viewModel = CalendarViewModel()
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var location = ""
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _startDate = State(initialValue: selectedDate)
        _endDate = State(initialValue: selectedDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace") {
                    Picker("Add to", selection: Binding(
                        get: { workspaceManager.selectedWorkspace?.id ?? "" },
                        set: { newId in
                            if let workspace = workspaceManager.availableWorkspaces.first(where: { $0.id == newId }) {
                                workspaceManager.selectWorkspace(workspace)
                            }
                        }
                    )) {
                        ForEach(workspaceManager.availableWorkspaces) { workspace in
                            HStack {
                                Circle()
                                    .fill(Color(hex: workspace.color))
                                    .frame(width: 8, height: 8)
                                Text(workspace.name)
                            }
                            .tag(workspace.id ?? "")
                        }
                    }
                }
                
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    
                    CollapsibleDatePicker(
                        label: "Starts",
                        date: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute],
                        onChange: { newStart in
                            if newStart > endDate {
                                endDate = newStart.addingTimeInterval(3600)
                            }
                        }
                    )
                    
                    CollapsibleDatePicker(
                        label: "Ends",
                        date: $endDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute],
                        onChange: { newEnd in
                            if newEnd < startDate {
                                endDate = startDate.addingTimeInterval(3600)
                            }
                        }
                    )
                }
                
                Section("Location") {
                    TextField("Location (optional)", text: $location)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        guard let userId = AuthService.shared.currentUser?.id else {
            print("No user ID")
            return
        }
        
        Task {
            if workspaceManager.selectedWorkspace == nil {
                print("No workspace selected")
                return
            }
            
            guard let workspaceId = workspaceManager.selectedWorkspace?.id else {
                print("Still no workspace after creation attempt")
                return
            }
            
            let event = Event(
                workspaceId: workspaceId,
                title: title,
                description: description.isEmpty ? nil : description,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                location: location.isEmpty ? nil : location,
                createdBy: userId
            )
            
            do {
                try await viewModel.createEvent(event)
                print("Event created successfully!")
                dismiss()
            } catch {
                print("Error creating event: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreateEventView(selectedDate: Date())
}

