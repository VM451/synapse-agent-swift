# Library & SDK Integration Rules

## Frameworks & Dependencies
- **SwiftSyntax (600.0.0+)**: Used in `SynapseAgentMacros` for parsing Swift declarations and generating compile-time OpenAPI/JSON schema and boilerplate.
- **SwiftData**: Apple's native persistence engine for `SwiftDataCheckpointer` (`ModelContainer`, `ModelContext`, `@Model`).
- **SQLite3 / CoreData**: Low-level embedded SQLite persistence for `SQLiteCheckpointer` without external C library package dependencies.
- **Security / Keychain**: System Keychain APIs for secure storage and retrieval of external model provider keys (OpenAI, Anthropic, Gemini, etc.).
- **NaturalLanguage & Metal / CoreML**: Apple on-device embedding, tokenization, and neural engine accelerated inference bindings.
- **Observation**: `@Observable` Swift 5.9/6.0 observation for SwiftUI state synchronization.
