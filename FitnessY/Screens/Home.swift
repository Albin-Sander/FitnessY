//
//  Home.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-07.
//

import SwiftUI

struct Home: View {
     var hkStore = HealthStore()
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                HStack {
                    CardView(healthData: hkStore.stepsy, sfImage: "shoe.fill", text: "Steps Today",color: .orange )
                    CardView(healthData: hkStore.exerciseMin, sfImage: "figure.run", text: "Exercise min today", color: .green)
                }
                CardView(healthData: hkStore.calories, sfImage: "bolt.fill", text: "Calories", color: .red)
            }
        }
        .onAppear {
                  Task {
                      do {
                          try await hkStore.requestAccess()
                          isLoading = false
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

#Preview {
    Home()
}
