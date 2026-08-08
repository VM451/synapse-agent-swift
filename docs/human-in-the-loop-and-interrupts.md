# Human-in-the-Loop & Interrupts

`SynapseAgent` provides first-class support for halting graph execution before sensitive actions (e.g. executing payments, issuing commands, deleting database records), freezing state snapshots, presenting review UI, and resuming execution.

---

## 1. Triggering an Interrupt

Inside any node, throwing `GraphInterrupt.approvalRequired` immediately halts graph execution and saves an interrupted checkpoint record:

```swift
builder.addNode("transferFunds") { (state: PaymentState) in
    guard state.isApproved else {
        throw GraphInterrupt.approvalRequired(
            message: "Approve transfer of $\(state.amount) to \(state.recipient)?",
            actionName: "TransferFunds",
            payload: [
                "amount": "\(state.amount)",
                "recipient": state.recipient
            ]
        )
    }
    // Proceed with payment execution...
    var next = state
    next.isCompleted = true
    return next
}
```

---

## 2. Resuming Execution

Once user approval is granted (e.g. from an interactive SwiftUI banner or modal), resume execution with the thread ID:

```swift
// Resume and proceed
let updatedResult = try await graph.resume(
    threadId: "user-thread-01",
    with: approvedState,
    approval: true
)
```

---

## 3. Human-in-the-Loop Banner in SwiftUI

`SynapseAgent` includes ready-to-use SwiftUI approval banners:

```swift
if let interrupt = viewModel.pendingInterrupt {
    InterruptApprovalBanner(
        interrupt: interrupt,
        onApprove: {
            viewModel.resume(approved: true)
        },
        onReject: {
            viewModel.resume(approved: false)
        }
    )
}
```
