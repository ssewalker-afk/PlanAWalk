//
//  HealthKitManager.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let typesToRead: Set<HKObjectType> = [workoutType, distanceType, stepsType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            print("HealthKit authorization granted")
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            isAuthorized = false
        }
    }
    
    // Fetch only indoor and outdoor walking workouts
    func fetchWalkingWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        let workoutType = HKObjectType.workoutType()
        
        // Predicate for indoor and outdoor walking
        let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [walkingPredicate, datePredicate])
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: compound, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    // Calculate total steps from walking workouts
    func fetchStepsFromWorkouts(workouts: [HKWorkout]) async throws -> Double {
        var totalSteps = 0.0
        
        // Try to get steps from workout statistics first
        for workout in workouts {
            if let stepsQuantity = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .stepCount)!)?.sumQuantity() {
                totalSteps += stepsQuantity.doubleValue(for: .count())
            }
        }
        
        // If no steps found in workout statistics, fall back to querying step samples during workout times
        if totalSteps == 0 && !workouts.isEmpty {
            guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                return 0
            }
            
            for workout in workouts {
                let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
                
                let steps = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                    let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                        continuation.resume(returning: steps)
                    }
                    
                    healthStore.execute(query)
                }
                
                totalSteps += steps
            }
        }
        
        return totalSteps
    }
    
    // Calculate total distance from workouts in miles
    func calculateTotalDistance(from workouts: [HKWorkout]) -> Double {
        let totalMeters = workouts.reduce(0.0) { sum, workout in
            sum + (workout.totalDistance?.doubleValue(for: .meter()) ?? 0)
        }
        // Convert meters to miles
        return totalMeters * 0.000621371
    }
    
    // Query HealthKit for all walking workouts and calculate total miles
    // Returns total distance rounded to 1 decimal place
    func fetchTotalWalkingMiles(from startDate: Date = .distantPast, to endDate: Date = Date()) async -> Double {
        do {
            // Query HealthKit for all walking workouts (HKWorkoutActivityType.walking)
            let walkingWorkouts = try await fetchWalkingWorkouts(from: startDate, to: endDate)
            
            // Sum the totalDistance property from each workout
            var totalMiles = 0.0
            for workout in walkingWorkouts {
                if let distance = workout.totalDistance {
                    // Convert from meters to miles
                    let miles = distance.doubleValue(for: .mile())
                    totalMiles += miles
                }
            }
            
            // Round to 1 decimal place
            return (totalMiles * 10).rounded() / 10
        } catch {
            print("Error fetching total walking miles: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    // Calculate total time in minutes
    func calculateTotalTime(from workouts: [HKWorkout]) -> Double {
        let totalSeconds = workouts.reduce(0.0) { sum, workout in
            sum + workout.duration
        }
        return totalSeconds / 60.0
    }
    
    // Calculate total time in hours
    func calculateTotalHours(from workouts: [HKWorkout]) -> Double {
        let totalSeconds = workouts.reduce(0.0) { sum, workout in
            sum + workout.duration
        }
        return totalSeconds / 3600.0 // Convert seconds to hours
    }
    
    // Fetch lifetime steps from all walking workouts
    func fetchLifetimeSteps() async -> Double {
        print("🔍 Starting fetchLifetimeSteps...")
        
        do {
            let allWorkouts = try await fetchWalkingWorkouts(from: .distantPast, to: Date())
            print("📊 Found \(allWorkouts.count) walking workouts")
            
            let totalSteps = try await fetchStepsFromWorkouts(workouts: allWorkouts)
            print("👣 Steps from workouts: \(totalSteps)")
            
            // If workouts don't have step data, try getting total step count directly
            if totalSteps == 0 {
                print("⚠️ No steps from workouts, trying total step count...")
                let directSteps = await fetchTotalStepCount(from: .distantPast, to: Date())
                print("👣 Direct step count: \(directSteps)")
                return directSteps
            }
            
            return totalSteps
        } catch {
            print("❌ Error fetching lifetime steps: \(error.localizedDescription)")
            // Even if workouts fail, try to get total step count
            let fallbackSteps = await fetchTotalStepCount(from: .distantPast, to: Date())
            print("👣 Fallback step count: \(fallbackSteps)")
            return fallbackSteps
        }
    }
    
    // Fetch total step count for a date range (not limited to workouts)
    func fetchTotalStepCount(from startDate: Date, to endDate: Date) async -> Double {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("❌ Could not create step count quantity type")
            return 0
        }
        
        // Use a reasonable start date if distantPast is provided (HealthKit might not like it)
        let effectiveStartDate = startDate == .distantPast 
            ? Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? startDate
            : startDate
        
        print("📅 Querying steps from \(effectiveStartDate) to \(endDate)")
        
        let predicate = HKQuery.predicateForSamples(withStart: effectiveStartDate, end: endDate, options: .strictStartDate)
        
        do {
            let steps = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                    if let error = error {
                        print("❌ HKStatisticsQuery error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    print("📊 Query returned \(steps) steps")
                    continuation.resume(returning: steps)
                }
                
                healthStore.execute(query)
            }
            
            return steps
        } catch {
            print("❌ Error fetching total step count: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    // Fetch lifetime hours from all walking workouts
    func fetchLifetimeHours() async -> Double {
        do {
            let allWorkouts = try await fetchWalkingWorkouts(from: .distantPast, to: Date())
            let totalHours = calculateTotalHours(from: allWorkouts)
            return (totalHours * 10).rounded() / 10 // Round to 1 decimal place
        } catch {
            print("Error fetching lifetime hours: \(error.localizedDescription)")
            return 0.0
        }
    }
}
