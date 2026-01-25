# Magi Architecture

## Overview

Magi queries three AI advisors in parallel and synthesizes their responses. It uses a **markdown-only** approach—no shell scripts, just direct CLI invocations documented in SKILL.md.

**Key insight**: The Claude advisor uses a Task subagent (which IS Claude), while Gemini and Codex use their respective CLIs via Bash.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         ORCHESTRATOR (Main Claude Code)                          │
│                                                                                  │
│  Receives user request, formulates advisor prompt, runs all 3 in parallel       │
└─────────────────────────────────────────────────────────────────────────────────┘
           │                          │                          │
           │ Bash                     │ Bash                     │ Task subagent
           │                          │                          │ model: opus
           ▼                          ▼                          ▼
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│      GEMINI       │      │      CODEX        │      │      CLAUDE       │
│                   │      │                   │      │                   │
│  gemini CLI       │      │  codex CLI        │      │  Subagent just    │
│  --sandbox        │      │  --sandbox        │      │  THINKS and       │
│  -o text          │      │  read-only        │      │  responds         │
│                   │      │                   │      │                   │
│                   │      │                   │      │  No subprocess    │
│                   │      │                   │      │  No CLI           │
│                   │      │                   │      │  No API call      │
└───────────────────┘      └───────────────────┘      └───────────────────┘
           │                          │                          │
           ▼                          ▼                          │
┌───────────────────┐      ┌───────────────────┐                 │
│   Google Gemini   │      │   OpenAI Codex    │                 │
│      API          │      │      API          │                 │
└───────────────────┘      └───────────────────┘                 │
           │                          │                          │
           └──────────────────────────┼──────────────────────────┘
                                      │
                                      ▼
                              ORCHESTRATOR
                              synthesizes all 3 responses
```

## Why Markdown-Only?

Previous versions used shell script wrappers (`ask_gemini.sh`, `ask_codex.sh`). These were removed because:

1. **Scripts were thin wrappers**: They validated input, checked CLI existence, and ran commands. Claude can do all of this directly.

2. **Error interpretation**: Claude can read CLI error messages and respond appropriately without pre-processing.

3. **Portability**: No GNU vs BSD differences to handle.

4. **Simplicity**: One less layer of indirection.

The CLI commands are now documented directly in SKILL.md:

```bash
# Gemini
gemini "[prompt]" --sandbox -o text

# Codex
codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
```

## Why Hybrid Approach?

### Claude: Task Subagent (not CLI)

Running `claude -p` as a subprocess from within Claude Code causes hangs due to:
- Session contention (both access `~/.claude/` files)
- Rate limiting (both hit Anthropic API)
- Lock file conflicts

**Solution**: Use a Task subagent with `model: "opus"`. The subagent IS Claude—it doesn't need to spawn a subprocess or call an API. It just thinks and responds.

```
OLD: claude -p subprocess          NEW: Task subagent
═══════════════════════            ═══════════════════

Orchestrator                       Orchestrator
     │                                  │
     └── Bash                           └── Task (opus)
           │                                  │
           └── claude -p                      └── (just responds)
                  │                                No process
                  └── API call                     No CLI
                         │                         No API
                    MAY HANG                       RELIABLE
```

### Gemini/Codex: Bash (not subagents)

Task subagents can't run Bash commands due to permission restrictions. So Gemini and Codex must be called via Bash directly from the orchestrator.

## Parallel Execution

Run all three in a single orchestrator turn using background execution:

```
Bash (background): gemini "[prompt]" --sandbox -o text
Bash (background): codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
Task (background): Claude subagent (opus)
TaskOutput: wait for all 3
```

## Command Routing

Magi supports both full counsel mode and single advisor mode:

| Command | Mode |
|---------|------|
| `/magi "prompt"` | Full counsel (all 3 + synthesis) |
| `/magi gemini "prompt"` | Single advisor (Gemini only) |
| `/magi codex "prompt"` | Single advisor (Codex only) |
| `/magi claude "prompt"` | Single advisor (Claude only) |

This is implemented via first-token matching in SKILL.md's routing rules.

## Model Selection

| Advisor | Method | Model | Rationale |
|---------|--------|-------|-----------|
| Gemini | Bash → CLI | (Gemini's default) | Web search, 1M context |
| Codex | Bash → CLI | gpt-5.2-codex | Fast, sandboxed |
| Claude | Task subagent | **opus** | Deep reasoning, best model |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, routing, CLI patterns |
| `reference.md` | Advisor capabilities, selection guide (loaded on demand) |
| `synthesis-guide.md` | Synthesis patterns, report template (loaded on demand) |
| `docs/ARCHITECTURE.md` | This file |
| `docs/DEVELOPMENT.md` | Local development and testing guide |
| `docs/REFERENCE.md` | Detailed reference for external documentation |
