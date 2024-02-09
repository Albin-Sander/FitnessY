//
//  WorkoutDataFetcher.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-09.
//

// WorkoutDataFetcher.swift

import Foundation
import HealthKit

struct WorkoutData: Identifiable {
    let id = UUID()
    let duration: Int
    let type: HKWorkoutActivityType
}

class WorkoutDataFetcher {
    private let healthStore: HKHealthStore
    private let workoutType = HKObjectType.workoutType()
    var array = [0]

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func fetchWorkoutsForToday(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout] else {
                completion(nil, error)
                return
            }

            completion(workouts, nil)
        }

        healthStore.execute(workoutQuery)
    }
    
    func workoutTypeToString(_ workoutType: HKWorkoutActivityType) -> String {
        switch workoutType {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        // Add more cases as needed
        default:
            return "Other"
        }
    }
    
    
    func fetchWorkouts() async throws -> [WorkoutData] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchWorkoutsForToday { [self] (workouts, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var workoutData = [WorkoutData]()
                for workout in workouts! {
                    let durationInMinutes = Int(workout.duration / 60)
                    let workoutType = workout.workoutActivityType
                    workoutData.append(WorkoutData(duration: durationInMinutes, type: workoutType))
                }
                continuation.resume(returning: workoutData)
            }
        }
    }
}
