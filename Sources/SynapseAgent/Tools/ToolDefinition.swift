import Foundation

/// Defines the OpenAPI / JSON Schema compliant contract for an invocable tool.
public struct ToolDefinition: Sendable, Codable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let parametersJSONSchema: [String: AnySendable]

    public init(
        name: String,
        description: String,
        parametersJSONSchema: [String: AnySendable] = [
            "type": AnySendable("object"),
            "properties": AnySendable([String: AnySendable]()),
            "required": AnySendable([AnySendable]())
        ]
    ) {
        self.id = name
        self.name = name
        self.description = description
        self.parametersJSONSchema = parametersJSONSchema
    }
}

/// Protocol defining a callable native Swift tool that can be invoked by an agent or LLM.
public protocol Tool: Sendable {
    var definition: ToolDefinition { get }
    func call(argumentsJSON: String) async throws -> String
}

/// Closure-based Tool implementation.
public struct ClosureTool: Tool {
    public let definition: ToolDefinition
    private let handler: @Sendable (String) async throws -> String

    public init(
        name: String,
        description: String,
        parametersSchema: [String: AnySendable] = [:],
        handler: @escaping @Sendable (String) async throws -> String
    ) {
        self.definition = ToolDefinition(name: name, description: description, parametersJSONSchema: parametersSchema)
        self.handler = handler
    }

    public func call(argumentsJSON: String) async throws -> String {
        try await handler(argumentsJSON)
    }
}
