# Providers & LLM Abstraction

`SynapseAgent` provides a unified `LLMProvider` protocol that standardizes model invocation, streaming, and tool definitions across on-device Apple Foundation Models and external multi-cloud providers.

---

## 1. Unified `LLMProvider` Protocol

```swift
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
```

---

## 2. Supported Model Providers

### 🍏 Apple Foundation Model Provider (On-Device Default)
Direct native integration on iOS, iPadOS, macOS, and visionOS with zero-copy hardware acceleration and offline capabilities:
```swift
let appleProvider = AppleFoundationModelProvider.default
let response = try await appleProvider.generate(prompt: [
    ChatMessage.user("Generate a Swift enum for network states.")
])
```

### 🌐 Cloud Providers
- **OpenAI**: GPT-4o, o1, o3-mini, GPT-4o-mini
```swift
let openai = OpenAIProvider(apiKey: "sk-...", model: "gpt-4o")
```

- **Anthropic**: Claude 3.5 Sonnet, Claude 3.5 Haiku, Claude 3 Opus
```swift
let anthropic = AnthropicProvider(apiKey: "sk-ant-...", model: "claude-3-5-sonnet-20241022")
```

- **Google Gemini**: Gemini 1.5 Pro, Flash, Gemini 2.0 Flash
```swift
let gemini = GoogleGeminiProvider(apiKey: "AIza...", model: "gemini-1.5-pro")
```

- **Ollama / Local Llama**: On-device local GGUF execution via Ollama (Llama 3.3, DeepSeek-R1)
```swift
let ollama = OllamaProvider(model: "llama3.3")
```

- **Mistral, xAI Grok, NVIDIA NIM**:
```swift
let mistral = MistralProvider(apiKey: "...")
let grok = GrokProvider(apiKey: "...")
let nvidia = NvidiaProvider(apiKey: "...")
```

---

## 3. Real-Time Token Streaming

Every provider natively supports asynchronous token chunk streams:

```swift
let stream = provider.stream(prompt: [ChatMessage.user("Explain quantum computing in 3 paragraphs.")])

for try await chunk in stream {
    if let delta = chunk.deltaText {
        print(delta, terminator: "")
    }
}
```
