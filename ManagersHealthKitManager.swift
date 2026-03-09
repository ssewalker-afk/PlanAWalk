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
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        var totalSteps = 0.0
        
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
        
        return totalSteps
    }
    
    // Calculate total distance from workouts
    func calculateTotalDistance(from workouts: [HKWorkout]) -> Double {
        let totalMeters = workouts.reduce(0.0) { sum, workout in
            sum + (workout.totalDistance?.doubleValue(for: .meter()) ?? 0)
        }
        // Convert meters to miles
        return totalMeters * 0.000621371
    }
    
    // Calculate total time in minutes
    func calculateTotalTime(from workouts: [HKWorkout]) -> Double {
        let totalSeconds = workouts.reduce(0.0) { sum, workout in
            sum + workout.duration
        }
        return totalSeconds / 60.0
    }
}
