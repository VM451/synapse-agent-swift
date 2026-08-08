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

## 3. Built-in Tool Library

- `CalculatorTool`: Evaluates arithmetic and math expressions deterministically.
- `FileSystemTool`: Sandboxed file reading, writing, and directory listing.
- `WebSearchTool`: Local search and documentation lookup.
- `DeviceInfoTool`: Telemetry on Apple device model, RAM, OS version, and thermal state.
