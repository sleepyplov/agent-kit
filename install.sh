#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# CONFIGURATION — Override via env vars if needed
# =============================================================================
: "${AGENT_KIT_REPO_URL:=https://github.com/sleepyplov/agent-kit.git}"
: "${AGENT_KIT_BRANCH:=main}"
: "${TARGET_SRC:=$HOME/.local/src/agent-kit}"
: "${TARGET_BIN:=$HOME/.local/bin}"
# =============================================================================

echo "🚀 Installing agent-kit from $AGENT_KIT_REPO_URL ($AGENT_KIT_BRANCH)..."

mkdir -p "$(dirname "$TARGET_SRC")" "$TARGET_BIN"

# =============================================================================
# STEP 1: Clone or Update Repository
# =============================================================================
if [[ -d "$TARGET_SRC/.git" ]]; then
    echo "📦 Updating existing installation..."
    cd "$TARGET_SRC"
    git pull --ff-only origin "$AGENT_KIT_BRANCH" --quiet
    echo "✅ Updated"
else
    echo "📦 Cloning repository..."
    git clone --branch "$AGENT_KIT_BRANCH" --depth 1 "$AGENT_KIT_REPO_URL" "$TARGET_SRC" --quiet
    echo "✅ Cloned to $TARGET_SRC"
fi

# =============================================================================
# STEP 2: Symlink Executables (Strip Extensions)
# =============================================================================
BIN_SRC="$TARGET_SRC/bin"
if [[ ! -d "$BIN_SRC" ]]; then
    echo "⚠️  bin/ directory not found. Skipping executable symlinks."
else
    echo "🔗 Creating symlinks in $TARGET_BIN..."
    for file in "$BIN_SRC"/*; do
        [[ -f "$file" ]] || continue
        [[ "$(basename "$file")" == .* ]] && continue

        filename="$(basename "$file")"
        link_name="${filename%.*}"
        [[ -z "$link_name" || "$link_name" == "$filename" ]] && link_name="$filename"
        target_link="$TARGET_BIN/$link_name"

        # Never overwrite real files/dirs
        if [[ -e "$target_link" && ! -L "$target_link" ]]; then
            echo "  ⚠️  Skipping $link_name: regular file/dir exists in $TARGET_BIN"
            continue
        fi

        ln -sf "$file" "$target_link"
        echo "  ✅ $link_name -> $filename"
    done
fi

# =============================================================================
# STEP 3: Manual Symlinks (Optional)
# =============================================================================
# MANUAL_LINKS=(
#   "$TARGET_SRC/docs/agent-core.md:$HOME/.config/agent-kit/core.md"
# )
# for entry in "${MANUAL_LINKS[@]:-}"; do
#   [[ -z "$entry" ]] && continue
#   src="${entry%%:*}"; dst="${entry##*:}"
#   mkdir -p "$(dirname "$dst")"
#   ln -sf "$src" "$dst"
#   echo "  ✅ $(basename "$dst") -> $(basename "$src")"
# done

# =============================================================================
# STEP 4: Post-Install
# =============================================================================
echo ""
echo "🎉 Installation complete!"

if [[ ":$PATH:" != *":$TARGET_BIN:"* ]]; then
    echo "💡 $TARGET_BIN is not in your PATH."
    echo "   Add to ~/.zshrc or ~/.bashrc:"
    echo "   export PATH=\"$TARGET_BIN:\$PATH\""
else
    echo "✅ $TARGET_BIN is already in your PATH."
fi

echo ""
echo "🔄 To update later: cd $TARGET_SRC && git pull && ./install.sh"
