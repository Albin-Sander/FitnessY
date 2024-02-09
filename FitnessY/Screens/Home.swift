//
//  Home.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-07.
//

import SwiftUI

struct Home: View {
    var hkStore: HealthStore
    @State private var isLoading = true
    @State private var progress = 0.0

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                CircleView(progress: Double(hkStore.exerciseMin) / Double(hkStore.exerciseMinGoal))
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 50)
                HStack {
                    CardView(healthData: hkStore.stepsy, sfImage: "shoe.fill", text: "Steps", color: .orange)
                    CardView(healthData: hkStore.exerciseMin, sfImage: "figure.run", text: "Exercise min", color: .lightGreen)
                }
                HStack {
                    CardView(healthData: hkStore.standHour, sfImage: "figure.stand", text: "Stand hours", color: .lightBlue)
                    CardView(healthData: hkStore.calories, sfImage: "bolt.fill", text: "Calories", color: .trainingRed)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await hkStore.requestAccess()
                    isLoading = false
                    progress = Double(hkStore.exerciseMin) / Double(hkStore.exerciseMinGoal)
                } catch {
                    print("Error requesting authorization: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                do {
                    try await hkStore.requestAccess()
                    isLoading = false
                } catch {
                    print("Error requesting authorization: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let hkStore = HealthStore()
        Home(hkStore: hkStore)
    }
}
