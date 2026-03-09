//
//  ContentView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct ContentView: View {
    @State private var managers = Managers()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            LifetimeStatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            BadgesView()
                .tabItem {
                    Label("Badges", systemImage: "trophy.fill")
                }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .environmentObject(managers.healthKitManager)
        .environmentObject(managers.goalManager)
    }
}

class Managers {
    let healthKitManager: HealthKitManager
    let goalManager: GoalManager
    
    init() {
        self.healthKitManager = HealthKitManager()
        self.goalManager = GoalManager(healthKitManager: healthKitManager)
    }
}

#Preview {
    ContentView()
}
