import Testing
import Foundation
@testable import SynapseAgent

@Suite("Tool Dispatcher Tests")
struct ToolDispatcherTests {

    @Test("CalculatorTool evaluates arithmetic string correctly")
    func testCalculatorTool() async throws {
        let calc = CalculatorTool()
        let result = try await calc.call(argumentsJSON: "{\"expression\": \"15 * 4 + 10\"}")
        #expect(result.contains("70") || result.contains("70.0"))
    }

    @Test("FileSystemTool reads and writes within temporary sandbox")
    func testFileSystemTool() async throws {
        let fs = FileSystemTool()
        let filename = "test_synapse_\(UUID().uuidString).txt"
        let writeJson = "{\"action\": \"write\", \"path\": \"\(filename)\", \"content\": \"Hello SynapseAgent\"}"
        _ = try await fs.call(argumentsJSON: writeJson)

        let readJson = "{\"action\": \"read\", \"path\": \"\(filename)\"}"
        let readContent = try await fs.call(argumentsJSON: readJson)
        #expect(readContent == "Hello SynapseAgent")
    }

    @Test("ToolDispatcher handles missing tools gracefully")
    func testToolDispatcherMissingTool() async {
        let dispatcher = ToolDispatcher()
        let call = ToolCall(name: "nonExistentTool", arguments: "{}")
        let result = await dispatcher.execute(call: call)

        #expect(result.content.contains("is not registered"))
    }
}

@Suite("Multi-Agent & Subgraph Tests")
struct MultiAgentTests {

    @Test("SubgraphNode invokes child graph and maps state back to parent")
    func testSubgraphNodeExecution() async throws {
        // Child Graph
        let childBuilder = GraphBuilder<SimpleAgentState>()
        childBuilder.addNode("childWorker") { state in
            var s = state
            s.count += 50
            return s
        }
        childBuilder.setEntryPoint("childWorker")
        childBuilder.addEdge(from: "childWorker", to: EndNode.id)
        let childGraph = childBuilder.compile()

        // Parent Graph
        let parentBuilder = GraphBuilder<PersistentState>()
        let subNode = SubgraphNode<PersistentState, SimpleAgentState>(
            id: "subAgent",
            childGraph: childGraph,
            stateToChild: { parent in SimpleAgentState(count: parent.step) },
            childToState: { parent, child in parent.step = child.count }
        )

        parentBuilder.addNode(subNode)
        parentBuilder.setEntryPoint("subAgent")
        parentBuilder.addEdge(from: "subAgent", to: EndNode.id)

        let parentGraph = parentBuilder.compile()
        let finalState = try await parentGraph.invoke(initialState: PersistentState(step: 10, data: "start"))

        #expect(finalState.step == 60)
    }

    @Test("ParallelNode executes concurrent branches via task group")
    func testParallelNodeExecution() async throws {
        let parallel = ParallelNode<SimpleAgentState>(
            id: "parallelWorker",
            branches: [
                { state, _ in SimpleAgentState(count: state.count + 10) },
                { state, _ in SimpleAgentState(count: state.count + 20) }
            ],
            reducer: { state, results in
                for r in results {
                    state.count += r.count
                }
            }
        )

        let builder = GraphBuilder<SimpleAgentState>()
        builder.addNode(parallel)
        builder.setEntryPoint("parallelWorker")
        builder.addEdge(from: "parallelWorker", to: EndNode.id)

        let graph = builder.compile()
        let res = try await graph.invoke(initialState: SimpleAgentState(count: 0))

        #expect(res.count == 30)
    }
}

@Suite("Security Guardrails & PII Sanitizer Tests")
struct SecurityGuardrailsTests {

    @Test("ZeroCloudMode throws when active and external provider is invoked")
    func testZeroCloudModeEnforcement() async throws {
        ZeroCloudMode.isEnabled = true
        defer { ZeroCloudMode.isEnabled = false }

        let provider = OpenAIProvider(apiKey: "fake-key")

        await #expect(throws: GraphError.self) {
            _ = try await provider.generate(prompt: [ChatMessage.user("hello")])
        }
    }

    @Test("PIISanitizer redacts emails, phones, and SSNs")
    func testPIISanitizer() {
        let dirty = "Contact john.doe@company.com or call 415-555-2671 or check SSN 123-45-6789."
        let cleaned = PIISanitizer.sanitize(text: dirty)

        #expect(!cleaned.contains("john.doe@company.com"))
        #expect(cleaned.contains("[REDACTED_EMAIL]"))
        #expect(!cleaned.contains("415-555-2671"))
        #expect(cleaned.contains("[REDACTED_PHONE]"))
        #expect(!cleaned.contains("123-45-6789"))
        #expect(cleaned.contains("[REDACTED_SSN]"))
    }
}

@Suite("Concurrency & Thread Safety Stress Tests")
struct ConcurrencyStressTests {

    @Test("50 concurrent graph invocations execute safely without race conditions")
    func testConcurrentGraphInvocations() async throws {
        let builder = GraphBuilder<SimpleAgentState>()
        builder.addNode("worker") { state in
            var s = state
            s.count += 1
            return s
        }
        builder.setEntryPoint("worker")
        builder.addEdge(from: "worker", to: EndNode.id)
        let graph = builder.compile()

        try await withThrowingTaskGroup(of: SimpleAgentState.self) { group in
            for i in 0..<50 {
                group.addTask {
                    try await graph.invoke(initialState: SimpleAgentState(count: i))
                }
            }

            var results: [SimpleAgentState] = []
            for try await res in group {
                results.append(res)
            }
            #expect(results.count == 50)
        }
    }
}
