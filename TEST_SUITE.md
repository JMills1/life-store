# LifePlanner - Comprehensive Test Suite

## Test Strategy

### Test Pyramid
1. **Unit Tests** (70%) - Test individual functions and business logic
2. **Integration Tests** (20%) - Test Firebase integration
3. **UI Tests** (10%) - Test user flows

## Manual Testing Checklist

### Pre-Test Setup
- [ ] Firebase project created and configured
- [ ] App installed on device/simulator
- [ ] Test user credentials ready
- [ ] Network connection available

---

## 1. Authentication Tests

### 1.1 Email/Password Sign Up
**Test Case**: Create new account with email and password

**Steps**:
1. Launch app
2. Tap "Sign Up"
3. Enter:
   - Full Name: "Test User"
   - Email: "test@example.com"
   - Password: "Test123!"
   - Confirm Password: "Test123!"
4. Tap "Sign Up"

**Expected**:
- [ ] Sign up succeeds
- [ ] User redirected to MainTabView
- [ ] User appears in Firebase Console → Authentication

**Edge Cases**:
- [ ] Weak password (< 6 chars) shows error
- [ ] Mismatched passwords shows error
- [ ] Invalid email format shows error
- [ ] Duplicate email shows error

### 1.2 Email/Password Sign In
**Test Case**: Sign in with existing account

**Steps**:
1. Sign out if logged in
2. Enter email and password
3. Tap "Sign In"

**Expected**:
- [ ] Sign in succeeds
- [ ] Redirected to MainTabView
- [ ] User state persists (check AuthService.currentUser)

**Edge Cases**:
- [ ] Wrong password shows error
- [ ] Non-existent email shows error
- [ ] Empty fields disables button

### 1.3 Sign in with Apple
**Test Case**: Authenticate with Apple ID

**Prerequisites**: Real device (not simulator)

**Steps**:
1. Tap "Sign in with Apple"
2. Complete Apple authentication
3. Allow app access

**Expected**:
- [ ] Apple auth flow completes
- [ ] User created in Firebase
- [ ] Redirected to MainTabView

### 1.4 Password Reset
**Test Case**: Reset forgotten password

**Steps**:
1. Tap "Forgot Password?"
2. Enter email
3. Tap "Send Reset Link"

**Expected**:
- [ ] Success message shown
- [ ] Email received (check inbox)
- [ ] Reset link works

### 1.5 Sign Out
**Test Case**: Log out of account

**Steps**:
1. Navigate to Settings tab
2. Tap "Sign Out"
3. Confirm

**Expected**:
- [ ] Signed out successfully
- [ ] Redirected to LoginView
- [ ] User state cleared

---

## 2. Calendar Tests

### 2.1 Calendar View Modes
**Test Case**: Switch between calendar views

**Steps**:
1. Navigate to Calendar tab
2. Tap "Month" / "Week" / "Day" buttons

**Expected**:
- [ ] Month view shows calendar grid
- [ ] Week view shows 7-day timeline
- [ ] Day view shows hourly slots
- [ ] Current date highlighted
- [ ] "Today" button returns to current date

### 2.2 Create Event
**Test Case**: Add new calendar event

**Steps**:
1. Tap "+" button
2. Enter:
   - Title: "Team Meeting"
   - Description: "Weekly sync"
   - Start: Today 2:00 PM
   - End: Today 3:00 PM
   - Location: "Conference Room"
3. Tap "Save"

**Expected**:
- [ ] Event created successfully
- [ ] Event appears on calendar
- [ ] Event saved to Firestore (check console)
- [ ] Event shows in correct time slot

**Edge Cases**:
- [ ] Empty title prevents save
- [ ] End before start shows error
- [ ] All-day event works correctly

### 2.3 View Event Details
**Test Case**: Tap event to view details

**Steps**:
1. Tap on created event

**Expected**:
- [ ] Event details sheet appears
- [ ] All information displayed correctly
- [ ] Can edit event
- [ ] Can delete event

### 2.4 Multiple Workspaces
**Test Case**: Events from different workspaces

**Steps**:
1. Create event in "Personal" workspace
2. Create family workspace
3. Create event in family workspace
4. Switch workspace selector

**Expected**:
- [ ] Only selected workspace events show
- [ ] Color coding matches workspace
- [ ] Real-time updates work

### 2.5 Date Navigation
**Test Case**: Navigate calendar dates

**Steps**:
1. In month view, tap next/previous month
2. In week view, swipe left/right
3. Tap specific date

**Expected**:
- [ ] Month changes correctly
- [ ] Week scrolls smoothly
- [ ] Selected date updates
- [ ] Events load for new dates

---

## 3. Todo/Task Tests

### 3.1 Create Task
**Test Case**: Add new task

**Steps**:
1. Navigate to Tasks tab
2. Tap "+"
3. Enter:
   - Title: "Buy groceries"
   - Description: "Milk, bread, eggs"
   - Priority: High
   - Due date: Tomorrow 5:00 PM
4. Tap "Save"

**Expected**:
- [ ] Task created
- [ ] Appears in Active section
- [ ] Priority color shown (red for high)
- [ ] Due date displayed
- [ ] Saved to Firestore

**Edge Cases**:
- [ ] Empty title prevents save
- [ ] Task without due date works
- [ ] All priority levels work

### 3.2 Complete Task
**Test Case**: Mark task as complete

**Steps**:
1. Tap circle icon next to task
2. Verify checkmark appears

**Expected**:
- [ ] Task marked complete
- [ ] Moves to Completed section
- [ ] Strikethrough applied
- [ ] completedAt timestamp set
- [ ] Updated in Firestore

### 3.3 Task with Calendar Integration
**Test Case**: Task appears on calendar

**Steps**:
1. Create task with due date
2. Go to Calendar tab
3. Find due date

**Expected**:
- [ ] Task appears on calendar
- [ ] Shows in correct date/time slot
- [ ] Distinct from events (different styling)

### 3.4 Overdue Tasks
**Test Case**: Overdue task indication

**Steps**:
1. Create task with past due date
2. View in task list

**Expected**:
- [ ] Due date shown in red
- [ ] Clearly indicates overdue
- [ ] Still functional

### 3.5 Task Filtering
**Test Case**: Active vs Completed sections

**Steps**:
1. Create multiple tasks
2. Complete some tasks
3. View list

**Expected**:
- [ ] Active tasks in Active section
- [ ] Completed tasks in Completed section
- [ ] Sorted correctly (due date ascending)

---

## 4. Notes Tests

### 4.1 Create Note
**Test Case**: Add new note

**Steps**:
1. Navigate to Notes tab
2. Tap pencil icon
3. Enter:
   - Title: "Meeting Notes"
   - Content: "Discussed project timeline..."
4. Tap "Save"

**Expected**:
- [ ] Note created
- [ ] Appears in notes list
- [ ] Preview shows first 100 chars
- [ ] Saved to Firestore

### 4.2 Edit Note
**Test Case**: Modify existing note

**Steps**:
1. Tap on note
2. Edit title and content
3. Tap "Save"

**Expected**:
- [ ] Changes saved
- [ ] updatedAt timestamp updated
- [ ] Preview updates
- [ ] Synced to Firestore

### 4.3 Pin Note
**Test Case**: Pin important note

**Steps**:
1. Open note
2. Toggle "Pin note"
3. Save

**Expected**:
- [ ] Note appears in Pinned section
- [ ] Pin icon shown
- [ ] Stays at top of list

### 4.4 Link Note to Calendar
**Test Case**: Associate note with date

**Steps**:
1. Create/edit note
2. Toggle "Link to calendar"
3. Select date
4. Save
5. Check calendar

**Expected**:
- [ ] Note linked to date
- [ ] Appears on calendar for that date
- [ ] Calendar icon shown in note list

### 4.5 Search Notes
**Test Case**: Find notes by text

**Steps**:
1. Create several notes
2. Tap search bar
3. Enter search term

**Expected**:
- [ ] Matching notes shown
- [ ] Searches title and content
- [ ] Real-time filtering
- [ ] Clear search works

---

## 5. Family/Workspace Tests

### 5.1 Create Family Group
**Test Case**: Set up family workspace

**Steps**:
1. Navigate to Family tab
2. Tap "Create Family Group"
3. Enter name: "Smith Family"
4. Tap "Create"

**Expected**:
- [ ] Family created
- [ ] User is admin
- [ ] Appears in family list
- [ ] Saved to Firestore

### 5.2 Workspace Isolation
**Test Case**: Personal vs shared data

**Steps**:
1. Create event in Personal workspace
2. Switch to Family workspace
3. Verify event not visible
4. Create event in Family workspace
5. Verify both users can see it

**Expected**:
- [ ] Personal data is private
- [ ] Shared data visible to all members
- [ ] Workspace colors differ
- [ ] Real-time sync works

### 5.3 Permissions
**Test Case**: Role-based access

**Steps**:
1. Create family with different roles
2. Test member capabilities
3. Test admin capabilities

**Expected**:
- [ ] Admins can invite members
- [ ] Members can view/edit
- [ ] Viewers can only view (if implemented)

---

## 6. Settings Tests

### 6.1 View Account Info
**Test Case**: Display user profile

**Steps**:
1. Navigate to Settings tab
2. View account section

**Expected**:
- [ ] Name displayed
- [ ] Email displayed
- [ ] Premium status shown
- [ ] All info correct

### 6.2 Notification Settings
**Test Case**: Configure notifications

**Steps**:
1. Tap "Notifications"
2. Toggle various options
3. Save

**Expected**:
- [ ] Settings persist
- [ ] Saved to user preferences
- [ ] Applied to notifications

### 6.3 Premium Upgrade
**Test Case**: View premium options

**Steps**:
1. Tap "Upgrade to Premium"
2. Review features
3. (Don't purchase in test)

**Expected**:
- [ ] Premium sheet appears
- [ ] Features listed
- [ ] $2.99/month shown
- [ ] Can dismiss

---

## 7. Ads & Monetization Tests

### 7.1 Banner Ads Display
**Test Case**: Verify ads show for free users

**Steps**:
1. Use free account
2. Navigate to Calendar, Tasks, Notes tabs

**Expected**:
- [ ] Banner ad at bottom of each screen
- [ ] Ad loads correctly
- [ ] Doesn't obstruct content
- [ ] Test ad ID works

### 7.2 Premium Ad Removal
**Test Case**: Premium users see no ads

**Steps**:
1. Set isPremium = true in Firebase
2. Reload app
3. Check all screens

**Expected**:
- [ ] No banner ads shown
- [ ] More screen space
- [ ] Premium badge in settings

---

## 8. Real-time Sync Tests

### 8.1 Multi-Device Sync
**Test Case**: Changes sync across devices

**Prerequisites**: Two devices logged into same account

**Steps**:
1. Device 1: Create event
2. Device 2: Observe

**Expected**:
- [ ] Event appears on Device 2 instantly
- [ ] No refresh needed
- [ ] Works for events, tasks, notes

### 8.2 Offline Mode
**Test Case**: App works without internet

**Steps**:
1. Enable airplane mode
2. Try to create event
3. Re-enable internet

**Expected**:
- [ ] App doesn't crash
- [ ] Shows error gracefully
- [ ] Syncs when reconnected (if cached)

---

## 9. Performance Tests

### 9.1 Launch Time
**Test Case**: App starts quickly

**Steps**:
1. Force quit app
2. Launch app
3. Time to LoginView

**Expected**:
- [ ] Launches in < 3 seconds
- [ ] No white screen flash
- [ ] Smooth animation

### 9.2 Large Dataset
**Test Case**: Handles many items

**Steps**:
1. Create 50+ events
2. Navigate calendar
3. Switch views

**Expected**:
- [ ] No lag
- [ ] Smooth scrolling
- [ ] Quick view switches

### 9.3 Memory Usage
**Test Case**: No memory leaks

**Steps**:
1. Use app for 10 minutes
2. Switch tabs repeatedly
3. Create/delete items

**Expected**:
- [ ] Memory stable
- [ ] No growing memory usage
- [ ] No crashes

---

## 10. Security Tests

### 10.1 Data Isolation
**Test Case**: Users can't access others' data

**Steps**:
1. User A creates event
2. User B tries to access (via Firestore)

**Expected**:
- [ ] User B cannot read User A's personal data
- [ ] Security rules enforce isolation
- [ ] Shared workspace data accessible

### 10.2 Authentication Required
**Test Case**: All actions need auth

**Steps**:
1. Sign out
2. Try to access protected routes

**Expected**:
- [ ] Redirected to LoginView
- [ ] Cannot access data
- [ ] No unauthorized actions

---

## 11. Edge Cases & Error Handling

### 11.1 Network Errors
**Test Case**: Graceful failure on network issues

**Steps**:
1. Disable internet mid-operation
2. Try to save data

**Expected**:
- [ ] Error message shown
- [ ] App doesn't crash
- [ ] Can retry when online

### 11.2 Invalid Data
**Test Case**: Handle malformed input

**Steps**:
1. Enter special characters
2. Enter very long text
3. Enter emoji

**Expected**:
- [ ] No crashes
- [ ] Data validated
- [ ] Saved correctly

### 11.3 Rapid Actions
**Test Case**: Handle quick user input

**Steps**:
1. Rapidly tap buttons
2. Quick tab switching
3. Fast data entry

**Expected**:
- [ ] No duplicate actions
- [ ] No crashes
- [ ] Loading states shown

---

## Test Results Template

```markdown
## Test Run: [Date]
**Tester**: [Name]
**Device**: [iPhone/iPad Model]
**iOS Version**: [Version]
**Build**: [Build Number]

### Summary
- Total Tests: X
- Passed: X
- Failed: X
- Blocked: X

### Failed Tests
1. [Test Name] - [Issue Description] - [Priority: High/Med/Low]

### Notes
- [Any observations]
- [Performance notes]
- [UX feedback]
```

---

## Automated Testing (To Implement)

### Unit Tests Needed
```swift
// AuthServiceTests.swift
- testSignUpWithValidEmail()
- testSignInWithWrongPassword()
- testPasswordReset()

// CalendarViewModelTests.swift
- testLoadEvents()
- testFilterEventsByDate()
- testCreateEvent()

// TodoViewModelTests.swift
- testCompleteTask()
- testPriorityFiltering()
- testOverdueTasks()
```

### UI Tests Needed
```swift
// LoginFlowTests.swift
- testSignUpFlow()
- testLoginFlow()
- testLogoutFlow()

// CalendarFlowTests.swift
- testCreateEventFlow()
- testSwitchViewModes()
```

---

## Test Data Setup

### Create Test Accounts
```
Email: test1@lifeplanner.app
Password: Test123!

Email: test2@lifeplanner.app  
Password: Test123!
```

### Sample Data
- 10 events across different dates
- 15 tasks with various priorities
- 5 notes (some pinned, some linked to calendar)
- 1 family group with 2 members

---

## Success Criteria

App is ready for production when:
- [ ] All authentication tests pass
- [ ] All core feature tests pass
- [ ] No crashes in normal usage
- [ ] Firebase sync works reliably
- [ ] Ads display correctly for free users
- [ ] Premium upgrade flow works
- [ ] Performance acceptable (< 3s launch, smooth scrolling)
- [ ] Security rules prevent unauthorized access
- [ ] Works on iOS 16+ devices
- [ ] Works on iPhone and iPad

**Estimated Testing Time**: 3-4 hours for complete manual suite

