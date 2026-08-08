@_exported import Foundation
@_exported import SwiftUI

#if canImport(SwiftData)
@_exported import SwiftData
#endif

// Re-export core macros
@freestanding(declaration, names: arbitrary)
public macro Tool(
    description: String = ""
) = #externalMacro(module: "SynapseAgentMacros", type: "ToolMacro")

@attached(member, names: arbitrary)
public macro SynapseGraph() = #externalMacro(module: "SynapseAgentMacros", type: "SynapseGraphMacro")

@attached(peer, names: arbitrary)
public macro AgentNode(
    id: String = "",
    description: String = ""
) = #externalMacro(module: "SynapseAgentMacros", type: "AgentNodeMacro")
