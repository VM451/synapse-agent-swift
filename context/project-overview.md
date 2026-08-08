# Project Overview: SynapseAgent (synapse-agent-swift)

## Product Vision
`synapse-agent-swift` (Module: `SynapseAgent`) is the definitive, open-source, high-performance, native Swift framework designed to construct stateful, multi-actor, resilient AI agents on Apple platforms (iOS, iPadOS, macOS, visionOS).

Inspired by the cyclic execution flow of LangGraph and the native ergonomics of SwiftAgent, it brings production-grade agentic orchestration into the Apple ecosystem with 100% on-device first execution, zero forced cloud dependency, first-class Apple Foundation Model integration, and a unified external provider layer (OpenAI, Anthropic, Google Gemini, Ollama/Local Llama, Mistral, Grok, Nvidia).

## Key Features & Value Proposition
1. **Cyclic Graph Execution Engine**: Actor-isolated state machine with Direct Edges, Conditional Edges, dynamic tool routing, recursion limits, and reducer-driven partial state merges.
2. **First-Class Apple Foundation Model & Unified Multi-Provider Abstraction**: Sendable `LLMProvider` protocol supporting streaming, tool calling, multimodal inputs, structured outputs, and zero-cloud local fallback.
3. **Swift 6 Macros for World-Class DX**: `@Tool` macro for automated JSON Schema / OpenAPI parameter synthesis and invocation, `@SynapseGraph` and `@AgentNode` for declarative graph building.
4. **State Persistence, Time-Travel, & Checkpointing**: `SwiftDataCheckpointer`, `SQLiteCheckpointer`, and `InMemoryCheckpointer` to snapshot state after each node, fork execution, and survive app lifecycle events.
5. **Human-in-the-Loop Interrupts & Resumption**: Deterministic pause/resume (`GraphInterrupt.approvalRequired`) for human approval, UI inspection, and seamless resumption via `graph.resume(...)`.
6. **Subgraphs & Multi-Agent Consensus**: Nested subgraphs, Supervisor agent pattern, Swarm / Handoff pattern, and Map-Reduce / Parallel node orchestrations.
7. **SwiftUI First-Class Observable Bindings**: `@Observable` graph view models, streaming token sequences, live node visualizer models, and time-travel inspection components.
8. **Privacy & Security Guardrails**: `ZeroCloudMode` configuration, macOS/iOS Keychain credentials store, and PII data sanitization pipeline.

## Target Platforms
- iOS 17.0+ / 18.0+
- iPadOS 17.0+ / 18.0+
- macOS 14.0+ / 15.0+
- visionOS 1.0+ / 2.0+
- Swift 6.0+ Language Mode with strict concurrency checking.
