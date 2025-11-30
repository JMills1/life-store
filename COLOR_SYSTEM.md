# Color System - How It Works

## Color Hierarchy (Database-Driven)

### 1. Personal Color (User Level)
**Stored in**: `users/{userId}/preferences/personalColor`
**Default**: Red (#EF5350)
**Purpose**: Your events show in YOUR color in shared workspaces

**Example**:
- Jay's color: Red
- Sarah's color: Blue
- Mike's color: Green

### 2. Workspace Color (Workspace Level)
**Stored in**: `workspaces/{workspaceId}/color`
**Default**: Green (#4CAF50)
**Purpose**: Workspace identification in calendar selector

**Example**:
- "Personal" workspace: Green
- "Family" workspace: Yellow
- "Work" workspace: Purple

### 3. Event Color (Event Level - Optional Override)
**Stored in**: `events/{eventId}/color`
**Default**: null (uses creator's personal color)
**Purpose**: Custom color for specific events

---

## How Colors Are Determined

### Priority (Top to Bottom):
1. **Event custom color** (if set) - Overrides everything
2. **Creator's personal color** (if useCreatorColor = true) - Default behavior
3. **Workspace color** (fallback) - If creator color not available

### Code Logic:
```swift
func displayColor(workspace: Workspace?, creatorColor: String?) -> String {
    // 1. Check event-specific color
    if let customColor = color {
        return customColor
    }
    
    // 2. Use creator's personal color
    if useCreatorColor, let creatorColor = creatorColor {
        return creatorColor
    }
    
    // 3. Fall back to workspace color
    return workspace?.color ?? "4CAF50"
}
```

---

## User Experience

### In Personal Workspace:
- All YOUR events: Your personal color (Red)
- Easy to see your schedule at a glance

### In Shared Workspace (Family Calendar):
- Jay's events: Red
- Sarah's events: Blue  
- Mike's events: Green
- **Everyone knows who created what!**

### Setting Your Color:

1. Go to **Settings** tab
2. Tap **"My Color"**
3. Select from 10 color options:
   - Red, Pink, Purple, Blue, Cyan
   - Green, Yellow, Orange, Brown, Gray
4. See preview
5. Tap **"Save Color"**
6. All your future events use this color in shared calendars!

---

## Examples

### Family Calendar (Yellow workspace):
```
Dec 25, 2025
┌────────────────────────────────┐
│ Christmas Dinner               │  ← Red (Jay created it)
├────────────────────────────────┤
│ Kids Soccer Game               │  ← Blue (Sarah created it)
├────────────────────────────────┤
│ Family Movie Night             │  ← Green (Mike created it)
└────────────────────────────────┘
```

### Personal Calendar (Green workspace):
```
Dec 30, 2025
┌────────────────────────────────┐
│ Dentist Appointment            │  ← Red (all your color)
├────────────────────────────────┤
│ Team Meeting                   │  ← Red (all your color)
├────────────────────────────────┤
│ Gym Session                    │  ← Red (all your color)
└────────────────────────────────┘
```

---

## Database Structure

### Users Collection:
```json
{
  "userId": "user123",
  "displayName": "Jay Mills",
  "preferences": {
    "personalColor": "EF5350",  ← Your personal color (Red)
    "themeColor": "4CAF50"      ← App theme (Green)
  }
}
```

### Workspaces Collection:
```json
{
  "workspaceId": "workspace456",
  "name": "Family",
  "color": "FFEB3B",  ← Workspace color (Yellow)
  "type": "shared"
}
```

### Events Collection:
```json
{
  "eventId": "event789",
  "title": "Soccer Practice",
  "workspaceId": "workspace456",
  "createdBy": "user123",
  "useCreatorColor": true,  ← Use Jay's red color
  "color": null             ← No custom override
}
```

**Result**: Event shows in RED (Jay's color) on the YELLOW (Family) calendar

---

## Benefits

### ✅ Instant Visual Recognition
- See who created what at a glance
- No need to tap each event

### ✅ Family Coordination
- "Sarah's events are always blue"
- "Dad's events are always brown"
- Kids can quickly identify their tasks

### ✅ Flexibility
- Want a specific event in a custom color? Override it!
- Want all your events same color? Use personal color
- Want workspace-based colors? Turn off useCreatorColor

---

## Implementation Status

✅ **Complete**:
- User personal color in database model
- Color hierarchy logic
- Event color extension
- Settings UI for color selection
- 10 color options
- Preview in settings

🟨 **Needs Testing**:
- Save/load personal color
- Display correct color on calendar
- Shared workspace color mixing

---

## How to Test (After Build):

1. **Set your color**:
   - Settings → My Color → Select Red → Save

2. **Create events**:
   - Create "My Event" in Personal workspace
   - Should show in RED

3. **Share with family** (later):
   - Family member sets their color to Blue
   - Their events show in BLUE
   - Your events still show in RED
   - Easy to see who owns what!

---

This is the **scalable, database-driven** solution you wanted! 🎨

