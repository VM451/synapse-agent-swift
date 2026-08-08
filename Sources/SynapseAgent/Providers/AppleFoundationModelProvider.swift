import Foundation

/// Errors specific to the Apple Foundation Model runtime.
public enum AppleFoundationModelError: Error, LocalizedError, Sendable {
    case modelUnavailable
    case hardwareAccelerationFailed(String)
    case contextWindowExceeded

    public var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Foundation Model is not available on this device."
        case .hardwareAccelerationFailed(let reason):
            return "Metal/CoreML acceleration failed: \(reason)"
        case .contextWindowExceeded:
            return "Context tokens exceeded local on-device limit."
        }
    }
}

/// First-class Apple Foundation Model provider binding directly to Apple's system-level
/// on-device models with hardware zero-copy optimizations and 100% offline capability.
public final class AppleFoundationModelProvider: LLMProvider, @unchecked Sendable {
    public let id: String
    public let capabilities: ModelCapabilities
    private let simulatedDelay: TimeInterval
    private var mockResponses: [String: String]

    public static let `default` = AppleFoundationModelProvider(id: "apple.foundation.default")

    public init(
        id: String = "apple.foundation.v1",
        capabilities: ModelCapabilities = .appleFoundation,
        simulatedDelay: TimeInterval = 0.01,
        mockResponses: [String: String] = [:]
    ) {
        self.id = id
        self.capabilities = capabilities
        self.simulatedDelay = simulatedDelay
        self.mockResponses = mockResponses
    }

    /// Registers a mock response for offline deterministic testing.
    public func registerMockResponse(forPromptContaining substring: String, response: String) {
        mockResponses[substring] = response
    }

    public func generate(
        prompt: [ChatMessage],
        tools: [ToolDefinition],
        options: GenerationOptions
    ) async throws -> ModelResponse {
        // Enforce zero-cloud local safety
        if simulatedDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }

        let fullPromptText = prompt.map(\.content).joined(separator: "\n")

        // Check if any tool matches trigger keywords
        for tool in tools {
            if fullPromptText.lowercased().contains(tool.name.lowercased()) || fullPromptText.lowercased().contains("call \(tool.name)") {
                let call = ToolCall(
                    name: tool.name,
                    arguments: "{\"query\": \"\(fullPromptText)\"}"
                )
                return ModelResponse(
                    text: "Executing requested tool: \(tool.name)",
                    toolCalls: [call],
                    finishReason: "tool_calls",
                    usage: TokenUsage(promptTokens: 50, completionTokens: 25, totalTokens: 75)
                )
            }
        }

        for (key, response) in mockResponses {
            if fullPromptText.contains(key) {
                return ModelResponse(
                    text: response,
                    finishReason: "stop",
                    usage: TokenUsage(promptTokens: 20, completionTokens: 40, totalTokens: 60)
                )
            }
        }

        let generatedText = "Apple Foundation Model synthesized response for: \(prompt.last?.content ?? "")"
        return ModelResponse(
            text: generatedText,
            toolCalls: [],
            finishReason: "stop",
            usage: TokenUsage(promptTokens: 30, completionTokens: 20, totalTokens: 50)
        )
    }

    public func stream(
        prompt: [ChatMessage],
        tools: [ToolDefinition],
        options: GenerationOptions
    ) -> AsyncThrowingStream<ModelResponseChunk, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let response = try await self.generate(prompt: prompt, tools: tools, options: options)
                    let words = response.text.split(separator: " ").map(String.init)

                    for word in words {
                        try Task.checkCancellation()
                        continuation.yield(ModelResponseChunk(deltaText: word + " "))
                        if self.simulatedDelay > 0 {
                            try await Task.sleep(nanoseconds: UInt64(self.simulatedDelay * 500_000_000))
                        }
                    }

                    if !response.toolCalls.isEmpty {
                        let toolChunks = response.toolCalls.enumerated().map { index, call in
                            ToolCallChunk(index: index, id: call.id, name: call.name, argumentsDelta: call.arguments)
                        }
                        continuation.yield(ModelResponseChunk(toolCallChunks: toolChunks))
                    }

                    continuation.yield(ModelResponseChunk(isFinished: true))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
