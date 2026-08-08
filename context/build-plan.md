# Build Plan & Roadmap: SynapseAgent

## Phase 1: Core Engine & Native Apple Foundation Model Integration
- [x] Swift Package structure with Swift 6 strict concurrency (`Package.swift`)
- [x] Core Graph Types: `AgentState`, `Graph`, `GraphBuilder`, `AgentNode`, `AgentEdge`, `EndNode`, `StartNode`
- [x] State Reducer System: Reducer Protocol, Field Reducers (Append, Overwrite, Merge, Custom)
- [x] Cyclic Execution Engine & Loop Guard (Max recursion depth, cycle detection, async execution)
- [x] Apple Foundation Model native provider with simulated/local inference and hardware acceleration interfaces
- [x] Swift 6 Compiler Macros (`@Tool`, `@SynapseGraph`, `@AgentNode`) for compile-time schema generation

## Phase 2: External Adapters, Tool Dispatcher, Persistence & HITL
- [x] Unified `LLMProvider` Protocol & Request/Response Models (`ChatMessage`, `ModelResponse`, `ModelResponseChunk`, `ToolDefinition`, `GenerationOptions`)
- [x] Universal Cloud & Local Providers: OpenAI, Anthropic, Google Gemini, Ollama/Local Llama, Mistral, Grok, Nvidia NIM
- [x] Streaming SSE Pipeline (`AsyncThrowingStream<ModelResponseChunk, Error>`) across all providers
- [x] Dynamic Tool Dispatcher with JSON Schema validation and error recovery
- [x] Built-in Tools: Calculator, FileSystem, WebSearch, DeviceInfo
- [x] State Checkpointing (`StateCheckpointer`, `SwiftDataCheckpointer`, `SQLiteCheckpointer`, `InMemoryCheckpointer`)
- [x] Human-in-the-Loop Interrupts (`GraphInterrupt.approvalRequired`, `graph.resume(threadId:inputs:)`)
- [x] Time-Travel & State Replay Engine (inspect past steps, branch from history)

## Phase 3: Advanced Multi-Agent Patterns, Security & SwiftUI Integration
- [x] Subgraphs (Nested Agents inside Graph Nodes)
- [x] Multi-Agent Consensus & Routing: Supervisor Agent, Swarm / Handoff Agent, Parallel Node Execution
- [x] Security Guardrails: Zero-Cloud Mode enforcement, Keychain API Key Storage, PII Sanitizer middleware
- [x] SwiftUI Native Observability: `@Observable` `AgentViewModel`, streaming UI components, Time-Travel Inspector, Human-in-the-Loop Approval Banner
- [x] Comprehensive Swift Testing Suite (`swift-testing-pro`, `#expect`, parameterized tests, concurrency stress tests)
