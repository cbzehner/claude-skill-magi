---
name: magi
description: Queries Gemini CLI, Codex CLI, and Claude Code as research advisors, synthesizes responses into unified recommendations. Use when planning features, debugging errors, researching APIs, or wanting alternative perspectives. Triggers on "magi", "plan", "debug", "research", "alternative perspective", "ask Gemini", "ask Codex", "ask Claude".
allowed-tools: Bash, Read, Glob, Grep, Write, Edit, Task
---

# Magi

Query Gemini, Codex, and Claude as advisors. Synthesize their input. You write all code.

## How to Query Advisors

**Run all 3 in parallel** (single message):

```
# Gemini (via Bash) - pass prompt as positional argument ONLY, do NOT pipe stdin
Bash: scripts/ask_gemini.sh "[ADVISOR_PROMPT]"
      run_in_background: true

# Codex (via Bash) - pass prompt as positional argument ONLY, do NOT pipe stdin
Bash: scripts/ask_codex.sh "[ADVISOR_PROMPT]"
      run_in_background: true

# Claude (via Task subagent - no CLI needed!)
Task:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: "You are a senior software architect advisor. [ADVISOR_PROMPT]
           Provide: 1) Approach 2) Steps 3) Risks 4) Alternatives"
  run_in_background: true

# Then collect results
TaskOutput: [gemini_task_id]
TaskOutput: [codex_task_id]
TaskOutput: [claude_task_id]
```

**Why this approach?** Claude uses a Task subagent (which IS Claude) - no subprocess needed. Gemini/Codex use their CLIs via Bash. Running `claude -p` as a subprocess would hang due to session contention.

**IMPORTANT: Do NOT pipe stdin to the scripts.** Pass the prompt as a single positional argument only.

```bash
# CORRECT - positional argument only
scripts/ask_gemini.sh "Your prompt here"

# WRONG - will fail with "Cannot use both positional prompt and --prompt flag"
cat file.txt | scripts/ask_gemini.sh "Your prompt here"
echo "prompt" | scripts/ask_gemini.sh "Your prompt here"
```

For large prompts, include the content directly in the quoted argument string.

## Tool Selection

| Task | Best Advisor | Why |
|------|--------------|-----|
| Web/API docs | Gemini | google_web_search |
| Current info | Gemini | Web access |
| Fast analysis | Codex | Speed |
| Large context | Gemini | 1M tokens |
| Deep reasoning | Claude | Opus model |
| Code review | Claude | Code expertise |
| Architecture | Claude | Reasoning depth |

## Planning Workflow

```
Planning Progress:
- [ ] Query all three advisors with task context
- [ ] Review responses for agreements/conflicts
- [ ] Synthesize into unified plan
- [ ] Present to user with reasoning
- [ ] Implement (you write the code)
```

**Advisor prompt template**:
```
Task: [description]
Context: [codebase context]
Constraints: [limitations]

Provide: 1) Approach 2) Steps 3) Risks 4) Alternatives
```

## Debugging Workflow

```
Debugging Progress:
- [ ] Gather error context
- [ ] Query all three advisors with error + code
- [ ] Evaluate suggested fixes
- [ ] Implement fix yourself
- [ ] Verify solution
```

**Advisor prompt template**:
```
Error: [message]
Code: [relevant code]
Context: [what was attempted]

Provide: 1) Likely cause 2) Investigation steps 3) Fix 4) Prevention
```

## Research Workflow

**Advisor prompt template**:
```
Topic: [question]
Context: [why needed]

Provide: 1) Key findings 2) Sources 3) Applicability 4) Caveats
```

## Synthesis Patterns

When combining advisor responses:

| Pattern | When | Action |
|---------|------|--------|
| **Consensus** | All agree | Proceed with confidence |
| **Complementary** | Different but compatible | Combine insights |
| **Conflict** | Direct contradiction | Evaluate evidence, decide |
| **Gap** | One silent | Query specifically or use own knowledge |

**Synthesis format**:
```
Gemini: [key points]
Codex: [key points]
Claude: [key points]
Synthesis: [recommendation]
Reasoning: [why, noting agreements/conflicts]
```

## Handling Disagreements

When advisors conflict:

1. **Categorize**: Factual (verify docs), Architectural (consider constraints), Stylistic (follow project), Risk (evaluate evidence)
2. **Evaluate evidence**: Good = specific references, reasoned arguments. Weak = vague claims, false confidence.
3. **Apply context**: Existing patterns, team expertise, requirements
4. **Decide**: Prefer simpler, prefer reversible, prefer established
5. **Communicate**: "Gemini suggested X, Codex suggested Y, Claude suggested Z, I chose W because..."

### Anti-Patterns to Avoid

- **False consensus**: Agreement does not equal correctness
- **Authority bias**: Preferring one advisor without reason
- **Analysis paralysis**: Over-deliberating minor decisions
- **Ignoring context**: Generic advice to specific situation

## Reference

For detailed templates, tool capabilities, and examples see [docs/REFERENCE.md](docs/REFERENCE.md).
