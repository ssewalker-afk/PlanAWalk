//
//  SettingsView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section("Current Goal") {
                if let goal = goalManager.currentGoal {
                    HStack {
                        Image(systemName: goal.type.icon)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.type.rawValue)
                                .font(.headline)
                            
                            Text("\(Int(goal.targetValue)) \(unitLabel(for: goal.type))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(goal.progressPercentage)%")
                            .font(.headline)
                            .foregroundStyle(goal.isCompleted ? .green : .blue)
                    }
                    
                    HStack {
                        Text("Walking Frequency")
                        Spacer()
                        Text(goal.frequency.rawValue)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Started")
                        Spacer()
                        Text(goal.startDate.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                    
                    if let lastWalk = goal.lastWalkDate {
                        HStack {
                            Text("Last Walk")
                            Spacer()
                            Text(lastWalk.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        Text("Delete Goal")
                    }
                } else {
                    Text("No active goal")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Statistics") {
                StatRow(label: "Total Miles", value: String(format: "%.1f", goalManager.totalMilesEarned))
                StatRow(label: "Current Streak", value: "\(goalManager.currentStreak) days")
                StatRow(label: "Badges Earned", value: "\(goalManager.badges.count)")
                StatRow(label: "Total Walks", value: "\(goalManager.walkHistory.count)")
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                    }
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    HStack {
                        Text("Terms of Service")
                        Spacer()
                    }
                }
                
                Link(destination: URL(string: "https://www.apple.com/health/")!) {
                    HStack {
                        Text("Health Data Privacy")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PlanAWalk")
                            .font(.headline)
                        Text("Track your walking goals and earn badges!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Delete Goal?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                goalManager.currentGoal = nil
                goalManager.saveData()
            }
        } message: {
            Text("This will delete your current goal but keep your badges and statistics.")
        }
    }
    
    private func unitLabel(for type: GoalType) -> String {
        switch type {
        case .steps: return "steps"
        case .miles: return "miles"
        case .time: return "minutes"
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
    }
}
