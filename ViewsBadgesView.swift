//
//  BadgesView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var selectedBadge: Badge?
    @State private var showingShareSheet = false
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            if goalManager.badges.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "trophy.circle")
                        .font(.system(size: 80))
                        .foregroundStyle(.gray)
                        .padding(.top, 60)
                    
                    Text("No Badges Yet")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Start walking to earn your first badge!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(goalManager.badges.sorted(by: { $0.earnedDate > $1.earnedDate })) { badge in
                        BadgeCard(badge: badge)
                            .onTapGesture {
                                selectedBadge = badge
                                goalManager.markBadgeAsViewed(badge)
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge, showingShareSheet: $showingShareSheet)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Badge Card

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badge.type.color.gradient)
                    .frame(width: 100, height: 100)
                
                Image(systemName: badge.type.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                
                if badge.isNew {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(.red)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("!")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                )
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .frame(width: 100, height: 100)
            
            VStack(spacing: 4) {
                Text(badge.type.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(badge.earnedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Badge Detail View

struct BadgeDetailView: View {
    let badge: Badge
    @Binding var showingShareSheet: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(badge.type.color.gradient)
                    .frame(width: 140, height: 140)
                    .shadow(color: badge.type.color.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: badge.type.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text(badge.type.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(badge.type.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Earned on \(badge.earnedDate.formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            
            Button(action: shareBadge) {
                Label("Share Badge", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(badge.type.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    @MainActor
    private func shareBadge() {
        let renderer = ImageRenderer(content: BadgeShareView(badge: badge))
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [image, "I just earned the \(badge.type.rawValue) badge in PlanAWalk! 🎉"],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
        
        dismiss()
    }
}

// MARK: - Badge Share View (for rendering as image)

struct BadgeShareView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [badge.type.color.opacity(0.3), badge.type.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 16) {
                    Text("PlanAWalk Achievement")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        Circle()
                            .fill(badge.type.color.gradient)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: badge.type.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text(badge.type.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(badge.type.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text(badge.earnedDate.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(40)
            }
        }
        .frame(width: 400, height: 500)
    }
}

#Preview {
    NavigationStack {
        BadgesView()
            .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
    }
}
