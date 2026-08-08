# Observability & Execution Tracing

SynapseAgent provides a LangSmith-equivalent observability stack built entirely in Swift — no external telemetry services required. Every graph run emits structured spans, computes token costs, and supports step-by-step replay.

---

## 1. ExecutionTracer — Hierarchical Span Collection

`ExecutionTracer` is a thread-safe `actor` that collects spans during graph execution and assembles them into a `RunTrace`.

### Span Kinds

| Kind | Emitted by |
|:---|:---|
| `.graph` | Top-level graph invocation |
| `.node` | Each node execution |
| `.tool` | Each tool call dispatched |
| `.llm` | Each LLM provider call |
| `.subgraph` | Nested subgraph invocations |

### Span Fields

Each `TraceSpan` captures:
- `spanId`, `parentId`: Hierarchical parent/child relationships
- `startedAt`, `endedAt`, `durationMilliseconds`: Precise timing
- `status`: `.pending`, `.running`, `.completed`, `.failed`, `.interrupted`
- `inputSnapshot`, `outputSnapshot`: JSON-serialized state deltas
- `tokenUsage`: Prompt and completion token counts
- `costUSD`: Attributed USD cost

### Collecting a Trace

```swift
import SynapseAgent

// Attach tracer to graph execution
let tracer = ExecutionTracer()
let finalState = try await graph.invoke(
    initialState: myState,
    tracer: tracer
)
let trace = await tracer.finalize()
```

---

## 2. Visualization & Export

### ASCII DAG Tree

Renders a human-readable tree showing node execution order, durations, and status.

```swift
print(trace.renderDAG())
// Example output:
// [graph] my-agent-run  (47ms) ✅
// ├── [node] classify   (12ms) ✅
// ├── [tool] web_search (18ms) ✅
// └── [node] respond    (17ms) ✅
```

### Mermaid Diagram

Generates an interactive Mermaid flow diagram you can embed in GitHub READMEs or documentation portals.

```swift
let mermaid = trace.renderMermaid()
print(mermaid)
// graph TD
//   classify --> web_search
//   web_search --> respond
//   respond --> END
```

### JSON Export

Full ISO-8601-timestamped export for logging to files, CloudKit, or analytics pipelines.

```swift
let json = try trace.exportJSON()
// Write to disk, telemetry endpoint, or local SQLite log
```

---

## 3. TokenAccounting — Real-Time Cost Attribution

### Built-in Model Pricing (per 1M tokens)

| Model | Input | Output | Cached |
|:---|---:|---:|---:|
| **Gemini 3.6 Flash** | $0.10 | $0.40 | $0.025 |
| **Gemini 3.6 Pro** | $1.25 | $5.00 | $0.30 |
| **Claude 3.7 Sonnet** | $3.00 | $15.00 | $0.30 |
| **Claude 3.5 Haiku** | $0.80 | $4.00 | $0.08 |
| **GPT-4o** | $2.50 | $10.00 | $1.25 |
| **GPT-4o-mini** | $0.15 | $0.60 | $0.075 |
| **Apple Foundation Models** | $0.00 | $0.00 | $0.00 |
| **Ollama (Local)** | $0.00 | $0.00 | $0.00 |

### CostCalculator

```swift
import SynapseAgent

let pricing = ModelPricing.gemini36Flash
let cost = CostCalculator.compute(
    promptTokens: 1200,
    completionTokens: 450,
    pricing: pricing
)
print(String(format: "Cost: $%.6f", cost)) // Cost: $0.000300
```

### TokenLedger — Per-Node and Per-Tool Attribution

`TokenLedger` is a thread-safe `actor` that tracks token consumption and cost across an entire run, broken down by node name and tool name.

```swift
let ledger = TokenLedger()

// Record consumption at node level
await ledger.record(
    nodeId: "classify",
    provider: "gemini-3.6-flash",
    promptTokens: 800,
    completionTokens: 120
)

// Retrieve per-node breakdown
let nodeSummary = await ledger.summaryByNode()
let totalCostUSD = await ledger.totalCostUSD()
print("Total run cost: \(String(format: "$%.5f", totalCostUSD))")
```

---

## 4. TraceDebugger — Replay & State Inspection

### StepInspector — State Diff Across Steps

`StepInspector` computes key-level mutations between any two consecutive execution snapshots:

```swift
let inspector = StepInspector(trace: trace)

// Compare state before and after node "respond"
let diff = inspector.diff(afterSpanId: "respond-span-id")
for change in diff {
    switch change {
    case .modified(let key, let from, let to):
        print("~ \(key): \(from) → \(to)")
    case .added(let key, let value):
        print("+ \(key): \(value)")
    case .removed(let key):
        print("- \(key)")
    }
}
```

### ReplayEngine — Historical State Reconstruction

`ReplayEngine` reconstructs the full agent state at any historical checkpoint, enabling debugging and what-if branching:

```swift
let replay = ReplayEngine(checkpointer: checkpointer)

// Inspect state at step 3
let stateAtStep3 = try await replay.stateAt(step: 3, threadId: "run-abc")
print(stateAtStep3)

// Fork execution from step 3 with a modified state
let alternativeState = stateAtStep3.with(query: "Alternative query")
let branchedResult = try await graph.invoke(
    initialState: alternativeState,
    threadId: "run-abc-fork-1"
)
```

---

## 5. Integration with SynapseAgent Ecosystem

All observability is registered automatically when using `registerAllEcosystemCapabilities()`:

```swift
let registry = ToolRegistry()
registry.registerAllEcosystemCapabilities()

let tracer = ExecutionTracer()
let ledger = TokenLedger()

let finalState = try await graph.invoke(
    initialState: myState,
    tracer: tracer,
    ledger: ledger
)

let trace = await tracer.finalize()
let totalCost = await ledger.totalCostUSD()

print(trace.renderDAG())
print(String(format: "Run cost: $%.5f", totalCost))
```
