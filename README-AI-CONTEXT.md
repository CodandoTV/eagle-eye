# AI Context Structure

EagleEye uses multiple AI coding tools (OpenCode, Claude Code, GitHub Copilot, Gemini, Cursor, etc.). Instead of maintaining separate context files for each tool — which would quickly diverge — all tools point to the same source.

```
📄 AGENTS.md  ← single source of truth (master initializer)
📁 ia/        ← detailed context: instructions, skills, module graph
```

```mermaid
graph LR
    OPENCODE["OpenCode<br/><code>opencode.json → AGENTS.md</code>"]
    CLAUDE["Claude Code<br/><code>CLAUDE.md</code>"]
    COPILOT["GitHub Copilot<br/><code>.github/copilot-instructions.md</code>"]
    CURSOR["Cursor<br/><code>.cursorrules</code>"]
    GEMINI["Gemini<br/><code>.gemini/context.md</code>"]
    CODEX["Codex / OpenAI<br/>(reads natively)"]

    AG["📄 AGENTS.md<br/>Master Initializer"]
    IA["📁 ia/<br/>Detailed Context"]

    OPENCODE -->|reads| AG
    CLAUDE -->|reads| AG
    COPILOT -->|reads| AG
    CURSOR -->|reads| AG
    GEMINI -->|reads| AG
    CODEX -->|reads| AG

    AG -->|references| IA
```

## ia/ structure

```
ia/
  module-graph.md         ← module dependency graph
  instructions/
    dart.md               ← Dart CLI patterns and conventions
  skills/
    architecture.md       ← architectural rules and code conventions
    testing.md            ← testing strategies
    release-notes.md      ← release process
    documentation-review.md ← docs validation
    minimum-requirements.md ← version requirements
    run-build.md          ← how to build and test
    review-pr.md          ← PR review checklist
```

## Tool-specific config

| Location | Tool | Purpose |
|---|---|---|
| `AGENTS.md` | All tools | Master initializer — single source of truth |
| `CLAUDE.md` | Claude Code | Entry point → reads `AGENTS.md` |
| `.gemini/context.md` | Gemini | Entry point → reads `AGENTS.md` |
| `.github/copilot-instructions.md` | GitHub Copilot | Entry point → reads `AGENTS.md` |
| `.cursorrules` | Cursor | Entry point → reads `AGENTS.md` |
| `opencode.json` → `AGENTS.md` | OpenCode | Reads `AGENTS.md` and `ia/skills/` |
