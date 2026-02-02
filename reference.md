# Magi Reference

Advisor capabilities and CLI details. Loaded on demand.

---

## Advisor Capabilities

| Advisor | Model | Strengths | Best For |
|---------|-------|-----------|----------|
| Gemini | gemini-3-pro-preview | Web search, 1M token context, advanced reasoning | Current info, API docs, library research |
| Codex | gpt-5.2-codex (high reasoning) | Fast (Rust-based), fine-grained sandboxing | Quick analysis, CI/CD patterns, security |
| Claude | Opus 4.5 | Deep reasoning, code expertise | Architecture, code review, complex problems |

---

## CLI Reference

### Gemini

```bash
gemini "[prompt]" --model gemini-3-pro-preview --sandbox -o text
```

| Flag | Purpose |
|------|---------|
| `--model` | `gemini-3-pro-preview` (max reasoning), `gemini-3-flash-preview` (fallback) |
| `--sandbox` | Read-only mode, no file writes |
| `-o` | Output format: `text`, `json`, `stream-json` |

**Capacity errors**: Pro preview has limited capacity. On 429 error: wait 60s → retry pro → try flash → skip if still fails.

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
| `--model` | Model override (default: gpt-5.2-codex) |

**Config**: `model_reasoning_effort = "high"` set in `~/.codex/config.toml`

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
