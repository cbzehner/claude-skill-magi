---
name: magi
description: Multi-AI counsel system. Query Gemini, Codex, Claude advisors independently (/magi gemini "prompt") or together (/magi "prompt") with synthesis. Use when planning features, debugging errors, researching APIs, finalizing plans, reviewing code, or wanting alternative perspectives.
allowed-tools: Bash, Read, Glob, Grep, Task
# Note: Write/Edit intentionally excluded - magi is advisory only
---

# Magi

Query AI advisors for multi-perspective counsel.

## Command Routing

Parse `$ARGUMENTS` to determine mode. **Do not announce routing decisions**—just execute the appropriate mode silently.

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

Run as a **single background Task** that queries all advisors and returns the complete synthesis:

```
Task:
  subagent_type: "general-purpose"
  model: "opus"
  run_in_background: true
  prompt: |
    You are orchestrating a magi counsel session. Query all three advisors and synthesize their responses.

    **User's question**: [prompt]

    **Instructions**:
    1. Run these two Bash commands in parallel:
       - gemini "[prompt]" --sandbox -o text
       - codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
    2. Also consider the question yourself as the Claude advisor (senior software architect perspective)
    3. Wait for ALL results before proceeding
    4. Synthesize per the patterns below, then return the complete synthesis

    **Synthesis format**:
    - Quick Answer: 1-2 sentence recommendation
    - Advisor Summary: Table of each advisor's key insight
    - Consensus/Conflicts: What they agreed or disagreed on
    - Synthesized recommendation: Your combined analysis

    **Error handling**:
    - If Gemini/Codex fails, note it and synthesize with available responses
    - If auth error, mention the fix (gemini --login or codex login)
```

This ensures the main thread only receives the complete synthesis, not partial results.

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
