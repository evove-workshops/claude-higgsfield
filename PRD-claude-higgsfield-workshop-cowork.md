# Product Requirements Document
## Workshop Environment Setup — Claude Cowork + Higgsfield MCP
### Project Owner: OPEN Interactive Global, LLC
### Version: 2.0 · May 2026

---

## 1. Overview

This PRD defines the **setup-only** scope for the workshop environment used by OPEN Interactive Global's upcoming hands-on session. The single objective of this project is to ensure every attendee arrives with **Claude Desktop installed, the Cowork tab visible and signed in, and the Higgsfield MCP server connected.**

The workshop content (curriculum, prompts, run-of-show, exercises) is **out of scope** for this PRD and is tracked as a separate, downstream project.

Cowork is used as the project execution layer — a non-code agentic workspace where Claude reads, writes, and organizes files in a designated folder on the instructor's desktop.

---

## 2. Background

OPEN Interactive is producing a workshop where every minute of room time depends on attendees having a working environment before they sit down. The session uses **Claude Cowork** (a feature of the Claude Desktop app) together with the **Higgsfield MCP** server for AI-powered video and image generation.

In past workshops, environment problems consumed the first hour. This setup project exists to compress that to zero — by giving attendees a one-line installer that does the entire setup non-interactively, plus a fallback auth station at the door for anyone who couldn't run it ahead of time.

---

## 3. Goals

Each goal below is scoped to setup only.

- Every attendee arrives with **Claude Desktop installed and launchable** on macOS or Windows.
- The **Cowork tab is visible** in Claude Desktop after they sign in to their Anthropic account.
- The **Higgsfield MCP server entry** is written into Claude Desktop's config so the server appears in Cowork's MCP list without manual JSON editing.
- The first Higgsfield OAuth completes successfully (the attendee approves it in a browser).
- The whole setup is reachable from a single branded installer page so non-technical attendees can complete it without a terminal.
- Non-developer team members (Gia, Comms Director) can update attendee-facing copy through plain-language Cowork instructions.

**Explicit non-goals (handled by the curriculum project, not this one):**
- Workshop curriculum, lessons, or example prompts.
- A workshop GitHub repo with starter code.
- A `CLAUDE.md` context document for attendees.
- Instructor run-of-show or minute-by-minute timing.

---

## 4. Cowork Setup

### 4.1 Designated Folder

```
~/OPEN-Interactive/Workshops/claude-higgsfield-workshop/
```

This is the folder granted to Cowork with read/write/create permissions. All setup-project files live here. Cowork must not operate outside this folder without explicit instruction.

### 4.2 Cowork Access Requirements

| Permission | Required | Notes |
|---|---|---|
| Read files | Yes | Read all files in designated folder |
| Write / edit files | Yes | Update copy, scripts, and config |
| Create files | Yes | Generate new assets on instruction |
| Browser (Chrome connector) | Optional | For QR code generation or GitHub push |
| Slack connector | Optional | For team notifications when assets are ready |

### 4.3 How to Activate Cowork

1. Open the **Claude Desktop app**.
2. Switch to the **Cowork** tab.
3. Designate the folder above as the working folder.
4. Confirm folder permissions.
5. All subsequent tasks in this PRD are issued as plain-language instructions in the Cowork chat interface.

---

## 5. Project Folder Structure

```
claude-higgsfield-workshop/
│
├── README.md                        # Project overview for instructors
│
├── _distribution/                   # Final packaged outputs for attendees
│   ├── workshop-setup-mac.sh
│   ├── workshop-setup-windows.ps1
│   ├── installer-ui.html
│   └── workshop-attendee-kit.zip
│
├── scripts/
│   ├── workshop-setup-mac.sh        # Installs Claude Desktop + writes MCP config (macOS)
│   └── workshop-setup-windows.ps1   # Installs Claude Desktop + writes MCP config (Windows)
│
├── installer-ui/
│   └── index.html                   # Branded attendee installer page
│
├── comms/
│   ├── pre-workshop-email.md        # 48-hour advance email (setup instructions only)
│   └── day-of-reminder.md           # Morning-of reminder
│
├── instructor/
│   ├── auth-station-guide.md        # 1-page helper brief for the door
│   └── troubleshooting.md           # Install-flow issues by OS
│
└── PRD-claude-higgsfield-workshop-cowork.md   # This document
```

> **What's deliberately absent:** there is no `workshop-repo/`, no `CLAUDE.md`, no starter project, no run-of-show. Those belong to the separate curriculum project.

---

## 6. Deliverables

### 6.1 Setup Scripts (Priority: High)

| File | What it does |
|---|---|
| `scripts/workshop-setup-mac.sh` | Installs Homebrew if missing → installs Claude Desktop (via brew cask, falls back to DMG) → ensures Node.js (for the `mcp-remote` bridge) → writes the Higgsfield MCP entry into `~/Library/Application Support/Claude/claude_desktop_config.json` (merges if config already exists, with `.bak`) → clears Gatekeeper quarantine on Claude.app → pre-warms `npx mcp-remote` → launches Claude Desktop. |
| `scripts/workshop-setup-windows.ps1` | Installs Node.js (winget, or direct MSI fallback) → installs Claude Desktop (winget Anthropic.Claude, or direct EXE fallback) → writes the Higgsfield MCP entry into `%APPDATA%\Claude\claude_desktop_config.json` using `ConvertFrom-Json`/`ConvertTo-Json` (merges with `.bak`) → pre-warms `npx mcp-remote` → launches Claude Desktop. |

The Higgsfield MCP entry written by both scripts is:

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

`mcp-remote` is the standard bridge for connecting remote HTTP MCP servers to Claude Desktop; Node.js is required only as the host for that bridge.

**Cowork instruction example:**
> "In both setup scripts, update the Higgsfield MCP URL from `https://mcp.higgsfield.ai/mcp` to `[NEW_URL]`. Save the files."

---

### 6.2 Installer UI (Priority: High)

| File | What it is |
|---|---|
| `installer-ui/index.html` | A branded HTML page attendees open in a browser. Shows the macOS/Windows install commands with copy buttons, plus a 5-step verification checklist (script done → Desktop open → signed in → Cowork tab visible → Higgsfield shows in MCP list). When all five are checked, an "all set" card appears. |

Brand colors are baked in: Deep Navy `#0D2B6B`, Royal Blue `#1A4FB5`, Signal Orange `#E87722`.

**Cowork instruction example:**
> "In `installer-ui/index.html`, change the headline subtitle to 'One command. Three minutes. You're done.' Save the file."

---

### 6.3 Attendee Comms (Priority: Medium)

| File | Purpose | Owner |
|---|---|---|
| `comms/pre-workshop-email.md` | 48-hour advance email. Sole goal: get attendees to create the two accounts and run the installer. | Gia |
| `comms/day-of-reminder.md` | Morning-of reminder with the installer link for anyone who skipped. | Gia |

Both files have `[BRACKET]` placeholders so Gia can fill in date, venue, and times via plain-language Cowork instructions.

**Cowork instruction example (for Gia):**
> "In `comms/pre-workshop-email.md`, update [DATE] to June 3 and [VENUE] to Pillar Hall."

---

### 6.4 Instructor Documentation (Priority: Medium)

| File | Contents |
|---|---|
| `instructor/auth-station-guide.md` | 1-page brief for the helper running the door auth station. Defines the five verification checkpoints and the unhappy-path triage. |
| `instructor/troubleshooting.md` | Install-flow issues by OS: Mac Gatekeeper, Windows SmartScreen, missing Cowork tab, MCP not appearing in Cowork settings, Higgsfield OAuth port 8080 conflict. |

**Cowork instruction example:**
> "In `instructor/troubleshooting.md`, add a new entry for 'Claude Desktop crashes on launch after install'. Symptom, Cause, Fix format like the others."

---

### 6.5 Distribution Package (Priority: High, final step)

Once all files are finalized:

**Cowork instruction:**
> "Copy `scripts/workshop-setup-mac.sh`, `scripts/workshop-setup-windows.ps1`, and `installer-ui/index.html` into `_distribution/`, then create `workshop-attendee-kit.zip` containing all three. Save to `_distribution/`."

---

## 7. Task Sequence

> **Prerequisites — must be done before any of these files are usable:** the setup scripts and installer UI fetch from `https://github.com/evove-workshops/claude-higgsfield` directly (no subfolder — the repo is dedicated to this workshop's setup). Until that repo exists with the scripts pushed to `main`, every attendee command will 404. Tasks P1–P3 below cover this. The `push-to-github.sh` helper in the project root automates P1–P3 in one run.

| # | Task | File(s) | Owner |
|---|---|---|---|
| P1 | **Confirm `evove-workshops/claude-higgsfield` repo exists** (or create it — public visibility, default branch `main`) | n/a | Adam |
| P2 | **Push** `scripts/` and `installer-ui/` to the repo root on `main` | scripts/, installer-ui/ | Adam |
| P3 | **Verify the raw URLs resolve** (the push-to-github.sh helper does this automatically) | n/a | Adam |
| 1 | Create folder structure per Section 5 | All directories | Adam |
| 2 | Create `scripts/workshop-setup-mac.sh` | macOS script | Adam |
| 3 | Create `scripts/workshop-setup-windows.ps1` | Windows script | Adam |
| 4 | Create `installer-ui/index.html` | Installer page | Adam |
| 5 | Create `comms/pre-workshop-email.md` | Pre-workshop email | Gia |
| 6 | Create `comms/day-of-reminder.md` | Day-of reminder | Gia |
| 7 | Create `instructor/auth-station-guide.md` | Auth station brief | Adam |
| 8 | Create `instructor/troubleshooting.md` | Troubleshooting | Adam |
| 9 | **Verify P1–P3 are done** — open `https://github.com/evove-workshops/claude-higgsfield` in a browser and confirm both scripts and the installer UI are visible at the repo root | n/a | Adam |
| 10 | QA: verify both scripts run end-to-end on clean Mac and Windows VMs (will only work once P1–P3 are done) | Both scripts | Adam |
| 11 | QA: verify installer UI brand colors and URLs | Installer | Adam |
| 12 | Package `_distribution/` and create `workshop-attendee-kit.zip` | _distribution/ | Adam |

---

## 8. QA Checklist

Before any file is distributed, Cowork runs the following on instruction.

**GitHub hosting (do this first — everything else depends on it)**
- [ ] `evove-workshops/claude-higgsfield` repo exists, public visibility
- [ ] Both setup scripts and the installer UI are pushed to the repo root on `main`
- [ ] Visiting `https://github.com/evove-workshops/claude-higgsfield` returns the repo (not 404)
- [ ] Visiting `https://raw.githubusercontent.com/evove-workshops/claude-higgsfield/main/scripts/workshop-setup-mac.sh` returns the script source (not 404)
- [ ] Same for the Windows script
- [ ] (`push-to-github.sh` in the project root runs all four of the above as one step)

**Scripts (Mac and Windows)**
- [ ] Higgsfield MCP URL is correct and consistent in both scripts
- [ ] No `PLACEHOLDER` text remains
- [ ] Tested on at least one clean OS install per platform
- [ ] On a machine with no existing Claude config, the script creates `claude_desktop_config.json` cleanly
- [ ] On a machine with an existing Claude config, the script merges the Higgsfield entry without destroying other servers (and writes a `.bak`)
- [ ] After running, the Cowork → MCP list shows `higgsfield` (post Claude restart)
- [ ] Banner displays OPEN Interactive branding

**Installer UI**
- [ ] Both OS command blocks point at the final raw.githubusercontent URLs
- [ ] Brand colors match: Deep Navy `#0D2B6B`, Royal Blue `#1A4FB5`, Signal Orange `#E87722`
- [ ] Copy buttons work (clipboard API)
- [ ] "All done" card appears after all five steps are ticked

**Comms**
- [ ] Date, time, venue current in both files
- [ ] Installer URL correct
- [ ] Signup links for Anthropic + Higgsfield included
- [ ] No references to workshop curriculum (which is out of scope here)

---

## 9. Ongoing Maintenance via Cowork

After this workshop, the same files serve future workshops. Recurring tasks:

**New workshop date:**
> "Update the date and venue in `comms/pre-workshop-email.md` and `comms/day-of-reminder.md`."

**Updating the Higgsfield MCP URL:**
> "In both setup scripts, replace `https://mcp.higgsfield.ai/mcp` with `[NEW_URL]`."

**New troubleshooting entry:**
> "In `instructor/troubleshooting.md`, add a section for [SYMPTOM]. Use the Symptom/Cause/Fix format from the existing entries."

---

## 10. Key References

| Resource | URL |
|---|---|
| Claude Cowork product page | https://claude.com/product/cowork |
| Claude Desktop download | https://claude.ai/download |
| Higgsfield MCP | https://mcp.higgsfield.ai/mcp |
| mcp-remote (npm) | https://www.npmjs.com/package/mcp-remote |
| Workshop GitHub repo (host scripts) | https://github.com/evove-workshops/claude-higgsfield |
| OPEN Interactive | https://inspiredbyopen.com |

---

## 11. Document Control

| Version | Date | Author | Notes |
|---|---|---|---|
| 1.0 | May 2026 | Adam Anderson | Initial PRD — overscoped, included workshop curriculum |
| 2.0 | May 2026 | Adam Anderson | Rewrite: scope narrowed to setup-only. Curriculum (CLAUDE.md, run-of-show, starter project, sample prompts) moved out to a separate downstream project. Scripts switched from installing Claude Code CLI to installing Claude Desktop + writing the Higgsfield MCP entry into `claude_desktop_config.json` via the `mcp-remote` bridge. |

*Prepared by OPEN Interactive Global, LLC · adam@madebyopen.com*
