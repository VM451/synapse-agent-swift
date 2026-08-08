# Getting Started with SynapseAgent

`SynapseAgent` is a Swift 6 framework for building stateful, multi-actor, cyclic AI agents exclusively on Apple platforms (**iOS 27.0+, iPadOS 27.0+, macOS 27.0+, visionOS 27.0+**, and newer) with 100% on-device local execution and multi-provider cloud support.

---

## 📦 Installation via Swift Package Manager

Add `SynapseAgent` to your `Package.swift` or Xcode Project:

```swift
dependencies: [
    .package(url: "https://github.com/VM451/synapse-agent-swift.git", from: "1.0.0")
]
```

Then add `SynapseAgent` to your target's dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "SynapseAgent", package: "synapse-agent-swift")
    ]
)
```

---

## 🚀 3-Minute Quickstart

### Step 1: Define your Agent State

Every state structure in `SynapseAgent` conforms to `AgentState` (`Codable`, `Sendable`, and `Equatable`):

```swift
import SynapseAgent

struct ResearchState: AgentState {
    var query: String = ""
    var draftNotes: String = ""
    var finalReport: String = ""
    var isDone: Bool = false
}
```

### Step 2: Build the Graph Workflow

```swift
let builder = GraphBuilder<ResearchState>()

// Node 1: Gather Information
builder.addNode("gather") { state in
    let provider = AppleFoundationModelProvider.default
    let response = try await provider.generate(prompt: [
        .user("Research query: \(state.query)")
    ])
    var nextState = state
    nextState.draftNotes = response.text
    return nextState
}

// Node 2: Synthesize Final Report
builder.addNode("synthesize") { state in
    var nextState = state
    nextState.finalReport = "Report Summary:\n" + state.draftNotes
    nextState.isDone = true
    return nextState
}

// Set Flow & Transitions
builder.setEntryPoint("gather")
builder.addEdge(from: "gather", to: "synthesize")
builder.addEdge(from: "synthesize", to: EndNode.id)

// Compile the Graph
let graph = builder.compile()
```

### Step 3: Run the Agent

```swift
// Synchronous Invocation
let initialState = ResearchState(query: "On-device AI on Apple Silicon")
let result = try await graph.invoke(initialState: initialState)
print(result.finalReport)
```

---

## 🌊 Real-Time Lifecycle Streaming

You can stream lifecycle events as the graph executes node transitions:

```swift
for try await event in graph.stream(initialState: initialState) {
    switch event {
    case .started(let threadId, _):
        print("Starting execution thread \(threadId)...")
    case .nodeStarted(let nodeId, _, let step):
        print("▶ Node '\(nodeId)' started at step \(step)")
    case .nodeCompleted(let nodeId, _, let duration, _):
        print("✔ Node '\(nodeId)' finished in \(String(format: "%.3f", duration))s")
    case .interrupted(let interrupt, _, _):
        print("⚠️ Interrupted: \(interrupt.message)")
    case .completed(let finalState, let totalSteps):
        print("🎉 Finished in \(totalSteps) steps! Report: \(finalState.finalReport)")
    default:
        break
    }
}
```

---

## 📚 Table of Contents

- [Architecture & Design](architecture-and-design.md)
- [Core Graph Engine & State Reducers](core-graph-engine.md)
- [Providers & Foundation Models](providers-and-models.md)
- [State Persistence & Time Travel](state-persistence-and-time-travel.md)
- [Human-in-the-Loop & Interrupts](human-in-the-loop-and-interrupts.md)
- [Multi-Agent Consensus & Orchestration](multi-agent-orchestration.md)
- [Tools & Dynamic Tool Dispatcher](tools-and-dispatcher.md)
- [Security & Zero-Cloud Guardrails](security-and-privacy.md)
- [SwiftUI Native Integration](swiftui-integration.md)
