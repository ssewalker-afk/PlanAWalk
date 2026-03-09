# PlanAWalk 🚶‍♀️

A privacy-first iOS walking tracker that helps you set goals, track progress, and earn achievement badges—all while keeping your health data secure on your device.

![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)
![HealthKit](https://img.shields.io/badge/HealthKit-Integrated-red.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

## 📱 Features

### Goal Tracking
- **Flexible Goal Types**: Set goals for steps, miles, or walking time
- **Custom Durations**: Choose from 1 day to 1 year, or create custom durations
- **Smart Calculator**: Built-in calculator helps you determine realistic cumulative targets
- **Progress Monitoring**: Real-time progress tracking with visual indicators
- **Timeline Insights**: See your pace, daily averages, and days remaining

### Statistics & Insights
- **Current Goal Stats**: Track steps, miles, and last walk date for your active goal
- **Lifetime Statistics**: View all-time miles, steps, and hours walked
- **Streak Tracking**: Monitor your consecutive walking days
- **Walking History**: Complete history of all your walks

### Achievement System
- **Progress Badges**: Earn badges at 25%, 50%, 75%, and 100% completion
- **Streak Badges**: Achievements for 3, 7, 14, and 30-day streaks
- **Habit Badges**: Recognition for consistency, early bird walks, night owl walks, and more
- **Badge Collection**: View all earned badges with timestamps
- **Celebration Animations**: Fun animations when you unlock new badges

### User Experience
- **Beautiful UI**: Modern SwiftUI design with gradient backgrounds
- **Motivational Messages**: Encouraging prompts when you need them
- **Pull to Refresh**: Easy data updates
- **Goal Management**: Edit or delete goals anytime
- **Privacy First**: All data stored locally on your device

## 🎯 Screenshots

*(Add your app screenshots here)*

## 🛠 Tech Stack

- **Language**: Swift 6.0
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Health Integration**: HealthKit
- **Storage**: Local file system (JSON)
- **Minimum iOS**: 18.0

## 📋 Requirements

- iOS 18.0 or later
- iPhone or iPad
- Access to Health app (HealthKit permissions)

## 🚀 Installation

### Prerequisites
- Xcode 16.0 or later
- iOS 18.0 SDK
- Valid Apple Developer account (for device testing)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/PlanAWalk.git
   cd PlanAWalk
   ```

2. **Open in Xcode**
   ```bash
   open PlanAWalk.xcodeproj
   ```

3. **Add HTML files to project**
   - Drag `PrivacyPolicy.html` and `TermsOfService.html` into Xcode
   - Ensure "Copy items if needed" is checked
   - Add files to app target

4. **Configure HealthKit**
   - Select your project in Xcode
   - Go to "Signing & Capabilities"
   - Add "HealthKit" capability
   - The app requests the following permissions:
     - Walking & Running Distance (Read)
     - Step Count (Read)
     - Workouts (Read)

5. **Update Bundle Identifier** (if needed)
   - Select your project → General tab
   - Update the Bundle Identifier

6. **Build and Run**
   - Select your target device or simulator
   - Press ⌘R to build and run

## 📂 Project Structure

```
PlanAWalk/
├── App/
│   ├── PlanAWalkApp.swift          # App entry point
│   └── ContentView.swift           # Tab view container
├── Managers/
│   ├── HealthKitManager.swift      # HealthKit integration
│   └── GoalManager.swift           # Goal and badge logic
├── Models/
│   ├── WalkingGoal.swift           # Goal data model
│   └── Badge.swift                 # Badge types and data
├── Views/
│   ├── HomeView.swift              # Main dashboard
│   ├── GoalCreationView.swift     # Create new goals
│   ├── GoalEditView.swift         # Edit existing goals
│   ├── BadgesView.swift           # Badge collection
│   ├── LifetimeStatsView.swift    # Lifetime statistics
│   ├── SettingsView.swift         # App settings
│   ├── PrivacyPolicyView.swift    # Privacy policy viewer
│   ├── TermsOfServiceView.swift   # Terms viewer
│   └── Components/
│       ├── MotivationCard.swift
│       ├── ProgressMilestoneView.swift
│       └── BadgeCelebrationView.swift
└── Resources/
    ├── PrivacyPolicy.html
    └── TermsOfService.html
```

## 🔒 Privacy & Security

PlanAWalk is designed with privacy as a top priority:

- ✅ **Local Storage Only**: All data stored on device, never transmitted to servers
- ✅ **No Cloud Sync**: Data stays on your device
- ✅ **No Third-Party Analytics**: Zero tracking or data collection
- ✅ **No Ads**: Completely ad-free experience
- ✅ **HealthKit Privacy**: Full compliance with Apple's HealthKit privacy guidelines
- ✅ **User Control**: Complete control over HealthKit permissions

See [Privacy Policy](PrivacyPolicy.html) for full details.

## 🏃‍♀️ How to Use

### Creating Your First Goal

1. Launch the app and grant HealthKit permissions
2. Tap "Create Your Goal"
3. Choose goal type (Steps, Miles, or Time)
4. Set your duration (week, month, 6 months, etc.)
5. Use the calculator to determine your cumulative target, or enter manually
6. Set your walking frequency for reminders
7. Tap "Create Goal"

### Tracking Progress

- **Home Screen**: View current progress, motivational messages, and quick stats
- **Pull to Refresh**: Update your progress at any time
- **Stats Cards**: Quick view of total steps, miles, and last walk
- **Progress Ring**: Visual representation of goal completion

### Managing Goals

- **Edit Goal**: Tap the menu (•••) → Edit Goal to modify settings
- **Delete Goal**: Tap the menu (•••) → Delete Goal (badges are preserved)
- **View Lifetime Stats**: Tap the "View Stats" card to see all-time achievements

### Earning Badges

Badges are automatically awarded when you:
- Complete your first walk
- Reach progress milestones (25%, 50%, 75%, 100%)
- Maintain walking streaks (3, 7, 14, 30 days)
- Walk at specific times (early morning, late evening)
- Show consistency throughout your goal
- Walk faster than your average pace

## 🐛 Known Issues

- N/A (Initial release)

## 🗺 Roadmap

- [ ] iPad-optimized layout
- [ ] Apple Watch companion app
- [ ] Widgets for home screen
- [ ] Dark mode optimization
- [ ] Export statistics to CSV
- [ ] Share achievements
- [ ] Custom badge designs
- [ ] Weekly progress reports
- [ ] Goal templates

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Guidelines

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain MVVM architecture
- Add comments for complex logic
- Test on multiple devices/screen sizes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Sarah Walker**
- Email: sarah@thereallifehq.com
- Website: [thereallifehq.com](https://thereallifehq.com)

## 🙏 Acknowledgments

- Apple's HealthKit framework for health data integration
- SF Symbols for beautiful icons
- SwiftUI for modern UI development
- The iOS development community for inspiration

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/PlanAWalk/issues) page
2. Create a new issue with detailed information
3. Email: sarah@thereallifehq.com

## ⚖️ Legal

### Medical Disclaimer

PlanAWalk is not a medical device and should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult your physician before beginning any exercise program.

### App Store

Available on the App Store (coming soon)

### Compliance

- ✅ Apple App Store Guidelines
- ✅ HealthKit Review Guidelines  
- ✅ COPPA Compliant (13+ age requirement)
- ✅ Privacy regulations compliant

---

## 📊 Statistics

- **Version**: 1.0.0
- **Release Date**: March 2026
- **Category**: Health & Fitness
- **Platform**: iOS
- **Size**: TBD

---

<p align="center">Made with ❤️ and SwiftUI</p>
<p align="center">🚶‍♀️ Keep walking, keep achieving! 🏆</p>
