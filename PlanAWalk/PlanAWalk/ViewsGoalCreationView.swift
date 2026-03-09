//
//  GoalCreationView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/8/26.
//

import SwiftUI

struct GoalCreationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var goalManager: GoalManager
    
    @State private var selectedType: GoalType = .steps
    @State private var targetValue: Double = 10000
    @State private var selectedFrequency: WalkingFrequency = .daily
    @State private var startDate = Date()
    @State private var selectedDuration: GoalDuration = .week
    @State private var customDurationDays: Int = 30
    @State private var showCustomDurationPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) { oldValue, newValue in
                        updateDefaultTarget()
                    }
                }
                
                Section("Target") {
                    HStack {
                        Text(targetLabel)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        TextField("Target", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    Text(targetDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Timeline") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(GoalDuration.allCases, id: \.self) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                    .onChange(of: selectedDuration) { oldValue, newValue in
                        showCustomDurationPicker = (newValue == .custom)
                    }
                    
                    if showCustomDurationPicker || selectedDuration == .custom {
                        HStack {
                            Text("Custom Days")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            TextField("Days", value: $customDurationDays, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                    
                    if let endDate = calculateEndDate() {
                        HStack {
                            Text("End Date")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(endDate, style: .date)
                        }
                    }
                    
                    Text(durationSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Walking Frequency") {
                    Picker("How often?", selection: $selectedFrequency) {
                        ForEach(WalkingFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text("We'll send you a friendly reminder if you haven't walked in \(selectedFrequency.daysUntilReminder) day(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Button(action: createGoal) {
                        HStack {
                            Spacer()
                            Text("Create Goal")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValidGoal)
                }
            }
            .navigationTitle("Create Walking Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var targetLabel: String {
        switch selectedType {
        case .steps: return "Steps"
        case .miles: return "Miles"
        case .time: return "Minutes"
        }
    }
    
    private var targetDescription: String {
        switch selectedType {
        case .steps: return "Recommended: 10,000 steps per day"
        case .miles: return "Recommended: 3-5 miles per day"
        case .time: return "Recommended: 30-60 minutes per day"
        }
    }
    
    private var durationSummary: String {
        if selectedDuration == .custom {
            return "Goal will run for \(customDurationDays) days"
        } else if let days = selectedDuration.days {
            return "Goal will run for \(days) days"
        }
        return ""
    }
    
    private var isValidGoal: Bool {
        if selectedDuration == .custom {
            return targetValue > 0 && customDurationDays > 0
        }
        return targetValue > 0
    }
    
    private func calculateEndDate() -> Date? {
        let calendar = Calendar.current
        if selectedDuration == .custom {
            return calendar.date(byAdding: .day, value: customDurationDays, to: startDate)
        } else if let days = selectedDuration.days {
            return calendar.date(byAdding: .day, value: days, to: startDate)
        }
        return nil
    }
    
    private func updateDefaultTarget() {
        switch selectedType {
        case .steps:
            targetValue = 10000
        case .miles:
            targetValue = 3.0
        case .time:
            targetValue = 30
        }
    }
    
    private func createGoal() {
        goalManager.createGoal(
            type: selectedType, 
            target: targetValue, 
            frequency: selectedFrequency,
            startDate: startDate,
            duration: selectedDuration,
            customDurationDays: selectedDuration == .custom ? customDurationDays : nil
        )
        dismiss()
    }
}

#Preview {
    GoalCreationView()
        .environmentObject(GoalManager(healthKitManager: HealthKitManager()))
}
