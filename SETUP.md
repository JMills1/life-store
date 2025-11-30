# LifePlanner - Setup Guide

## 🔥 Firebase Setup (DO THIS FIRST)

### 1. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create new project: "LifePlanner"
3. Enable Google Analytics (optional)

### 2. Add iOS App
1. Click "Add app" → iOS
2. Bundle ID: `com.jaymills.LifePlanner` (update in Xcode if different)
3. Download `GoogleService-Info.plist`
4. **IMPORTANT**: Drag this file into Xcode project (LifeNotes folder)

### 3. Enable Firebase Services
In Firebase Console:
- **Authentication** → Sign-in method → Enable:
  - Apple (requires Apple Developer setup)
  - Email/Password
- **Firestore Database** → Create database → Start in **test mode** (we'll add security rules later)
- **Cloud Messaging** → Enable
- **Storage** → Create bucket

### 4. Apple Developer Setup (for Sign in with Apple)
1. Go to https://developer.apple.com
2. Certificates, Identifiers & Profiles → Identifiers
3. Select your app → Enable "Sign in with Apple"
4. In Firebase: Auth → Sign-in method → Apple → Add your Service ID

---

## 📦 Dependencies (Add via SPM in Xcode)

### File → Add Package Dependencies:

1. **Firebase iOS SDK**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: Latest (11.x)
   - Select:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseMessaging
     - FirebaseStorage

2. **Google Mobile Ads** (for banner ads)
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
   - Version: Latest (11.x)

---

## 🎨 Color Scheme

**Primary**: Mint Green `#4CAF50`
**Secondary**: Soft Blue `#64B5F6`
**Accent**: Warm Coral `#FF8A65`

Users can customize in settings!

---

## 💰 Monetization Setup

### Google AdMob
1. Create account: https://admob.google.com
2. Create App → Add iOS app
3. Create Ad Units:
   - Banner ad (320x50) for calendar/notes/todos
4. Copy App ID and Ad Unit IDs to `Config.swift`

### In-App Purchases (Premium)
1. App Store Connect → Your App → Features → In-App Purchases
2. Create Auto-Renewable Subscription:
   - Product ID: `com.jaymills.lifeplanner.premium.monthly`
   - Price: $2.99/month
   - Benefits: No ads, unlimited workspaces, priority support

---

## 🧪 Testing

- Run on **real device** for Sign in with Apple testing
- Simulator works for most features but not Apple auth
- Test ads in "test mode" before production

---

## 🚀 Ready to Build!

Once Firebase is configured, the app will handle:
- ✅ Authentication
- ✅ Real-time sync
- ✅ Cloud storage
- ✅ Push notifications
- ✅ Multi-platform (iOS now, Android later)

**Next**: Open Xcode and let's start building! 🎉

