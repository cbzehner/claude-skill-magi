# Magi Reference

Advisor capabilities and CLI details. Loaded on demand.

---

## Advisor Capabilities

| Advisor | Strengths | Best For |
|---------|-----------|----------|
| Gemini | Web search (`google_web_search`), 1M token context | Current info, API docs, library research |
| Codex | Fast (Rust-based), fine-grained sandboxing | Quick analysis, CI/CD patterns, security |
| Claude | Deep reasoning (Opus model), code expertise | Architecture, code review, complex problems |

---

## CLI Reference

### Gemini

```bash
gemini "[prompt]" --sandbox -o text
```

| Flag | Purpose |
|------|---------|
| `--sandbox` | Read-only mode, no file writes |
| `-o` | Output format: `text`, `json`, `stream-json` |
| `-m` | Model: `flash`, `pro`, `flash-lite` |

**Rate limits (free tier)**: 60/min, 1000/day

**Install**: `npm install -g @google/gemini-cli && gemini --login`

### Codex

```bash
codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
```

| Flag | Purpose |
|------|---------|
| `exec` | Non-interactive mode |
| `--sandbox` | `read-only`, `workspace-write`, `danger-full-access` |
| `--skip-git-repo-check` | Run outside git repositories |
| `--model` | Model override |

**Install**: `npm install -g @openai/codex && codex login`

### Claude (Task Subagent)

No CLI needed. Uses Task subagent with `model: "opus"`.

```
Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "You are a senior software architect advisor. [prompt]"
```

**Why not CLI?** Running `claude -p` as subprocess causes session contention. Task subagents avoid this.

---

## Selection Guide

| Task Type | Recommended | Why |
|-----------|-------------|-----|
| Web/API docs | Gemini | Web search access |
| Current info (2024+) | Gemini | Real-time search |
| Library comparison | Gemini | Can research options |
| Fast analysis | Codex | Speed |
| Large codebase context | Gemini | 1M token window |
| Security review | Codex | Sandboxing focus |
| CI/CD patterns | Codex | Automation expertise |
| Deep reasoning | Claude | Opus model capabilities |
| Code review | Claude | Code expertise |
| Architecture decisions | Claude | Reasoning depth |

---

## Prompt Templates

### Planning
```
Task: [description]
Context: [codebase context]
Constraints: [limitations]

Provide: 1) Approach 2) Steps 3) Risks 4) Alternatives
```

### Debugging
```
Error: [message]
Code: [relevant code]
Context: [what was attempted]

Provide: 1) Likely cause 2) Investigation steps 3) Fix 4) Prevention
```

### Research
```
Topic: [question]
Context: [why needed]

Provide: 1) Key findings 2) Sources 3) Applicability 4) Caveats
```

### Code Review
```
Code: [code]
Intent: [what it should do]

Provide: 1) Correctness 2) Issues 3) Improvements 4) Style
```
