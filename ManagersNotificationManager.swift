//
//  NotificationManager.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    
    func requestAuthorization() async {
        do {
            isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification authorization: \(isAuthorized)")
        } catch {
            print("Failed to request notification authorization: \(error.localizedDescription)")
        }
    }
    
    func scheduleWalkingReminder(frequency: WalkingFrequency, lastWalkDate: Date?) {
        // Cancel existing reminders
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }
        
        let messages = [
            "Your sneakers are getting lonely! 👟",
            "Time to take those legs for a spin! 🚶‍♀️",
            "The outdoors is calling... and it's been leaving voicemails! 📱",
            "Even your fitness tracker is asking where you've been! ⌚️",
            "Your walking goal misses you! Let's get moving! 💪",
            "A journey of a thousand miles begins with a single step... how about today? 🌟",
            "Breaking news: Your legs still work! Let's use them! 📰",
            "Your walking buddy (me!) thinks you're awesome. Prove me right! 🎉",
            "The perfect weather for a walk is any weather you walk in! 🌤️",
            "Plot twist: You decide to crush that walking goal today! 🎬"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "PlanAWalk Reminder"
        content.body = messages.randomElement() ?? "Time for your walk!"
        content.sound = .default
        
        // Schedule based on last walk date and frequency
        let daysToWait = frequency.daysUntilReminder
        let calendar = Calendar.current
        
        var triggerDate: Date
        if let lastWalk = lastWalkDate {
            triggerDate = calendar.date(byAdding: .day, value: daysToWait, to: lastWalk) ?? Date().addingTimeInterval(86400)
        } else {
            triggerDate = Date().addingTimeInterval(86400) // Tomorrow
        }
        
        // Set time to 10 AM
        var components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 10
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "walkingReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(triggerDate)")
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
