# Workshop Setup — Claude Cowork + Higgsfield MCP

**Project owner:** OPEN Interactive Global, LLC
**Scope:** Setup only — get every attendee installed and connected before the workshop starts.
**Out of scope:** Workshop curriculum, prompts, run-of-show. Those live in a separate downstream project.
**Maintained via:** Claude Cowork in this folder.

---

## ⚠ Before this can be distributed: push to GitHub

The setup scripts and installer UI point at `https://github.com/evove-workshops/claude-higgsfield`. Until the repo exists with the scripts and installer UI on `main`, every install command in the attendee comms will fail with a 404.

The fastest path is to run `../push-to-github.sh` from this folder's parent (`Workshop Setup/`) — it handles repo creation (if needed), commit, and push, then verifies the live URLs. Manual equivalent:

1. **Ensure the repo exists.** If `https://github.com/evove-workshops/claude-higgsfield` doesn't already exist, create it (public visibility, default branch `main`). If it does, just clone it locally.
2. **Push** the contents of this project's `scripts/` and `installer-ui/` directories to the repo's `main` branch so the final layout is:
   ```
   claude-higgsfield/
   ├── scripts/
   │   ├── workshop-setup-mac.sh
   │   └── workshop-setup-windows.ps1
   └── installer-ui/
       └── index.html
   ```
3. **Verify** by opening these three URLs in a fresh incognito tab — each should return content, not a 404:
   - `https://github.com/evove-workshops/claude-higgsfield`
   - `https://raw.githubusercontent.com/evove-workshops/claude-higgsfield/main/scripts/workshop-setup-mac.sh`
   - `https://raw.githubusercontent.com/evove-workshops/claude-higgsfield/main/scripts/workshop-setup-windows.ps1`

Only once all three URLs resolve is the kit safe to distribute. Section 8 of the PRD has the complete pre-distribution checklist.

---

## What this folder is

Everything an instructor or comms lead needs to deliver one outcome: when attendees walk in, they already have Claude Desktop installed, the Cowork tab visible, and the Higgsfield MCP server connected.

## Folder map

| Path | What's in it |
|---|---|
| `scripts/` | The macOS `.sh` and Windows `.ps1` setup scripts. Install Claude Desktop and write the Higgsfield MCP entry into Claude's config. |
| `installer-ui/` | The branded HTML installer page attendees see. Copy buttons + 5-step verification checklist. |
| `comms/` | Attendee-facing 48-hour email and day-of reminder. Gia owns these. |
| `instructor/` | Auth station guide and install-flow troubleshooting reference. |
| `_distribution/` | Final packaged outputs. Don't edit by hand — regenerate via Cowork. |
| `PRD-claude-higgsfield-workshop-cowork.md` | Source-of-truth PRD (v2.0). |

## Quick-start for instructors

1. Open Claude Desktop, switch to the **Cowork** tab.
2. Point Cowork at this folder.
3. Issue plain-language instructions — see Section 6 of the PRD for examples.
4. Before each workshop, run the QA checklist in Section 8 of the PRD.
5. Regenerate `_distribution/workshop-attendee-kit.zip` after any script or installer-UI change.

## What the setup actually does

Both scripts (Mac and Windows) install **Claude Desktop**, ensure **Node.js** is present (used by the `mcp-remote` bridge), and write this entry into `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "higgsfield": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.higgsfield.ai/mcp"]
    }
  }
}
```

If an existing config is present, the scripts merge in the Higgsfield entry without destroying other servers and write a `.bak` alongside.

## Repo URL

The public workshop repo (referenced by both scripts and the installer UI for hosting raw script content) is:

```
https://github.com/evove-workshops/claude-higgsfield
```

The repo is dedicated to this workshop's setup assets — scripts and installer UI live at the repo root.

## Contact

Adam Anderson · adam@madebyopen.com · OPEN Interactive Global, LLC
