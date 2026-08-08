# Apple Platform Pre-Built Tools

SynapseAgent ships a curated library of native Apple platform tools that agents can invoke directly. Each tool is protocol-oriented with both a `MockApplePlatformServices` implementation (for sandboxed testing and zero-cloud compliance) and a `NativeApplePlatformServices` implementation that calls real system frameworks.

---

## 1. Quick Registration

Register all Apple Platform tools in one line:

```swift
import SynapseAgent

let registry = ToolRegistry()
registry.registerApplePlatformCapabilities()

// Or register everything including Search, Memory, and Sandbox tools:
registry.registerAllEcosystemCapabilities()
```

---

## 2. Available Tools

### `CalendarTool` — `calendar`

Queries and creates calendar events via EventKit.

| Action | Description |
|:---|:---|
| `list_events` | List events in a date range |
| `create_event` | Create a new calendar event |
| `find_free_slots` | Find scheduling availability |

```swift
// Example agent call JSON
{
  "action": "create_event",
  "title": "Design Review",
  "start": "2026-08-10T10:00:00Z",
  "end": "2026-08-10T11:00:00Z",
  "notes": "Review new onboarding flow"
}
```

---

### `RemindersTool` — `reminders`

Manages to-do lists and reminders via EventKit Reminders.

| Action | Description |
|:---|:---|
| `list` | List reminders in a list |
| `add` | Add a reminder with optional due date and priority |
| `complete` | Mark a reminder as complete |

---

### `NotesTool` — `notes`

Reads and creates Apple Notes.

| Action | Description |
|:---|:---|
| `search` | Full-text search across notes |
| `read` | Read the content of a specific note |
| `create` | Create a new note with title and body |

```swift
// Example agent invocation result
"Found 2 notes matching 'onboarding': [Note: 'Onboarding Checklist', Note: 'New Hire Notes']"
```

---

### `ContactsTool` — `contacts`

Searches the Contacts store via the Contacts framework.

| Action | Description |
|:---|:---|
| `search` | Search contacts by name |
| `get_email` | Retrieve email addresses for a contact |
| `get_phone` | Retrieve phone numbers for a contact |

---

### `MailTool` — `mail`

Drafts emails and searches the mailbox.

| Action | Description |
|:---|:---|
| `draft` | Draft an email with to, cc, subject, body |
| `search` | Search mailbox by sender, subject, or keyword |

---

### `FilesTool` — `files`

Reads, writes, and lists files in iCloud Drive and app containers.

| Action | Description |
|:---|:---|
| `read` | Read file contents from a path |
| `write` | Write content to a file path |
| `list` | List directory contents |
| `info` | Get file metadata (size, modification date) |

---

### `MapsTool` — `maps`

Searches points of interest and calculates directions via MapKit and CoreLocation.

| Action | Description |
|:---|:---|
| `search` | Search for places (restaurants, hospitals, etc.) |
| `directions` | Get turn-by-turn route description |
| `distance` | Calculate straight-line or road distance |

---

### `SystemControlTool` — `systemControl`

Reads device state and manages the clipboard.

| Action | Description |
|:---|:---|
| `battery` | Get current battery level and charging state |
| `thermal` | Read thermal state (nominal, fair, serious, critical) |
| `clipboard_read` | Read clipboard content |
| `clipboard_write` | Write text to the clipboard |

---

### `TimerTool` — `timer`

Sets countdown timers.

| Action | Description |
|:---|:---|
| `set` | Set a timer with a duration (seconds) and label |
| `list` | List active timers |

---

## 3. Using Mock Services for Testing

All tools accept an `ApplePlatformAccessProvider` conformance. Use `MockApplePlatformServices` in tests and CI to avoid requiring device permissions or entitlements:

```swift
import SynapseAgent

let mock = MockApplePlatformServices()
let calendarTool = CalendarTool(services: mock)
let notesTool = NotesTool(services: mock)

// Register mock-backed tools into a test registry
let registry = ToolRegistry()
registry.register(calendarTool)
registry.register(notesTool)

let dispatcher = ToolDispatcher(registry: registry)
let result = try await dispatcher.dispatch(
    toolName: "calendar",
    argumentsJSON: #"{"action": "list_events", "start": "2026-08-01", "end": "2026-08-31"}"#
)
print(result)
```

---

## 4. Using Native Services in Production

Swap to `NativeApplePlatformServices` in your app target. Native services use EventKit, Contacts, CoreLocation, MapKit, FileManager, and ProcessInfo, with every access logged via `OSLog` for auditability:

```swift
let services = NativeApplePlatformServices()
let registry = ToolRegistry()
registry.registerApplePlatformCapabilities(services: services)
```

> **Privacy**: Always request the appropriate system permissions (`NSCalendarsUsageDescription`, `NSContactsUsageDescription`, etc.) in your app's `Info.plist` before activating native services in production.

---

## 5. Full Agent Example

```swift
import SynapseAgent

struct AssistantState: AgentState {
    var userRequest: String = ""
    var agentResponse: String = ""
    var toolsUsed: [String] = []
}

let registry = ToolRegistry()
registry.registerApplePlatformCapabilities()

let builder = GraphBuilder<AssistantState>()
builder.addNode(LLMNode(id: "act", provider: AppleFoundationModelProvider.default, registry: registry))
builder.setEntryPoint("act")
builder.addEdge(from: "act", to: EndNode.id)

let graph = builder.compile()
let finalState = try await graph.invoke(
    initialState: AssistantState(userRequest: "Schedule a call with Alex next Monday at 3 PM")
)
print(finalState.agentResponse)
// "I've created a calendar event: 'Call with Alex' on Monday, August 11 at 3:00 PM."
```
