//
//  LifetimeStatsView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/9/26.
//

import SwiftUI

struct LifetimeStatsView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background matching HomeView
                LinearGradient(
                    colors: [.blue.opacity(0.3), .green.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)
                            
                            Text("Your Journey")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("All-time achievements and statistics")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Lifetime Stats Cards
                        VStack(spacing: 16) {
                            LifetimeStatCard(
                                icon: "figure.walk",
                                title: "Lifetime Miles",
                                value: String(format: "%.1f", goalManager.lifetimeMiles),
                                unit: "miles",
                                color: .blue,
                                gradient: [.blue, .cyan]
                            )
                            
                            LifetimeStatCard(
                                icon: "shoeprints.fill",
                                title: "Lifetime Steps",
                                value: Int(goalManager.lifetimeSteps).formatted(),
                                unit: "steps",
                                color: .orange,
                                gradient: [.orange, .yellow]
                            )
                            
                            LifetimeStatCard(
                                icon: "clock.fill",
                                title: "Lifetime Hours",
                                value: String(format: "%.1f", goalManager.lifetimeHours),
                                unit: "hours",
                                color: .purple,
                                gradient: [.purple, .pink]
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Lifetime Stats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { Task { await refreshData() } }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    }
                    .disabled(isRefreshing)
                }
            }
            .task {
                // Load lifetime stats when view appears
                if goalManager.lifetimeSteps == 0 && goalManager.lifetimeHours == 0 {
                    await refreshData()
                }
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        await goalManager.updateProgress()
        try? await Task.sleep(for: .seconds(0.5))
        isRefreshing = false
    }
}

// MARK: - Lifetime Stat Card

struct LifetimeStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(color)
                    
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    LifetimeStatsView()
        .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
}
