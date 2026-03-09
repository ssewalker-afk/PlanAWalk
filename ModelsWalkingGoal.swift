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

struct WalkingGoal: Identifiable, Codable {
    var id = UUID()
    var type: GoalType
    var targetValue: Double
    var currentValue: Double = 0
    var frequency: WalkingFrequency
    var startDate: Date
    var lastWalkDate: Date?
    var isActive: Bool = true
    
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
}
