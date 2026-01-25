---
name: magi
description: Multi-AI counsel system. Query Gemini, Codex, Claude advisors independently (/magi gemini "prompt") or together (/magi "prompt") with synthesis. Use when planning features, debugging errors, researching APIs, finalizing plans, reviewing code, or wanting alternative perspectives.
allowed-tools: Bash, Read, Glob, Grep, Task
# Note: Write/Edit intentionally excluded - magi is advisory only
---

# Magi

Query AI advisors for multi-perspective counsel.

## Command Routing

Parse `$ARGUMENTS` to determine mode:

| Pattern | Mode | Action |
|---------|------|--------|
| `gemini "prompt"` | Single | Query Gemini only |
| `codex "prompt"` | Single | Query Codex only |
| `claude "prompt"` | Single | Query Claude only |
| `"prompt"` (no prefix) | Full | All three + synthesis |
| (empty) | Help | Show usage examples |

### Routing Rules

1. Extract first whitespace-delimited token from `$ARGUMENTS`
2. If token exactly matches `gemini`, `codex`, or `claude` (case-insensitive):
   - Route to single advisor mode
   - Remaining text is the prompt
3. If no match: Full counsel mode, entire `$ARGUMENTS` is the prompt
4. If empty: Show usage examples

**Examples**:
- `/magi gemini "test"` → Single (Gemini)
- `/magi "use gemini for this"` → Full (first token is "use", no match)
- `/magi Gemini "test"` → Single (case-insensitive match)

## Single Advisor Mode

### Gemini
```
Bash: gemini "[prompt]" --sandbox -o text
```

### Codex
```
Bash: codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
```

### Claude
```
Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "You are a senior software architect advisor. [prompt]"
```

Return the advisor's response directly.

## Full Counsel Mode

Run all 3 in parallel (single message with multiple tool calls):

```
Bash: gemini "[prompt]" --sandbox -o text
      run_in_background: true

Bash: codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
      run_in_background: true

Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "You are a senior software architect advisor. [prompt]"
  run_in_background: true
```

Collect results with `TaskOutput`, then synthesize per [synthesis-guide.md](synthesis-guide.md).

## Handling Failures

Claude (Task subagent) always succeeds - it's internal.
Gemini and Codex (external CLIs) may fail.

| Available | Action |
|-----------|--------|
| 3/3 | Full synthesis |
| 2/3 | Partial synthesis, note which advisor was unavailable |
| 1/3 (Claude only) | Return Claude's response with note: "External advisors unavailable. This is Claude's analysis only. Want me to retry Gemini/Codex?" |

### Error Handling

- If command fails with network error, retry once
- If auth error (mentions "login" or "credentials"), suggest: `gemini --login` or `codex login`
- If CLI not found, explain how to install (see [reference.md](reference.md))
- Don't retry auth failures

## Usage Examples

When `$ARGUMENTS` is empty, show:

```
Usage:
  /magi "prompt"           # Query all three advisors + synthesis
  /magi gemini "prompt"    # Query Gemini only
  /magi codex "prompt"     # Query Codex only
  /magi claude "prompt"    # Query Claude only

Examples:
  /magi "How should we implement caching?"
  /magi gemini "What's the latest on React Server Components?"
  /magi codex "Review this function for performance issues"
  /magi claude "Help me design the authentication architecture"
```

## References

- Advisor capabilities and CLI details: [reference.md](reference.md)
- Synthesis patterns and report template: [synthesis-guide.md](synthesis-guide.md)
