# Architecture Documentation

Technical architecture and implementation details for LifePlanner.

## Architecture Pattern

**MVVM + Clean Architecture**

```
┌─────────────────────────────────────────────────┐
│                   Views (SwiftUI)                │
│  CalendarView, TodoListView, NotesListView, etc │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│              ViewModels (@MainActor)             │
│   CalendarViewModel, TodoViewModel, etc         │
│   - @Published properties                        │
│   - Business logic                               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│                   Services                       │
│   AuthService, WorkspaceManager, etc            │
│   - Firebase interactions                        │
│   - Shared state management                      │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│              Domain Models                       │
│   User, Event, Todo, Note, Workspace            │
│   - Codable, Identifiable                       │
│   - Business rules                               │
└─────────────────────────────────────────────────┘
```

## Key Components

### 1. Authentication Flow

**AuthService** (`Services/AuthService.swift`)
- Singleton pattern with `@MainActor`
- Handles Sign in with Apple and Email/Password
- Manages current user state
- Creates default workspace on signup

```swift
@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool
    
    func signInWithEmail(email: String, password: String)
    func signUpWithEmail(email: String, password: String, displayName: String)
    func signInWithApple(authorization: ASAuthorization)
}
```

### 2. Workspace Management

**WorkspaceManager** (`Services/WorkspaceManager.swift`)
- Centralized workspace state management
- Real-time Firestore listeners
- Multi-workspace selection support

```swift
@MainActor
class WorkspaceManager: ObservableObject {
    @Published var availableWorkspaces: [Workspace]
    @Published var selectedWorkspace: Workspace?
    @Published var selectedWorkspaceIds: [String]
    
    func loadWorkspaces()
    func selectWorkspace(_ workspace: Workspace)
    func createWorkspace(name: String, type: WorkspaceType)
}
```

### 3. Data Models

All models conform to `Codable` and `Identifiable` for Firebase integration.

**User Model**
```swift
struct User: Identifiable, Codable, Sendable {
    var id: String?
    var email: String
    var displayName: String
    var authProvider: AuthProvider
    var isPremium: Bool
    var preferences: UserPreferences
    var familyMemberships: [String]
}
```

**Workspace Model**
```swift
struct Workspace: Identifiable, Codable {
    var id: String?
    var name: String
    var type: WorkspaceType  // personal, shared
    var ownerId: String
    var color: String  // Hex color
    var members: [WorkspaceMember]
}
```

**Event Model**
```swift
struct Event: Identifiable, Codable {
    var id: String?
    var workspaceId: String
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var color: String?
    var location: String?
    var description: String?
    var reminders: [EventReminder]
    var createdBy: String
}
```

**Todo Model**
```swift
struct Todo: Identifiable, Codable {
    var id: String?
    var workspaceId: String
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var subtasks: [Subtask]
    var createdBy: String
}
```

**Note Model**
```swift
struct Note: Identifiable, Codable {
    var id: String?
    var workspaceId: String
    var title: String
    var content: String
    var linkedDate: Date?  // Shows on calendar
    var isPinned: Bool
    var tags: [String]
    var createdBy: String
}
```

## Firebase Structure

### Firestore Collections

```
users/
  {userId}/
    - email, displayName, isPremium, preferences, etc.

workspaces/
  {workspaceId}/
    - name, type, ownerId, color, members[], etc.

events/
  {eventId}/
    - workspaceId, title, startDate, endDate, etc.
    
todos/
  {todoId}/
    - workspaceId, title, isCompleted, dueDate, subtasks[], etc.

notes/
  {noteId}/
    - workspaceId, title, content, linkedDate, etc.

eventComments/
  {commentId}/
    - eventId, userId, content, createdAt, etc.

families/
  {familyId}/
    - name, members[], etc.
```

### Security Rules

See `firestore.rules` for complete security rules.

Key principles:
- Users can only read/write their own data
- Workspace members can read/write workspace data based on permissions
- Owner has full control over workspace

## State Management

### ObservableObject Pattern

All ViewModels use `@Published` properties for reactive updates:

```swift
@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var todos: [Todo] = []
    @Published var notes: [Note] = []
    @Published var isLoading = false
}
```

### Environment Objects

Shared state is injected via `@EnvironmentObject`:

```swift
struct MainTabView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    
    var body: some View {
        TabView {
            CalendarView()
                .environmentObject(workspaceManager)
        }
    }
}
```

## Calendar Implementation

### Continuous Scrolling

**MonthView** uses `ScrollView` with `LazyVStack` for infinite scrolling:

```swift
ScrollView {
    LazyVStack {
        ForEach(monthsToDisplay, id: \.self) { month in
            MonthGridView(currentMonth: month, ...)
        }
    }
}
```

### Horizontal Event Spanning

Events spanning multiple days are displayed as continuous bars across the calendar grid.

### Date Indicators

Small colored dots below each date show:
- **Event color**: Workspace color
- **Todo color**: User's personal color
- **Note color**: Gray

## Color System

### Workspace Colors
Each workspace has a custom color (hex string) used for:
- Events created in that workspace
- Workspace selector indicators
- Subtle borders on items

### Personal Colors
Each user has a personal color used for:
- Calendar selection circle
- Today's date indicator
- Todo item dots on calendar

### Color Extensions

```swift
extension Color {
    init?(hex: String)
    func darker(by percentage: Double = 0.2) -> Color
    func lighter(by percentage: Double = 0.2) -> Color
}
```

## Notifications

**NotificationService** (`Services/NotificationService.swift`)
- Local notifications for reminders
- Push notifications via Firebase Cloud Messaging
- Per-workspace notification settings

## Monetization

### Free Tier
- Banner ads on Calendar, Todo, and Notes screens
- Google Mobile Ads SDK integration

### Premium ($2.99/month)
- Ad-free experience
- Stored in `User.isPremium` field

## Testing

### Unit Tests
- `CalendarViewModelTests.swift`
- `TodoViewModelTests.swift`
- `NotesViewModelTests.swift`
- `ModelTests.swift`

### Mock Data
- `MockData.swift` provides sample data for testing

## Performance Optimizations

1. **Lazy Loading**: Use `LazyVStack` and `LazyVGrid` for large lists
2. **Real-time Listeners**: Firestore snapshot listeners for automatic updates
3. **@MainActor**: Ensures UI updates on main thread
4. **Pagination**: Limit queries with `.limit(to:)`
5. **Indexing**: Firestore composite indexes for complex queries

## Future Extensibility

### Android Support
- Models use `Codable` which maps to JSON
- Firebase SDKs available for Android
- Business logic can be shared via Kotlin Multiplatform

### Apple Watch
- WidgetKit for complications
- WatchConnectivity for iPhone-Watch sync
- Separate Watch app target

### Web Dashboard
- Firebase Web SDK
- React or Vue.js frontend
- Shared Firestore database

## Development Guidelines

### Code Style
- Minimal comments (self-documenting code)
- SwiftUI declarative syntax
- MVVM separation of concerns
- No emojis in code (unless UI design element)

### Git Workflow
- Main branch for stable releases
- Feature branches for new features
- Pull requests for code review

### Dependencies
- Firebase iOS SDK (Auth, Firestore, Storage, Messaging)
- Google Mobile Ads SDK
- Native iOS frameworks (SwiftUI, Combine, WidgetKit)

## Security Considerations

1. **Authentication**: Sign in with Apple + Email/Password
2. **Authorization**: Firestore security rules enforce permissions
3. **Data Validation**: Server-side validation in security rules
4. **Secure Storage**: Firebase handles encryption at rest
5. **HTTPS**: All Firebase communication over HTTPS

## Deployment

See `SETUP.md` for deployment instructions.

Key steps:
1. Configure Firebase project
2. Deploy Firestore security rules
3. Set up App Store Connect
4. Configure push notifications
5. Submit for App Store review

