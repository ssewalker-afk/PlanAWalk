//
//  BadgeCelebrationView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct BadgeCelebrationView: View {
    let badge: Badge
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            VStack(spacing: 24) {
                // Confetti effect (simplified)
                ZStack {
                    ForEach(0..<20, id: \.self) { index in
                        Circle()
                            .fill(randomColor())
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(Double(index) * .pi / 10) * 100,
                                y: sin(Double(index) * .pi / 10) * 100
                            )
                            .opacity(opacity)
                    }
                }
                
                // Badge
                ZStack {
                    Circle()
                        .fill(badge.type.color.gradient)
                        .frame(width: 160, height: 160)
                        .shadow(color: badge.type.color.opacity(0.6), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: badge.type.icon)
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                
                VStack(spacing: 8) {
                    Text("🎉 Badge Earned! 🎉")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(badge.type.rawValue)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(badge.type.color)
                    
                    Text(badge.type.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(opacity)
                
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(badge.type.color.gradient)
                        .clipShape(Capsule())
                }
                .opacity(opacity)
                .padding(.top, 8)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.4)) {
                rotation = 360
            }
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    private func randomColor() -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors.randomElement() ?? .blue
    }
}

#Preview {
    BadgeCelebrationView(
        badge: Badge(type: .progress50, earnedDate: Date()),
        isPresented: .constant(true)
    )
}
