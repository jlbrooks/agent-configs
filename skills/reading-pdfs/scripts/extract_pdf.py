#!/usr/bin/env python3
"""
PDF text extraction with automatic fallback.

Decision tree:
1. Try pdftotext (fast, native PDFs)
2. Check output quality
3. Fall back to OCR if scanned/empty

Usage:
    python extract_pdf.py input.pdf [output.txt]
    python extract_pdf.py input.pdf -  # stdout
"""

import subprocess
import sys
import shutil
import re
from pathlib import Path


def check_deps():
    """Check available tools."""
    deps = {
        "pdftotext": shutil.which("pdftotext"),
        "tesseract": shutil.which("tesseract"),
        "pdftoppm": shutil.which("pdftoppm"),  # for pdf2image fallback
    }
    return deps


def is_garbage_text(text: str) -> bool:
    """Detect if extracted text is garbage (wrong encoding, etc)."""
    if not text or len(text.strip()) < 50:
        return True

    # High ratio of non-printable or weird chars
    printable = sum(1 for c in text if c.isprintable() or c.isspace())
    if printable / len(text) < 0.8:
        return True

    # Too few actual words (likely encoding garbage)
    words = re.findall(r'[a-zA-Z]{3,}', text)
    if len(words) < 10:
        return True

    return False


def extract_with_pdftotext(pdf_path: Path, layout: bool = False) -> tuple[str, bool]:
    """Extract text using pdftotext. Returns (text, success)."""
    cmd = ["pdftotext"]
    if layout:
        cmd.append("-layout")
    cmd.extend([str(pdf_path), "-"])

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            return result.stdout, True
        return "", False
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return "", False


def extract_with_ocr(pdf_path: Path) -> tuple[str, bool]:
    """Extract text using OCR (tesseract + pdftoppm)."""
    deps = check_deps()

    if not deps["tesseract"] or not deps["pdftoppm"]:
        missing = []
        if not deps["tesseract"]:
            missing.append("tesseract-ocr")
        if not deps["pdftoppm"]:
            missing.append("poppler-utils")
        return f"[OCR requires: {', '.join(missing)}]", False

    import tempfile
    import os

    with tempfile.TemporaryDirectory() as tmpdir:
        # Convert PDF to images
        try:
            subprocess.run(
                ["pdftoppm", "-png", "-r", "300", str(pdf_path), f"{tmpdir}/page"],
                check=True, capture_output=True, timeout=120
            )
        except subprocess.CalledProcessError as e:
            return f"[pdftoppm failed: {e.stderr.decode()}]", False
        except subprocess.TimeoutExpired:
            return "[pdftoppm timeout]", False

        # OCR each page
        pages = sorted(Path(tmpdir).glob("page-*.png"))
        if not pages:
            return "[No pages extracted]", False

        text_parts = []
        for page in pages:
            try:
                result = subprocess.run(
                    ["tesseract", str(page), "stdout", "-l", "eng"],
                    capture_output=True, text=True, timeout=60
                )
                if result.returncode == 0:
                    text_parts.append(result.stdout)
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue

        if text_parts:
            return "\n\n--- Page Break ---\n\n".join(text_parts), True
        return "[OCR produced no text]", False


def extract_pdf(pdf_path: str, output_path: str | None = None) -> int:
    """Main extraction with decision tree."""
    pdf = Path(pdf_path)

    if not pdf.exists():
        print(f"Error: {pdf_path} not found", file=sys.stderr)
        return 1

    if not pdf.suffix.lower() == ".pdf":
        print(f"Warning: {pdf_path} may not be a PDF", file=sys.stderr)

    deps = check_deps()
    print(f"[Tools: pdftotext={'✓' if deps['pdftotext'] else '✗'}, "
          f"tesseract={'✓' if deps['tesseract'] else '✗'}]", file=sys.stderr)

    # Step 1: Try pdftotext
    if deps["pdftotext"]:
        print("[Trying pdftotext...]", file=sys.stderr)
        text, success = extract_with_pdftotext(pdf)

        if success and not is_garbage_text(text):
            print(f"[Success: pdftotext extracted {len(text)} chars]", file=sys.stderr)
            return output_text(text, output_path)

        if success:
            print("[pdftotext output looks like garbage/empty, trying OCR...]", file=sys.stderr)
        else:
            print("[pdftotext failed, trying OCR...]", file=sys.stderr)

    # Step 2: Fall back to OCR
    print("[Trying OCR (this may take a while)...]", file=sys.stderr)
    text, success = extract_with_ocr(pdf)

    if success:
        print(f"[Success: OCR extracted {len(text)} chars]", file=sys.stderr)
        return output_text(text, output_path)

    print(f"[Failed: {text}]", file=sys.stderr)
    return 1


def output_text(text: str, output_path: str | None) -> int:
    """Write text to file or stdout."""
    if output_path is None or output_path == "-":
        print(text)
    else:
        Path(output_path).write_text(text)
        print(f"[Written to {output_path}]", file=sys.stderr)
    return 0


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("\nInstalled tools:")
        for tool, path in check_deps().items():
            status = f"✓ {path}" if path else "✗ not found"
            print(f"  {tool}: {status}")
        return 1

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    return extract_pdf(pdf_path, output_path)


if __name__ == "__main__":
    sys.exit(main())
