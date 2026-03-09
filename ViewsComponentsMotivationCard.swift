//
//  MotivationCard.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct MotivationCard: View {
    let message: String
    let daysSinceLastWalk: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(motivationColor.gradient)
                    .frame(width: 60, height: 60)
                
                Image(systemName: motivationIcon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(motivationTitle)
                    .font(.headline)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var motivationIcon: String {
        if daysSinceLastWalk == 0 {
            return "checkmark.circle.fill"
        } else if daysSinceLastWalk <= 1 {
            return "flame.fill"
        } else {
            return "bell.fill"
        }
    }
    
    private var motivationTitle: String {
        if daysSinceLastWalk == 0 {
            return "Great Job!"
        } else if daysSinceLastWalk <= 1 {
            return "Keep It Up!"
        } else {
            return "Time to Walk!"
        }
    }
    
    private var motivationColor: Color {
        if daysSinceLastWalk == 0 {
            return .green
        } else if daysSinceLastWalk <= 1 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MotivationCard(message: "You walked today! Keep up the great work!", daysSinceLastWalk: 0)
        MotivationCard(message: "You're doing great! Keep it up!", daysSinceLastWalk: 1)
        MotivationCard(message: "Your sneakers are getting lonely! 👟", daysSinceLastWalk: 3)
    }
    .padding()
}
