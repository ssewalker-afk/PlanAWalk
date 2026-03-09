# Long-Term Goals Update

## Overview
I've enhanced the PlanAWalk app to support long-term walking goals with custom start dates and flexible durations, including support for year-long goals like your example of 500 miles starting January 1, 2026.

## What's New

### 1. **Flexible Goal Durations**
Added a new `GoalDuration` enum with the following options:
- **1 Day** - Quick daily challenges
- **1 Week** - Short-term weekly goals
- **2 Weeks** - Two-week challenges
- **1 Month** - Monthly targets
- **3 Months** - Quarterly goals
- **6 Months** - Half-year commitments
- **1 Year** - Annual goals (like your 500-mile example!)
- **Custom** - Set any number of days you want

### 2. **Custom Start Dates**
Users can now:
- Set a start date in the past (e.g., January 1, 2026)
- Backdate goals to track progress from a specific date
- The app will calculate progress from the chosen start date

### 3. **Enhanced Goal Tracking**

#### Timeline Information
For goals longer than 7 days, the app now displays:
- **Date Range**: Shows start and end dates (e.g., "Jan 1, 2026 - Dec 31, 2026")
- **Days Remaining**: Countdown to goal deadline
- **Day X of Y**: Current position in the timeline
- **Time Progress Bar**: Visual indicator of how much time has elapsed

#### Smart Progress Metrics
- **Daily Average Needed**: Shows how much you need to walk each day to hit your target
  - Color-coded warning if you're falling behind pace
- **Current Pace**: Shows your actual daily average so far
- **Progress Ring**: Visual representation of goal completion
  - Changes to green when completed
  - Changes to orange/red if the goal expires before completion

### 4. **Updated Goal Creation Interface**

The `GoalCreationView` now includes:
- **Start Date Picker**: Choose any date (past or future)
- **Duration Selector**: Choose from preset durations or custom
- **Custom Days Input**: When "Custom" is selected, enter exact number of days
- **Live End Date Display**: Automatically calculates and shows the end date
- **Duration Summary**: Shows total days for the goal
- **Validation**: Ensures all fields are valid before allowing goal creation

## Example Use Case

**Your 500-Mile Year Goal:**

1. Open the app and tap "Create Goal"
2. Select **Goal Type**: Miles
3. Enter **Target**: 500
4. Set **Start Date**: January 1, 2026
5. Choose **Duration**: 1 Year
6. Select **Frequency**: Daily (or whatever cadence you prefer for reminders)
7. Tap "Create Goal"

The app will then show:
- Progress: X / 500 miles
- Timeline: Jan 1, 2026 - Dec 31, 2026
- Days Remaining: Updates daily
- Daily Avg Needed: ~1.37 miles/day (adjusts based on current progress)
- Current Pace: Shows your actual average
- Time Progress: Visual bar showing where you are in the year

## Keeping Short-Term Goals

All your favorite short-term goal options are still available:
- **Daily Goals**: Perfect for building consistent habits
- **3x per Week**: Flexible schedule
- **5x per Week**: Active lifestyle
- **Weekly Goals**: Simple targets

You can still create short duration goals like:
- 1 Day: "Walk 10,000 steps today!"
- 1 Week: "Walk 20 miles this week"
- 2 Weeks: "Complete 10 walks"

## Technical Changes

### Files Modified

1. **ModelsWalkingGoal.swift**
   - Added `GoalDuration` enum
   - Enhanced `WalkingGoal` struct with timeline properties
   - Added computed properties: `isExpired`, `daysRemaining`, `totalDays`, `daysElapsed`, `timeProgress`, `displayDateRange`

2. **ManagersGoalManager.swift**
   - Updated `createGoal()` method to accept `startDate`, `duration`, and `customDurationDays` parameters

3. **ViewsGoalCreationView.swift**
   - Added date picker for start date selection
   - Added duration picker with all options
   - Added custom duration input field
   - Live end date calculation and display
   - Enhanced validation logic

4. **ViewsHomeView.swift**
   - Enhanced `GoalProgressCard` to show timeline information for long-term goals
   - Added time progress bar
   - Added daily average calculations
   - Added current pace tracking
   - Color-coded warnings for behind-schedule goals

## Benefits

1. **Long-Term Planning**: Track ambitious year-long goals
2. **Historical Tracking**: Backdate goals to capture past progress
3. **Better Insights**: See if you're on pace to meet your goals
4. **Flexibility**: Mix short-term and long-term goals as needed
5. **Visual Feedback**: Clear progress indicators for both time and achievement

## Next Steps

The app is now ready to support your 500-mile year goal starting January 1, 2026! You can create the goal with any past start date, and the app will properly calculate your progress and remaining timeline.

All existing features (badges, streaks, reminders) continue to work with both short-term and long-term goals.
