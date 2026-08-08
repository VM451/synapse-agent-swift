import Foundation

/// Thread-safe registry holding available agent tools.
public final class ToolRegistry: @unchecked Sendable {
    private var tools: [String: any Tool] = [:]
    private let lock = NSLock()

    public init() {}

    /// Registers a tool into the registry.
    public func register(_ tool: any Tool) {
        lock.lock()
        defer { lock.unlock() }
        tools[tool.definition.name] = tool
    }

    /// Fetches all active tool definitions for LLM prompt injection.
    public func definitions() -> [ToolDefinition] {
        lock.lock()
        defer { lock.unlock() }
        return tools.values.map(\.definition)
    }

    /// Looks up a registered tool by its name.
    public func tool(named name: String) -> (any Tool)? {
        lock.lock()
        defer { lock.unlock() }
        return tools[name]
    }
}

/// Dynamic Tool Dispatcher that isolates tool execution, validates JSON inputs against typed parameters,
/// and handles runtime execution errors cleanly without breaking the agent loop.
public struct ToolDispatcher: Sendable {
    public let registry: ToolRegistry

    public init(registry: ToolRegistry = ToolRegistry()) {
        self.registry = registry
    }

    /// Dispatches a batch of tool calls and returns results mapped by call ID.
    public func dispatch(toolCalls: [ToolCall]) async -> [ChatMessage] {
        var results: [ChatMessage] = []
        for call in toolCalls {
            let resultMessage = await execute(call: call)
            results.append(resultMessage)
        }
        return results
    }

    /// Safely executes a single tool call with error recovery.
    public func execute(call: ToolCall) async -> ChatMessage {
        guard let tool = registry.tool(named: call.name) else {
            return ChatMessage.toolResult("Error: Tool '\(call.name)' is not registered.", toolCallId: call.id)
        }

        do {
            let output = try await tool.call(argumentsJSON: call.arguments)
            return ChatMessage.toolResult(output, toolCallId: call.id)
        } catch {
            return ChatMessage.toolResult("Execution Error in '\(call.name)': \(error.localizedDescription)", toolCallId: call.id)
        }
    }
}
