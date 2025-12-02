# Workspace System Documentation

## Overview
The LifePlanner app now has a comprehensive workspace management system that supports both personal and shared workspaces with invitation links.

## Workspace Types

### 1. Personal Workspace
- **Automatically created** when a user signs up
- **Private** - only accessible by the owner
- **Uses personal color** - displays using the user's personal color preference
- **Cannot be shared** - exclusive to the individual user
- Named "Personal" by default

### 2. Shared Workspaces
- **Created by users** - any user can create multiple shared workspaces
- **Customizable** - users can choose:
  - Workspace name
  - Workspace color (from 8 preset colors)
  - Workspace icon (from 8 preset icons)
- **Shareable** - can be shared with family members and friends
- **Collaborative** - all members can view and edit content

## Workspace Sharing System

### Invitation Links
- **24-hour expiration** - links automatically expire after 24 hours
- **Automatic regeneration** - when viewing the share screen, expired links are automatically regenerated
- **Usage tracking** - tracks how many times a link has been used
- **Unique codes** - each link has a unique UUID-based code

### Sharing Process
1. Owner opens workspace management in Settings
2. Taps share button on a shared workspace
3. System automatically generates/refreshes invite link
4. Owner can:
   - Copy link to clipboard
   - Share via system share sheet (Messages, Email, etc.)
   - Generate a new link manually

### Joining Process
1. User receives invite link (format: `lifeplanner://join/{inviteCode}`)
2. User taps the link
3. If not logged in:
   - Invite code is stored
   - User is prompted to log in
   - After login, automatically joins workspace
4. If already logged in:
   - Immediately joins workspace
   - Success message displayed
5. Workspace appears in user's workspace list

## Member Management

### Roles
- **Owner** - Creator of the workspace
  - Can remove any member
  - Can generate invite links
  - Full edit permissions
- **Editor** (default for joined members)
  - Can create, edit, and delete events, todos, and notes
  - Cannot remove members
  - Cannot generate invite links

### Removing Members
- **Owner-only feature** - only the workspace owner can remove members
- **Cannot remove owner** - the owner cannot be removed
- **Instant removal** - member is immediately removed from workspace
- **Access revocation** - removed member loses access to all workspace content

## Color System

### Personal Workspaces
- Use the user's **personal color** (set in Settings > My Color)
- Color updates automatically when user changes their personal color
- Applies to:
  - Calendar events
  - Todo items
  - Notes
  - Workspace indicators

### Shared Workspaces
- Use the **workspace color** (set when creating workspace)
- Color is consistent for all members
- Helps distinguish between different shared workspaces

## User Interface

### Settings > Workspaces
Shows three sections:
1. **Personal Workspace** - User's private workspace
2. **My Shared Workspaces** - Workspaces created by the user (with share buttons)
3. **Joined Workspaces** - Workspaces shared by others

### Workspace Share View
- Displays current invite link
- Shows expiration time
- Copy link button
- Share link button (opens system share sheet)
- Generate new link button
- View members button

### Workspace Members View
- Lists all workspace members
- Shows member details:
  - Name
  - Email
  - Join date
  - Role (Owner badge)
- Remove button (for owner only, except for themselves)

## Technical Implementation

### Files Created/Modified

#### Models
- `Workspace.swift` - Added `inviteLink` property and `WorkspaceInviteLink` struct
- Added `displayColor()` method to determine correct color based on workspace type

#### Services
- `WorkspaceInvitationService.swift` - Handles all invitation logic
  - Generate invite links
  - Join workspaces
  - Refresh expired links
  - Fetch member details
  - Remove members
- `DeepLinkHandler.swift` - Handles deep link URLs
  - Processes `lifeplanner://join/{code}` URLs
  - Stores pending invites for unauthenticated users
  - Shows success/error alerts
- `WorkspaceManager.swift` - Added `createWorkspace(_ workspace:)` overload
- `AuthService.swift` - Already creates personal workspace on signup

#### Views
- `WorkspaceManagementView.swift` - Main workspace management screen
- `WorkspaceShareView.swift` - Share workspace with invite link
- `WorkspaceMembersView.swift` - View and manage workspace members
- `CreateWorkspaceView.swift` - Create new shared workspace
- `SettingsView.swift` - Already has "Workspaces" navigation link

#### App
- `LifeNotesApp.swift` - Added deep link handling with `.onOpenURL()`
- `MainTabView.swift` - Added alert for successful workspace joins

### Firebase Structure

```
workspaces/
  {workspaceId}/
    - name: String
    - type: "personal" | "shared"
    - ownerId: String
    - color: String (hex)
    - icon: String (SF Symbol name)
    - members: Array<WorkspaceMember>
    - inviteLink: {
        code: String
        createdAt: Timestamp
        expiresAt: Timestamp
        createdBy: String
        usageCount: Number
      }
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

### Deep Link URL Scheme
- **Scheme**: `lifeplanner://`
- **Host**: `join`
- **Path**: `/{inviteCode}`
- **Full Example**: `lifeplanner://join/A1B2C3D4-E5F6-G7H8-I9J0-K1L2M3N4O5P6`

## Security & Permissions

### Firestore Rules (to be updated)
```javascript
// Workspace access
match /workspaces/{workspaceId} {
  allow read: if isMemberOfWorkspace(workspaceId);
  allow create: if isAuthenticated();
  allow update: if isMemberOfWorkspace(workspaceId);
  allow delete: if isOwnerOfWorkspace(workspaceId);
}

// Helper functions
function isMemberOfWorkspace(workspaceId) {
  return isAuthenticated() && 
    get(/databases/$(database)/documents/workspaces/$(workspaceId))
      .data.members.hasAny([{'userId': request.auth.uid}]);
}

function isOwnerOfWorkspace(workspaceId) {
  return isAuthenticated() && 
    get(/databases/$(database)/documents/workspaces/$(workspaceId))
      .data.ownerId == request.auth.uid;
}
```

## Future Enhancements (Not Implemented)
- [ ] Role-based permissions (Admin, Viewer)
- [ ] Workspace leave functionality (for non-owners)
- [ ] Workspace transfer ownership
- [ ] Workspace archiving
- [ ] Member activity tracking
- [ ] Push notifications for workspace invites
- [ ] Email invitations
- [ ] Workspace templates
- [ ] Workspace settings (privacy, permissions)

## Testing Checklist
- [ ] Create personal workspace on signup
- [ ] Create shared workspace
- [ ] Generate invite link
- [ ] Share invite link via system share
- [ ] Copy invite link to clipboard
- [ ] Join workspace via link (authenticated)
- [ ] Join workspace via link (unauthenticated, then login)
- [ ] View workspace members
- [ ] Remove member (as owner)
- [ ] Verify colors (personal vs shared)
- [ ] Verify link expiration (24 hours)
- [ ] Verify automatic link regeneration
- [ ] Verify owner cannot be removed
- [ ] Verify non-owner cannot remove members

