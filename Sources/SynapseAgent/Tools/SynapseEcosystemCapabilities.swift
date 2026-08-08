import Foundation

/// Ecosystem capability registrar providing one-line registration of all Synapse capabilities:
/// SynapseMemory (Memory & Knowledge), SynapseSandbox (Execution & UI Canvas), and SynapseSearch (Web & Local Discovery).
public extension ToolRegistry {

    /// Registers the standard full suite of Synapse Ecosystem capabilities.
    func registerAllEcosystemCapabilities(
        memoryTools: [any Tool] = [MemorySearchTool(), MemoryStoreTool(), CoreMemoryTool()],
        sandboxTools: [any Tool] = [SandboxRenderTool(), SandboxPatchTool(), SandboxInspectDOMTool()],
        searchTools: [any Tool] = [WebSearchTool(), WebContentsTool(), DeepResearchAgentTool()],
        utilityTools: [any Tool] = [CalculatorTool(), FileSystemTool(), DeviceInfoTool()]
    ) {
        for tool in memoryTools { register(tool) }
        for tool in sandboxTools { register(tool) }
        for tool in searchTools { register(tool) }
        for tool in utilityTools { register(tool) }
    }

    /// Registers SynapseMemory long-term and working memory tools.
    func registerMemoryCapabilities(
        searchTool: any Tool = MemorySearchTool(),
        storeTool: any Tool = MemoryStoreTool(),
        coreMemoryTool: any Tool = CoreMemoryTool()
    ) {
        register(searchTool)
        register(storeTool)
        register(coreMemoryTool)
    }

    /// Registers SynapseSandbox live execution, DOM inspection, and patching tools.
    func registerSandboxCapabilities(
        renderTool: any Tool = SandboxRenderTool(),
        patchTool: any Tool = SandboxPatchTool(),
        inspectDOMTool: any Tool = SandboxInspectDOMTool()
    ) {
        register(renderTool)
        register(patchTool)
        register(inspectDOMTool)
    }

    /// Registers SynapseSearch web discovery, stealth scraping, and deep research tools.
    func registerSearchCapabilities(
        searchTool: any Tool = WebSearchTool(),
        contentsTool: any Tool = WebContentsTool(),
        researchTool: any Tool = DeepResearchAgentTool()
    ) {
        register(searchTool)
        register(contentsTool)
        register(researchTool)
    }
}
