//
//  Workouts.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-09.
//

import SwiftUI
import HealthKit

struct Workouts: View {
    var hkStore: HealthStore
    var WorkOutFetcher: WorkoutDataFetcher {
        WorkoutDataFetcher(healthStore: hkStore.healthStore)
    }
    @State private var array = [WorkoutData]()

    @State private var isLoading = true
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                ForEach(array) { workout in
                    VStack(alignment: .leading) {
                        Text("Duration: \(workout.duration) minutes")
                        Text("Type: \(WorkOutFetcher.workoutTypeToString(workout.type))")
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let workoutData = try await WorkOutFetcher.fetchWorkouts()
                    array = workoutData
                  isLoading = false
                } catch {
                    print("Failed to fetch workouts: \(error)")
                }
            }
        }
    }
}
