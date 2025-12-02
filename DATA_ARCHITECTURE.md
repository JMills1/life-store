# Data Architecture & Storage

## Overview
LifePlanner uses **Firebase Firestore** as the primary database, which provides automatic server-side storage with built-in offline capabilities.

## Current Implementation

### ✅ Server-Side Storage (Firebase Firestore)

All data is stored on Firebase servers:

#### **Collections:**
1. **`users/`** - User profiles and preferences
2. **`workspaces/`** - Personal and shared workspaces
3. **`events/`** - Calendar events
4. **`todos/`** - Tasks and to-do items
5. **`notes/`** - Notes and documents
6. **`families/`** - Family group information

### ✅ Automatic Local Caching

Firebase Firestore provides **automatic offline persistence**:

- **Read-only when offline**: Users can view cached data
- **Queued writes**: Changes made offline are queued and synced when online
- **Automatic sync**: Data syncs automatically when connection is restored
- **No custom code needed**: Built into Firebase SDK

### Current Behavior:

#### **When Online:**
- ✅ Full read/write access
- ✅ Real-time updates
- ✅ Immediate sync across devices
- ✅ Data stored on Firebase servers

#### **When Offline:**
- ✅ Can view previously loaded data (cached)
- ✅ Can make changes (queued for sync)
- ⚠️ Changes sync when connection restored
- ❌ Cannot load new data not in cache

## Your Requirement: View-Only Offline Mode

You want users to:
- ✅ View locally cached data when offline
- ❌ NOT be able to interact/edit when offline

### Implementation Options:

### **Option 1: Disable Offline Persistence (Recommended)**
Make all operations require internet connection.

```swift
// In FirebaseConfig.swift
let settings = FirestoreSettings()
settings.isPersistenceEnabled = false // Disable offline cache
Firestore.firestore().settings = settings
```

**Pros:**
- Simple implementation
- No offline edits possible
- Always shows latest data

**Cons:**
- No offline viewing at all
- App won't work without internet

---

### **Option 2: Read-Only Offline Mode (Best for Your Needs)**
Allow viewing cached data but prevent edits when offline.

```swift
// Check network status before any write operation
func isOnline() -> Bool {
    // Use network reachability check
    return NetworkMonitor.shared.isConnected
}

// Before any create/update/delete
guard isOnline() else {
    showAlert("You must be online to make changes")
    return
}
```

**Pros:**
- Users can view cached data offline
- Prevents offline edits
- Clear user feedback

**Cons:**
- Requires network monitoring
- Need to add checks to all write operations

---

### **Option 3: Firestore's Default (Current)**
Allow offline edits, sync when online.

**Pros:**
- Best user experience
- No data loss
- Automatic sync

**Cons:**
- Users can edit offline (may cause confusion)
- Potential sync conflicts

---

## Recommendation

Based on your requirements, I recommend **Option 2: Read-Only Offline Mode**.

### Implementation Plan:

1. **Add Network Monitor**
   - Detect online/offline status
   - Update UI to show connection state

2. **Disable Write Operations When Offline**
   - Show "Offline Mode" banner
   - Disable create/edit buttons
   - Show alert if user tries to edit

3. **Keep Firestore Persistence Enabled**
   - Users can still view cached data
   - Data syncs automatically when online

### Benefits:
- ✅ View cached data offline
- ✅ Cannot edit offline
- ✅ Clear user feedback
- ✅ Automatic sync when online
- ✅ All data stored server-side

## Current Data Flow

```
User Action
    ↓
SwiftUI View
    ↓
ViewModel
    ↓
FirestoreRepository / Service
    ↓
Firebase SDK
    ↓
[If Online] → Firebase Servers → ✅ Saved
[If Offline] → Local Cache → ⏳ Queued for sync
```

## No Local-Only Storage

The app currently does NOT use:
- ❌ UserDefaults (except for system preferences)
- ❌ Core Data
- ❌ Local file storage
- ❌ SQLite
- ❌ Realm

Everything goes through Firebase Firestore.

## Would You Like Me To Implement?

I can implement **Option 2 (Read-Only Offline Mode)** which will:

1. Add a `NetworkMonitor` service
2. Show "Offline" indicator in UI
3. Disable all create/edit/delete buttons when offline
4. Show alerts if user tries to edit offline
5. Keep viewing enabled with cached data

This matches your requirement: **"people can view locally stored data but can't interact more than viewing"**

Let me know if you'd like me to implement this! 🚀

