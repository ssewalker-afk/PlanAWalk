//
//  ProgressMilestoneView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct ProgressMilestoneView: View {
    let progress: Double
    let hasBadge25: Bool
    let hasBadge50: Bool
    let hasBadge75: Bool
    let hasBadge100: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress Milestones")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 0) {
                // 25% Milestone
                MilestoneMarker(
                    percentage: 25,
                    isAchieved: hasBadge25,
                    isReached: progress >= 0.25,
                    color: .cyan
                )
                
                // Connecting line
                Rectangle()
                    .fill(progress >= 0.50 ? Color.mint : Color.gray.opacity(0.3))
                    .frame(height: 2)
                
                // 50% Milestone
                MilestoneMarker(
                    percentage: 50,
                    isAchieved: hasBadge50,
                    isReached: progress >= 0.50,
                    color: .mint
                )
                
                // Connecting line
                Rectangle()
                    .fill(progress >= 0.75 ? Color.teal : Color.gray.opacity(0.3))
                    .frame(height: 2)
                
                // 75% Milestone
                MilestoneMarker(
                    percentage: 75,
                    isAchieved: hasBadge75,
                    isReached: progress >= 0.75,
                    color: .teal
                )
                
                // Connecting line
                Rectangle()
                    .fill(progress >= 1.0 ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(height: 2)
                
                // 100% Milestone
                MilestoneMarker(
                    percentage: 100,
                    isAchieved: hasBadge100,
                    isReached: progress >= 1.0,
                    color: .yellow
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MilestoneMarker: View {
    let percentage: Int
    let isAchieved: Bool
    let isReached: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(isReached ? color : Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 36, height: 36)
                
                if isAchieved {
                    Circle()
                        .fill(color.gradient)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                } else if isReached {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
            }
            
            Text("\(percentage)%")
                .font(.caption2)
                .fontWeight(isReached ? .semibold : .regular)
                .foregroundStyle(isReached ? color : .secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressMilestoneView(
            progress: 0.30,
            hasBadge25: true,
            hasBadge50: false,
            hasBadge75: false,
            hasBadge100: false
        )
        .padding()
        
        ProgressMilestoneView(
            progress: 0.65,
            hasBadge25: true,
            hasBadge50: true,
            hasBadge75: false,
            hasBadge100: false
        )
        .padding()
        
        ProgressMilestoneView(
            progress: 1.0,
            hasBadge25: true,
            hasBadge50: true,
            hasBadge75: true,
            hasBadge100: true
        )
        .padding()
    }
}
