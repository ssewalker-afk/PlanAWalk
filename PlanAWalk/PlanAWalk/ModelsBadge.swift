//
//  Badge.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import Foundation
import SwiftUI

enum BadgeType: String, Codable {
    case firstWalk = "First Steps"
    case streak3 = "3 Day Streak"
    case streak7 = "Week Warrior"
    case streak14 = "Two Week Champion"
    case streak30 = "Monthly Master"
    case goalComplete = "Goal Crusher"
    case progress25 = "Quarter Way"
    case progress50 = "Halfway Hero"
    case progress75 = "Almost There"
    case perfectWeek = "Perfect Week"
    case earlyBird = "Early Bird"
    case nightOwl = "Night Owl"
    case speedster = "Speedster"
    case consistent = "Consistency King"
    
    var icon: String {
        switch self {
        case .firstWalk: return "figure.walk.circle.fill"
        case .streak3: return "flame.fill"
        case .streak7: return "star.fill"
        case .streak14: return "sparkles"
        case .streak30: return "crown.fill"
        case .goalComplete: return "trophy.fill"
        case .progress25: return "chart.bar.fill"
        case .progress50: return "chart.bar.fill"
        case .progress75: return "chart.bar.fill"
        case .perfectWeek: return "checkmark.seal.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .speedster: return "hare.fill"
        case .consistent: return "calendar.badge.checkmark"
        }
    }
    
    var color: Color {
        switch self {
        case .firstWalk: return .green
        case .streak3: return .orange
        case .streak7: return .purple
        case .streak14: return .pink
        case .streak30: return .yellow
        case .goalComplete: return .yellow
        case .progress25: return .cyan
        case .progress50: return .mint
        case .progress75: return .teal
        case .perfectWeek: return .green
        case .earlyBird: return .yellow
        case .nightOwl: return .indigo
        case .speedster: return .red
        case .consistent: return .blue
        }
    }
    
    var description: String {
        switch self {
        case .firstWalk: return "Completed your first walk!"
        case .streak3: return "3 days in a row!"
        case .streak7: return "A full week of walking!"
        case .streak14: return "14 days in a row! Incredible!"
        case .streak30: return "30 days in a row! You're unstoppable!"
        case .goalComplete: return "Completed a walking goal!"
        case .progress25: return "You're 25% of the way to your goal!"
        case .progress50: return "You're halfway there! Keep going!"
        case .progress75: return "75% complete! You're almost there!"
        case .perfectWeek: return "Walked every day this week!"
        case .earlyBird: return "Walked before 8 AM!"
        case .nightOwl: return "Walked after 8 PM!"
        case .speedster: return "Completed a walk faster than usual!"
        case .consistent: return "Walked regularly throughout your goal!"
        }
    }
}

struct Badge: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: BadgeType
    var earnedDate: Date
    var isNew: Bool = true
}
