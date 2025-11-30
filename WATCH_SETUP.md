# Apple Watch Extension Setup

## Overview

The Apple Watch extension allows users to:
- View upcoming events
- Check today's tasks
- Quick add tasks
- Receive notifications
- View complications on watch face

## Setup Instructions

### 1. Add watchOS Target in Xcode

1. File → New → Target
2. Select **watchOS** → **Watch App**
3. Product Name: "LifePlannerWatch"
4. Include Notification Scene: Yes
5. Finish

### 2. Configure Watch App

The watch app will share data with the iOS app via:
- **WatchConnectivity** - Real-time data sync
- **Shared App Group** - Shared UserDefaults/CoreData
- **iCloud** - Cloud sync via Firebase

### 3. Watch App Structure

```
LifePlannerWatch/
├── Views/
│   ├── ContentView.swift       # Main watch interface
│   ├── EventListView.swift     # Today's events
│   ├── TodoListView.swift      # Active tasks
│   └── QuickAddView.swift      # Quick task creation
├── Complications/
│   └── ComplicationController.swift
└── Services/
    └── WatchConnectivityManager.swift
```

### 4. Sample Watch ContentView

```swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EventListView()
                .tag(0)
            
            TodoListView()
                .tag(1)
        }
        .tabViewStyle(.page)
    }
}
```

### 5. Complications

Support these complication families:
- **Circular Small** - Event count
- **Modular Small** - Next event time
- **Graphic Corner** - Event timeline
- **Graphic Circular** - Today's tasks

### 6. WatchConnectivity Setup

```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \\(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \\(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received messages
    }
}
```

## Implementation Timeline

### Phase 1 (MVP - Deferred)
Apple Watch extension is marked as **future enhancement** for the MVP.

Reasons:
1. Focus on iOS app first
2. Watch requires iOS app to be stable
3. Can be added as update after launch

### Phase 2 (Post-Launch)
Once iOS app is released and stable:
1. Add watchOS target
2. Implement basic views
3. Add complications
4. Submit as app update

## Testing Watch App

### Simulator
1. Xcode → Open Developer Tool → Simulator
2. Select Apple Watch simulator
3. Run watch app target

### Physical Device
1. Pair Apple Watch with iPhone
2. Select iPhone + Watch as run destination
3. Build and run

## Watch App Features Priority

**High Priority**
- [ ] View today's events
- [ ] View active tasks
- [ ] Quick task completion toggle
- [ ] Event notifications

**Medium Priority**
- [ ] Complications
- [ ] Quick add task
- [ ] View upcoming week

**Low Priority**
- [ ] View/edit notes
- [ ] Full calendar view
- [ ] Family workspace switching

## Resources

- [Apple Watch Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [WatchConnectivity Documentation](https://developer.apple.com/documentation/watchconnectivity)
- [Complications Documentation](https://developer.apple.com/documentation/clockkit)

## Notes

The Apple Watch extension is a valuable feature but not critical for MVP launch. Focus on perfecting the iOS experience first, then expand to Watch as a value-add update.

