# Auth Station — Helper Briefing

**Role:** Get every attendee from "laptop in bag" to "Claude Desktop open, signed in, Cowork tab visible, Higgsfield MCP connected." That's the entire mission of this station. The workshop content is downstream — not your concern.
**Time on station:** 30 minutes before doors → 15 minutes after start
**Owner today:** [AUTH_LEAD_NAME]

---

## The five checkpoints

For each attendee, the goal is to verify these five — in this order. If all five are true, send them to a seat. If anything is missing, work it before the workshop starts.

1. Setup script finished without errors (green "Setup complete!" banner).
2. Claude Desktop launches and stays open.
3. Attendee is signed in with the email on their **Claude Pro** (or Max/Team) account — not a free account.
4. The **Cowork** tab is visible in the Claude Desktop sidebar. *(If it isn't, 9 times out of 10 the account isn't paid — see "Pro plan check" below.)*
5. Open Cowork → Settings → MCP servers. `higgsfield` is listed and shows connected (green) after browser auth.

### Pro plan check (do this first, before anything else)

The single biggest source of door-side problems is attendees who didn't sign up for Claude Pro before arriving. Cowork is gated behind a paid Claude plan.

Before troubleshooting *anything* else, ask:

> "Are you signed in with the email on your paid Claude plan — Pro, Max, or Team?"

- If yes, great — proceed with the normal checkpoints.
- If no or unsure: have them open https://claude.ai → check the plan in their account settings. If they're on free, they need to upgrade at https://claude.ai/upgrade *before* the installer's work is useful. The script will have installed Claude Desktop correctly, but the Cowork tab won't appear until the plan is upgraded.
- If they refuse or can't upgrade today: escalate to Adam. Don't burn 20 minutes trying to make Cowork appear without a Pro plan — it won't.

---

## What the station has

- Printed installer URL + QR code (table-height poster)
- 1 reference laptop with the installer page open full-screen
- Power strip, USB-C/A cables, two USB-C → HDMI adapters
- Printed copy of `troubleshooting.md` — keep it visible
- Index cards + Sharpie for noting attendee name + issue, if you need to bounce them to a floater

---

## The happy path (most attendees)

1. Attendee says "I haven't installed anything."
2. Ask: macOS or Windows?
3. Send them to the installer URL on their phone, or point them at the reference laptop.
4. They open Terminal (Mac) or PowerShell (Windows) and paste the one-line command.
5. The script runs for 3–5 minutes: it installs Claude Desktop and writes the Higgsfield MCP entry into Claude's config file.
6. Claude Desktop opens automatically. Attendee signs in with their Anthropic account.
7. They switch to the **Cowork** tab. The first Higgsfield call opens a browser window for Higgsfield OAuth. They approve. The MCP shows green.
8. Done. Seat them.

Your job is to keep the pipeline flowing — get the next person started while the last person's script is still running.

---

## The unhappy paths to be ready for

Hand them `troubleshooting.md` and stay with them. The five most common, in order:

1. **macOS Gatekeeper blocks Claude.app** — "can't be opened because it is from an unidentified developer." The script clears the quarantine attribute, but if the attendee installed via a different path it may not have run. Fix in System Settings → Privacy & Security → Open Anyway.
2. **Windows SmartScreen blocks the installer** — "Windows protected your PC." Tell them: click "More info" → "Run anyway."
3. **Cowork tab isn't visible** — usually means they're not signed in, or their account doesn't have Cowork enabled. Check the sign-in status; if account-level, escalate to Adam.
4. **Higgsfield doesn't show in Cowork's MCP list** — the config file didn't get written, or Claude Desktop was running when the script wrote it. Fix: fully quit Claude Desktop (⌘Q on Mac, right-click in tray on Windows), then reopen.
5. **Higgsfield OAuth opens but fails** — usually port 8080 is in use locally. Stop whatever else is bound to it; retry the connect from inside Cowork.

If you hit a 6th unique issue, write it on an index card and bring it to Adam at the break — it goes in the troubleshooting guide.

---

## What to escalate to Adam

- Locked-down corporate laptop (no admin, no install rights). Seat them next to a neighbor; we'll send a recap.
- Any flow that fails twice. Don't burn 20 minutes on one person — bounce and seat them.
- Anything that suggests Cowork isn't enabled at the account level — that's an Anthropic-side fix, not a script-side fix.

---

## When you stand down

15 minutes after start. By that point, anyone still stuck can join the room and a floater will work with them 1:1.

Thanks for running this — the workshop's first hour only works because this station does.
