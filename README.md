# SynapseAgent (synapse-agent-swift)

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0%20Strict%20Concurrency-orange?logo=swift&logoColor=white" alt="Swift 6.0" />
  <img src="https://img.shields.io/badge/Platforms-iOS%2027+%20%7C%20macOS%2027+%20%7C%20iPadOS%2027+%20%7C%20visionOS%2027+-blue" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  <img src="https://img.shields.io/badge/Tests-23%20Passing-brightgreen" alt="Tests" />
  <img src="https://img.shields.io/badge/On--Device-100%25%20Zero--Cloud%20Ready-purple" alt="On-Device First" />
</p>

**SynapseAgent** is an open-source, high-performance, native Swift framework designed to construct stateful, multi-actor, resilient AI agents exclusively on Apple platforms (**iOS 27.0+, iPadOS 27.0+, macOS 27.0+, visionOS 27.0+**, and newer).

Inspired by the cyclic execution flow of LangGraph and the native ergonomics of SwiftAgent, SynapseAgent brings production-grade agentic orchestration into the Apple ecosystem with on-device execution, zero forced cloud dependency, first-class Apple Foundation Model integration, and a unified external provider layer (OpenAI, Anthropic, Gemini, Ollama, Mistral, Grok, Nvidia).

---

## 📊 Comprehensive Feature Comparison Matrix

| Architectural Feature | SynapseAgent (Native Swift) | LangGraph (Python / JS) | Microsoft AutoGen / SK | SwiftAgent (Community) |
| :--- | :---: | :---: | :---: | :---: |
| **Native Apple Platforms (iOS 27+, macOS 27+, visionOS 27+)** | ✅ | ❌ | ❌ | ❌ |
| **100% On-Device First (Zero Forced Cloud)** | ✅ | ❌ | ❌ | ❌ |
| **Swift 6 Strict Concurrency (Data-Race Free Actors)** | ✅ | ❌ | ❌ | ❌ |
| **Compile-Time Type-Safe State Graphs** | ✅ | ❌ | ❌ | ❌ |
| **First-Class Apple Foundation Model Local Bindings** | ✅ | ❌ | ❌ | ❌ |
| **Hardware Accelerated Local Inference (Apple Silicon / Metal)** | ✅ | ❌ | ❌ | ❌ |
| **Cyclic Graph & Loop Execution Engine** | ✅ | ✅ | ❌ | ❌ |
| **State Persistence via SwiftData & Embedded SQLite3** | ✅ | ❌ | ❌ | ❌ |
| **Time-Travel State Replay & Historical Forking** | ✅ | ✅ | ❌ | ❌ |
| **Human-in-the-Loop Interrupts & Thread Resumption** | ✅ | ✅ | ❌ | ❌ |
| **Multi-Agent Supervisor & Swarm Handoff Routing** | ✅ | ✅ | ✅ | ❌ |
| **Dynamic Tool Dispatcher with JSON Schema Validation** | ✅ | ✅ | ✅ | ❌ |
| **Native SwiftUI `@Observable` State & UI Components** | ✅ | ❌ | ❌ | ❌ |
| **Universal Multi-Cloud Fallback (OpenAI, Claude, Gemini, Ollama)** | ✅ | ✅ | ✅ | ❌ |
| **Zero-Cloud Air-Gapped Network Enforcement** | ✅ | ❌ | ❌ | ❌ |
| **Secure Apple Keychain API Credential Management** | ✅ | ❌ | ❌ | ❌ |
| **Pre-Flight Automatic PII Sanitizer Middleware** | ✅ | ❌ | ❌ | ❌ |
| **Zero Heavy C / Python / Bridge Dependencies** | ✅ | ❌ | ❌ | ❌ |

---

## 🏗 Architectural Overview

```mermaid
graph TD
    App[SwiftUI Application / @Observable State] --> GraphAPI[SynapseGraph / GraphBuilder]
    GraphAPI --> Engine[Stateful Graph Execution Engine]
    Engine --> NodeDispatcher[Actor NodeDispatcher]
    Engine --> Checkpointer[Checkpointer: InMemory / SQLite / SwiftData]
    Engine --> HITL[Human-in-the-Loop & Time-Travel Replay]
    NodeDispatcher --> Providers[LLMProvider Protocol Layer]
    Providers --> AppleFM[Apple Foundation Model / Local Neural Engine]
    Providers --> CloudModels[Multi-Cloud: OpenAI, Anthropic, Gemini, Ollama, Mistral, Grok, Nvidia]
    NodeDispatcher --> ToolEngine[Dynamic Tool Dispatcher & Built-in Tools]
    ToolEngine --> Tools[Calculator, FileSystem, WebSearch, DeviceInfo]
```

---

## ⚡ 30-Second Quickstart

```swift
import SynapseAgent

// 1. Define State
struct AssistantState: AgentState {
    var query: String = ""
    var response: String = ""
}

// 2. Build Cyclic Graph
let builder = GraphBuilder<AssistantState>()
builder.addNode("think") { state in
    let provider = AppleFoundationModelProvider.default
    let res = try await provider.generate(prompt: [.user(state.query)])
    var updated = state
    updated.response = res.text
    return updated
}
builder.setEntryPoint("think")
builder.addEdge(from: "think", to: EndNode.id)

// 3. Compile & Run with SQLite Checkpointer
let graph = builder.compile(checkpointer: SQLiteCheckpointer())
let finalState = try await graph.invoke(initialState: AssistantState(query: "Hello on-device AI!"))
print(finalState.response)
```

---

## 📖 In-Depth Documentation

For granular guides and comprehensive API references, see the **[`docs/`](docs/)** directory:

- 🚀 **[Getting Started & Installation](docs/getting-started.md)**: Setup, SPM integration, and lifecycle streaming.
- 🏛 **[Architecture & Design](docs/architecture-and-design.md)**: Swift 6 strict concurrency, actor isolation, and cyclic data flow.
- 🔄 **[Core Graph Engine & State Reducers](docs/core-graph-engine.md)**: Nodes, direct edges, conditional routing, branching, and state reducers.
- 🤖 **[Providers & Foundation Models](docs/providers-and-models.md)**: Apple Foundation Models, OpenAI, Anthropic, Gemini, Ollama, Mistral, Grok, Nvidia NIM.
- 💾 **[State Persistence & Time Travel](docs/state-persistence-and-time-travel.md)**: SwiftData, SQLite, InMemory checkpointers, state inspection, and thread forking.
- 🛑 **[Human-in-the-Loop & Interrupts](docs/human-in-the-loop-and-interrupts.md)**: Safe action pausing, approval banners, and thread resumption.
- 🤝 **[Multi-Agent Orchestration](docs/multi-agent-orchestration.md)**: Subgraph nesting, supervisor routing, swarm handoffs, and parallel task groups.
- 🛠 **[Tools & Dynamic Tool Dispatcher](docs/tools-and-dispatcher.md)**: Tool definitions, JSON schemas, calculator, filesystem, and telemetry tools.
- 🛡 **[Security & Privacy Guardrails](docs/security-and-privacy.md)**: Zero-cloud mode, Keychain credential management, and PII sanitization.
- 📱 **[SwiftUI Native Integration](docs/swiftui-integration.md)**: `@Observable` `AgentViewModel`, chat interfaces, approval banners, and timeline scrubbers.

---

## 🧪 Testing

SynapseAgent features a test suite with 100% data-race free Swift 6 strict concurrency verification:

```bash
swift test --disable-sandbox
```

---

## 📄 License

MIT License. Built with ❤️ for the Apple AI Developer community.
