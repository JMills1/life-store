//
//  NotificationService.swift
//  LifePlanner
//

import Foundation
import UserNotifications
import FirebaseMessaging
import Combine

#if canImport(UIKit)
import UIKit
#endif

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                #if canImport(UIKit)
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                #endif
            }
            
            return granted
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleEventReminder(for event: Event) {
        guard let eventId = event.id else { return }
        
        for reminder in event.reminders where reminder.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = event.title
            content.body = event.description ?? "Upcoming event"
            content.sound = .default
            
            let triggerDate = event.startDate.addingTimeInterval(-Double(reminder.minutesBefore * 60))
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "\(eventId)-\(reminder.id)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleTodoReminder(for todo: Todo) {
        guard let todoId = todo.id,
              let dueDate = todo.dueDate else { return }
        
        for reminder in todo.reminders where reminder.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = todo.title
            content.body = todo.description ?? "Task due soon"
            content.sound = .default
            
            let triggerDate = dueDate.addingTimeInterval(-Double(reminder.minutesBefore * 60))
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "\(todoId)-\(reminder.id)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelNotifications(for itemId: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(itemId) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM Token: \(token)")
    }
}

