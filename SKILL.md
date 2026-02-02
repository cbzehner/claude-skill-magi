---
name: magi
description: Multi-AI counsel system. Query Gemini, Codex, Claude advisors together with synthesis. Use when planning features, debugging errors, researching APIs, finalizing plans, reviewing code, or wanting alternative perspectives.
allowed-tools: Bash, Read, Glob, Grep, Task
# Note: Write/Edit intentionally excluded - magi is advisory only
---

# Magi

Query AI advisors for multi-perspective counsel.

## Usage

If `$ARGUMENTS` is empty, show usage examples. Otherwise, query all three advisors with the prompt.

## Querying Advisors

Run as a **single background Task** that queries all advisors and returns the complete synthesis:

```
Task:
  subagent_type: "general-purpose"
  model: "opus"
  run_in_background: true
  prompt: |
    You are orchestrating a magi counsel session.

    **User's question**: [prompt]

    **Instructions**:
    1. Run these two Bash commands in parallel:
       - gemini "[prompt]" --model gemini-3-pro-preview --sandbox -o text
       - codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
    2. Also formulate your own response as the Claude advisor
    3. Wait for ALL results before proceeding
    4. If Gemini fails with 429/capacity error:
       - Wait 60 seconds, retry with gemini-3-pro-preview
       - If still fails, try gemini-3-flash-preview
       - If that fails, note "Gemini unavailable" and proceed
    5. If EITHER command fails with permission denied ("denied by policy"):
       - STOP immediately
       - Do NOT proceed with Claude-only synthesis
       - Return ONLY this setup message:

       ## Magi Setup Required

       The magi skill needs permission to run external AI advisors.

       Add these entries to your `.claude/settings.local.json` permissions.allow array:
       - `"Bash(gemini *)"`
       - `"Bash(codex *)"`

       Then restart Claude Code and try again.

    **Output format** (use exactly):

    ## Quick Answer
    [1-2 sentence recommendation]

    <details>
    <summary>Gemini Response</summary>

    [Full Gemini response or "Unavailable: [reason]"]

    </details>

    <details>
    <summary>Codex Response</summary>

    [Full Codex response or "Unavailable: [reason]"]

    </details>

    <details>
    <summary>Claude Response</summary>

    [Your analysis as Claude advisor]

    </details>

    ## Synthesis
    | Advisor | Key Insight |
    |---------|-------------|
    | Gemini | ... |
    | Codex | ... |
    | Claude | ... |

    **Consensus**: [What they agreed on]
    **Conflicts**: [Disagreements and resolution]
    **Recommendation**: [Your synthesized advice]
```

This ensures the main thread receives both individual responses (collapsible) and the synthesis.

## Handling Failures

Claude (Task subagent) always succeeds - it's internal.
Gemini and Codex (external CLIs) may fail.

| Available | Action |
|-----------|--------|
| 3/3 | Full synthesis |
| 2/3 | Partial synthesis, note which advisor was unavailable |
| 1/3 (Claude only) | Only if failures are capacity/network errors. Return Claude's response with note about unavailable advisors. |
| Permission denied | **STOP** - do not synthesize, show setup instructions instead |

### Error Handling

| Error Type | Action |
|------------|--------|
| Permission denied | **STOP** - show setup instructions below |
| 429 / capacity | Wait 60s → retry pro → try flash → proceed without if still fails |
| Auth error | Suggest `gemini --login` or `codex login` |
| CLI not found | Link to [reference.md](reference.md) for install |
| Network error | Retry once |

**Permission setup** (show only for permission errors):
```
Add these entries to your .claude/settings.local.json permissions.allow array:
  "Bash(gemini *)"
  "Bash(codex *)"

Then restart Claude Code.
```
Do NOT fall back to Claude-only for permission errors - user must fix setup.

## Usage Examples

When `$ARGUMENTS` is empty, show:

```
Usage:
  /magi "prompt"    # Query all three advisors + synthesis

Examples:
  /magi "How should we implement caching?"
  /magi "What's the best approach for authentication?"
  /magi "Review this architecture for potential issues"
```

## References

- Advisor capabilities and CLI details: [reference.md](reference.md)
- Synthesis patterns and report template: [synthesis-guide.md](synthesis-guide.md)
