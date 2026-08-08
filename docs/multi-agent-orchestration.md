# Multi-Agent Orchestration & Subgraphs

`SynapseAgent` supports advanced multi-actor consensus architectures, hierarchical routing, sub-agent encapsulation, and parallel branch execution.

---

## 1. Nested Subgraphs (`SubgraphNode`)

Encapsulate an entire child graph within a parent graph node:

```swift
let childGraph = ChildGraphBuilder.compile()

let subNode = SubgraphNode<ParentState, ChildState>(
    id: "researchSubAgent",
    childGraph: childGraph,
    stateToChild: { parentState in
        ChildState(query: parentState.userGoal)
    },
    childToState: { parentState, childFinalState in
        parentState.researchSummary = childFinalState.summary
    }
)

parentBuilder.addNode(subNode)
```

---

## 2. Supervisor Agent Pattern (`SupervisorAgent`)

A central supervisor evaluates tasks and delegates them to specialized workers:

```swift
let workerA = AgentWorker(name: "Coder", roleDescription: "Writes Swift code", graph: codeGraph)
let workerB = AgentWorker(name: "Tester", roleDescription: "Runs test suites", graph: testGraph)

let supervisor = SupervisorAgent(
    workers: [workerA, workerB],
    provider: AppleFoundationModelProvider.default
)

let finalResult = try await supervisor.run(
    initialState: MyState(),
    taskDescription: "Write unit tests for state checkpointer"
)
```

---

## 3. Swarm & Handoff Pattern (`SwarmOrchestrator`)

Enables agents to hand off conversation threads directly to other agents:

```swift
let swarm = SwarmOrchestrator<SupportState>()
swarm.register(agentName: "Triage", graph: triageGraph)
swarm.register(agentName: "Billing", graph: billingGraph)

let handedOffState = try await swarm.handoff(
    from: "Triage",
    to: "Billing",
    state: currentState,
    threadId: "support-thread-88"
)
```

---

## 4. Concurrent Parallel Branches (`ParallelNode`)

Runs multiple worker branches concurrently using Swift's structured concurrency (`withThrowingTaskGroup`):

```swift
let parallel = ParallelNode<ResearchState>(
    id: "parallelFetch",
    branches: [
        { state, context in try await fetchWebSources(state) },
        { state, context in try await queryLocalDatabase(state) }
    ],
    reducer: { state, results in
        for res in results {
            state.gatheredNotes.append(contentsOf: res.gatheredNotes)
        }
    }
)
```
