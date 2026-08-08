import Foundation

/// Built-in tool for fetching scraped page contents, Markdown conversion, and text highlights.
public struct WebContentsTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "webContents",
            description: "Fetches full-text, rendered HTML, clean Markdown, and highlights for a target web URL.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "url": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("Target website or documentation URL")
                    ]),
                    "extractMarkdown": AnySendable([
                        "type": AnySendable("boolean"),
                        "description": AnySendable("Whether to convert HTML to clean semantic Markdown (default: true)")
                    ])
                ]),
                "required": AnySendable([AnySendable("url")])
            ]
        )
    }

    private let fetchHandler: @Sendable (String, Bool) async throws -> String

    public init(fetchHandler: @escaping @Sendable (_ url: String, _ extractMarkdown: Bool) async throws -> String) {
        self.fetchHandler = fetchHandler
    }

    public init(mockPages: [String: String] = [:]) {
        self.fetchHandler = { url, _ in
            if let text = mockPages[url] {
                return text
            }
            return "# Web Page Content: \(url)\n\nThis page contains documentation and structured data for \(url)."
        }
    }

    public func call(argumentsJSON: String) async throws -> String {
        guard let data = argumentsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let url = json["url"] as? String else {
            throw GraphError.toolExecutionFailed(toolName: "webContents", errorDescription: "Missing or invalid 'url' parameter.")
        }

        let extractMarkdown = (json["extractMarkdown"] as? Bool) ?? true
        return try await fetchHandler(url, extractMarkdown)
    }
}

/// Built-in tool for running multi-step autonomous deep research with synthesized citations.
public struct DeepResearchAgentTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "deepResearch",
            description: "Performs iterative multi-step deep research across web and local sources, synthesizing an answer with verified citations.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "query": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("The research question or topic to investigate deeply")
                    ]),
                    "maxDepth": AnySendable([
                        "type": AnySendable("integer"),
                        "description": AnySendable("Maximum link harvesting depth (default: 2)")
                    ]),
                    "maxPages": AnySendable([
                        "type": AnySendable("integer"),
                        "description": AnySendable("Maximum pages to crawl and analyze (default: 5)")
                    ])
                ]),
                "required": AnySendable([AnySendable("query")])
            ]
        )
    }

    private let researchHandler: @Sendable (String, Int, Int) async throws -> String

    public init(researchHandler: @escaping @Sendable (_ query: String, _ maxDepth: Int, _ maxPages: Int) async throws -> String) {
        self.researchHandler = researchHandler
    }

    public init() {
        self.researchHandler = { query, maxDepth, maxPages in
            return """
            # Deep Research Report: \(query)
            - Crawled \(maxPages) pages at depth \(maxDepth).
            - Synthesized findings: Primary sources confirm key architectural insights on-device.
            - Citations:
              [1] https://developer.apple.com/documentation/swift
              [2] localWorkspace://notes.md
            """
        }
    }

    public func call(argumentsJSON: String) async throws -> String {
        guard let data = argumentsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = json["query"] as? String else {
            throw GraphError.toolExecutionFailed(toolName: "deepResearch", errorDescription: "Missing or invalid 'query' parameter.")
        }

        let maxDepth = (json["maxDepth"] as? Int) ?? 2
        let maxPages = (json["maxPages"] as? Int) ?? 5
        return try await researchHandler(query, maxDepth, maxPages)
    }
}
