//
//  HomeView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var goalManager: GoalManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var showingGoalCreation = false
    @State private var isRefreshing = false
    @State private var showBadgeCelebration = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [.blue.opacity(0.3), .green.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with encouragement
                        if let goal = goalManager.currentGoal {
                            VStack(spacing: 8) {
                                Text(greeting())
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 20)
                            
                            // Motivation Card
                            MotivationCard(
                                message: goalManager.getEncouragementMessage(),
                                daysSinceLastWalk: goalManager.daysSinceLastWalk()
                            )
                            .padding(.horizontal)
                            
                            // Main Progress Card
                            GoalProgressCard(goal: goal)
                                .padding(.horizontal)
                            
                            // Progress Milestones
                            ProgressMilestoneView(
                                progress: goal.progress,
                                hasBadge25: goalManager.badges.contains(where: { $0.type == .progress25 }),
                                hasBadge50: goalManager.badges.contains(where: { $0.type == .progress50 }),
                                hasBadge75: goalManager.badges.contains(where: { $0.type == .progress75 }),
                                hasBadge100: goalManager.badges.contains(where: { $0.type == .goalComplete })
                            )
                            .padding(.horizontal)
                            
                            // Stats Grid
                            StatsGrid(
                                totalSteps: goalManager.totalSteps,
                                totalMiles: goalManager.totalMilesEarned,
                                daysSinceLastWalk: goalManager.daysSinceLastWalk()
                            )
                            .padding(.horizontal)
                            
                            // Recent Badges Preview
                            if !goalManager.badges.isEmpty {
                                RecentBadgesView(badges: Array(goalManager.badges.prefix(3)))
                                    .padding(.horizontal)
                            }
                            
                        } else {
                            // No goal state
                            VStack(spacing: 20) {
                                Image(systemName: "figure.walk.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.blue)
                                    .padding(.top, 60)
                                
                                Text("Let's Get Walking!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Set your first walking goal to start tracking your progress and earning badges!")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Button(action: { showingGoalCreation = true }) {
                                    Label("Create Your Goal", systemImage: "plus.circle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .padding(.top, 20)
                            }
                            .padding()
                        }
                    }
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("PlanAWalk")
            .toolbar {
                if goalManager.currentGoal != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showingGoalCreation = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                    
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
            .sheet(isPresented: $showingGoalCreation) {
                GoalCreationView()
                    .environmentObject(goalManager)
            }
            .overlay {
                if showBadgeCelebration, let badge = goalManager.newlyEarnedBadge {
                    BadgeCelebrationView(badge: badge, isPresented: $showBadgeCelebration)
                        .transition(.opacity)
                        .onDisappear {
                            goalManager.clearNewlyEarnedBadge()
                        }
                }
            }
            .onChange(of: goalManager.newlyEarnedBadge) { oldValue, newValue in
                if newValue != nil {
                    showBadgeCelebration = true
                }
            }
            .task {
                if !healthKitManager.isAuthorized {
                    await healthKitManager.requestAuthorization()
                }
                
                if healthKitManager.isAuthorized {
                    await refreshData()
                }
            }
        }
    }
    
    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning!"
        case 12..<17: return "Good Afternoon!"
        default: return "Good Evening!"
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        await goalManager.updateProgress()
        try? await Task.sleep(for: .seconds(0.5))
        isRefreshing = false
    }
}

// MARK: - Goal Progress Card

struct GoalProgressCard: View {
    let goal: WalkingGoal
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: goal.type.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your \(goal.type.rawValue) Goal")
                        .font(.headline)
                    
                    Text(goal.frequency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                } else if goal.isExpired {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title)
                        .foregroundStyle(.orange)
                }
            }
            
            // Timeline info for long-term goals
            if goal.totalDays > 7 {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Timeline")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(goal.displayDateRange)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(goal.daysRemaining) days left")
                                .font(.caption)
                                .foregroundStyle(goal.daysRemaining < 7 ? .orange : .secondary)
                                .fontWeight(goal.daysRemaining < 7 ? .semibold : .regular)
                            
                            Text("Day \(goal.daysElapsed) of \(goal.totalDays)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Time progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: geometry.size.width * goal.timeProgress, height: 8)
                                .animation(.spring(duration: 0.5), value: goal.timeProgress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 8)
            }
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(
                        LinearGradient(
                            colors: progressGradientColors(for: goal),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0), value: goal.progress)
                
                VStack(spacing: 4) {
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 44, weight: .bold))
                    
                    Text(goal.displayValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: 200)
            .padding(.vertical)
            
            // Additional info for long-term goals
            if goal.totalDays > 7 {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Daily Avg Needed")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        let remaining = goal.targetValue - goal.currentValue
                        let daysLeft = max(goal.daysRemaining, 1)
                        let dailyNeeded = remaining / Double(daysLeft)
                        
                        Text(formatDailyNeeded(dailyNeeded, type: goal.type))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(dailyNeeded > (goal.targetValue / Double(goal.totalDays)) * 1.5 ? .orange : .primary)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(spacing: 4) {
                        Text("Current Pace")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        let currentPace = goal.daysElapsed > 0 ? goal.currentValue / Double(goal.daysElapsed) : 0
                        
                        Text(formatDailyNeeded(currentPace, type: goal.type))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func progressGradientColors(for goal: WalkingGoal) -> [Color] {
        if goal.isCompleted {
            return [.green, .green]
        } else if goal.isExpired {
            return [.orange, .red]
        } else {
            return [.blue, .purple, .pink]
        }
    }
    
    private func formatDailyNeeded(_ value: Double, type: GoalType) -> String {
        switch type {
        case .steps:
            return "\(Int(value)) steps"
        case .miles:
            return String(format: "%.1f mi", value)
        case .time:
            return "\(Int(value)) min"
        }
    }
}

// MARK: - Stats Grid

struct StatsGrid: View {
    let totalSteps: Double
    let totalMiles: Double
    let daysSinceLastWalk: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "shoeprints.fill",
                title: "\(Int(totalSteps).formatted())",
                subtitle: "Total Steps",
                color: .orange
            )
            
            StatCard(
                icon: "map.fill",
                title: String(format: "%.1f mi", totalMiles),
                subtitle: "Total Miles",
                color: .blue
            )
            
            StatCard(
                icon: "calendar",
                title: daysSinceLastWalk == 0 ? "Today" : "\(daysSinceLastWalk)d ago",
                subtitle: "Last Walk",
                color: .green
            )
            
            NavigationLink(destination: LifetimeStatsView()) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title)
                        .foregroundStyle(.purple)
                    
                    Text("View Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Lifetime")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Recent Badges Preview

struct RecentBadgesView: View {
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Badges")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: BadgesView().environmentObject(GoalManager(healthKitManager: HealthKitManager()))) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(badges) { badge in
                        BadgeMiniCard(badge: badge)
                    }
                }
            }
        }
    }
}

struct BadgeMiniCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.type.color.gradient)
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.type.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            Text(badge.type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(HealthKitManager())
        .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
}
