#!/bin/sh

if git diff --cached | grep -E '\bnocheckin\b' >/dev/null; then
    echo "❌ Commit blocked: forbidden token 'nocheckin' detected."
    exit 1
fi

exit 0
