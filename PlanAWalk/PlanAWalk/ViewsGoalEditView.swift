//
//  GoalEditView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/9/26.
//

import SwiftUI

struct GoalEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var goalManager: GoalManager
    
    let goal: WalkingGoal
    
    @State private var selectedType: GoalType
    @State private var targetValue: Double
    @State private var selectedFrequency: WalkingFrequency
    @State private var startDate: Date
    @State private var selectedDuration: GoalDuration
    @State private var customDurationDays: Int
    @State private var showCustomDurationPicker: Bool
    
    init(goal: WalkingGoal) {
        self.goal = goal
        _selectedType = State(initialValue: goal.type)
        _targetValue = State(initialValue: goal.targetValue)
        _selectedFrequency = State(initialValue: goal.frequency)
        _startDate = State(initialValue: goal.startDate)
        _selectedDuration = State(initialValue: goal.duration)
        _customDurationDays = State(initialValue: goal.customDurationDays ?? 30)
        _showCustomDurationPicker = State(initialValue: goal.duration == .custom)
    }
    
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
                
                Section {
                    HStack {
                        Text("Cumulative Target")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        TextField("Target", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        
                        Text(targetUnit)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    Text(targetDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Cumulative Target")
                } footer: {
                    Text("This is your total goal to achieve over the entire duration, not per day.")
                        .font(.caption)
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
                    Button(action: saveChanges) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValidGoal)
                }
            }
            .navigationTitle("Edit Goal")
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
    
    private var targetUnit: String {
        switch selectedType {
        case .steps: return "steps"
        case .miles: return "mi"
        case .time: return "min"
        }
    }
    
    private var targetDescription: String {
        switch selectedType {
        case .steps: return "Example: For 10,000 steps/day over a week = 70,000 total steps"
        case .miles: return "Example: For 3 miles/day over a week = 21 total miles"
        case .time: return "Example: For 45 min/day over a week = 315 total minutes"
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
    
    private func saveChanges() {
        goalManager.updateGoal(
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
    let healthKitManager = HealthKitManager()
    let goalManager = GoalManager(healthKitManager: healthKitManager)
    
    // Create a sample goal for preview
    goalManager.createGoal(type: .steps, target: 70000, frequency: .daily, duration: .week)
    
    return GoalEditView(goal: goalManager.currentGoal!)
        .environmentObject(goalManager)
}
