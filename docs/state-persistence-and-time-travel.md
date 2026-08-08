# State Persistence & Time Travel

`SynapseAgent` includes snapshot-based checkpointing that saves graph state after every single node execution. This ensures zero state loss if an iOS application is suspended, put in the background, or receives a memory warning.

---

## 1. Checkpointer Implementations

### `SwiftDataCheckpointer` (Recommended for iOS 27+ / macOS 27+)
Uses Apple's native SwiftData `@ModelActor` engine for persistent storage:
```swift
import SwiftData

let schema = Schema([CheckpointEntity.self])
let container = try ModelContainer(for: schema)
let checkpointer = SwiftDataCheckpointer(modelContainer: container)

let graph = builder.compile(checkpointer: checkpointer)
```

### `SQLiteCheckpointer` (Zero-Dependency Local Storage)
Direct embedded SQLite3 storage without third-party frameworks:
```swift
let checkpointer = SQLiteCheckpointer()
let graph = builder.compile(checkpointer: checkpointer)
```

### `InMemoryCheckpointer` (Testing & Ephemeral Tasks)
```swift
let inMemory = InMemoryCheckpointer()
let graph = builder.compile(checkpointer: inMemory)
```

---

## 2. Time-Travel Engine & State Replay

`TimeTravelEngine` allows developers and UI tools to inspect past state snapshots, calculate diffs, and branch execution from historical nodes:

```swift
let engine = TimeTravelEngine(checkpointer: checkpointer)

// 1. Fetch entire execution history for a conversation thread
let history = try await engine.fetchHistory(threadId: "chat-thread-101")

// 2. Inspect state at a specific checkpoint step
let previousState = try await engine.inspectState(
    at: "checkpoint-id-42",
    threadId: "chat-thread-101",
    as: MyAgentState.self
)

// 3. Branch/Fork execution from historical step into a new thread
let forkedCheckpoint = try await engine.branch(
    fromCheckpointId: "checkpoint-id-42",
    onThread: "chat-thread-101",
    newThreadId: "forked-thread-202"
)
```
