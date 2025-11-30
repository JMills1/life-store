# Installation & Setup Checklist

## Pre-Flight Check

Run these commands to verify your environment:

```bash
# Check Xcode version (need 15+)
xcodebuild -version

# Check Swift version
swift --version

# Check if you're logged into Apple Developer
# (Required for Sign in with Apple)
```

## Step-by-Step Installation

### 1. Open Xcode Project
```bash
cd "/Users/jaymills/Documents/Code 2025/LifePlanner/LifeNotes"
open LifeNotes.xcodeproj
```

### 2. Install Swift Packages

**File → Add Package Dependencies**

#### Package 1: Firebase iOS SDK
```
URL: https://github.com/firebase/firebase-ios-sdk
Version: 11.4.2 (or latest)
```

**Select these packages:**
- [x] FirebaseAuth
- [x] FirebaseFirestore
- [x] FirebaseMessaging
- [x] FirebaseStorage
- [x] FirebaseCore (auto-selected)

**Add to target:** LifeNotes

#### Package 2: Google Mobile Ads
```
URL: https://github.com/googleads/swift-package-manager-google-mobile-ads
Version: 11.12.0 (or latest)
```

**Select:**
- [x] GoogleMobileAds

**Add to target:** LifeNotes

### 3. Firebase Console Setup

#### Create Project
1. Go to: https://console.firebase.google.com
2. Click "Create a project"
3. Project name: **LifePlanner**
4. Disable Google Analytics for now (can enable later)
5. Create project

#### Add iOS App
1. Click iOS icon
2. **iOS bundle ID**: Get from Xcode
   - Xcode → Select LifeNotes target → General → Bundle Identifier
   - Should be: `com.jaymills.LifeNotes` (or similar)
3. App nickname: LifePlanner
4. Download **GoogleService-Info.plist**
5. **IMPORTANT**: Drag this file into Xcode
   - Put in: LifeNotes/LifeNotes folder (same level as LifeNotesApp.swift)
   - Check "Copy items if needed"
   - Target membership: LifeNotes (checked)

#### Enable Authentication
1. Firebase Console → Build → Authentication
2. Click "Get started"
3. Sign-in method tab
4. Enable **Email/Password**
   - Click Email/Password
   - Enable toggle
   - Save
5. Enable **Apple** (requires Apple Developer account)
   - Will configure Apple side later

#### Create Firestore Database
1. Firebase Console → Build → Firestore Database
2. Click "Create database"
3. **Start in test mode** (we'll secure it later)
4. Location: Choose closest (e.g., us-central)
5. Click Enable
6. Wait for provisioning (~30 seconds)

#### Enable Cloud Messaging
1. Firebase Console → Build → Cloud Messaging
2. No setup needed yet
3. Note: Will need APNs key for production

#### Enable Storage
1. Firebase Console → Build → Storage
2. Click "Get started"
3. Start in **test mode**
4. Use default location
5. Done

### 4. Configure Info.plist

**Location**: `LifeNotes/LifeNotes/Info.plist`

Right-click Info.plist → Open As → Source Code

Add these entries inside the `<dict>` tag:

```xml
<!-- AdMob Configuration -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Privacy Descriptions -->
<key>NSUserTrackingUsageDescription</key>
<string>We use tracking to show you relevant ads</string>

<key>NSCalendarsUsageDescription</key>
<string>Access your calendar to sync events</string>

<key>NSRemindersUsageDescription</key>
<string>Create reminders for your tasks</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Upload photos to notes and events</string>

<key>NSCameraUsageDescription</key>
<string>Take photos for notes</string>
```

### 5. Configure Xcode Capabilities

1. Select **LifeNotes** target
2. **Signing & Capabilities** tab
3. Click **"+ Capability"**

Add these capabilities:
- [x] **Push Notifications**
- [x] **Background Modes**
  - Check: Remote notifications
- [x] **Sign in with Apple**

### 6. Deploy Firebase Security Rules

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Or with Homebrew
brew install firebase-cli

# Login to Firebase
firebase login

# Initialize Firestore (in project root)
cd "/Users/jaymills/Documents/Code 2025/LifePlanner"
firebase init firestore

# Select your Firebase project from list
# Use existing firestore.rules and firestore.indexes.json

# Deploy security rules
firebase deploy --only firestore:rules
```

### 7. Apple Developer Account Setup (for Sign in with Apple)

#### Configure App ID
1. https://developer.apple.com/account
2. Certificates, Identifiers & Profiles
3. Identifiers → App IDs
4. Find your app (or create if needed)
5. Capabilities → Check **Sign in with Apple**
6. Save

#### Get Service ID for Firebase (Optional - Advanced)
1. Identifiers → Services IDs → "+"
2. Create service ID for Firebase
3. Configure with your domain
4. Add to Firebase Console → Authentication → Apple

### 8. Build Configuration

#### Update Bundle Identifier (if needed)
1. Xcode → LifeNotes target → General
2. Identity → Bundle Identifier
3. Should match Firebase: `com.jaymills.LifeNotes`

#### Signing
1. Signing & Capabilities tab
2. Team: Select your Apple Developer team
3. Automatically manage signing: Checked

### 9. Verify Installation

#### Check Package Dependencies
1. Project Navigator → LifeNotes project
2. Package Dependencies section
3. Should see:
   - firebase-ios-sdk (11.4.2 or similar)
   - swift-package-manager-google-mobile-ads (11.12.0 or similar)

#### Check Files
- [x] GoogleService-Info.plist in LifeNotes folder
- [x] Info.plist has AdMob app ID
- [x] All source files visible in Project Navigator
- [x] Capabilities enabled

### 10. First Build

```bash
# Clean build folder
Cmd + Shift + K

# Build
Cmd + B
```

**Expected result**: Build succeeds with 0 errors

**If build fails**, check:
- All packages installed correctly
- GoogleService-Info.plist is in target
- Info.plist entries correct
- No syntax errors (shouldn't be any)

### 11. First Run

```bash
# Run on simulator
Cmd + R

# Or select iPhone/iPad from device menu first
```

**Expected behavior**:
1. App launches
2. Shows LoginView with gradient background
3. Can see "Sign In", "Sign Up", "Sign in with Apple" buttons
4. No crashes

**Note**: Sign in with Apple requires a real device, not simulator

## Post-Installation Verification

### Test Checklist
- [ ] App launches without crash
- [ ] LoginView displays correctly
- [ ] Can navigate to SignUpView
- [ ] Can create account (email/password)
- [ ] Redirects to MainTabView after login
- [ ] All 5 tabs visible (Calendar, Tasks, Notes, Family, Settings)
- [ ] No Firebase connection errors in console

### Common Issues

#### "GoogleService-Info.plist not found"
- Check file is in Xcode, not just Finder
- Check target membership
- Clean and rebuild

#### "Cannot find 'Firebase' in scope"
- Package dependency not added
- Clean derived data: Xcode → Product → Clean Build Folder
- Restart Xcode

#### "Sign in with Apple failed"
- Normal on simulator
- Use real device
- Check Apple Developer account

#### Build errors about duplicate symbols
- Clean derived data
- Delete DerivedData folder manually
- Restart Xcode

## Firebase Console Verification

After first run, check Firebase:
1. Authentication → Users (should be empty initially)
2. Firestore → Data (should show empty collections)
3. No errors in console

## Next Steps

Once installation complete:
1. Create test account
2. Add test data (events, tasks, notes)
3. Run full test suite (see TEST_SUITE.md)
4. Verify all features work

## Time Estimate

- Package installation: 5 minutes
- Firebase setup: 15 minutes
- Info.plist config: 2 minutes
- Capabilities: 2 minutes
- First build: 2 minutes
- **Total: ~30 minutes**

