import Foundation

/// Defines the operational capabilities of a target LLM or Foundation Model.
public struct ModelCapabilities: Sendable, Codable, Equatable {
    public let supportsStreaming: Bool
    public let supportsToolCalling: Bool
    public let supportsVision: Bool
    public let supportsJSONSchema: Bool
    public let maxContextTokens: Int
    public let isOnDevice: Bool

    public init(
        supportsStreaming: Bool = true,
        supportsToolCalling: Bool = true,
        supportsVision: Bool = false,
        supportsJSONSchema: Bool = true,
        maxContextTokens: Int = 128_000,
        isOnDevice: Bool = false
    ) {
        self.supportsStreaming = supportsStreaming
        self.supportsToolCalling = supportsToolCalling
        self.supportsVision = supportsVision
        self.supportsJSONSchema = supportsJSONSchema
        self.maxContextTokens = maxContextTokens
        self.isOnDevice = isOnDevice
    }

    public static let appleFoundation = ModelCapabilities(
        supportsStreaming: true,
        supportsToolCalling: true,
        supportsVision: true,
        supportsJSONSchema: true,
        maxContextTokens: 32_768,
        isOnDevice: true
    )

    public static let cloudStandard = ModelCapabilities(
        supportsStreaming: true,
        supportsToolCalling: true,
        supportsVision: true,
        supportsJSONSchema: true,
        maxContextTokens: 128_000,
        isOnDevice: false
    )
}

/// Generation hyperparameters for model requests.
public struct GenerationOptions: Sendable, Codable, Equatable {
    public var temperature: Double?
    public var topP: Double?
    public var maxTokens: Int?
    public var stopSequences: [String]
    public var responseFormatJSON: Bool

    public init(
        temperature: Double? = 0.7,
        topP: Double? = 1.0,
        maxTokens: Int? = 4096,
        stopSequences: [String] = [],
        responseFormatJSON: Bool = false
    ) {
        self.temperature = temperature
        self.topP = topP
        self.maxTokens = maxTokens
        self.stopSequences = stopSequences
        self.responseFormatJSON = responseFormatJSON
    }
}

/// Token usage accounting.
public struct TokenUsage: Sendable, Codable, Equatable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    public init(promptTokens: Int = 0, completionTokens: Int = 0, totalTokens: Int = 0) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

/// Complete response output from an LLM.
public struct ModelResponse: Sendable, Codable, Equatable {
    public let text: String
    public let toolCalls: [ToolCall]
    public let finishReason: String?
    public let usage: TokenUsage?

    public init(
        text: String,
        toolCalls: [ToolCall] = [],
        finishReason: String? = "stop",
        usage: TokenUsage? = nil
    ) {
        self.text = text
        self.toolCalls = toolCalls
        self.finishReason = finishReason
        self.usage = usage
    }
}

/// Incremental delta chunk from a streaming LLM response.
public struct ModelResponseChunk: Sendable, Codable, Equatable {
    public let deltaText: String?
    public let toolCallChunks: [ToolCallChunk]?
    public let isFinished: Bool

    public init(
        deltaText: String? = nil,
        toolCallChunks: [ToolCallChunk]? = nil,
        isFinished: Bool = false
    ) {
        self.deltaText = deltaText
        self.toolCallChunks = toolCallChunks
        self.isFinished = isFinished
    }
}

/// The unified model abstraction protocol across native Apple Foundation Models and external cloud APIs.
public protocol LLMProvider: Sendable {
    var id: String { get }
    var capabilities: ModelCapabilities { get }

    func generate(
        prompt: [ChatMessage],
        tools: [ToolDefinition],
        options: GenerationOptions
    ) async throws -> ModelResponse

    func stream(
        prompt: [ChatMessage],
        tools: [ToolDefinition],
        options: GenerationOptions
    ) -> AsyncThrowingStream<ModelResponseChunk, Error>
}

public extension LLMProvider {
    func generate(prompt: [ChatMessage]) async throws -> ModelResponse {
        try await generate(prompt: prompt, tools: [], options: GenerationOptions())
    }

    func stream(prompt: [ChatMessage]) -> AsyncThrowingStream<ModelResponseChunk, Error> {
        stream(prompt: prompt, tools: [], options: GenerationOptions())
    }
}
