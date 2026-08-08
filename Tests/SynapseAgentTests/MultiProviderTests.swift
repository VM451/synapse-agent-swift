import Testing
import Foundation
@testable import SynapseAgent

@Suite("Multi-Provider & Adapter Tests")
struct MultiProviderTests {

    @Test("Apple Foundation Model generates response offline")
    func testAppleFoundationModelGeneration() async throws {
        let provider = AppleFoundationModelProvider(id: "apple.foundation.test", simulatedDelay: 0.0)
        provider.registerMockResponse(forPromptContaining: "summarize", response: "Summary: SynapseAgent is fast.")

        let prompt = [ChatMessage.user("Please summarize SynapseAgent")]
        let response = try await provider.generate(prompt: prompt)

        #expect(response.text.contains("SynapseAgent is fast"))
        #expect(response.usage?.totalTokens ?? 0 > 0)
    }

    @Test("Apple Foundation Model triggers tool call")
    func testAppleFoundationModelToolCall() async throws {
        let provider = AppleFoundationModelProvider(id: "apple.foundation.toolTest", simulatedDelay: 0.0)
        let tool = CalculatorTool()

        let prompt = [ChatMessage.user("Please call calculator with 5 + 5")]
        let response = try await provider.generate(prompt: prompt, tools: [tool.definition], options: GenerationOptions())

        #expect(!response.toolCalls.isEmpty)
        #expect(response.toolCalls.first?.name == "calculator")
    }
}

@Suite("Streaming Pipeline Tests")
struct StreamingTests {

    @Test("Graph.stream emits chronological lifecycle events")
    func testGraphStreamLifecycle() async throws {
        let builder = GraphBuilder<SimpleAgentState>()

        builder.addNode("step1") { state in
            var s = state
            s.count += 10
            return s
        }

        builder.setEntryPoint("step1")
        builder.addEdge(from: "step1", to: EndNode.id)

        let graph = builder.compile()
        var nodeCount = 0
        var isFinished = false

        for try await event in graph.stream(initialState: SimpleAgentState()) {
            switch event {
            case .nodeStarted(let id, _, _):
                #expect(id == "step1")
                nodeCount += 1
            case .completed(let state, _):
                #expect(state.count == 10)
                isFinished = true
            default:
                break
            }
        }

        #expect(nodeCount == 1)
        #expect(isFinished == true)
    }
}
