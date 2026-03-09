//
//  ContentView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var goalManager: GoalManager
    
    init() {
        let healthKit = HealthKitManager()
        _healthKitManager = StateObject(wrappedValue: healthKit)
        _goalManager = StateObject(wrappedValue: GoalManager(healthKitManager: healthKit))
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
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
        .environmentObject(healthKitManager)
        .environmentObject(goalManager)
    }
}

#Preview {
    ContentView()
}
