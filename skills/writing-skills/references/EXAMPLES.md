# Skill Examples

## Description Examples

### Good Descriptions

```yaml
description: >-
  Extract text and tables from PDF files, fill forms, merge documents.
  Use when working with PDFs, forms, or document extraction.
```
- Specific actions (extract, fill, merge)
- Trigger phrases (PDFs, forms, document extraction)

```yaml
description: >-
  Generate descriptive commit messages by analyzing git diffs.
  Use when user asks for help writing commits or reviewing staged changes.
```
- Clear capability (generate commit messages)
- Multiple trigger phrases (commits, staged changes)

```yaml
description: >-
  Analyze Excel spreadsheets, create pivot tables, generate charts.
  Use when analyzing spreadsheets, tabular data, or .xlsx files.
```
- Synonyms covered (spreadsheets, tabular data, .xlsx)

### Bad Descriptions

```yaml
description: Helps with documents
```
- Too vague, won't trigger reliably

```yaml
description: Does stuff with files
```
- No specificity, no trigger phrases

```yaml
description: I can help you process data
```
- First person (should be third)
- Vague "process data"

## Naming Examples

### Good Names

- `processing-pdfs` - gerund, specific
- `analyzing-spreadsheets` - gerund, clear domain
- `git-commit-messages` - specific task
- `bigquery-analysis` - tool + action

### Bad Names

- `helper` - vague
- `utils` - generic
- `my-skill` - meaningless
- `documents` - noun only, no action

## Structure Examples

### Simple Skill (flat file ok)

```
skills/
└── rotate-image.md
```

Content:
```yaml
---
name: rotate-image
description: >-
  Rotate images by specified degrees. Use for image rotation tasks.
---

Rotate image using ImageMagick:

```bash
convert input.jpg -rotate 90 output.jpg
```

Options: 90, 180, 270, or any degree value.
```

### Medium Skill (folder with references)

```
skills/pdf-processing/
├── SKILL.md
├── scripts/
│   ├── extract_text.py
│   └── validate.py
└── references/
    └── FORMS.md
```

### Complex Skill (multi-domain)

```
skills/data-analysis/
├── SKILL.md
├── scripts/
│   └── query_runner.py
└── references/
    ├── finance.md
    ├── sales.md
    ├── product.md
    └── marketing.md
```

## Conciseness Examples

### Bad: Over-explained

```markdown
## What is a PDF?

PDF stands for Portable Document Format. It was created by Adobe
in 1993 and is widely used for document sharing because it preserves
formatting across different systems...

## How to extract text

To extract text from a PDF file, you will need to use a library
that can parse the PDF format. There are several options available
in Python, including pypdf, pdfplumber, and PyMuPDF. Each has its
own strengths and weaknesses...
```

150+ tokens explaining what Claude already knows.

### Good: Direct

```markdown
## Text extraction

Use pdfplumber (best for tables) or PyMuPDF (fastest):

```python
import pdfplumber
with pdfplumber.open("doc.pdf") as pdf:
    text = "\n".join(p.extract_text() for p in pdf.pages)
```

For scanned PDFs: `pdf2image` + `pytesseract`
```

~50 tokens, actionable immediately.

## Freedom Level Examples

### High Freedom (guidelines)

```markdown
## Code review guidelines

Look for:
- Logic errors and edge cases
- Performance concerns
- Security issues
- Maintainability

Provide constructive feedback with specific suggestions.
```

Many valid approaches, let Claude decide.

### Low Freedom (exact commands)

```markdown
## Database migration

ALWAYS run exactly:

```bash
alembic upgrade head --sql > migration.sql
# Review migration.sql manually
alembic upgrade head
```

NEVER use `--autogenerate` in production.
```

Fragile operation, exact steps required.
