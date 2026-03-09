//
//  GoalManager.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import Foundation
import SwiftUI
import Combine
import HealthKit

@MainActor
class GoalManager: ObservableObject {
    @Published var currentGoal: WalkingGoal?
    @Published var badges: [Badge] = []
    @Published var totalMilesEarned: Double = 0
    @Published var currentStreak: Int = 0
    @Published var walkHistory: [Date] = []
    @Published var newlyEarnedBadge: Badge? = nil
    
    private let healthKitManager: HealthKitManager
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        loadData()
    }
    
    // MARK: - Persistence
    
    private var goalsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("walkingGoal.json")
    }
    
    private var badgesURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("badges.json")
    }
    
    private var statsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("stats.json")
    }
    
    func loadData() {
        // Load goal
        if let data = try? Data(contentsOf: goalsURL),
           let goal = try? JSONDecoder().decode(WalkingGoal.self, from: data) {
            currentGoal = goal
        }
        
        // Load badges
        if let data = try? Data(contentsOf: badgesURL),
           let loadedBadges = try? JSONDecoder().decode([Badge].self, from: data) {
            badges = loadedBadges
        }
        
        // Load stats
        if let data = try? Data(contentsOf: statsURL),
           let stats = try? JSONDecoder().decode(Stats.self, from: data) {
            totalMilesEarned = stats.totalMiles
            currentStreak = stats.currentStreak
            walkHistory = stats.walkHistory
        }
    }
    
    func saveData() {
        // Save goal
        if let goal = currentGoal,
           let data = try? JSONEncoder().encode(goal) {
            try? data.write(to: goalsURL)
        }
        
        // Save badges
        if let data = try? JSONEncoder().encode(badges) {
            try? data.write(to: badgesURL)
        }
        
        // Save stats
        let stats = Stats(totalMiles: totalMilesEarned, currentStreak: currentStreak, walkHistory: walkHistory)
        if let data = try? JSONEncoder().encode(stats) {
            try? data.write(to: statsURL)
        }
    }
    
    // MARK: - Goal Management
    
    func createGoal(type: GoalType, target: Double, frequency: WalkingFrequency) {
        currentGoal = WalkingGoal(
            type: type,
            targetValue: target,
            frequency: frequency,
            startDate: Date()
        )
        saveData()
    }
    
    func updateProgress() async {
        guard let goal = currentGoal else { return }
        
        do {
            let workouts = try await healthKitManager.fetchWalkingWorkouts(
                from: goal.startDate,
                to: Date()
            )
            
            var newValue: Double = 0
            
            switch goal.type {
            case .steps:
                newValue = try await healthKitManager.fetchStepsFromWorkouts(workouts: workouts)
            case .miles:
                newValue = healthKitManager.calculateTotalDistance(from: workouts)
            case .time:
                newValue = healthKitManager.calculateTotalTime(from: workouts)
            }
            
            currentGoal?.currentValue = newValue
            
            // Update last walk date if there are workouts
            if let lastWorkout = workouts.first {
                currentGoal?.lastWalkDate = lastWorkout.endDate
                
                // Update walk history and streak
                updateWalkHistory(with: lastWorkout.endDate)
            }
            
            // Update total miles for badge tracking
            totalMilesEarned += healthKitManager.calculateTotalDistance(from: workouts)
            
            // Check for new badges
            checkForBadges(workouts: workouts)
            
            saveData()
        } catch {
            print("Error updating progress: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Badge System
    
    private func checkForBadges(workouts: [HKWorkout]) {
        // First walk badge
        if workouts.count >= 1 && !hasBadge(.firstWalk) {
            awardBadge(.firstWalk)
        }
        
        // Streak badges
        if currentStreak >= 3 && !hasBadge(.streak3) {
            awardBadge(.streak3)
        }
        if currentStreak >= 7 && !hasBadge(.streak7) {
            awardBadge(.streak7)
        }
        
        // Progress badges (25%, 50%, 75%)
        if let goal = currentGoal {
            let progress = goal.progress
            
            if progress >= 0.25 && !hasBadge(.progress25) {
                awardBadge(.progress25)
            }
            if progress >= 0.50 && !hasBadge(.progress50) {
                awardBadge(.progress50)
            }
            if progress >= 0.75 && !hasBadge(.progress75) {
                awardBadge(.progress75)
            }
            
            // Goal completion badge
            if goal.isCompleted && !hasBadge(.goalComplete) {
                awardBadge(.goalComplete)
            }
        }
        
        // Mileage milestones
        if totalMilesEarned >= 10 && !hasBadge(.milestone10) {
            awardBadge(.milestone10)
        }
        if totalMilesEarned >= 50 && !hasBadge(.milestone50) {
            awardBadge(.milestone50)
        }
        if totalMilesEarned >= 100 && !hasBadge(.milestone100) {
            awardBadge(.milestone100)
        }
        
        // Time-based badges
        for workout in workouts {
            let hour = Calendar.current.component(.hour, from: workout.startDate)
            
            if hour < 8 && !hasBadge(.earlyBird) {
                awardBadge(.earlyBird)
            }
            
            if hour >= 20 && !hasBadge(.nightOwl) {
                awardBadge(.nightOwl)
            }
        }
    }
    
    private func hasBadge(_ type: BadgeType) -> Bool {
        badges.contains { $0.type == type }
    }
    
    private func awardBadge(_ type: BadgeType) {
        let badge = Badge(type: type, earnedDate: Date())
        badges.append(badge)
        newlyEarnedBadge = badge // Set for celebration animation
        saveData()
    }
    
    func clearNewlyEarnedBadge() {
        newlyEarnedBadge = nil
    }
    
    func markBadgeAsViewed(_ badge: Badge) {
        if let index = badges.firstIndex(where: { $0.id == badge.id }) {
            badges[index].isNew = false
            saveData()
        }
    }
    
    // MARK: - Streak Tracking
    
    private func updateWalkHistory(with date: Date) {
        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: date)
        
        if !walkHistory.contains(where: { calendar.isDate($0, inSameDayAs: dateOnly) }) {
            walkHistory.append(dateOnly)
            walkHistory.sort(by: >)
            calculateStreak()
        }
    }
    
    private func calculateStreak() {
        guard !walkHistory.isEmpty else {
            currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today
        
        for walkDate in walkHistory.sorted(by: >) {
            if calendar.isDate(walkDate, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if walkDate < checkDate {
                break
            }
        }
        
        currentStreak = streak
    }
    
    // MARK: - Reminder Messages
    
    func getEncouragementMessage() -> String {
        guard let goal = currentGoal else {
            return "Ready to set a walking goal?"
        }
        
        let daysSinceLastWalk = daysSinceLastWalk()
        
        let messages: [String] = [
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
        
        if daysSinceLastWalk >= goal.frequency.daysUntilReminder {
            return messages.randomElement() ?? messages[0]
        }
        
        return "You're doing great! Keep it up! 🌟"
    }
    
    func daysSinceLastWalk() -> Int {
        guard let lastWalk = currentGoal?.lastWalkDate else { return 999 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: lastWalk, to: Date()).day ?? 999
        return days
    }
}

// Helper struct for stats persistence
private struct Stats: Codable {
    var totalMiles: Double
    var currentStreak: Int
    var walkHistory: [Date]
}
