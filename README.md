# LifePlanner

A family-focused life planning iOS app with multi-member support, featuring calendar, to-do lists, notes, and secure workspace sharing.

## Features

### Calendar
- TimeTree-style interface with horizontal event spanning
- Month, Week, and Day views
- Continuous scrolling through months
- Color-coded events by workspace
- Event comments and collaboration
- All-day events displayed separately
- Calendar dots for events, tasks, and notes

### To Do Lists
- Subtasks/checklist support
- Priority levels (Low, Medium, High)
- Due date integration with calendar
- Workspace color borders
- Quick edit via tap

### Notes
- Apple Notes-style interface
- Calendar date linking
- Pin important notes
- Rich text support
- Workspace organization

### Workspaces
- Personal and shared workspaces
- Custom colors per workspace
- Granular member permissions
- Multi-workspace selection and filtering

### User Features
- Sign in with Apple
- Email/password authentication
- Personal color customization
- Premium subscription ($2.99/month) to remove ads
- Configurable notifications per workspace

## Tech Stack

- **Frontend**: SwiftUI, MVVM + Clean Architecture
- **Backend**: Firebase (Firestore, Auth, Storage, Cloud Messaging)
- **Authentication**: Sign in with Apple, Email/Password
- **Monetization**: Google Mobile Ads SDK
- **Widgets**: WidgetKit for iOS and Apple Watch
- **State Management**: Combine, ObservableObject

## Quick Start

See [SETUP.md](SETUP.md) for detailed installation instructions.

```bash
# Clone the repository
git clone https://github.com/JMills1/life-store.git
cd life-store

# Open in Xcode
open LifeNotes/LifeNotes.xcodeproj

# Add Firebase and Google Mobile Ads dependencies
# Add your GoogleService-Info.plist
# Build and run
```

## Project Structure

```
LifeNotes/
├── Config/              # App and Firebase configuration
├── Domain/
│   └── Models/          # Data models (User, Event, Todo, Note, Workspace)
├── Features/
│   ├── Authentication/  # Login, signup, password reset
│   ├── Calendar/        # Calendar views and event management
│   ├── Todos/          # Task management
│   ├── Notes/          # Note taking
│   ├── Family/         # Family/group management
│   ├── Today/          # Dashboard view
│   └── Settings/       # App settings and preferences
├── Services/           # AuthService, WorkspaceManager, NotificationService
└── Shared/
    ├── Components/     # Reusable UI components
    ├── Extensions/     # Swift extensions
    └── Theme/          # App theme and colors
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed technical documentation.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase account
- Google AdMob account (for ads)

## License

Copyright © 2025. All rights reserved.

## Contact

For questions or support, please open an issue on GitHub.
