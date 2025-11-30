# Setup Checklist - Do These NOW

## Critical: Cannot Build Without These Steps

### Step 1: Open Project (30 seconds)
```bash
cd "/Users/jaymills/Documents/Code 2025/LifePlanner/LifeNotes"
open LifeNotes.xcodeproj
```

### Step 2: Add Firebase SDK (5 min)
In Xcode:
1. File → Add Package Dependencies
2. Paste: `https://github.com/firebase/firebase-ios-sdk`
3. Click "Add Package"
4. Select these 4 packages:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseMessaging
   - ✅ FirebaseStorage
5. Click "Add Package"
6. Wait for download (~2 min)

### Step 3: Add Google Mobile Ads SDK (3 min)
In Xcode:
1. File → Add Package Dependencies
2. Paste: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
3. Click "Add Package"
4. Select: GoogleMobileAds
5. Click "Add Package"

### Step 4: Try to Build (1 min)
1. Press Cmd + B (Build)
2. **Expected Result**: 
   - Many errors about "GoogleService-Info.plist not found"
   - This is GOOD - means packages are installed!

### Step 5: Create Firebase Project (15 min)

#### 5a. Create Project
1. Go to: https://console.firebase.google.com
2. Click "Add project" or "Create a project"
3. Project name: **LifePlanner**
4. Google Analytics: **Disable** (for now)
5. Click "Create project"
6. Wait 30 seconds

#### 5b. Add iOS App
1. Click iOS icon (or "Add app" → iOS)
2. **Bundle ID**: 
   - Check Xcode → Select "LifeNotes" target → General tab → Bundle Identifier
   - Copy the bundle ID (probably `com.jaymills.LifeNotes`)
   - Paste into Firebase
3. App nickname: **LifePlanner**
4. Click "Register app"
5. **Download GoogleService-Info.plist** ⬇️
6. Click "Next" (skip SDK setup - we already did it)
7. Click "Continue to console"

#### 5c. Drag GoogleService-Info.plist into Xcode
**CRITICAL STEP**:
1. Find downloaded `GoogleService-Info.plist` in Downloads
2. Drag it into Xcode
3. Drop it in: `LifeNotes/LifeNotes/` folder (same level as LifeNotesApp.swift)
4. ✅ Check "Copy items if needed"
5. ✅ Make sure "LifeNotes" target is checked
6. Click "Finish"

#### 5d. Enable Firebase Services
In Firebase Console:

**Authentication:**
1. Build → Authentication → Get started
2. Sign-in method tab
3. Click "Email/Password" → Enable → Save
4. (Optional: Click "Apple" → Enable - requires Apple Developer account)

**Firestore Database:**
1. Build → Firestore Database → Create database
2. Select: **Start in test mode** ⚠️
3. Location: **us-central** (or nearest)
4. Click "Enable"
5. Wait 30 seconds

**Storage:**
1. Build → Storage → Get started
2. **Start in test mode** ⚠️
3. Click "Done"

**Cloud Messaging:**
1. Build → Cloud Messaging
2. (No action needed - just verify it exists)

### Step 6: Build Again (1 min)
1. Back in Xcode
2. Press Cmd + B (Build)
3. **Expected Result**: Build SUCCEEDS! ✅

---

## If Build Still Fails

### Common Issues:

**Error: "GoogleService-Info.plist not found"**
- Check file is in Xcode Project Navigator (left sidebar)
- Right-click file → Show in Finder → verify location
- Check target membership (File Inspector → Target Membership → LifeNotes checked)

**Error: "No such module 'FirebaseAuth'"**
- Wait for package download to complete
- Xcode → File → Packages → Resolve Package Versions
- Clean build: Cmd + Shift + K, then Cmd + B

**Error: "Cannot find 'GoogleMobileAds' in scope"**
- Verify package was added
- Restart Xcode
- Clean and rebuild

---

## After Successful Build

Run these commands to verify:

```bash
# Check if packages are installed
ls ~/Library/Developer/Xcode/DerivedData/*/SourcePackages/checkouts/

# Should see:
# - firebase-ios-sdk
# - swift-package-manager-google-mobile-ads
```

Then RUN the app (Cmd + R)!

---

## What You Should See

1. App launches
2. LoginView appears with:
   - Green/blue gradient background
   - "LifePlanner" title
   - Email/Password fields
   - "Sign In" button
   - "Sign Up" button
   - "Sign in with Apple" button

3. Console shows:
   ```
   Firebase configured for DEBUG
   ```

4. No crash, no errors ✅

---

## Once It Runs

Let me know and I'll:
1. Test authentication
2. Test data operations
3. Run comprehensive test suite
4. Fix any bugs
5. Optimize performance

---

## Estimated Time

- Step 1-3: 10 minutes (add packages)
- Step 4: 1 minute (build to verify)
- Step 5: 15 minutes (Firebase setup)
- Step 6: 1 minute (final build)

**Total: ~30 minutes**

Then we're ready to test! 🚀

