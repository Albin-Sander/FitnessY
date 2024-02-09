//
//  TabNavigation.swift
//  FitnessY
//
//  Created by Albin Sander on 2024-02-09.
//

import SwiftUI

struct TabNavigation: View {
    var hkStore = HealthStore()
    var body: some View {
        TabView {
            Home(hkStore: hkStore)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Workouts(hkStore: hkStore)
                .tabItem {
                    Label("Workouts", systemImage: "firewall")
                }
        }
    }
}

#Preview {
    TabNavigation()
}
