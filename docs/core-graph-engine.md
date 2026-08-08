# Core Graph Engine & State Reducers

The Core Graph Engine is the heart of `SynapseAgent`. It coordinates node execution, dynamic edge evaluation, and state reductions.

---

## 1. Defining State

Agents represent their state with a Swift struct conforming to `AgentState`:

```swift
import SynapseAgent

public struct CodingAgentState: AgentState {
    public var messages: [ChatMessage] = []
    public var codeDraft: String = ""
    public var testLogs: String = ""
    public var attempts: Int = 0

    public init() {}
}
```

---

## 2. Nodes (`AgentNode`)

Nodes are self-contained units of execution. They can be created using closures or custom structs conforming to `AgentNode`.

### Closure Nodes
```swift
// Full action with ExecutionContext
builder.addNode("coder") { (state: CodingAgentState, context: ExecutionContext) in
    var updated = state
    updated.attempts += 1
    return .state(updated)
}

// Simple transformation
builder.addNode("formatter") { (state: CodingAgentState) in
    var updated = state
    updated.codeDraft = state.codeDraft.trimmingCharacters(in: .whitespacesAndNewlines)
    return updated
}

// In-place mutation
builder.addNode("increment") { (state: inout CodingAgentState) in
    state.attempts += 1
}
```

---

## 3. Edges (`AgentEdge`)

### Direct Edges
Unconditional transition from `NodeA` to `NodeB`:
```swift
builder.addEdge(from: "coder", to: "formatter")
```

### Conditional Edges
Dynamic routing based on runtime state evaluations:
```swift
builder.addConditionalEdge(from: "verifier") { (state: CodingAgentState) in
    if state.testLogs.contains("PASS") {
        return EndNode.id
    } else if state.attempts > 3 {
        return "humanReview"
    } else {
        return "coder" // Loop back
    }
}
```

### Discriminator Branch Edges
Routing using dictionary key mapping:
```swift
builder.addBranchEdge(
    from: "router",
    path: { state in state.intentCategory },
    mapping: [
        "sales": "salesAgent",
        "support": "supportAgent",
        "billing": "billingAgent"
    ],
    defaultTarget: "fallbackAgent"
)
```

---

## 4. State Reducer Pipeline

When nodes output partial updates (such as appending message arrays or modifying dictionaries), `StateReducer` merges them deterministically:

```swift
// Append Reducer
let appendReducer = AppendReducer<CodingAgentState, ChatMessage>(keyPath: \.messages)

// Overwrite Reducer
let overwriteReducer = OverwriteReducer<CodingAgentState, String>(keyPath: \.codeDraft)

// Numeric Increment Reducer
let addReducer = NumericAddReducer<CodingAgentState, Int>(keyPath: \.attempts)
```
