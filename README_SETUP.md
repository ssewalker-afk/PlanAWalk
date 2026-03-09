# PlanAWalk - Required Configurations

## Info.plist Setup

Add the following entries to your Info.plist file:

### HealthKit Privacy Description
```xml
<key>NSHealthShareUsageDescription</key>
<string>PlanAWalk needs access to your walking workouts to track your progress toward your goals and award badges.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>PlanAWalk will update your health data with workout information.</string>
```

### User Notifications (for reminders)
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>PlanAWalk would like to send you friendly reminders to help you stay on track with your walking goals.</string>
```

## Project Capabilities

Enable the following capabilities in your Xcode project:

1. **HealthKit**
   - Go to your target's "Signing & Capabilities" tab
   - Click "+ Capability"
   - Add "HealthKit"

2. **Background Modes** (optional, for better sync)
   - Add "Background fetch"
   - Add "Background processing"

## File Organization

The project is organized as follows:

```
PlanAWalk/
├── Models/
│   ├── WalkingGoal.swift
│   └── Badge.swift
├── Managers/
│   ├── HealthKitManager.swift
│   └── GoalManager.swift
├── Views/
│   ├── HomeView.swift
│   ├── GoalCreationView.swift
│   └── BadgesView.swift
├── ContentView.swift
└── PlanAWalkApp.swift
```

## Key Features

### 1. Goal Types
- **Steps**: Track daily step count from walking workouts
- **Miles**: Track distance covered during walks
- **Time**: Track duration of walking workouts

### 2. Badge System
- First Steps: Complete your first walk
- 3 Day Streak: Walk 3 days in a row
- Week Warrior: Walk 7 days in a row
- Goal Crusher: Complete a walking goal
- Mileage Milestones: 10, 50, 100 miles
- Early Bird: Walk before 8 AM
- Night Owl: Walk after 8 PM

### 3. Progress Tracking
- Real-time sync with HealthKit
- Only counts indoor and outdoor walking workouts
- Visual progress indicators
- Streak tracking

### 4. Badge Sharing
- Tap any badge to view details
- Share badges as beautiful images
- Save to photos or share on social media

### 5. Encouragement Messages
Funny and motivating messages when you haven't walked in a while:
- "Your sneakers are getting lonely! 👟"
- "The outdoors is calling... and it's been leaving voicemails! 📱"
- And many more!

## Next Steps

To fully implement notifications for reminders, you would need to:

1. Import UserNotifications framework
2. Request notification permissions
3. Schedule local notifications based on walking frequency
4. Handle notification responses

## Testing

Since HealthKit requires a physical device and actual workout data:

1. Install the app on a physical iOS device
2. Grant HealthKit permissions when prompted
3. Use the Health app or Apple Watch to log walking workouts
4. Refresh the app to see progress updates
5. Earn badges as you hit milestones!

## Design Features

- Bright, colorful gradient backgrounds
- Material design with blur effects
- Smooth animations
- Responsive cards and grids
- Pull-to-refresh support
