# Tools & Dynamic Tool Dispatcher

`SynapseAgent` provides compile-time schema generation and dynamic runtime tool execution with automatic error recovery.

---

## 1. Defining a Tool

Implement the `Tool` protocol:

```swift
import SynapseAgent

public struct WeatherTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "getWeather",
            description: "Fetches current weather for a city.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "city": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("City name")
                    ])
                ]),
                "required": AnySendable([AnySendable("city")])
            ]
        )
    }

    public func call(argumentsJSON: String) async throws -> String {
        // Parse parameters and execute native Swift logic
        return "Sunny, 24°C in Cupertino"
    }
}
```

---

## 2. Dynamic Tool Dispatcher & Registry

`ToolDispatcher` securely routes model tool calls and formats results into typed `ChatMessage` objects:

```swift
let registry = ToolRegistry()
registry.register(WeatherTool())
registry.register(CalculatorTool())
registry.register(FileSystemTool())

let dispatcher = ToolDispatcher(registry: registry)

// Dispatch batch of tool calls returned by LLM
let responses = await dispatcher.dispatch(toolCalls: modelResponse.toolCalls)
```

---

## 3. Built-in Core Tool Library

- `CalculatorTool` — Evaluates arithmetic and math expressions deterministically.
- `FileSystemTool` — Sandboxed file reading, writing, and directory listing.
- `WebSearchTool` — Local search and documentation lookup.
- `DeviceInfoTool` — Telemetry on Apple device model, RAM, OS version, and thermal state.

---

## 4. Pre-Built Apple Platform Tools

SynapseAgent ships a curated library of native Apple platform tools. Register them all in one call:

```swift
registry.registerApplePlatformCapabilities()
```

| Tool | ID | Capability |
|:---|:---|:---|
| `CalendarTool` | `calendar` | List events, create appointments, find free slots |
| `RemindersTool` | `reminders` | Add, list, and complete to-dos |
| `NotesTool` | `notes` | Search, read, and create Apple Notes |
| `ContactsTool` | `contacts` | Search contacts, get email and phone |
| `MailTool` | `mail` | Draft emails, search mailboxes |
| `FilesTool` | `files` | Read, write, list iCloud Drive files |
| `MapsTool` | `maps` | Search POIs, get directions and distances |
| `SystemControlTool` | `systemControl` | Battery, thermal state, clipboard |
| `TimerTool` | `timer` | Set countdown timers |

Each tool works with either `MockApplePlatformServices` (for testing) or `NativeApplePlatformServices` (for production). See the [Apple Platform Tools Guide](apple-platform-tools.md) for full details.

---

## 5. MCP (Model Context Protocol) Integration

`SynapseAgent` supports bidirectional MCP interoperability:

```swift
// Import tools from an external MCP server
let clientBridge = MCPClientBridge(serverURL: URL(string: "http://localhost:8080/mcp")!)
try await clientBridge.importTools(into: registry)

// Expose your registry as an MCP tool catalog
let serverBridge = MCPServerBridge(registry: registry)
let catalog = serverBridge.listTools()  // Returns [MCPToolSchema]

// Handle an incoming MCP tool call
let result = try await serverBridge.handleCall(toolName: "calendar", argumentsJSON: argsJSON)
```

See the [MCP Integration Guide](mcp-integration.md) for a full bidirectional setup.

---

## 6. Register the Full Ecosystem

One call registers all built-in tools (memory, search, sandbox, Apple platform, and MCP-ready schemas):

```swift
let registry = ToolRegistry()
registry.registerAllEcosystemCapabilities()

// Equivalent to registering:
// CalculatorTool, FileSystemTool, DeviceInfoTool
// MemorySearchTool, MemoryStoreTool, CoreMemoryTool
// WebSearchTool, WebContentsTool, DeepResearchTool
// SandboxRenderTool, SandboxPatchTool, SandboxInspectTool
// CalendarTool, RemindersTool, NotesTool, ContactsTool,
// MailTool, FilesTool, MapsTool, SystemControlTool, TimerTool
```

