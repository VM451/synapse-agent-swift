# Security & Privacy Guardrails

`SynapseAgent` is designed for strict enterprise privacy, HIPAA/GDPR compliance, and on-device offline security on Apple devices.

---

## 1. Zero-Cloud Mode Enforcement

When `ZeroCloudMode.isEnabled` is set to `true`, the framework prevents any external HTTP, REST, or WebSocket connection across all cloud model providers:

```swift
// Enforce 100% On-Device Mode
ZeroCloudMode.isEnabled = true

// Any external provider invocation throws GraphError.zeroCloudViolation immediately
let openai = OpenAIProvider(apiKey: "key")
try await openai.generate(prompt: [...]) // Throws ZeroCloudViolation error
```

---

## 2. Secure Apple Keychain Storage

Store external API keys in the Apple Keychain rather than plaintext configuration files or `UserDefaults`:

```swift
let keychain = KeychainStorage(service: "com.synapse.agent.keys")

// Store API key securely
try keychain.save(key: "ANTHROPIC_API_KEY", value: "sk-ant-...")

// Retrieve API key
if let key = try keychain.get(key: "ANTHROPIC_API_KEY") {
    let anthropic = AnthropicProvider(apiKey: key)
}
```

---

## 3. PII Sanitizer Middleware

Redacts Personally Identifiable Information (Emails, Phone Numbers, Social Security Numbers) prior to dispatching prompts:

```swift
let rawInput = "Please email john.appleseed@apple.com or call 408-555-0199."
let safeInput = PIISanitizer.sanitize(text: rawInput)
// Result: "Please email [REDACTED_EMAIL] or call [REDACTED_PHONE]."
```
