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
    
    // Calculator state
    @State private var showCalculator = false
    @State private var calculatorDailyAmount: Double = 0
    @State private var calculatorDaysPerWeek: Int = 3
    
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
                        updateCalculatorDefaults()
                    }
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
                
                // Goal Calculator Section
                Section {
                    DisclosureGroup("Goal Calculator", isExpanded: $showCalculator) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calculate your cumulative target based on your duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Per session")
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                TextField("Amount", value: $calculatorDailyAmount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                
                                Text(calculatorUnit)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            
                            Picker("Days per week", selection: $calculatorDaysPerWeek) {
                                ForEach(1...7, id: \.self) { days in
                                    Text("\(days) day\(days == 1 ? "" : "s")")
                                }
                            }
                            .pickerStyle(.menu)
                            
                            if let totalDays = totalDaysInGoal {
                                let weeksInGoal = Double(totalDays) / 7.0
                                let totalSessions = weeksInGoal * Double(calculatorDaysPerWeek)
                                let calculatedTotal = calculatorDailyAmount * totalSessions
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Divider()
                                    
                                    HStack {
                                        Text("Calculation:")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Duration: \(totalDays) days (\(String(format: "%.1f", weeksInGoal)) weeks)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("\(formatCalculatorValue(calculatorDailyAmount)) \(calculatorUnit) × \(calculatorDaysPerWeek) days/week × \(String(format: "%.1f", weeksInGoal)) weeks")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("Suggested Target:")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("\(formatCalculatorValue(calculatedTotal)) \(calculatorUnit)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    Button(action: {
                                        targetValue = calculatedTotal
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.down.circle.fill")
                                            Text("Use This Target")
                                        }
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                                .padding(.top, 4)
                            } else {
                                Text("Select a duration above to calculate")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Need help calculating?")
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
    
    private var targetUnit: String {
        switch selectedType {
        case .steps: return "steps"
        case .miles: return "mi"
        case .time: return "min"
        }
    }
    
    private var calculatorUnit: String {
        switch selectedType {
        case .steps: return "steps"
        case .miles: return "miles"
        case .time: return "min"
        }
    }
    
    private var totalDaysInGoal: Int? {
        if selectedDuration == .custom {
            return customDurationDays
        } else {
            return selectedDuration.days
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
    
    private func updateCalculatorDefaults() {
        switch selectedType {
        case .steps:
            calculatorDailyAmount = 10000
        case .miles:
            calculatorDailyAmount = 3.0
        case .time:
            calculatorDailyAmount = 45
        }
    }
    
    private func formatCalculatorValue(_ value: Double) -> String {
        if selectedType == .miles {
            return String(format: "%.1f", value)
        } else {
            return Int(value).formatted()
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
