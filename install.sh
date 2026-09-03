#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.config/opencode/agents"
TARGET_FILE="${TARGET_DIR}/advisor.md"
SOURCE_FILE="${SCRIPT_DIR}/agents/advisor.md"

echo "==> Installing OpenCode Advisor Subagent..."

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: Source file $SOURCE_FILE does not exist." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

# Copy or create symlink
cp -f "$SOURCE_FILE" "$TARGET_FILE"

echo "==> Successfully installed advisor subagent to: $TARGET_FILE"
echo "==> You can now invoke the subagent via task tool: subagent_type: 'advisor'"
