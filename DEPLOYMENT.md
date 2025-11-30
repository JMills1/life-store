# Deployment Guide

## Firebase Deployment

### 1. Deploy Firestore Security Rules

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project (if not already done)
firebase init firestore

# Deploy security rules
firebase deploy --only firestore:rules
```

### 2. Set up Firebase Cloud Functions (Optional)

Create Cloud Functions for:
- Sending push notifications
- Cleaning up deleted data
- Generating invite codes
- Processing subscriptions

### 3. Configure Firebase Cloud Messaging

1. In Firebase Console → Cloud Messaging
2. Upload APNs certificates (for iOS push notifications)
3. Copy Server Key for backend use

## App Store Deployment

### 1. Prepare App for Release

```swift
// Update version in AppConfig.swift
static let version = "1.0.0"

// Build number in Xcode
// Target → General → Identity → Build
```

### 2. App Store Connect Setup

1. Create app in App Store Connect
2. Fill in App Information
   - Name: LifePlanner
   - Bundle ID: com.jaymills.lifeplanner
   - Primary Language: English
   - Category: Productivity

3. Upload Screenshots
   - 6.7" display (iPhone 15 Pro Max)
   - 6.5" display (iPhone 11 Pro Max)
   - 5.5" display (iPhone 8 Plus)

4. App Privacy
   - Data collected: Email, Name, Calendar data, Tasks, Notes
   - Data usage: App functionality, Analytics
   - Third-party analytics: Firebase

### 3. In-App Purchases Setup

1. App Store Connect → Features → In-App Purchases
2. Create Auto-Renewable Subscription
   - Reference Name: Premium Monthly
   - Product ID: com.jaymills.lifeplanner.premium.monthly
   - Price: $2.99/month
   - Description: Remove ads, unlimited workspaces, advanced features

3. Create Subscription Group
   - Name: Premium Subscriptions
   - Add monthly subscription

4. Set up promotional offers
   - 7-day free trial

### 4. Archive and Upload

```bash
# In Xcode
# 1. Select "Any iOS Device" as target
# 2. Product → Archive
# 3. Wait for archive to complete
# 4. Distribute App → App Store Connect
# 5. Upload
```

### 5. TestFlight (Beta Testing)

1. App Store Connect → TestFlight
2. Add internal testers (up to 100)
3. Add external testers (up to 10,000)
4. Collect feedback before production release

### 6. Submit for Review

1. Complete all required information
2. Submit for review
3. Typical review time: 24-48 hours

## Monitoring

### Firebase Analytics
- Track user engagement
- Monitor crash reports
- Analyze feature usage

### AdMob
- Monitor ad performance
- Track revenue
- Optimize ad placement

### App Store Analytics
- Downloads
- Retention
- Subscription metrics

## Post-Launch Checklist

- [ ] Monitor crash reports
- [ ] Check Firebase usage (ensure within free tier)
- [ ] Monitor subscription conversions
- [ ] Collect user feedback
- [ ] Plan feature updates
- [ ] Schedule regular security audits

