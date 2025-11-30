# Get Started with LifePlanner

## 🎯 Quick Overview

You now have a complete iOS app with:
- Authentication (Apple + Email)
- Calendar with 3 view modes
- Task management
- Notes
- Family workspaces
- Premium subscription
- Ad monetization

## ✅ What to Do Next

### Step 1: Xcode Setup (5 minutes)

```bash
# Open the project
cd "/Users/jaymills/Documents/Code 2025/LifePlanner/LifeNotes"
open LifeNotes.xcodeproj
```

**In Xcode:**
1. Check that all new files are visible in Project Navigator
2. If files are missing, drag the folders from Finder into Xcode
3. Ensure files are in the "LifeNotes" target

### Step 2: Add Dependencies (10 minutes)

**File → Add Package Dependencies**

Add these two packages:

1. Firebase iOS SDK
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
   Select: FirebaseAuth, FirebaseFirestore, FirebaseMessaging, FirebaseStorage

2. Google Mobile Ads
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads
   ```
   Select: GoogleMobileAds

### Step 3: Firebase Setup (15 minutes)

Follow the detailed guide in `QUICKSTART.md`

**Quick version:**
1. Go to https://console.firebase.google.com
2. Create project: "LifePlanner"
3. Add iOS app with your bundle ID
4. Download `GoogleService-Info.plist`
5. Drag into Xcode (LifeNotes folder)
6. Enable Authentication (Email + Apple)
7. Create Firestore database (test mode)
8. Enable Cloud Messaging
9. Enable Storage

### Step 4: Configure Info.plist

Add to `LifeNotes/LifeNotes/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

See `Info.plist.example` for complete configuration.

### Step 5: Capabilities

**In Xcode → Target → Signing & Capabilities:**

1. Add "Push Notifications"
2. Add "Background Modes" → Check "Remote notifications"
3. Add "Sign in with Apple"

### Step 6: Build & Test

```
Cmd + B to build
Cmd + R to run
```

**First run checklist:**
- [ ] App launches without crashes
- [ ] Login screen appears
- [ ] Can create account with email/password
- [ ] Can navigate to all tabs
- [ ] Calendar displays correctly
- [ ] Can create events
- [ ] Can create tasks
- [ ] Can create notes

## 🎨 Customization

### Change Colors
Edit `LifeNotes/LifeNotes/Shared/Theme/AppTheme.swift`

```swift
// Change primary color (currently light green)
static let primary = Color(hex: "YOUR_HEX_COLOR")
```

### Update App Name
1. Xcode → Target → General → Display Name
2. Update in `AppConfig.swift`

### Configure Ads
1. Create AdMob account: https://admob.google.com
2. Get your App ID and Ad Unit IDs
3. Update `AppConfig.swift`:

```swift
static let appID = "YOUR_ADMOB_APP_ID"
static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
```

## 🐛 Common Issues

### Build Errors

**"GoogleService-Info.plist not found"**
- Make sure file is in Xcode, not just Finder
- Check target membership is "LifeNotes"

**"Cannot find 'Firebase' in scope"**
- Add Firebase package dependency
- Clean build folder (Cmd + Shift + K)
- Rebuild

**"Multiple commands produce..."**
- Delete DerivedData folder
- Clean build folder
- Rebuild

### Runtime Errors

**"Sign in with Apple not working"**
- Use real device (not simulator)
- Check Apple Developer account setup
- Verify bundle ID matches

**"Firebase connection failed"**
- Check `GoogleService-Info.plist` is correct file
- Verify internet connection
- Check Firebase Console for project status

## 📱 Testing on Device

For Sign in with Apple to work:
1. Connect iPhone via USB
2. Select your iPhone as target in Xcode
3. Cmd + R to run
4. Trust developer certificate on iPhone (Settings → General → VPN & Device Management)

## 🚀 Next Steps

### Short Term
1. Test all features thoroughly
2. Add test data (events, tasks, notes)
3. Create family group
4. Test workspace sharing
5. Review UI/UX

### Before Launch
1. Production AdMob setup
2. In-App Purchase configuration
3. Privacy policy
4. App Store screenshots
5. App description and keywords

### Post-Launch
1. Monitor crash reports
2. Collect user feedback
3. Plan feature updates
4. Add Apple Watch extension
5. Consider Android version

## 📚 Documentation

- **QUICKSTART.md** - Detailed setup instructions
- **SETUP.md** - Firebase configuration
- **DEPLOYMENT.md** - App Store submission
- **PROJECT_SUMMARY.md** - Complete overview
- **WATCH_SETUP.md** - Apple Watch (future)

## 🎯 Development Tips

1. **Use Test AdMob IDs** during development (already configured)
2. **Firebase Emulator** for local testing (advanced)
3. **TestFlight** for beta testing
4. **SwiftUI Previews** for quick UI iteration
5. **Breakpoints** for debugging auth and data flow

## 🔒 Security

- Firebase security rules are in `firestore.rules`
- Deploy them with: `firebase deploy --only firestore:rules`
- Never commit production API keys to git
- Use .gitignore for sensitive files

## 💡 Feature Ideas

Based on your requirements, future enhancements:
- Recurring events
- File attachments to notes
- Rich text formatting
- Calendar export/import
- Custom reminders
- Voice notes
- Shared task assignment
- Calendar templates
- Goal tracking

## ✨ You're All Set!

Your LifePlanner app is ready to build and test. Follow the steps above, and you'll have a working app in under 30 minutes.

**Need help?**
- Check the documentation files
- Review Firebase Console for errors
- Check Xcode debug console for logs

Happy coding! 🚀

