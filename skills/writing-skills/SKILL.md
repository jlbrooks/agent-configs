---
name: writing-skills
description: >-
  Create new Claude Code skills with proper structure, frontmatter, and patterns.
  Use when building skills, writing SKILL.md files, or setting up skill folders.
---

## Jacob's Setup

Default location: `~/projects/agent-configs/skills/`

Structure options:
- **Simple**: `skills/my-skill.md` (flat file, no references)
- **Complex**: `skills/my-skill/SKILL.md` + `references/`, `scripts/`, `assets/`

## Required Frontmatter

```yaml
---
name: kebab-case-name        # ≤64 chars, no "anthropic"/"claude"
description: >-
  Third person. What it does + when to trigger.
  Include synonyms users might say.
---
```

Optional fields:
- `allowed-tools`: Scope permissions (e.g., `Read,Write,Bash(git:*)`)
- `argument-hint`: Show expected args (e.g., `[plan-file]`)
- `user-invocable: false`: Hide from menu, programmatic only

## Token Hierarchy

1. **Level 1** (~100 tokens): Name/description always loaded in system prompt
2. **Level 2** (~1.5-5k tokens): SKILL.md body after skill triggers
3. **Level 3** (unlimited): References loaded on-demand

**Target**: SKILL.md <500 lines. Heavy content → `references/`

## Core Principles

### Conciseness
Challenge each line: "Does Claude need this?" Assume competence. Show code, skip explanations.

### Progressive Disclosure
```markdown
## Quick start
[Essential example]

## Advanced
See [references/ADVANCED.md](references/ADVANCED.md)
```

References: one level deep only. No chains.

### Degrees of Freedom
- **High**: Multiple valid approaches (guidelines)
- **Medium**: Preferred pattern, variation ok (templates)
- **Low**: Fragile/error-prone (exact commands, no flags)

## Description Writing

**Good**: Specific + trigger phrases
```
Analyze Excel spreadsheets, create pivot tables, generate charts.
Use when analyzing spreadsheets, tabular data, or .xlsx files.
```

**Bad**: Vague
```
Helps with documents
```

## Anti-Patterns

| Problem | Fix |
|---------|-----|
| Vague description | Specific + trigger phrases |
| Too many options | Default + escape hatch |
| Windows paths | Forward slashes |
| Deep reference chains | One level deep |
| Explaining obvious | Show code directly |
| Magic numbers | Document why |

## References

- [Workflow Patterns](references/PATTERNS.md) - Checklist, feedback loop, template patterns
- [Skill Archetypes](references/ARCHETYPES.md) - CLI ref, methodology, safety, orchestration
- [Examples](references/EXAMPLES.md) - Good/bad examples from real skills
