#!/usr/bin/env bash
# ============================================================
# OPEN Interactive Global, LLC
# Workshop Setup - macOS
# Goal: Install Claude Desktop + connect the Higgsfield MCP server
#       so the attendee arrives ready to work in Cowork.
# Version 1.0  ·  May 2026
# ============================================================
set -euo pipefail

HIGGSFIELD_MCP_URL="https://mcp.higgsfield.ai/mcp"
CLAUDE_DMG_URL="https://claude.ai/download/mac"   # 302s to current .dmg
CONFIG_DIR="$HOME/Library/Application Support/Claude"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

# ----- Banner -----
printf '\n\033[1;34m'
printf '================================================================\n'
printf '  OPEN Interactive Global, LLC\n'
printf '  Workshop Setup  -  macOS\n'
printf '  Installs Claude Desktop + connects Higgsfield MCP\n'
printf '================================================================\n\033[0m\n'

log()  { printf '\033[1;36m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[X]\033[0m %s\n' "$*" >&2; exit 1; }

# ----- 1. Homebrew (so we can install Claude Desktop and Node) -----
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  ok "Homebrew present."
fi

# ----- 2. Claude Desktop -----
# Cowork lives inside the Claude Desktop app. Preferred: brew cask.
# Fallback: direct DMG download + install.
if [[ -d "/Applications/Claude.app" ]]; then
  ok "Claude Desktop already installed."
else
  log "Installing Claude Desktop via Homebrew cask..."
  if brew install --cask claude 2>/dev/null; then
    ok "Claude Desktop installed via brew."
  else
    warn "Brew cask install failed; falling back to direct DMG download."
    TMP_DMG="$(mktemp -t claude).dmg"
    curl -fL "$CLAUDE_DMG_URL" -o "$TMP_DMG"
    log "Mounting DMG..."
    MOUNT_OUT="$(hdiutil attach -nobrowse -readonly "$TMP_DMG")"
    MOUNT_POINT="$(printf '%s' "$MOUNT_OUT" | tail -n1 | awk -F'\t' '{print $3}')"
    if [[ -d "$MOUNT_POINT/Claude.app" ]]; then
      cp -R "$MOUNT_POINT/Claude.app" /Applications/
      ok "Claude.app copied to /Applications."
    else
      warn "Could not find Claude.app in DMG at $MOUNT_POINT."
    fi
    hdiutil detach "$MOUNT_POINT" -quiet || true
    rm -f "$TMP_DMG"
  fi
fi

# Clear Gatekeeper quarantine attribute so the first launch doesn't prompt.
if [[ -d "/Applications/Claude.app" ]]; then
  xattr -dr com.apple.quarantine "/Applications/Claude.app" 2>/dev/null || true
fi

# ----- 3. Node.js (needed by mcp-remote bridge) -----
if ! command -v node >/dev/null 2>&1; then
  log "Installing Node.js via Homebrew..."
  brew install node
else
  ok "Node $(node -v) present."
fi

# ----- 4. Write Higgsfield MCP into Claude Desktop config -----
log "Configuring Higgsfield MCP server in Claude Desktop..."
mkdir -p "$CONFIG_DIR"

# Use python3 to merge safely if a config already exists; create fresh otherwise.
if [[ -f "$CONFIG_FILE" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$CONFIG_FILE" "$HIGGSFIELD_MCP_URL" <<'PY'
import json, sys, os, shutil
path, url = sys.argv[1], sys.argv[2]
shutil.copy(path, path + ".bak")
try:
    with open(path) as f:
        cfg = json.load(f)
except json.JSONDecodeError:
    cfg = {}
if not isinstance(cfg, dict):
    cfg = {}
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["higgsfield"] = {
    "command": "npx",
    "args": ["-y", "mcp-remote", url],
}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print("Merged Higgsfield entry into existing config (backup at %s.bak)." % path)
PY
  else
    warn "python3 unavailable - backing up existing config and writing fresh."
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    cat > "$CONFIG_FILE" <<JSON
{
  "mcpServers": {
    "higgsfield": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "$HIGGSFIELD_MCP_URL"]
    }
  }
}
JSON
  fi
else
  cat > "$CONFIG_FILE" <<JSON
{
  "mcpServers": {
    "higgsfield": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "$HIGGSFIELD_MCP_URL"]
    }
  }
}
JSON
fi
ok "Higgsfield MCP entry written to $CONFIG_FILE"

# ----- 5. Launch Claude Desktop -----
# Note: mcp-remote installs on-demand via npx the first time Higgsfield is invoked
# from inside Cowork. We intentionally don't pre-warm it here, because mcp-remote
# tries to start an OAuth flow whenever it runs (which would pop a blank browser
# tab during setup and confuse the user).
if [[ -d "/Applications/Claude.app" ]]; then
  log "Launching Claude Desktop..."
  open -a "Claude" || warn "Could not auto-launch Claude. Open it from /Applications."
fi

# ----- 6. Done -----
printf '\n\033[1;32m'
printf '================================================================\n'
printf '  Setup complete!\n'
printf '================================================================\n\033[0m'
printf 'In Claude Desktop:\n'
printf '  1. Sign in to your Anthropic account.\n'
printf '  2. Switch to the Cowork tab.\n'
printf '  3. When Higgsfield asks to authenticate, approve it in the browser.\n'
printf '\nIf anything is missing, the auth station at the workshop will help.\n\n'
