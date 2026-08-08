# Evaluation & A/B Testing

SynapseAgent ships with a native Swift evaluation harness that lets you run regression datasets, score agent outputs with multiple metrics, and compare agent variants head-to-head — all on-device without external eval services.

---

## 1. Defining Eval Scenarios

An `EvalScenario` pairs an input state with expected outcomes and optional quality constraints:

```swift
import SynapseAgent

struct MyState: AgentState {
    var query: String = ""
    var answer: String = ""
    var toolsUsed: [String] = []
    var durationMs: Double = 0
}

let scenario = EvalScenario(
    name: "Capital City Lookup",
    inputState: MyState(query: "What is the capital of Japan?"),
    expectedOutputSubstrings: ["Tokyo"],       // Must appear in answer
    prohibitedSubstrings: ["error", "sorry"],  // Must NOT appear
    expectedToolCalls: ["web_search"],         // Tools expected to be called
    prohibitedToolCalls: ["send_email"],       // Tools that must NOT be called
    maxDurationSeconds: 5.0,                   // Latency SLA
    maxCostUSD: 0.001,                         // Cost budget cap
    gradingRubric: "Answer should name Tokyo as the capital."
)

let dataset = EvalDataset(name: "Geography Basics", scenarios: [scenario])
```

---

## 2. Running the Regression Harness

`AgentEvalRunner` runs a dataset against a compiled `Graph` and returns a scored `EvalReport`:

```swift
let runner = AgentEvalRunner<MyState>()
let report = try await runner.run(graph: graph, dataset: dataset)

print(report.formattedSummary())
// ================================================================================
// SYNAPSE AGENT EVALUATION REPORT: Geography Basics
// Pass Rate: 100.0% (1/1) | Avg Score: 1.00 | Avg Latency: 0.203s
// Total Tokens: 840 | Total Cost: $0.00084
// ================================================================================
```

### EvalReport Fields

| Field | Description |
|:---|:---|
| `passRatePercentage` | Percentage of scenarios where all metrics passed |
| `passedScenarios` / `totalScenarios` | Count of passed vs total |
| `averageScore` | Mean score across all scenario metrics (0.0–1.0) |
| `averageDuration` | Mean wall-clock execution time |
| `totalCostUSD` | Aggregate USD cost across all scenarios |
| `scenarioResults` | Per-scenario breakdown with individual metric scores |

---

## 3. Evaluation Metrics

### `ContainsEvaluator` — Substring Presence

```swift
let metric = ContainsEvaluator(
    expected: ["Tokyo", "Japan"],
    prohibited: ["error", "I don't know"]
)
```

### `ToolCallSequenceEvaluator` — Tool Usage Compliance

Verifies the agent called exactly the tools it should have (and avoided prohibited ones):

```swift
let metric = ToolCallSequenceEvaluator(
    expected: ["web_search"],
    prohibited: ["send_email", "delete_file"]
)
```

### `LatencyEvaluator` — Execution SLA Enforcement

```swift
let metric = LatencyEvaluator(maxDurationSeconds: 3.0)
// Score: 1.0 if under SLA, 0.0 if exceeded
```

### `CostBudgetEvaluator` — Dollar Budget Cap

```swift
let metric = CostBudgetEvaluator(maxCostUSD: 0.005)
// Score: 1.0 if under budget, 0.0 if exceeded
```

### `LLMAsJudgeEvaluator` — Qualitative Rubric Scoring

Uses a second LLM call to grade the output against a natural language rubric:

```swift
let metric = LLMAsJudgeEvaluator(
    rubric: "The answer should clearly state Tokyo as the capital, be factually accurate, and be concise.",
    provider: AppleFoundationModelProvider.default  // On-device grading — free
)
// Returns a continuous score 0.0–1.0
```

---

## 4. A/B Testing Two Agent Variants

`AgentABExperiment` runs the same dataset against two different agent graphs and produces a statistical comparison:

```swift
// Variant A — simple prompt
let builderA = GraphBuilder<MyState>()
builderA.addNode(ClosureNode(id: "respond") { state in
    var s = state
    s.answer = try await baselineProvider.generate(prompt: state.query)
    return s
})
builderA.setEntryPoint("respond")
builderA.addEdge(from: "respond", to: EndNode.id)
let graphA = builderA.compile()

// Variant B — enhanced chain-of-thought prompt
let builderB = GraphBuilder<MyState>()
builderB.addNode(ClosureNode(id: "respond") { state in
    var s = state
    s.answer = try await enhancedProvider.generate(
        prompt: "Think step by step. \(state.query)"
    )
    return s
})
builderB.setEntryPoint("respond")
builderB.addEdge(from: "respond", to: EndNode.id)
let graphB = builderB.compile()

// Run experiment
let experiment = AgentABExperiment<MyState>(
    name: "Prompt Refinement Study",
    variantAName: "Baseline Prompt",
    variantBName: "Chain-of-Thought Prompt"
)
let comparison = try await experiment.compare(
    graphA: graphA,
    graphB: graphB,
    dataset: dataset
)

print(comparison.formattedReport())
// ================================================================================
// A/B EXPERIMENT REPORT: Prompt Refinement Study
// Winner: 🏆 Chain-of-Thought Prompt
// --------------------------------------------------------------------------------
// Metric                    | Baseline Prompt  | Chain-of-Thought Prompt
// Pass Rate                 | 60.0%            | 100.0%
// Avg Quality Score         | 0.61             | 0.97
// Avg Latency               | 0.183s           | 0.247s
// Total Cost USD            | $0.00031         | $0.00048
// Head-to-Head Win Rate     | 0.0%             | 100.0%
// ================================================================================
```

### ABExperimentComparison Fields

| Field | Description |
|:---|:---|
| `winningVariant` | Name of the winning variant |
| `winRateA` / `winRateB` | Head-to-head win percentage per variant |
| `latencyDeltaPercent` | Latency difference B vs A (positive = B slower) |
| `costDeltaPercent` | Cost difference B vs A (positive = B costs more) |
| `reportA` / `reportB` | Full `EvalReport` for each variant |

---

## 5. Continuous Integration Integration

Integrate your eval suite into CI by running from the command line:

```bash
swift test --filter EvaluationTests
```

All evaluation tests run fully offline using `MockApplePlatformServices` — no API keys, no network, no cost.
