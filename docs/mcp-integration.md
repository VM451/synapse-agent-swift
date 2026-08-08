# MCP Integration Guide

SynapseAgent natively supports the **Model Context Protocol (MCP)** — the open standard for tool interoperability between AI agents and tool servers. This lets SynapseAgent both **expose** its tools to external MCP clients and **consume** tools from external MCP servers.

---

## 1. Overview

| Component | Role |
|:---|:---|
| `MCPToolAdapter` | Converts any native `Tool` into an MCP-compliant JSON schema |
| `MCPServerBridge` | Exposes all `ToolRegistry` tools as an MCP tool catalog |
| `MCPClientBridge` | Imports all tools from an external MCP server into `ToolRegistry` |

---

## 2. Converting a Native Tool to MCP Schema

`MCPToolAdapter` wraps any `Tool` conformance and generates a fully compliant `MCPToolSchema`:

```swift
import SynapseAgent

let calendarTool = CalendarTool()
let schema = MCPToolAdapter.toMCPSchema(calendarTool)

print(schema.name)         // "calendar"
print(schema.description)  // "Reads and manages Apple Calendar events..."
print(schema.inputSchema)  // JSON Schema dict for arguments
```

You can also go the other way — wrap an external MCP tool definition as a native `Tool`:

```swift
let externalSchema = MCPToolSchema(
    name: "database_query",
    description: "Runs a SQL query against the project database.",
    inputSchema: ["type": "object", "properties": ["sql": ["type": "string"]]]
)

let nativeTool = MCPToolAdapter.fromMCPSchema(externalSchema) { arguments in
    // Route the call to your external MCP server
    return try await myMCPClient.call(tool: "database_query", arguments: arguments)
}
```

---

## 3. MCPServerBridge — Expose SynapseAgent Tools

`MCPServerBridge` exposes all registered tools as an MCP-compliant tool catalog. External MCP clients (e.g. Claude Desktop, Cursor, or custom agents) can discover and invoke SynapseAgent tools over JSON-RPC.

```swift
import SynapseAgent

let registry = ToolRegistry()
registry.registerAllEcosystemCapabilities()

let bridge = MCPServerBridge(registry: registry)

// List all exposed tools in MCP format
let catalog = bridge.listTools()
for tool in catalog {
    print("\(tool.name): \(tool.description)")
}

// Handle an incoming MCP tool call
let result = try await bridge.handleCall(
    toolName: "calendar",
    argumentsJSON: #"{"action": "list_events", "start": "2026-08-08", "end": "2026-08-15"}"#
)
print(result) // JSON string result
```

---

## 4. MCPClientBridge — Import External MCP Tools

`MCPClientBridge` connects to an external MCP server and imports all its tools into a local `ToolRegistry` as native Swift `Tool` instances:

```swift
import SynapseAgent

let registry = ToolRegistry()

// Import all tools from an external MCP server (e.g. a database MCP server)
let clientBridge = MCPClientBridge(
    serverURL: URL(string: "http://localhost:8080/mcp")!,
    authToken: "Bearer \(myToken)"
)
try await clientBridge.importTools(into: registry)

// Now use them like any other native tool
let dispatcher = ToolDispatcher(registry: registry)
let response = await dispatcher.dispatch(toolName: "database_query", argumentsJSON: #"{"sql": "SELECT * FROM users LIMIT 10"}"#)
print(response)
```

---

## 5. Full Bidirectional MCP Setup

A common pattern is to run SynapseAgent as both an MCP server (serving tools to Claude Desktop or Cursor) and an MCP client (consuming external data tools):

```swift
import SynapseAgent

// 1. Start with native tools
let registry = ToolRegistry()
registry.registerApplePlatformCapabilities()

// 2. Import external tools from MCP server
let clientBridge = MCPClientBridge(serverURL: externalMCPServer)
try await clientBridge.importTools(into: registry)

// 3. Expose all combined tools as an MCP catalog
let serverBridge = MCPServerBridge(registry: registry)
// Serve serverBridge over JSON-RPC to external clients

// 4. Use all tools in your graph
let builder = GraphBuilder<MyState>()
builder.addNode(LLMNode(id: "act", provider: provider, registry: registry))
builder.setEntryPoint("act")
builder.addEdge(from: "act", to: EndNode.id)
let graph = builder.compile()
```

---

## 6. Ecosystem Registration

All MCP components register automatically alongside Apple Platform tools:

```swift
let registry = ToolRegistry()
registry.registerAllEcosystemCapabilities()
// Registers: CalculatorTool, FileSystemTool, MemoryTools, SearchTools,
//            SandboxTools, CalendarTool, RemindersTool, NotesTool,
//            ContactsTool, MailTool, FilesTool, MapsTool, SystemControlTool,
//            TimerTool — all MCP-adapter-ready
```
