# Setup Guide

Complete setup instructions for LifePlanner iOS app.

## Prerequisites

1. **Xcode 15.0+** installed
2. **Firebase account** (free tier works)
3. **Google AdMob account** (optional, for ads)
4. **Apple Developer account** (for Sign in with Apple)

## Step 1: Clone the Repository

```bash
git clone https://github.com/JMills1/life-store.git
cd life-store
```

## Step 2: Firebase Setup

### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "LifePlanner" (or your choice)
4. Disable Google Analytics (optional)
5. Click "Create project"

### Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. **iOS bundle ID**: `com.yourcompany.LifeNotes` (match your Xcode project)
3. **App nickname**: LifePlanner
4. Download `GoogleService-Info.plist`
5. Add `GoogleService-Info.plist` to `LifeNotes/LifeNotes/` folder in Xcode

### Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable:
   - **Email/Password**
   - **Apple** (requires Apple Developer account)

#### Firestore Database
1. Go to Firestore Database → Create database
2. Start in **test mode** (we'll add security rules later)
3. Choose a location close to your users

#### Deploy Security Rules
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
cd life-store
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

The security rules are in `firestore.rules` file.

## Step 3: Xcode Configuration

### Open Project
```bash
open LifeNotes/LifeNotes.xcodeproj
```

### Add Dependencies

1. **File → Add Package Dependencies**
2. Add Firebase iOS SDK:
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: 10.0.0 or later
   - Select packages:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseStorage
     - FirebaseMessaging

3. Add Google Mobile Ads SDK:
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
   - Version: Latest
   - Select: GoogleMobileAds

### Configure Bundle Identifier

1. Select project in navigator
2. Select "LifeNotes" target
3. Change **Bundle Identifier** to match your Firebase iOS app
4. Example: `com.yourcompany.LifeNotes`

### Add AdMob App ID

1. Get your AdMob App ID from [AdMob Console](https://apps.admob.com/)
2. In Xcode, select project → LifeNotes target → Info tab
3. Add new key:
   - **Key**: `GADApplicationIdentifier`
   - **Type**: String
   - **Value**: Your AdMob App ID (e.g., `ca-app-pub-3940256099942544~1458002511` for test)

### Configure Sign in with Apple

1. Select project → LifeNotes target → Signing & Capabilities
2. Click "+ Capability"
3. Add "Sign in with Apple"
4. Ensure your Apple Developer account is configured

## Step 4: Build and Run

1. Select a simulator or device
2. Press **Cmd + B** to build
3. Press **Cmd + R** to run

## Step 5: Create Test Account

1. Launch app in simulator
2. Tap "Sign Up"
3. Enter email and password
4. Create your first workspace

## Troubleshooting

### Build Errors

**"No such module 'FirebaseAuth'"**
- Ensure Firebase packages are added via Swift Package Manager
- Clean build folder: **Cmd + Shift + K**
- Rebuild: **Cmd + B**

**"GoogleService-Info.plist not found"**
- Download from Firebase Console
- Drag into Xcode project (LifeNotes folder)
- Ensure "Copy items if needed" is checked

### Runtime Errors

**"Google Mobile Ads SDK was initialized without an application ID"**
- Add `GADApplicationIdentifier` to Info.plist
- Use test App ID: `ca-app-pub-3940256099942544~1458002511`

**"Firebase not configured"**
- Ensure `GoogleService-Info.plist` is in the app bundle
- Check bundle identifier matches Firebase project

### Authentication Issues

**Sign in with Apple not working**
- Ensure capability is added in Xcode
- Check Apple Developer account is valid
- Test on physical device (doesn't work in some simulators)

## Optional: Apple Watch Setup

See `WATCH_SETUP.md` for Apple Watch widget configuration.

## Next Steps

- Customize app colors in `AppTheme.swift`
- Configure notifications in Settings
- Create workspaces and invite family members
- Deploy Firestore security rules for production

## Production Checklist

Before releasing to App Store:

- [ ] Replace AdMob test IDs with production IDs
- [ ] Deploy Firestore security rules
- [ ] Configure Firebase App Check
- [ ] Enable Firebase Analytics (optional)
- [ ] Test on physical devices
- [ ] Configure push notifications
- [ ] Set up App Store Connect
- [ ] Create app screenshots and description
- [ ] Submit for review

## Support

For issues, please check:
1. [Firebase Documentation](https://firebase.google.com/docs/ios/setup)
2. [GitHub Issues](https://github.com/JMills1/life-store/issues)
