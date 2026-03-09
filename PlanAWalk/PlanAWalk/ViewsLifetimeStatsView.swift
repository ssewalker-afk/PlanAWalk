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
                        
                        // Lifetime Achievement Badges
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Lifetime Achievements")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("\(lifetimeAchievementBadges.count)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            
                            if lifetimeAchievementBadges.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.gray.opacity(0.5))
                                    
                                    Text("Start walking to earn achievements!")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(lifetimeAchievementBadges) { badge in
                                        LifetimeAchievementBadgeCard(badge: badge)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
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
        }
    }
    
    private var lifetimeAchievementBadges: [Badge] {
        // Filter badges to only show lifetime milestone badges
        goalManager.badges.filter { badge in
            switch badge.type {
            case .milestone10, .milestone50, .milestone100, .milestone500, .milestone1000:
                return true
            default:
                return false
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

// MARK: - Lifetime Achievement Badge Card

struct LifetimeAchievementBadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badge.type.color.gradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: badge.type.color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: badge.type.icon)
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 4) {
                Text(badge.type.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.earnedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    LifetimeStatsView()
        .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
}
