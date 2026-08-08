import Foundation

/// Built-in tool for rendering or hot-reloading web applications in an embedded sandbox.
public struct SandboxRenderTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "sandboxRender",
            description: "Renders or replaces the active HTML5/JS/CSS web application in the embedded client sandbox.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "html": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("Complete HTML document structure to render")
                    ]),
                    "workspaceName": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("Optional identifier of the sandbox workspace (e.g. 'Canvas')")
                    ])
                ]),
                "required": AnySendable([AnySendable("html")])
            ]
        )
    }

    private let renderHandler: @Sendable (String, String?) async throws -> String

    public init(renderHandler: @escaping @Sendable (_ html: String, _ workspaceName: String?) async throws -> String) {
        self.renderHandler = renderHandler
    }

    public init() {
        self.renderHandler = { html, workspaceName in
            let name = workspaceName ?? "DefaultWorkspace"
            return "Sandbox workspace '\(name)' successfully rendered HTML (\(html.count) characters)."
        }
    }

    public func call(argumentsJSON: String) async throws -> String {
        guard let data = argumentsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let html = json["html"] as? String else {
            throw GraphError.toolExecutionFailed(toolName: "sandboxRender", errorDescription: "Missing or invalid 'html' parameter.")
        }

        let workspaceName = json["workspaceName"] as? String
        return try await renderHandler(html, workspaceName)
    }
}

/// Built-in tool for applying sub-millisecond JS and CSS deltas to a live sandbox without full page reloads.
public struct SandboxPatchTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "sandboxPatch",
            description: "Applies live JavaScript execution deltas and CSS stylesheet patches to the running sandbox web app.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "jsDelta": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("JavaScript snippet to execute in sandbox context")
                    ]),
                    "cssDelta": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("Optional CSS rules to inject into sandbox document head")
                    ])
                ]),
                "required": AnySendable([AnySendable("jsDelta")])
            ]
        )
    }

    private let patchHandler: @Sendable (String, String?) async throws -> String

    public init(patchHandler: @escaping @Sendable (_ jsDelta: String, _ cssDelta: String?) async throws -> String) {
        self.patchHandler = patchHandler
    }

    public init() {
        self.patchHandler = { jsDelta, cssDelta in
            let cssCount = cssDelta?.count ?? 0
            return "Sandbox patch applied: JS (\(jsDelta.count) bytes), CSS (\(cssCount) bytes). Execution status: 200 OK."
        }
    }

    public func call(argumentsJSON: String) async throws -> String {
        guard let data = argumentsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let jsDelta = json["jsDelta"] as? String else {
            throw GraphError.toolExecutionFailed(toolName: "sandboxPatch", errorDescription: "Missing or invalid 'jsDelta' parameter.")
        }

        let cssDelta = json["cssDelta"] as? String
        return try await patchHandler(jsDelta, cssDelta)
    }
}

/// Built-in tool for extracting token-optimized semantic DOM structures (Markdown/JSON) from the sandbox.
public struct SandboxInspectDOMTool: Tool {
    public var definition: ToolDefinition {
        ToolDefinition(
            name: "sandboxInspectDOM",
            description: "Extracts a token-optimized semantic Markdown or JSON representation of the live sandbox DOM for agent reasoning.",
            parametersJSONSchema: [
                "type": AnySendable("object"),
                "properties": AnySendable([
                    "format": AnySendable([
                        "type": AnySendable("string"),
                        "description": AnySendable("Format to return: 'markdown' or 'json' (default: 'markdown')")
                    ]),
                    "maxTokens": AnySendable([
                        "type": AnySendable("integer"),
                        "description": AnySendable("Token budget for pruning the DOM hierarchy (default: 4096)")
                    ])
                ]),
                "required": AnySendable([String: AnySendable]())
            ]
        )
    }

    private let inspectHandler: @Sendable (String, Int) async throws -> String

    public init(inspectHandler: @escaping @Sendable (_ format: String, _ maxTokens: Int) async throws -> String) {
        self.inspectHandler = inspectHandler
    }

    public init(mockDOM: String = "# Application Root\n- <div id=\"canvas\">Live UI Component</div>\n- <button id=\"submit\">Submit</button>") {
        self.inspectHandler = { format, maxTokens in
            if format.lowercased() == "json" {
                return "{\"tree\": [{\"tag\": \"div\", \"id\": \"canvas\", \"text\": \"Live UI Component\"}, {\"tag\": \"button\", \"id\": \"submit\", \"text\": \"Submit\"}]}"
            }
            return mockDOM
        }
    }

    public func call(argumentsJSON: String) async throws -> String {
        var format = "markdown"
        var maxTokens = 4096

        if let data = argumentsJSON.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let f = json["format"] as? String { format = f }
            if let m = json["maxTokens"] as? Int { maxTokens = m }
        }

        return try await inspectHandler(format, maxTokens)
    }
}
