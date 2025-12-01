# Firebase Firestore Indexes

## Required Composite Indexes

The app requires several composite indexes for efficient querying. You have two options to create them:

### Option 1: Automatic (Click the Links)

When you see these errors in the console, click the provided links to automatically create the indexes:

1. **Events Index** (workspaceId + startDate):
   ```
   https://console.firebase.google.com/v1/r/project/lifeplanner-ccf8f/firestore/indexes?create_composite=...
   ```

2. **Todos Index** (workspaceId + completedAt):
   ```
   https://console.firebase.google.com/v1/r/project/lifeplanner-ccf8f/firestore/indexes?create_composite=...
   ```

3. **Notes Index** (isPinned + workspaceId + updatedAt):
   ```
   https://console.firebase.google.com/v1/r/project/lifeplanner-ccf8f/firestore/indexes?create_composite=...
   ```

### Option 2: Deploy via Firebase CLI

1. Install Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```bash
   cd "/Users/jaymills/Documents/Code 2025/LifePlanner"
   firebase init firestore
   ```
   - Select your project: `lifeplanner-ccf8f`
   - Use `firestore.rules` for rules
   - Use `firestore.indexes.json` for indexes

4. Deploy the indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```

### Option 3: Manual Creation

Go to [Firebase Console](https://console.firebase.google.com/project/lifeplanner-ccf8f/firestore/indexes):

1. Click "Create Index"
2. For each index below, add the fields in order:

**Events Index:**
- Collection: `events`
- Fields:
  - `workspaceId` (Ascending)
  - `startDate` (Ascending)

**Todos Index:**
- Collection: `todos`
- Fields:
  - `workspaceId` (Ascending)
  - `completedAt` (Ascending)

**Notes Index:**
- Collection: `notes`
- Fields:
  - `isPinned` (Ascending)
  - `workspaceId` (Ascending)
  - `updatedAt` (Descending)

## Index Build Time

After creating indexes, Firebase will build them. This typically takes:
- Small datasets (< 1000 docs): 1-2 minutes
- Medium datasets: 5-10 minutes
- Large datasets: Can take hours

You'll receive an email when indexes are ready, or check status in the Firebase Console.

## Why These Indexes Are Needed

- **Events Index**: Efficiently query events by workspace and sort by start date
- **Todos Index**: Query todos by workspace and filter by completion status
- **Notes Index**: Query pinned notes by workspace and sort by update time

Without these indexes, Firestore cannot execute the compound queries used in the app.

