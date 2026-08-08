# System Architecture: SynapseAgent

## Tech Stack & Dependencies
- **Language:** Swift 6.0+ (Strict Concurrency `-strict-concurrency=complete`)
- **Package Manager:** Swift Package Manager (SPM) with macros target `SynapseAgentMacros` via `SwiftSyntax`
- **Core Frameworks:** Foundation, SwiftData, CoreData / SQLite3, Metal, NaturalLanguage, Combine, OSLog, LocalAuthentication, Security (Keychain)
- **UI Framework:** SwiftUI with `@Observable` (Observation framework)

## Modular Package Layout
```text
SynapseAgent/
├── Package.swift
├── Sources/
│   ├── SynapseAgent/                      # Main Public API Module
│   │   ├── Core/                          # Graph execution engine, Nodes, Edges, State, Reducers
│   │   │   ├── Graph.swift
│   │   │   ├── GraphBuilder.swift
│   │   │   ├── AgentNode.swift
│   │   │   ├── AgentEdge.swift
│   │   │   ├── AgentState.swift
│   │   │   ├── StateReducer.swift
│   │   │   ├── NodeDispatcher.swift
│   │   │   └── ExecutionContext.swift
│   │   ├── Persistence/                   # Checkpointing, Time-Travel & Storage
│   │   │   ├── StateCheckpointer.swift
│   │   │   ├── SwiftDataCheckpointer.swift
│   │   │   ├── SQLiteCheckpointer.swift
│   │   │   ├── InMemoryCheckpointer.swift
│   │   │   ├── CheckpointRecord.swift
│   │   │   └── TimeTravelEngine.swift
│   │   ├── Providers/                     # Unified LLM Provider Abstraction
│   │   │   ├── LLMProvider.swift
│   │   │   ├── ChatMessage.swift
│   │   │   ├── ModelCapabilities.swift
│   │   │   ├── GenerationOptions.swift
│   │   │   ├── AppleFoundationModelProvider.swift
│   │   │   ├── OpenAIProvider.swift
│   │   │   ├── AnthropicProvider.swift
│   │   │   ├── GoogleGeminiProvider.swift
│   │   │   ├── OllamaProvider.swift
│   │   │   ├── MistralProvider.swift
│   │   │   ├── GrokProvider.swift
│   │   │   └── NvidiaProvider.swift
│   │   ├── Tools/                         # Tool Protocol, Dispatcher & Built-in Library
│   │   │   ├── Tool.swift
│   │   │   ├── ToolDefinition.swift
│   │   │   ├── ToolDispatcher.swift
│   │   │   ├── ToolRegistry.swift
│   │   │   └── Builtin/
│   │   │       ├── CalculatorTool.swift
│   │   │       ├── FileSystemTool.swift
│   │   │       ├── WebSearchTool.swift
│   │   │       └── DeviceInfoTool.swift
│   │   ├── Interrupts/                    # Human-in-the-Loop & Flow Control
│   │   │   ├── GraphInterrupt.swift
│   │   │   ├── InterruptManager.swift
│   │   │   └── ResumePayload.swift
│   │   ├── MultiAgent/                    # Subgraphs & Multi-Agent Consensus
│   │   │   ├── SubgraphNode.swift
│   │   │   ├── SupervisorAgent.swift
│   │   │   ├── SwarmOrchestrator.swift
│   │   │   └── ParallelNode.swift
│   │   ├── Security/                      # Privacy & Security Guardrails
│   │   │   ├── ZeroCloudMode.swift
│   │   │   ├── KeychainStorage.swift
│   │   │   └── PIISanitizer.swift
│   │   ├── SwiftUI/                       # SwiftUI Integration & Visual Components
│   │   │   ├── AgentViewModel.swift
│   │   │   ├── AgentChatView.swift
│   │   │   ├── TimeTravelInspectorView.swift
│   │   │   └── InterruptApprovalBanner.swift
│   │   └── Exports.swift
│   ├── SynapseAgentMacros/                # Swift Compiler Macros Implementation
│   │   ├── SynapseAgentMacrosPlugin.swift
│   │   ├── ToolMacro.swift
│   │   ├── SynapseGraphMacro.swift
│   │   └── AgentNodeMacro.swift
├── Tests/
│   ├── SynapseAgentTests/                 # Comprehensive Swift Testing Suites
│   │   ├── CoreGraphTests.swift
│   │   ├── StateReducerTests.swift
│   │   ├── CheckpointerTests.swift
│   │   ├── TimeTravelTests.swift
│   │   ├── HumanInTheLoopTests.swift
│   │   ├── MultiProviderTests.swift
│   │   ├── StreamingTests.swift
│   │   ├── ToolDispatcherTests.swift
│   │   ├── MultiAgentTests.swift
│   │   ├── SecurityGuardrailsTests.swift
│   │   └── ConcurrencyStressTests.swift
│   └── SynapseAgentMacrosTests/           # Macro Expansion & Schema Generation Tests
│       └── ToolMacroTests.swift
```

## Architecture Invariants
1. **Actor-Isolated Execution:** The graph runtime is managed by `actor GraphEngine<State>` or `actor NodeDispatcher` to ensure thread safety without lock contention.
2. **Deterministic State Reducer Pipeline:** State is an immutable value type (`struct: Codable & Sendable`). State updates are merged through declared reducers.
3. **Zero-Cloud Enforcement:** When `ZeroCloudMode.isEnabled` is set, all external network requests throw `ZeroCloudViolationError` immediately before network dispatch.
