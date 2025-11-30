# LifePlanner

A family-focused life planning app for iOS with calendar, tasks, and notes. Built with SwiftUI, Firebase, and designed for future cross-platform expansion.

## Features

### Core Functionality
- **Calendar** - TimeTree-inspired interface with month/week/day views
- **Tasks** - Priority-based todo lists with calendar integration
- **Notes** - Apple Notes-style interface with rich text support
- **Family Workspaces** - Share calendars, tasks, and notes with family members
- **Multi-Platform** - iOS app with Apple Watch support (Android planned)

### Premium Features ($2.99/month)
- Ad-free experience
- Unlimited workspaces
- Advanced family features
- Priority support
- Enhanced cloud sync

## Tech Stack

### Frontend (iOS)
- SwiftUI
- SwiftData (local caching)
- Firebase iOS SDK
- Google Mobile Ads SDK
- StoreKit (In-App Purchases)

### Backend
- Firebase Authentication (Apple Sign-In + Email/Password)
- Cloud Firestore (real-time database)
- Firebase Cloud Messaging (push notifications)
- Firebase Storage (file attachments)

### Architecture
- MVVM pattern
- Clean architecture (Domain/Data layers)
- Repository pattern for data abstraction
- Scalable for future Android development

## Setup Instructions

### Prerequisites
1. Xcode 15+ (macOS Sonoma+)
2. Apple Developer account
3. Firebase account
4. CocoaPods or Swift Package Manager

### Firebase Setup
See `SETUP.md` for detailed Firebase configuration instructions.

### Dependencies (Swift Package Manager)

Add these packages in Xcode:

1. **Firebase iOS SDK**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Packages: FirebaseAuth, FirebaseFirestore, FirebaseMessaging, FirebaseStorage

2. **Google Mobile Ads**
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`

### Configuration Files Needed

1. `GoogleService-Info.plist` - Download from Firebase Console
2. Update `AppConfig.swift` with your AdMob IDs
3. Configure Sign in with Apple in Apple Developer portal

### Build & Run

```bash
# Open project
open LifeNotes/LifeNotes.xcodeproj

# Build in Xcode
# Cmd+B to build
# Cmd+R to run on simulator or device
```

## Project Structure

```
LifeNotes/
├── Config/              # App & Firebase configuration
├── Domain/
│   └── Models/          # Core business models
├── Features/
│   ├── Authentication/  # Login, sign up, forgot password
│   ├── Calendar/        # Calendar views & event management
│   ├── Todos/           # Task list & task editor
│   ├── Notes/           # Notes list & note editor
│   ├── Family/          # Family groups & workspace sharing
│   └── Settings/        # App settings & premium upgrade
├── Services/            # Auth, notifications, etc.
└── Shared/
    ├── Components/      # Reusable UI components
    └── Theme/           # Colors, fonts, spacing
```

## Database Schema

See `SETUP.md` for complete Firestore schema.

Collections:
- `users` - User profiles and preferences
- `families` - Family groups
- `workspaces` - Personal and shared workspaces
- `events` - Calendar events
- `todos` - Tasks
- `notes` - Notes

## Monetization

- **Free Tier**: Basic features with banner ads
- **Premium**: $2.99/month subscription removes ads and unlocks advanced features
- Ads displayed on: Calendar view, Task list, Notes editor (banner at bottom)

## Future Roadmap

### Phase 1 (Current - MVP)
- [x] Authentication
- [x] Calendar (month/week/day views)
- [x] Tasks with priority & due dates
- [x] Notes with calendar linking
- [x] Family groups
- [x] Ad integration
- [x] Premium subscription

### Phase 2 (Next)
- [ ] Apple Watch app & complications
- [ ] Recurring events
- [ ] File attachments
- [ ] Rich text editor for notes
- [ ] Advanced workspace permissions
- [ ] Offline mode

### Phase 3 (Future)
- [ ] Android app
- [ ] Web app
- [ ] Widget extensions
- [ ] Siri shortcuts
- [ ] Advanced analytics

## Testing

Run on a real device for full functionality (Sign in with Apple requires physical device).

```bash
# Test mode uses AdMob test IDs
# See AppConfig.swift DEBUG section
```

## Contributing

This is a private project. For questions or issues, contact the development team.

## License

Proprietary - All rights reserved.

