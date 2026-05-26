#!/usr/bin/env bash

# Setups a worktree with staged changes from a source branch onto a target branch.

set -eo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source-branch> <target-branch>"
  exit 1
fi

SOURCE="$1"
TARGET="$2"
REVIEW_ROOT=$(mktemp -d -t git-review-$SOURCE-$TARGET)

echo "📥 Fetching branches..."
git fetch origin "$SOURCE" "$TARGET" >/dev/null 2>&1

echo "🌳 Creating worktree..."
# review-$SOURCE naming to look better in file explorers in IDEs
WORKTREE_DIR="$REVIEW_ROOT/review-$SOURCE"
git worktree add "$WORKTREE_DIR" "origin/$TARGET"

echo "📦 Staging changes from '$SOURCE' onto '$TARGET' (3-way merge, no commit)..."

# This computes: merge-base(target, source) + target's unique changes + source's unique changes
# Only the delta from 'source' is staged on top of the current 'target' state.
if ! git merge --no-commit --no-ff "origin/$SOURCE" 2>&1; then
    # Check if the merge was just "already up to date"
    if git diff --staged --quiet && git diff --quiet; then
        echo "ℹ️  '$SOURCE' is already fully merged into '$TARGET'. No changes staged."
        exit 0
    fi
    # If conflicts exist, they are staged and marked. We still exit 0 for review.
    echo "⚠️  Conflicts detected during merge. They are staged for review."
    echo "    Resolve them in your editor, then stage/unstage as needed."
fi

echo ""
echo "✅ Success! Changes from '$SOURCE' are now staged on '$TARGET'."
echo "   Review in your IDE or run: git diff --staged"
echo ""
echo "🔄 To cleanly revert to the original '$TARGET' state:"
echo "   git merge --abort"
echo ""
echo "💡 To keep staged changes but drop merge metadata (optional):"
echo "   git commit --allow-empty -m 'temp-staged-review' && git reset HEAD~"

echo "✅ Workspace ready: $WORKTREE_DIR"
