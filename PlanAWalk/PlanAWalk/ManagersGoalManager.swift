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
    @Published var totalMilesEarned: Double = 0 // Miles for current goal period
    @Published var lifetimeMiles: Double = 0 // All-time miles for badges and display
    @Published var lifetimeSteps: Double = 0 // All-time steps
    @Published var lifetimeHours: Double = 0 // All-time hours walking
    @Published var totalSteps: Double = 0 // Total steps for current goal period
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
            lifetimeMiles = stats.lifetimeMiles
            lifetimeSteps = stats.lifetimeSteps
            lifetimeHours = stats.lifetimeHours
            totalSteps = stats.totalSteps
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
        let stats = Stats(
            totalMiles: totalMilesEarned,
            lifetimeMiles: lifetimeMiles,
            lifetimeSteps: lifetimeSteps,
            lifetimeHours: lifetimeHours,
            totalSteps: totalSteps,
            currentStreak: currentStreak,
            walkHistory: walkHistory
        )
        if let data = try? JSONEncoder().encode(stats) {
            try? data.write(to: statsURL)
        }
    }
    
    // MARK: - Goal Management
    
    func createGoal(type: GoalType, target: Double, frequency: WalkingFrequency, 
                   startDate: Date = Date(), duration: GoalDuration = .week, 
                   customDurationDays: Int? = nil) {
        currentGoal = WalkingGoal(
            type: type,
            targetValue: target,
            frequency: frequency,
            startDate: startDate,
            duration: duration,
            customDurationDays: customDurationDays
        )
        saveData()
    }
    
    func updateGoal(type: GoalType, target: Double, frequency: WalkingFrequency, 
                   startDate: Date, duration: GoalDuration, customDurationDays: Int?) {
        guard var goal = currentGoal else { return }
        
        goal.type = type
        goal.targetValue = target
        goal.frequency = frequency
        goal.startDate = startDate
        goal.duration = duration
        goal.customDurationDays = customDurationDays
        
        // Recalculate current value based on new dates if needed
        currentGoal = goal
        saveData()
        
        // Refresh progress with new goal parameters
        Task {
            await updateProgress()
        }
    }
    
    func deleteCurrentGoal() {
        currentGoal = nil
        
        // Delete the goal file
        try? FileManager.default.removeItem(at: goalsURL)
        
        // Keep badges and stats, just clear the current goal
        saveData()
    }
    
    func updateProgress() async {
        guard let goal = currentGoal else {
            // Even without a goal, we can update lifetime stats
            await updateLifetimeMiles()
            await updateLifetimeStats()
            saveData()
            return
        }
        
        do {
            // Fetch workouts for the current goal period
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
            
            // Calculate total lifetime miles (for badges and lifetime display)
            await updateLifetimeMiles()
            
            // Calculate goal period miles (for current goal card)
            await updateGoalPeriodMiles()
            
            // Calculate total steps for the goal period
            totalSteps = try await healthKitManager.fetchStepsFromWorkouts(workouts: workouts)
            
            // Calculate lifetime stats
            await updateLifetimeStats()
            
            // Check for new badges
            checkForBadges(workouts: workouts)
            
            saveData()
        } catch {
            print("Error updating progress: \(error.localizedDescription)")
        }
    }
    
    private func updateLifetimeMiles() async {
        // Query HealthKit for ALL walking workouts from all time
        // This is used for milestone badges and lifetime display
        lifetimeMiles = await healthKitManager.fetchTotalWalkingMiles(from: .distantPast)
    }
    
    private func updateGoalPeriodMiles() async {
        // Query HealthKit for walking workouts within the current goal period only
        // This is used for the "Total Miles" card on the dashboard
        let startDate = currentGoal?.startDate ?? Date.distantPast
        totalMilesEarned = await healthKitManager.fetchTotalWalkingMiles(from: startDate)
    }
    
    private func updateLifetimeStats() async {
        // Calculate lifetime steps and hours from all walking workouts
        print("🔄 updateLifetimeStats called")
        lifetimeSteps = await healthKitManager.fetchLifetimeSteps()
        print("✅ Lifetime steps updated: \(lifetimeSteps)")
        lifetimeHours = await healthKitManager.fetchLifetimeHours()
        print("✅ Lifetime hours updated: \(lifetimeHours)")
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
        if currentStreak >= 14 && !hasBadge(.streak14) {
            awardBadge(.streak14)
        }
        if currentStreak >= 30 && !hasBadge(.streak30) {
            awardBadge(.streak30)
        }
        
        // Perfect week badge (walked 7 days in a row)
        if currentStreak >= 7 && !hasBadge(.perfectWeek) {
            awardBadge(.perfectWeek)
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
            
            // Consistency badge - walked at least 50% of days in goal
            if goal.daysElapsed >= 7 {
                let walkedDaysInGoal = walkHistory.filter { walkDate in
                    walkDate >= goal.startDate && walkDate <= Date()
                }.count
                
                let consistencyRate = Double(walkedDaysInGoal) / Double(goal.daysElapsed)
                if consistencyRate >= 0.5 && !hasBadge(.consistent) {
                    awardBadge(.consistent)
                }
            }
        }
        
        // Time-based badges (earned once per goal)
        for workout in workouts {
            let hour = Calendar.current.component(.hour, from: workout.startDate)
            
            if hour < 8 && !hasBadge(.earlyBird) {
                awardBadge(.earlyBird)
            }
            
            if hour >= 20 && !hasBadge(.nightOwl) {
                awardBadge(.nightOwl)
            }
        }
        
        // Speedster badge - for faster than average walks
        if workouts.count > 1 {
            let distances = workouts.compactMap { $0.totalDistance?.doubleValue(for: .meter()) }
            let durations = workouts.map { $0.duration }
            
            if !distances.isEmpty && !durations.isEmpty {
                let speeds = zip(distances, durations).map { distance, duration in
                    distance / duration // meters per second
                }
                
                if let avgSpeed = speeds.reduce(0, +) / Double(speeds.count) as Double?,
                   let maxSpeed = speeds.max(),
                   maxSpeed > avgSpeed * 1.3 && !hasBadge(.speedster) {
                    awardBadge(.speedster)
                }
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
    var lifetimeMiles: Double
    var lifetimeSteps: Double
    var lifetimeHours: Double
    var totalSteps: Double
    var currentStreak: Int
    var walkHistory: [Date]
}
