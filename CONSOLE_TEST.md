# How to View Console Output in Xcode

## Method 1: Keyboard Shortcut
Press `Command + Shift + Y` to toggle the debug area (console)

## Method 2: Menu
1. Go to Xcode menu bar
2. Click `View` → `Debug Area` → `Show Debug Area`

## Method 3: Button
Look at the top-right corner of Xcode window, there are 3 square buttons:
- Left button: Hide/Show Navigator (left panel)
- Middle button: Hide/Show Debug Area (bottom panel) ← Click this!
- Right button: Hide/Show Inspector (right panel)

## Once Debug Area is Open:
At the top-right of the debug area (bottom panel), you'll see 2 buttons:
- Left button (≡): Variables view
- Right button (💬): Console view ← Click this to see print statements!

## Filter Settings:
In the console, look for a dropdown that says "All Output" - make sure this is selected.

## What You Should See:
When you run the app, you should immediately see:
```
============================================
LIFEPLANNER APP STARTING
============================================
✅ Firebase configured
✅ Google Mobile Ads started
```

If you don't see this, the console might not be properly configured.

## Troubleshooting:
If still no output, check your scheme settings:
1. Click on the scheme selector (next to Run/Stop buttons)
2. Choose "Edit Scheme..."
3. Select "Run" in left panel
4. Go to "Arguments" tab
5. Under "Environment Variables", look for `OS_ACTIVITY_MODE`
6. If it exists and is set to "disable", remove it or change to "default"
