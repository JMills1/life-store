//
//  NotificationSettingsView.swift
//  LifePlanner
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var eventReminders = true
    @State private var todoReminders = true
    @State private var sharedUpdates = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
            }
            
            if notificationsEnabled {
                Section("Remind me about") {
                    Toggle("Events", isOn: $eventReminders)
                    Toggle("Tasks", isOn: $todoReminders)
                    Toggle("Shared Updates", isOn: $sharedUpdates)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NotificationSettingsView()
}

