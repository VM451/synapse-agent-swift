# SwiftUI Integration & Observability

`SynapseAgent` provides deep native integration with SwiftUI via Swift's Observation framework (`@Observable`).

---

## 1. `@Observable` `AgentViewModel`

Direct state synchronization between graph node execution and SwiftUI views:

```swift
import SwiftUI
import SynapseAgent

struct ChatScreen: View {
    @State private var viewModel: AgentViewModel<MyState>

    init(graph: Graph<MyState>) {
        _viewModel = State(initialValue: AgentViewModel(graph: graph))
    }

    var body: some View {
        AgentChatView(viewModel: viewModel)
    }
}
```

---

## 2. Included SwiftUI Components

### `AgentChatView`
A complete chat interface with message bubbles, tool call badges, execution indicators, and user input field:

```swift
AgentChatView(viewModel: viewModel)
```

### `InterruptApprovalBanner`
Human-in-the-loop interactive card displaying pending actions with Approve and Reject buttons:

```swift
if let interrupt = viewModel.pendingInterrupt {
    InterruptApprovalBanner(
        interrupt: interrupt,
        onApprove: { viewModel.resume(approved: true) },
        onReject: { viewModel.resume(approved: false) }
    )
}
```

### `TimeTravelInspectorView`
Visual scrubber that allows developers and QA teams to inspect past checkpoints and state transitions:

```swift
TimeTravelInspectorView(checkpoints: viewModel.checkpoints) { checkpoint in
    print("Selected checkpoint: \(checkpoint.checkpointId)")
}
```
