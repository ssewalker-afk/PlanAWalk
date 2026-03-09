//
//  WalkingGoal.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import Foundation

enum GoalType: String, Codable, CaseIterable {
    case steps = "Steps"
    case miles = "Miles"
    case time = "Time"
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .miles: return "map"
        case .time: return "clock"
        }
    }
}

enum WalkingFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case threeTimes = "3x per week"
    case fiveTimes = "5x per week"
    case weekly = "Weekly"
    
    var daysUntilReminder: Int {
        switch self {
        case .daily: return 1
        case .threeTimes: return 2
        case .fiveTimes: return 2
        case .weekly: return 7
        }
    }
}

enum GoalDuration: String, Codable, CaseIterable {
    case day = "1 Day"
    case week = "1 Week"
    case twoWeeks = "2 Weeks"
    case month = "1 Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case year = "1 Year"
    case custom = "Custom"
    
    var days: Int? {
        switch self {
        case .day: return 1
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .year: return 365
        case .custom: return nil
        }
    }
    
    var displayName: String {
        rawValue
    }
}

struct WalkingGoal: Identifiable, Codable {
    var id = UUID()
    var type: GoalType
    var targetValue: Double
    var currentValue: Double = 0
    var frequency: WalkingFrequency
    var startDate: Date
    var endDate: Date
    var duration: GoalDuration
    var customDurationDays: Int?
    var lastWalkDate: Date?
    var isActive: Bool = true
    
    init(id: UUID = UUID(), type: GoalType, targetValue: Double, currentValue: Double = 0, 
         frequency: WalkingFrequency, startDate: Date, duration: GoalDuration, 
         customDurationDays: Int? = nil, lastWalkDate: Date? = nil, isActive: Bool = true) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.frequency = frequency
        self.startDate = startDate
        self.duration = duration
        self.customDurationDays = customDurationDays
        self.lastWalkDate = lastWalkDate
        self.isActive = isActive
        
        // Calculate end date based on duration
        let calendar = Calendar.current
        if duration == .custom, let days = customDurationDays {
            self.endDate = calendar.date(byAdding: .day, value: days, to: startDate) ?? startDate
        } else if let days = duration.days {
            self.endDate = calendar.date(byAdding: .day, value: days, to: startDate) ?? startDate
        } else {
            self.endDate = startDate
        }
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    var isExpired: Bool {
        Date() > endDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
    
    var totalDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
    }
    
    var daysElapsed: Int {
        let calendar = Calendar.current
        let elapsed = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(elapsed, totalDays)
    }
    
    var timeProgress: Double {
        guard totalDays > 0 else { return 0 }
        return min(Double(daysElapsed) / Double(totalDays), 1.0)
    }
    
    var displayValue: String {
        switch type {
        case .steps:
            return "\(Int(currentValue)) / \(Int(targetValue)) steps"
        case .miles:
            return String(format: "%.1f / %.1f miles", currentValue, targetValue)
        case .time:
            return "\(Int(currentValue)) / \(Int(targetValue)) mins"
        }
    }
    
    var displayDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
