# Skill Archetypes

## CLI Reference Skill

For tools like `gh`, `gcloud`, `vercel`:

```markdown
# Tool Name

## Authentication
[Auth commands - minimal, assume user knows CLI basics]

## Core Operations

### Resource A
- `tool create-a` - Create A
- `tool list-a` - List all A
- `tool delete-a <id>` - Delete A

### Resource B
[...]

## Common Workflows

### Deploy new version
```bash
tool build && tool deploy --env prod
```

### Rollback
```bash
tool rollback --to <version>
```
```

**Key**: Pure reference, minimal prose. Claude knows CLI semantics.

## Methodology Skill

For workflows like planning, code review, de-slopify:

```markdown
# Methodology Name

> **Core Philosophy:** [one-liner insight]

## Why This Matters
[2-3 sentences motivation - front-load the "why"]

## THE EXACT PROMPT

[Copy-paste ready prompt in all-caps section header.
Enables agent-to-agent handoff, automation.]

## Why This Prompt Works
[Technical breakdown of prompt design]

## Before/After Examples

### Before
[Bad example]

### After
[Good example with annotations]
```

**Key**: Motivation first, exact prompts for reproducibility, concrete examples.

## Safety Tool Skill

For tools like permission guards, command validators:

```markdown
# Tool Name

## Why This Exists
[Threat model - what bad things could happen]

## Risk Tiers

| Tier | Auto-approve | Examples |
|------|--------------|----------|
| CRITICAL | Never | `rm -rf /`, `DROP DATABASE` |
| DANGEROUS | Never | `git reset --hard` |
| CAUTION | After 30s | `rm file.txt` |
| SAFE | Immediately | `rm *.log` |

## What It Blocks
[Patterns that trigger rejection]

## What It Allows
[Patterns that pass through]

## Escape Hatches
[How to override when legitimate need]
```

**Key**: Clear threat model, explicit tiers, escape hatches for legitimate use.

## Orchestration Tool Skill

For tools like agent managers, session coordinators:

```markdown
# Tool Name

## Why This Exists
[Pain points solved - window chaos, context switching, etc.]

## Quick Start
```bash
tool init
tool spawn agent-1
tool send agent-1 "do the thing"
```

## Core Commands

### Session Management
- `tool list` - Show all sessions
- `tool attach <id>` - Attach to session
- `tool kill <id>` - Terminate session

### Communication
- `tool send <id> <message>` - Send message
- `tool broadcast <message>` - Send to all

## Robot Mode

Machine-readable output for automation:
```bash
tool --robot-status    # JSON status
tool --robot-snapshot  # Full state dump
```

## Exit Codes
- 0: Success
- 1: Error
- 2: Invalid args
- 3: Not found

## Integration
[How it connects to other tools in ecosystem]
```

**Key**: Quick start first, robot mode for automation, clear exit codes.

## Data Analysis Skill

For domain-specific data work:

```markdown
# Domain Analysis

## Available Datasets
- **Dataset A**: [description] → See [references/dataset-a.md]
- **Dataset B**: [description] → See [references/dataset-b.md]

## Common Queries

### Metric X over time
```sql
SELECT date, metric_x FROM table WHERE ...
```

### Segment by Y
```sql
SELECT segment, SUM(value) FROM table GROUP BY segment
```

## Output Format

Always structure findings as:
1. Key insight (one sentence)
2. Supporting data (table or chart)
3. Recommended action
```

**Key**: Dataset references, query templates, structured output format.
