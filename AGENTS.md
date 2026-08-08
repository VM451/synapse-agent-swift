# Agent Execution Protocol & Autonomous Engine

You are an autonomous AI engineering peer. You do NOT wait for explicit instructions to maintain project documentation. Maintaining, updating, and syncing context files is an **automatic side-effect of your regular workflow**.

---

## 1. FIRST-TIME BOOTSTRAP PROTOCOL (EXISTING CODEBASE INSPECTION)

**CRITICAL STEP FOR EXISTING PROJECTS:**
If `context/project-overview.md` contains placeholder text or if this is an existing project workspace, your VERY FIRST ACTION must be a **Full Codebase Audit**:

1. **Scan Directory Structure & Stack:** Read `Package.swift`, `Sources/`, `Tests/`, config files, and DB schemas.
2. **Auto-Populate Context Files Immediately:**
   - Write the real stack, folder structure, DB schemas, and invariants into `context/architecture.md`.
   - Extract primary colors, fonts, CSS variables, or styling configs into `context/ui-tokens.md`.
   - Identify existing reusable UI components and register them into `context/ui-registry.md`.
   - Reverse-engineer current features and pending tasks into `context/build-plan.md`.
   - Infer coding standards, error handling patterns, and types into `context/code-standards.md`.
   - Summarize the high-level project vision and user flow in `context/project-overview.md`.
   - Record third-party SDKs, APIs, and MCP services in `context/library-docs.md`.
   - Append an initial "Codebase Inspection Completed" entry to `context/progress-tracker.md`.

---

## 2. Context File Reading Sequence
Before executing any request, read these 9 files in order:
1. `context/project-overview.md` - High-level goals, target users, and scope
2. `context/architecture.md` - Tech stack, database schemas, boundaries, and system rules
3. `context/build-plan.md` - Phase roadmaps and feature sequences
4. `context/code-standards.md` - Code conventions and error handling models
5. `context/library-docs.md` - Third-party SDK guidelines and MCP tools
6. `context/ui-tokens.md` - Design primitives, CSS variables, and palette tokens
7. `context/ui-rules.md` - Styling rules, layout patterns, and visual constraints
8. `context/ui-registry.md` - Living index of constructed components
9. `context/progress-tracker.md` - Append-only continuous history log of all sessions

---

## 3. Autonomous Context Self-Sync (Zero-Prompt Protocol)

Continuously observe user conversations, code changes, and refactors, and automatically update context files as work happens:

### Automatic Trigger Map
- **When a feature is finished or modified:**
  -> Automatically update `context/build-plan.md` (check off items).
  -> Automatically append a new entry block at the bottom of `context/progress-tracker.md` (NEVER overwrite past entries).
- **When a UI component is created or styled:**
  -> Automatically register its structure in `context/ui-registry.md`.
  -> Sync any new CSS variables/tokens introduced into `context/ui-tokens.md`.
- **When database schemas, APIs, or stack dependencies change:**
  -> Automatically reflect schema/boundary changes in `context/architecture.md`.
  -> Log third-party SDK patterns in `context/library-docs.md`.
- **When code conventions or bug fixes reveal new patterns:**
  -> Automatically record the rule in `context/code-standards.md`.
- **When project scope shifts or user preferences change during conversation:**
  -> Automatically adjust vision/scope in `context/project-overview.md`.

---

## 4. Append-Only Progress Tracker Rule
- **`context/progress-tracker.md` is a permanent ledger.**
- **NEVER** clear, replace, or truncate past entries.
- Always **APPEND** a new log entry block at the very end of the file following this structure:

```markdown
### [Session Log] YYYY-MM-DD - [Task Title]
- **Status:** [Completed / In Progress / Blocked]
- **Summary:** Concise summary of what was implemented or changed.
- **Context Auto-Updated:** List of context files modified during this run (e.g., `architecture.md`, `ui-registry.md`).
- **Files Touched:** List of code files modified.
- **Key Decisions:** Architecture, design, or logic choices made.
```

---

## 5. Core System Invariants

* **Swift 6 Strict Concurrency:** 100% data-race free, Sendable conformance on all state, actor isolation on graph runners.
* **On-Device First:** Zero forced cloud dependency, Apple Foundation Model native bindings, local persistence (SwiftData, SQLite).
* **Macro-Driven DX:** Swift 6 Macros for `@SynapseGraph`, `@AgentNode`, `@Tool`, `@AgentState`.
