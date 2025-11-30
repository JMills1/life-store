# LifePlanner - Optimization Guide

## Current Optimizations (Already Implemented)

### 1. Architecture Optimizations
✅ **MVVM Pattern** - Separation of concerns, testable code
✅ **Repository Pattern** - Abstract data sources for easy swapping
✅ **Singleton Services** - AuthService, NotificationService (one instance)
✅ **Real-time Listeners** - Only active on current workspace (not all workspaces)
✅ **Async/Await** - Modern Swift concurrency, no callback hell

### 2. Firebase Optimizations  
✅ **Indexed Queries** - workspaceId indexed for fast lookup
✅ **Selective Listeners** - Only listen to active workspace data
✅ **Batch Operations** - Ready for batch writes (to implement when needed)
✅ **Security Rules** - Server-side validation reduces client errors

### 3. UI Optimizations
✅ **LazyVStack/LazyVGrid** - Efficient list rendering
✅ **SwiftUI Native** - Optimized by Apple, performant by default
✅ **Minimal Redraws** - @Published only on necessary properties
✅ **Computed Properties** - Cached results for active/completed todos

---

## Performance Improvements Needed

### Priority 1: Critical (Before Launch)

#### 1.1 Add Pagination to Lists
**Problem**: Loading 1000+ items crashes/slows app
**Solution**: Implement Firestore pagination

```swift
// In CalendarViewModel.swift
private var lastDocument: DocumentSnapshot?
private let pageSize = 20

func loadMoreEvents() async {
    guard !isLoading else { return }
    isLoading = true
    
    var query = db.collection("events")
        .whereField("workspaceId", in: workspaceIds)
        .order(by: "startDate")
        .limit(to: pageSize)
    
    if let lastDoc = lastDocument {
        query = query.start(afterDocument: lastDoc)
    }
    
    let snapshot = try? await query.getDocuments()
    lastDocument = snapshot?.documents.last
    // Append to events array
}
```

**Impact**: Handles unlimited events without performance hit
**Time**: 2 hours

#### 1.2 Implement Local Caching with SwiftData
**Problem**: Every app launch fetches from Firebase
**Solution**: Cache data locally, sync in background

```swift
// Create SwiftData models
@Model
class CachedEvent {
    var id: String
    var workspaceId: String
    var title: String
    var startDate: Date
    // ... other fields
    var lastSynced: Date
}

// In ViewModel
func loadEvents() async {
    // 1. Load from cache immediately (fast)
    loadFromCache()
    
    // 2. Fetch from Firebase in background
    await syncFromFirebase()
}
```

**Impact**: Instant app launch, works offline
**Time**: 4 hours

#### 1.3 Optimize Firebase Reads
**Problem**: 50k free reads/day can be exhausted
**Solution**: Smart querying

```swift
// Bad: Loads all events then filters
let allEvents = try await db.collection("events").getDocuments()
let todayEvents = allEvents.filter { isToday($0.startDate) }

// Good: Filter on server
let todayEvents = try await db.collection("events")
    .whereField("workspaceId", isEqualTo: workspaceId)
    .whereField("startDate", isGreaterThanOrEqualTo: startOfToday)
    .whereField("startDate", isLessThan: endOfToday)
    .getDocuments()
```

**Impact**: 10x reduction in Firebase reads
**Time**: 1 hour

---

### Priority 2: Important (Post-Launch Week 1)

#### 2.1 Image Optimization
**When Needed**: After implementing attachments

```swift
// Compress before upload
func compressImage(_ image: UIImage) -> Data? {
    // Resize to max 1024px
    let maxSize = 1024.0
    let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
    let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Compress to JPEG with 0.8 quality
    return resized?.jpegData(compressionQuality: 0.8)
}
```

**Impact**: Faster uploads, reduced storage costs
**Time**: 2 hours

#### 2.2 Debounce Search
**Problem**: Search queries on every keystroke

```swift
// In NotesListView
@State private var searchWorkItem: DispatchWorkItem?

var body: some View {
    .searchable(text: $searchText)
    .onChange(of: searchText) { newValue in
        searchWorkItem?.cancel()
        
        let task = DispatchWorkItem {
            performSearch(newValue)
        }
        searchWorkItem = task
        
        // Wait 300ms before searching
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
}
```

**Impact**: Reduces unnecessary searches
**Time**: 30 minutes

#### 2.3 Preload Adjacent Months
**Problem**: Calendar lag when changing months

```swift
// In MonthView
func preloadAdjacentMonths() {
    Task {
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)
        
        if let next = nextMonth {
            await viewModel.preloadEvents(for: next)
        }
        if let prev = prevMonth {
            await viewModel.preloadEvents(for: prev)
        }
    }
}
```

**Impact**: Instant month switching
**Time**: 1 hour

---

### Priority 3: Nice to Have (Month 1-2)

#### 3.1 Background Sync
**Purpose**: Keep data fresh without user interaction

```swift
// In AppDelegate
func application(_ application: UIApplication, 
                performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Task {
        let hasNewData = await SyncService.shared.syncAll()
        completionHandler(hasNewData ? .newData : .noData)
    }
}
```

#### 3.2 Memory Profiling
**Tool**: Xcode Instruments
**Steps**:
1. Product → Profile
2. Select "Leaks" template
3. Run through common flows
4. Fix any memory leaks

**Common Issues**:
- Retain cycles in closures (use `[weak self]`)
- Firebase listeners not removed (`deinit`)
- Large images not released

#### 3.3 Network Monitoring
```swift
// Add to AppDelegate
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    @Published var isConnected = true
    
    private let monitor = NWPathMonitor()
    
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}

// Show offline banner when disconnected
if !networkMonitor.isConnected {
    OfflineBanner()
}
```

---

## Security Optimizations (Already Good, Can Improve)

### Current State
✅ Firestore security rules deployed
✅ Authentication required for all operations
✅ Workspace-based permissions
✅ HTTPS enforced

### Enhancements

#### 1. Rate Limiting (Cloud Functions)
```javascript
// functions/index.js
exports.createEvent = functions.https.onCall(async (data, context) => {
    const uid = context.auth.uid;
    
    // Check rate limit (max 100 events/hour)
    const recentEvents = await admin.firestore()
        .collection('events')
        .where('createdBy', '==', uid)
        .where('createdAt', '>', Date.now() - 3600000)
        .count()
        .get();
    
    if (recentEvents.data().count > 100) {
        throw new functions.https.HttpsError('resource-exhausted', 'Rate limit exceeded');
    }
    
    // Create event
});
```

#### 2. Input Validation
```swift
// Add to models
extension Event {
    func validate() throws {
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        guard title.count <= 100 else {
            throw ValidationError.titleTooLong
        }
        guard endDate > startDate else {
            throw ValidationError.invalidDateRange
        }
    }
}
```

#### 3. Sanitize User Input
```swift
func sanitize(_ text: String) -> String {
    text
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "<script>", with: "")
        .replacingOccurrences(of: "</script>", with: "")
}
```

---

## Cost Optimization (Firebase)

### Current Free Tier Limits
- Firestore: 50k reads, 20k writes, 20k deletes per day
- Storage: 5 GB
- Authentication: Unlimited

### Optimization Strategies

#### 1. Reduce Reads
```swift
// Use real-time listeners (1 read) instead of repeated gets
// Bad: Polling
Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
    loadEvents() // 12 reads/minute!
}

// Good: Listener
db.collection("events").addSnapshotListener { snapshot, error in
    // Updates automatically, 1 read on subscribe
}
```

#### 2. Composite Indexes
```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "events",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "workspaceId", "order": "ASCENDING" },
        { "fieldPath": "startDate", "order": "ASCENDING" }
      ]
    }
  ]
}
```

#### 3. TTL for Temporary Data
```javascript
// Cloud Function to cleanup old completed tasks
exports.cleanupOldTodos = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const cutoff = Date.now() - (30 * 24 * 60 * 60 * 1000); // 30 days ago
    
    const old = await admin.firestore()
        .collection('todos')
        .where('isCompleted', '==', true)
        .where('completedAt', '<', cutoff)
        .get();
    
    const batch = admin.firestore().batch();
    old.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
});
```

---

## Speed Optimizations

### App Launch Optimization
**Current**: ~2-3 seconds
**Target**: < 1 second

```swift
// In LifePlannerApp
init() {
    // Initialize only critical services
    FirebaseConfig.shared.configure()
    
    // Defer non-critical init
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        NotificationService.shared.requestAuthorization()
        AnalyticsService.shared.initialize()
    }
}
```

### View Rendering Optimization
```swift
// Use @StateObject only when needed
@StateObject private var viewModel = CalendarViewModel() // Creates instance

// Use @ObservedObject when passed from parent
@ObservedObject var viewModel: CalendarViewModel // Observes existing

// Use @State for simple values
@State private var selectedDate = Date()
```

### Lazy Loading
```swift
// Don't load all workspaces
lazy var workspaceService = WorkspaceService()

// Load only visible calendar dates
let visibleDateRange = getVisibleDateRange()
loadEvents(in: visibleDateRange)
```

---

## Monitoring & Analytics

### Performance Monitoring
```swift
// Add Firebase Performance Monitoring
import FirebasePerformance

func loadEvents() async {
    let trace = Performance.startTrace(name: "load_events")
    
    // Load events
    
    trace?.stop()
}
```

### Crash Reporting
```swift
// Add Firebase Crashlytics
import FirebaseCrashlytics

Crashlytics.crashlytics().log("Loading events for workspace: \(workspaceId)")

// Custom keys for debugging
Crashlytics.crashlytics().setCustomValue(workspaceId, forKey: "workspace_id")
```

### User Analytics
```swift
// Track feature usage
Analytics.logEvent("event_created", parameters: [
    "workspace_type": workspace.type.rawValue,
    "has_reminders": !event.reminders.isEmpty
])
```

---

## Optimization Checklist

### Before Launch
- [ ] Implement pagination for lists
- [ ] Add local caching with SwiftData
- [ ] Optimize Firebase queries
- [ ] Deploy security rules
- [ ] Test with 100+ items
- [ ] Profile memory usage
- [ ] Test on older devices (iPhone 11)

### Week 1 Post-Launch
- [ ] Monitor Firebase usage
- [ ] Check crash reports
- [ ] Analyze performance metrics
- [ ] Optimize slow queries
- [ ] Add missing indexes

### Month 1
- [ ] Implement background sync
- [ ] Add offline mode
- [ ] Image optimization
- [ ] Network monitoring
- [ ] Rate limiting

---

## Performance Targets

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| App Launch | < 1s | ~2-3s | 🟨 Needs optimization |
| Event Load | < 500ms | Unknown | ⚪ Test needed |
| Search Response | < 200ms | Unknown | ⚪ Test needed |
| View Switch | < 100ms | Unknown | ⚪ Test needed |
| Memory Usage | < 100MB | Unknown | ⚪ Profile needed |
| Firebase Reads/Day | < 10k | 0 | ✅ Not launched |

---

## Estimated Optimization Timeline

**Before Launch** (1 day):
- Pagination: 2h
- Caching: 4h  
- Query optimization: 1h
- Testing: 3h

**Post-Launch Week 1** (2 days):
- Monitoring setup: 2h
- Performance fixes: 6h
- Security hardening: 2h

**Month 1** (1 week):
- Offline mode: 8h
- Background sync: 4h
- Advanced optimizations: 8h

**Total**: ~40 hours over first month

