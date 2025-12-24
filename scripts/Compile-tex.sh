#!/bin/bash
for f in updates/*.tex; do
    pdflatex "$f"
done
echo "✅ All updates compiled to PDF."
