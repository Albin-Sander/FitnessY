//
//  HealthStore.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-07.
//

import Foundation
import HealthKit

@Observable
class HealthStore {
    var stepsy = 0
    var exerciseMin = 0
    var calories = 0

    private let healthStore = HKHealthStore()
    private let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
    private let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!

    func requestAccess() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: [stepType, exerciseType, activeEnergyType]) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    self.fetchData()
                    self.setupObserverQueries()
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Authorization denied."]))
                }
            }
        }
    }

    private func fetchData() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let stepQuery = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { (query, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            print("Steps today: \(steps)")
            self.stepsy = steps
        }

        let exerciseQuery = HKStatisticsQuery(quantityType: exerciseType,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum) { (query, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch exercise minutes: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let exerciseMinutes = Int(sum.doubleValue(for: HKUnit.minute()))
            print("Exercise minutes today: \(exerciseMinutes)")
            self.exerciseMin = exerciseMinutes
        }
        
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
           let activeEnergyQuery = HKStatisticsQuery(quantityType: activeEnergyType,
                                                     quantitySamplePredicate: predicate,
                                                     options: .cumulativeSum) { [self] (query, result, error) in
               guard let result = result, let sum = result.sumQuantity() else {
                   print("Failed to fetch active energy burned: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }

               let activeEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
               print("Active energy burned today: \(activeEnergyBurned) kcal")
               // Store activeEnergyBurned in a property of your class
               calories = Int(activeEnergyBurned)
           }

        healthStore.execute(stepQuery)
        healthStore.execute(exerciseQuery)
        healthStore.execute(activeEnergyQuery)
    }

    private func setupObserverQueries() {
        let stepObserverQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Failed to set up step observer query: \(error.localizedDescription)")
            } else {
                self.fetchData()
                completionHandler()
            }
        }

        let exerciseObserverQuery = HKObserverQuery(sampleType: exerciseType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Failed to set up exercise observer query: \(error.localizedDescription)")
            } else {
                self.fetchData()
                completionHandler()
            }
        }

        healthStore.execute(stepObserverQuery)
        healthStore.execute(exerciseObserverQuery)

        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if let error = error {
                print("Failed to enable background delivery for step count: \(error.localizedDescription)")
            }
        }

        healthStore.enableBackgroundDelivery(for: exerciseType, frequency: .immediate) { success, error in
            if let error = error {
                print("Failed to enable background delivery for exercise time: \(error.localizedDescription)")
            }
        }
    }
}

