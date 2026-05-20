#!/bin/bash

# Pre-commit hook to enforce file modification whitelist
# This runs BEFORE git commit completes, blocking commits with unauthorized files
# SECURITY PRINCIPLE: Whitelist-only approach - only explicitly allowed files can be modified

# Define allowed documentation paths (WHITELIST)
# Based on analysis of 100+ actual agent PRs
# Everything NOT in this list is automatically FORBIDDEN
ALLOWED_PATTERNS=(
    "^en/docs/.*\.md$"                                      # Markdown documentation files
    "^en/mkdocs\.yml$"                                      # Navigation config (only when adding new pages)
    "^en/docs/assets/img/.*\.(png|jpg|jpeg|gif|webp)$"      # Safe image formats (NO SVG - can contain JS)
)

# Get list of files staged for commit
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo "Pre-commit validation: Checking staged files against whitelist..."

# Check if all changes are within allowed patterns (whitelist enforcement)
INVALID_FOUND=false

for file in $STAGED_FILES; do
    ALLOWED=false

    for pattern in "${ALLOWED_PATTERNS[@]}"; do
        if echo "$file" | grep -qE "$pattern"; then
            ALLOWED=true
            break
        fi
    done

    if [ "$ALLOWED" = false ]; then
        echo "❌ COMMIT BLOCKED: File outside allowed paths: $file"
        INVALID_FOUND=true
    fi
done

if [ "$INVALID_FOUND" = true ]; then
    echo ""
    echo "========================================"
    echo "COMMIT REJECTED - WHITELIST VIOLATION"
    echo "========================================"
    echo "You attempted to commit files that are NOT on the whitelist."
    echo ""
    echo "ONLY these file patterns are allowed:"
    for pattern in "${ALLOWED_PATTERNS[@]}"; do
        echo "  - $pattern"
    done
    echo ""
    echo "Examples of FORBIDDEN files (not exhaustive):"
    echo "  - .github/workflows/* (workflow files)"
    echo "  - en/requirements.txt (dependencies)"
    echo "  - en/hooks.py (executable Python code)"
    echo "  - *.svg files (can contain JavaScript)"
    echo "  - Any configuration files not explicitly allowed above"
    echo ""
    echo "Please unstage unauthorized files before committing."
    exit 1
fi

# Check for secrets in staged changes
echo ""
echo "Scanning for secrets in staged changes..."
SECRETS_FOUND=false

# Get the diff of staged changes
STAGED_DIFF=$(git diff --cached)

# Check for common secret patterns
if echo "$STAGED_DIFF" | grep -qiE '(GITHUB_TOKEN|ANTHROPIC|API_KEY|SECRET|PASSWORD|BEARER|ghp_|sk-|xox[baprs]-[a-zA-Z0-9-]+)'; then
    echo "❌ COMMIT BLOCKED: Potential secrets detected in staged changes"
    echo ""
    echo "Detected patterns that may contain secrets:"
    echo "$STAGED_DIFF" | grep -iE '(GITHUB_TOKEN|ANTHROPIC|API_KEY|SECRET|PASSWORD|BEARER|ghp_|sk-|xox[baprs]-[a-zA-Z0-9-]+)' || true
    SECRETS_FOUND=true
fi

# Check for variable references that might leak secrets
if echo "$STAGED_DIFF" | grep -qE '\$\{?[A-Z_]+[A-Z0-9_]*\}?'; then
    echo "⚠️  WARNING: Environment variable references detected"
    echo "Please verify these are not exposing secrets:"
    echo "$STAGED_DIFF" | grep -E '\$\{?[A-Z_]+[A-Z0-9_]*\}?' || true
    echo ""
    echo "If these are legitimate documentation variables, you may proceed."
    # Don't fail for variable references in documentation, just warn
fi

if [ "$SECRETS_FOUND" = true ]; then
    echo ""
    echo "========================================"
    echo "COMMIT REJECTED - SECRETS DETECTED"
    echo "========================================"
    echo "Your staged changes contain potential secrets or API keys."
    echo "Please remove sensitive data before committing."
    exit 1
fi

echo "✅ No secrets detected"
echo "✅ Pre-commit validation passed"
exit 0
