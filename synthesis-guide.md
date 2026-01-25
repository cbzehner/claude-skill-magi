# Synthesis Guide

Patterns for combining advisor responses. Loaded on demand.

---

## Synthesis Patterns

| Pattern | When | Action |
|---------|------|--------|
| **Consensus** | All advisors agree | Proceed with confidence; verify critical assumptions |
| **Complementary** | Different but compatible | Combine insights from each |
| **Conflict** | Direct contradiction | Evaluate evidence, apply context, decide |
| **Gap** | One advisor silent | Note gap, use available info, or query specifically |

### Consensus

All agree on approach. Watch for shared blind spots or outdated practices.

### Complementary

Different perspectives that fit together:
- Gemini's research for background/current state
- Codex's patterns for implementation details
- Claude's reasoning for architecture/risks

**Example**:
- Gemini: "OWASP recommends bcrypt"
- Codex: "Project uses argon2"
- Synthesis: "Use argon2 (meets OWASP standards, matches existing pattern)"

### Conflict

Direct contradiction requires resolution:
1. **Categorize**: Factual (verify docs), Architectural (consider constraints), Stylistic (follow project), Risk (evaluate evidence)
2. **Evaluate evidence**: Good = specific references, reasoned arguments. Weak = vague claims, false confidence.
3. **Apply context**: Existing patterns, team expertise, requirements
4. **Decide**: Prefer simpler, prefer reversible, prefer established

### Gap

One advisor didn't address something:
- Query that advisor specifically
- Use available information
- Mark as assumption if proceeding

---

## Report Template

Use appropriate sections based on query complexity. Simple queries may only need Quick Answer + Advisor Summary.

```markdown
# Magi Synthesis Report

## Quick Answer
[1-2 sentence actionable recommendation]

## Advisor Summary
| Advisor | Approach | Key Insight |
|---------|----------|-------------|
| Gemini | ... | ... |
| Codex | ... | ... |
| Claude | ... | ... |

## Consensus
[What advisors agreed on - if any]

## Conflicts & Resolution
[Only if significant disagreements exist]
- Gemini suggested X because [reasoning]
- Codex suggested Y because [reasoning]
- Resolution: Chose X because [synthesis]

## Synthesized Plan
[Combined recommendation with concrete steps]

## Gaps
[What wasn't addressed - if relevant]
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **False consensus** | Agreement doesn't equal correctness | Verify critical assumptions |
| **Authority bias** | Preferring one advisor without reason | Evaluate evidence quality |
| **Analysis paralysis** | Over-deliberating minor decisions | Set decision threshold |
| **Ignoring context** | Generic advice to specific situation | Apply project constraints |

---

## Communication Format

When presenting synthesis to users:

```
**Gemini**: [key points]
**Codex**: [key points]
**Claude**: [key points]

**Synthesis**: [recommendation]
**Reasoning**: [why, noting agreements/conflicts]
```

Be explicit about which advisor contributed what, and explain your reasoning for the final recommendation.
