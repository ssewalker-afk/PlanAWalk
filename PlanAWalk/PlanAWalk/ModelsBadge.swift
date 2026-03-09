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
    case goalComplete = "Goal Crusher"
    case progress25 = "Quarter Way"
    case progress50 = "Halfway Hero"
    case progress75 = "Almost There"
    case milestone10 = "10 Miles Club"
    case milestone50 = "50 Miles Club"
    case milestone100 = "Century Walker"
    case milestone500 = "500 Mile Legend"
    case milestone1000 = "1000 Mile Champion"
    case earlyBird = "Early Bird"
    case nightOwl = "Night Owl"
    case speedDemon = "Speed Demon"
    
    var icon: String {
        switch self {
        case .firstWalk: return "figure.walk.circle.fill"
        case .streak3: return "flame.fill"
        case .streak7: return "star.fill"
        case .goalComplete: return "trophy.fill"
        case .progress25: return "chart.bar.fill"
        case .progress50: return "chart.bar.fill"
        case .progress75: return "chart.bar.fill"
        case .milestone10: return "10.circle.fill"
        case .milestone50: return "50.circle.fill"
        case .milestone100: return "100.square.fill"
        case .milestone500: return "star.circle.fill"
        case .milestone1000: return "crown.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .speedDemon: return "hare.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstWalk: return .green
        case .streak3: return .orange
        case .streak7: return .purple
        case .goalComplete: return .yellow
        case .progress25: return .cyan
        case .progress50: return .mint
        case .progress75: return .teal
        case .milestone10: return .blue
        case .milestone50: return .indigo
        case .milestone100: return .pink
        case .milestone500: return .purple
        case .milestone1000: return .yellow
        case .earlyBird: return .yellow
        case .nightOwl: return .indigo
        case .speedDemon: return .red
        }
    }
    
    var description: String {
        switch self {
        case .firstWalk: return "Completed your first walk!"
        case .streak3: return "3 days in a row!"
        case .streak7: return "A full week of walking!"
        case .goalComplete: return "Completed a walking goal!"
        case .progress25: return "You're 25% of the way to your goal!"
        case .progress50: return "You're halfway there! Keep going!"
        case .progress75: return "75% complete! You're almost there!"
        case .milestone10: return "Walked 10 total miles!"
        case .milestone50: return "Walked 50 total miles!"
        case .milestone100: return "Walked 100 total miles!"
        case .milestone500: return "Walked 500 total miles! Legendary!"
        case .milestone1000: return "Walked 1000 total miles! Champion!"
        case .earlyBird: return "Walked before 8 AM!"
        case .nightOwl: return "Walked after 8 PM!"
        case .speedDemon: return "Fastest walk yet!"
        }
    }
}

struct Badge: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: BadgeType
    var earnedDate: Date
    var isNew: Bool = true
}
