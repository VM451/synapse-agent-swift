# Coding Standards & Conventions

## Language & Typing Conventions
- **Swift 6 Strict Concurrency:** All shared types must conform to `Sendable`. State objects must conform to `Codable & Sendable & Hashable & Equatable`.
- **Actor Isolation:** Shared state mutation and runtime state machines run within dedicated `actor` boundaries (`GraphEngine`, `NodeDispatcher`).
- **No Force Unwrapping:** Use `guard let`, `if let`, or `throw SynapseError` instead of force unwraps (`!`).
- **Modern Swift Testing:** All test suites use Swift Testing (`import Testing`, `@Suite`, `@Test`, `#expect`, `#require`), avoiding legacy `XCTestCase`.
- **Error Handling:** Domain-specific typed enums conforming to `Error & LocalizedError & Sendable` (e.g. `GraphError`, `ToolError`, `ProviderError`, `InterruptError`).
- **No Heavy C/Python Bridges:** 100% native Swift relying on Apple Foundation, SwiftData, Metal, NaturalLanguage, and SQLite3.

## Architecture Patterns
- **Value Semantics:** Graph State is a pure value type. Reducers are pure functions `(inout State, StateUpdate) -> Void`.
- **Structured Concurrency:** Use `withThrowingTaskGroup` for parallel node evaluations rather than detached tasks.
- **Resilient Cancellation:** Check `Task.isCancelled` at each node transition and stream chunk.
