---
name: reading-pdfs
description: >-
  Extract text from PDF files with automatic fallback to OCR for scanned documents.
  Use when reading PDFs, extracting PDF text, or working with scanned documents.
---

## Quick Start

```bash
python {baseDir}/scripts/extract_pdf.py input.pdf          # to stdout
python {baseDir}/scripts/extract_pdf.py input.pdf out.txt  # to file
```

Script auto-detects:
1. **Native PDF** → uses `pdftotext` (fast)
2. **Scanned/garbage output** → falls back to OCR

## Decision Tree

```
PDF Input
    │
    ├─► pdftotext extraction
    │       │
    │       ├─► Good text? ──► Done
    │       │
    │       └─► Empty/garbage? ──► OCR fallback
    │                                   │
    │                                   ├─► tesseract installed? ──► OCR extract
    │                                   │
    │                                   └─► Missing deps? ──► Report what to install
```

## Dependencies

**Required**: `poppler-utils` (provides `pdftotext`, `pdftoppm`)

**Optional** (for scanned PDFs): `tesseract-ocr`

```bash
# Ubuntu/Debian
sudo apt install poppler-utils tesseract-ocr

# macOS
brew install poppler tesseract
```

## Manual Extraction

When script unavailable:

```bash
# Native PDF
pdftotext input.pdf -              # stdout
pdftotext -layout input.pdf out.txt  # preserve layout

# Check if scanned (empty output = likely scanned)
pdftotext input.pdf - | head -20
```

## Output Modes

| Flag | Effect |
|------|--------|
| `-` or omit | stdout |
| `out.txt` | write to file |

## Troubleshooting

**Empty output from native PDF**: Try `-layout` flag, some PDFs have weird text ordering.

**OCR accuracy issues**: Scanned at low DPI or poor quality. Script uses 300 DPI conversion.

**Timeout on large PDFs**: OCR is slow (~30-60s per 10 pages). For large docs, extract specific pages first.
