# Workflow Patterns

## Checklist Pattern

For complex multi-step tasks. Track progress with checkboxes:

```markdown
## Workflow

- [ ] Step 1: Analyze input (run `scripts/analyze.py`)
- [ ] Step 2: Create mapping
- [ ] Step 3: Validate (`scripts/validate.py`)
- [ ] Step 4: Generate output
- [ ] Step 5: Verify result
```

## Feedback Loop Pattern

For quality-critical tasks. Validate after each change:

```markdown
## Validation loop

1. Make edits
2. **Validate immediately**: `python scripts/validate.py output/`
3. If validation fails:
   - Review error message
   - Fix issues
   - Run validation again
4. **Only proceed when validation passes**
```

## Conditional Workflow Pattern

Branch based on input type:

```markdown
## Determine workflow

First, identify the task type:
- **Creating new?** → Follow [Creation Workflow](#creation)
- **Editing existing?** → Follow [Editing Workflow](#editing)
- **Migrating?** → Follow [Migration Workflow](#migration)
```

## Template Pattern

Enforce consistent structure:

```markdown
## Output structure

ALWAYS use this template:

# [Title]

## Summary
[One paragraph]

## Details
[Bulleted findings]

## Next Steps
[Numbered actions]
```

## Scripts Pattern

When deterministic execution needed:

```markdown
## Available scripts

Execute (don't read):
- `scripts/validate.py <input>` - Check input format
- `scripts/generate.py <input> <output>` - Generate output
- `scripts/verify.py <output>` - Verify result

Flags:
- `--verbose` - Show detailed output
- `--dry-run` - Preview without changes
```

## Progressive Reference Pattern

For multi-domain skills with large reference sets:

```markdown
## Domain references

- **Finance**: Revenue, ARR metrics → See [references/finance.md]
- **Sales**: Pipeline, accounts → See [references/sales.md]
- **Product**: Usage, features → See [references/product.md]

## Quick search

For large files:
```bash
grep -i "metric_name" references/finance.md
```
```
