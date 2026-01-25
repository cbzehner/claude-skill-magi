# Plan 01: Progressive Disclosure Refactor

## Summary

Refactor the magi skill to follow Anthropic's official skill patterns:
- **Progressive disclosure** via multi-file structure
- **Command routing** for independent advisor access (`/magi gemini`, `/magi codex`, `/magi claude`)
- **Markdown-only** - remove shell script wrappers, CLI patterns directly in SKILL.md
- **Graceful degradation** when external advisors fail
- **Improved synthesis presentation** with soft-guided report template

## Target Architecture

```
claude-skill-magi/
├── SKILL.md                    # Main entry point (~80-100 lines)
├── reference.md                # Advisor capabilities, selection matrix
├── synthesis-guide.md          # Synthesis patterns, report template
├── docs/                       # External docs for GitHub (unchanged)
│   ├── ARCHITECTURE.md
│   └── REFERENCE.md
├── examples/                   # Unchanged
├── plans/
└── .claude-plugin/
    └── plugin.json
```

**Deleted files:**
- `scripts/ask_gemini.sh`
- `scripts/ask_codex.sh`
- `scripts/check_prereqs.sh`
- `scripts/` directory

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Single skill with routing | Simpler than 4 separate skills; uses official `$ARGUMENTS` pattern |
| Scripts | **Remove entirely** | Markdown-only approach aligns with skill philosophy; scripts were thin wrappers |
| Timeout | None | Advisors can take 3-12 minutes; no artificial cutoff |
| Retry | Instructed in markdown | "If network error, retry once" - Claude handles naturally |
| Routing | First token exact match | `gemini`, `codex`, `claude` - no aliases |
| Docs structure | Keep `docs/`, create minimal `reference.md` | GitHub viewers get full docs; skill loads lean context |
| Template | Soft guidance | Full template as reference, use appropriate sections based on complexity |
| allowed-tools | Remove Write/Edit | Magi is advisory only; implementation happens outside the skill |
| Missing CLIs | Claude handles | If Gemini/Codex not installed, Claude explains how to install |

---

## Implementation Tasks

### Phase 1: Create Supporting Files

#### Task 1.1: Create `reference.md`

**Content to include:**
- Advisor capabilities summary (strengths of each)
- Selection matrix (when to use which advisor)
- CLI command reference (flags, options)

**Keep it lean** (~60-80 lines). This is loaded on-demand, not always.

```markdown
# Magi Reference

## Advisor Capabilities

| Advisor | Strengths | Best For |
|---------|-----------|----------|
| Gemini | Web search, 1M token context | Current info, API docs, research |
| Codex | Fast (Rust), sandboxing | Quick analysis, CI/CD patterns |
| Claude | Deep reasoning (Opus) | Architecture, code review, complex problems |

## CLI Commands

### Gemini
gemini "[prompt]" --sandbox -o text

### Codex
codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"

## Selection Guide

[When to use each advisor table]
```

#### Task 1.2: Create `synthesis-guide.md`

**Content to include:**
- Synthesis patterns (consensus, complementary, conflict, gap)
- Conflict resolution framework
- Anti-patterns to avoid
- Report template (as reference, not mandate)

```markdown
# Synthesis Guide

## Patterns

| Pattern | When | Action |
|---------|------|--------|
| Consensus | All agree | Proceed with confidence |
| Complementary | Different but compatible | Combine insights |
| Conflict | Direct contradiction | Evaluate evidence, decide |
| Gap | One silent | Note gap, use available info |

## Report Template

Use appropriate sections based on query complexity:

# Magi Synthesis Report

## Quick Answer
[1-2 sentence actionable recommendation]

## Advisor Summary
| Advisor | Approach | Key Insight |
|---------|----------|-------------|

## Consensus
[What advisors agreed on - if any]

## Conflicts & Resolution
[Only if significant disagreements exist]

## Synthesized Plan
[Combined recommendation]

## Gaps
[What wasn't addressed - if relevant]

---

Simple queries may only need Quick Answer + Advisor Summary.
Complex architecture decisions should use the full template.
```

### Phase 2: Refactor SKILL.md

**Target: ~80-100 lines**

```yaml
---
name: magi
description: Multi-AI counsel system. Query Gemini, Codex, Claude advisors independently (/magi gemini "prompt") or together (/magi "prompt") with synthesis. Use when planning features, debugging errors, researching APIs, finalizing plans, reviewing code, or wanting alternative perspectives.
allowed-tools: Bash, Read, Glob, Grep, Task
# Note: Write/Edit intentionally excluded - magi is advisory only
---

# Magi

Query AI advisors for multi-perspective counsel.

## Command Routing

Parse ARGUMENTS to determine mode:

| Pattern | Mode | Action |
|---------|------|--------|
| `gemini "prompt"` | Single | Query Gemini only |
| `codex "prompt"` | Single | Query Codex only |
| `claude "prompt"` | Single | Query Claude only |
| `"prompt"` (no prefix) | Full | All three + synthesis |
| (empty) | Help | Show usage examples |

### Routing Rules
1. Extract first whitespace-delimited token from ARGUMENTS
2. If token exactly matches `gemini`, `codex`, or `claude` (case-insensitive):
   - Route to single advisor mode
   - Remaining text is the prompt
3. If no match: Full counsel mode, entire ARGUMENTS is the prompt
4. If empty: Show usage examples

## Single Advisor Mode

### Gemini
Bash: gemini "[prompt]" --sandbox -o text

### Codex
Bash: codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"

### Claude
Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "[prompt]"

Return the advisor's response directly.

## Full Counsel Mode

Run all 3 in parallel (single message):

Bash: gemini "[prompt]" --sandbox -o text
      run_in_background: true

Bash: codex exec --sandbox read-only --skip-git-repo-check -- "[prompt]"
      run_in_background: true

Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "You are a senior software architect advisor. [prompt]"
  run_in_background: true

Collect results with TaskOutput, then synthesize per [synthesis-guide.md](synthesis-guide.md).

## Handling Failures

Claude (Task subagent) always succeeds - it's internal.
Gemini and Codex (external CLIs) may fail.

| Available | Action |
|-----------|--------|
| 3/3 | Full synthesis |
| 2/3 | Partial synthesis, note which advisor was unavailable |
| 1/3 (Claude only) | Return Claude's response with note: "External advisors unavailable. This is Claude's analysis only. Want me to retry Gemini/Codex?" |

### Error Handling
- If Bash fails with network-related error, retry once
- If auth error (mentions "login" or "credentials"), suggest user run `gemini --login` or `codex login`
- Don't retry auth failures

## Usage Examples

When ARGUMENTS is empty, show:

Usage:
  /magi "prompt"                    # Query all three advisors + synthesis
  /magi gemini "prompt"             # Query Gemini only
  /magi codex "prompt"              # Query Codex only
  /magi claude "prompt"             # Query Claude only

Examples:
  /magi "How should we implement caching?"
  /magi gemini "What's the latest on React Server Components?"
  /magi codex "Review this function for performance issues"

## References

- Advisor capabilities and CLI details: [reference.md](reference.md)
- Synthesis patterns and report template: [synthesis-guide.md](synthesis-guide.md)
```

### Phase 3: Delete Scripts

Remove the `scripts/` directory entirely:
- `scripts/ask_gemini.sh`
- `scripts/ask_codex.sh`
- `scripts/check_prereqs.sh`

### Phase 4: Update Documentation

#### README.md
- Remove `scripts/check_prereqs.sh` verification command
- Update "How It Works" diagram (remove script wrappers)
- Update "Files" section (remove scripts/)
- Update trigger list to include: planning, debugging, research, **finalizing plans, reviewing code**, alternative perspectives

#### docs/ARCHITECTURE.md
- Rewrite to explain markdown-only approach
- Remove all script references
- Update parallel execution examples to use direct CLI calls

#### docs/REFERENCE.md
- Remove script wrapper sections
- Keep CLI command reference (now in reference.md too)

#### examples/*.md
- Update all three examples to show direct CLI calls instead of script invocations

#### docs/SKILL_GUIDE.md (New)
Create a guide on building excellent skills, focused on patterns and real insights:

1. **Progressive Disclosure** - when to split files, what stays in SKILL.md
2. **Scripts vs Markdown-Only** - decision framework
3. **File Structure Patterns** - reference files, examples, docs
4. **Description Writing** - trigger words, invocation hints
5. **Command Routing** - argument parsing patterns
6. **Error Handling** - graceful degradation strategies
7. **Testing Skills** - validation checklist

Link to official docs for comprehensive coverage; focus on insights not obvious from docs.

### Phase 5: Validation

- [ ] SKILL.md under 100 lines
- [ ] `/magi gemini "test"` works (single advisor)
- [ ] `/magi "test"` works (full counsel)
- [ ] `/magi` with no args shows usage
- [ ] `/magi "should I use gemini?"` routes to full mode (not Gemini)
- [ ] Graceful degradation when Gemini/Codex unavailable
- [ ] 1/3 case offers to retry

---

## File Change Summary

| File | Action |
|------|--------|
| `SKILL.md` | Refactor - add routing, CLI patterns, ~85 lines |
| `reference.md` | Create - advisor capabilities, ~70 lines |
| `synthesis-guide.md` | Create - patterns, template, ~80 lines |
| `scripts/` | **Delete entire directory** |
| `docs/ARCHITECTURE.md` | Rewrite - explain markdown-only approach, remove script references |
| `docs/REFERENCE.md` | Update - remove script wrapper sections |
| `README.md` | Update - remove script references, update "How It Works" diagram, update file tree |
| `examples/planning.md` | Update - change script calls to direct CLI commands |
| `examples/debugging.md` | Update - change script calls to direct CLI commands |
| `examples/research.md` | Update - change script calls to direct CLI commands |
| `docs/SKILL_GUIDE.md` | **Create** - patterns and insights for building excellent skills |

---

## Key Changes from Original Plan

| Original | Updated | Reason |
|----------|---------|--------|
| Shell script wrappers | Markdown-only | Simpler, aligns with skill philosophy |
| 90s timeout + retry | No timeout, retry via instruction | Advisors take 3-12 min naturally |
| Error classification in scripts | Error handling in markdown | Claude can interpret errors |
| 0/3 failure case | N/A (Claude always works) | Task subagent is internal |

---

## Magi Review Findings Incorporated

From the magi self-review, we incorporated:

1. **Keep execution mechanics in SKILL.md** (Gemini's advice) - CLI patterns stay in main file
2. **Explicit routing rules with examples** (Codex's advice) - Added parsing rules section
3. **Removed portability issues** (Claude's advice) - No `timeout` command, no scripts
4. **Soft template guidance** (All agreed) - Complexity-appropriate synthesis

---

## Sources

- [Anthropic Skills Documentation](https://code.claude.com/docs/en/skills)
- [Anthropic Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Agent Skills Engineering Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [anthropics/skills Repository](https://github.com/anthropics/skills)
