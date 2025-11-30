# Quick Start Guide

## Step 1: Firebase Setup (15 minutes)

### Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: "LifePlanner"
4. Continue through setup

### Add iOS App
1. Click iOS icon in project overview
2. iOS bundle ID: `com.jaymills.lifeplanner` (or your bundle ID from Xcode)
3. Download `GoogleService-Info.plist`
4. **Important**: Drag `GoogleService-Info.plist` into Xcode (LifeNotes folder)
   - Make sure "Copy items if needed" is checked
   - Target: LifeNotes

### Enable Firebase Services

#### Authentication
1. Firebase Console → Authentication → Get Started
2. Sign-in method tab
3. Enable **Email/Password**
4. Enable **Apple** (requires Apple Developer account)
   - For Apple Sign-In, you'll need to configure your Service ID in Apple Developer

#### Firestore Database
1. Firebase Console → Firestore Database → Create database
2. Start in **test mode** (we'll add security rules later)
3. Location: Choose closest to your users (e.g., us-central)
4. Click Enable

#### Cloud Messaging
1. Firebase Console → Cloud Messaging
2. No immediate setup needed
3. iOS APNs certificates will be needed for production

#### Storage
1. Firebase Console → Storage → Get Started
2. Start in test mode
3. Click Done

### Deploy Security Rules
```bash
# In terminal, from project root
firebase login
firebase init firestore
# Select your Firebase project
firebase deploy --only firestore:rules
```

## Step 2: Xcode Setup (10 minutes)

### Open Project
```bash
cd "/Users/jaymills/Documents/Code 2025/LifePlanner/LifeNotes"
open LifeNotes.xcodeproj
```

### Add Swift Packages

1. File → Add Package Dependencies
2. Add **Firebase iOS SDK**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: Up to Next Major Version (11.0.0)
   - Select packages:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseMessaging
     - FirebaseStorage

3. Add **Google Mobile Ads**
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
   - Version: Latest
   - Select: GoogleMobileAds

### Configure Info.plist

Add these entries to `Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>NSUserTrackingUsageDescription</key>
<string>We use tracking to show you relevant ads</string>

<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendar to sync events</string>
```

### Configure Capabilities

1. Select LifeNotes target
2. Signing & Capabilities tab
3. Click "+ Capability"
4. Add:
   - **Push Notifications**
   - **Background Modes** → Remote notifications
   - **Sign in with Apple**

### Update Bundle Identifier

1. Target → General → Identity
2. Bundle Identifier: `com.jaymills.lifeplanner`
3. Signing → Team: Select your team

## Step 3: Apple Developer Setup (Sign in with Apple)

### Configure App ID
1. https://developer.apple.com
2. Certificates, Identifiers & Profiles
3. Identifiers → Select your app
4. Scroll to "Sign in with Apple"
5. Check "Enable as a primary App ID"
6. Save

### Add Service ID (for Firebase)
1. Identifiers → "+" → Services IDs
2. Create new Service ID
3. Use this in Firebase Console → Authentication → Apple

## Step 4: AdMob Setup (Optional for MVP)

### Create AdMob Account
1. Go to https://admob.google.com
2. Sign in with Google account
3. Click "Get Started"

### Create App
1. Apps → Add App
2. Platform: iOS
3. App name: LifePlanner
4. Add app

### Create Ad Units
1. Select your app
2. Ad units → Add ad unit
3. Select **Banner**
4. Name: "Calendar Banner", "Tasks Banner", "Notes Banner"
5. Copy Ad Unit IDs

### Update AppConfig.swift
```swift
// Replace in AppConfig.swift
static let appID = "YOUR_ADMOB_APP_ID"
static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
```

For testing, the default test IDs work fine!

## Step 5: Build & Run

### Select Target
1. In Xcode, select target device (simulator or physical device)
2. For Sign in with Apple, use a **real device**

### Build
```
Cmd + B (or Product → Build)
```

### Run
```
Cmd + R (or Product → Run)
```

## Step 6: Test Core Features

### Test Authentication
1. Launch app
2. Click "Sign Up"
3. Enter email, password, name
4. Create account
5. Should redirect to main app

### Test Calendar
1. Click Calendar tab
2. Tap "+" to create event
3. Fill in details
4. Save
5. Event should appear on calendar

### Test Tasks
1. Click Tasks tab
2. Tap "+" to create task
3. Set title, priority, due date
4. Save
5. Task should appear in list

### Test Notes
1. Click Notes tab
2. Tap pencil icon
3. Create note
4. Save
5. Note should appear in list

## Common Issues

### GoogleService-Info.plist not found
- Make sure file is in Xcode project
- Check target membership (should be checked for LifeNotes target)

### Sign in with Apple not working
- Use real device (doesn't work in simulator)
- Check Apple Developer account setup
- Verify bundle ID matches

### Firebase connection failed
- Check `GoogleService-Info.plist` is correct
- Verify Firebase project configuration
- Check internet connection

### Ads not showing
- Test ads only work in test mode
- Check AdMob app ID in Info.plist
- Verify GoogleMobileAds package is installed

## Next Steps

1. **Customize Theme**
   - Edit `AppTheme.swift` to change colors
   - User preference for theme coming in future update

2. **Add Family Members**
   - Create family group in Family tab
   - Generate invite code
   - Share with family

3. **Test Premium**
   - Click Settings → Upgrade to Premium
   - Test subscription flow (will use sandbox in development)

4. **Deploy**
   - See `DEPLOYMENT.md` for App Store submission
   - Configure production AdMob IDs
   - Set up production Firebase

## Support

For issues or questions:
- Check Firebase Console for errors
- Review Xcode debug console
- Test on different devices
- Verify all setup steps completed

## Development Tips

- Use test AdMob IDs during development
- Firebase Emulator Suite for local testing (advanced)
- TestFlight for beta testing before App Store
- Monitor Firebase usage (free tier limits)

