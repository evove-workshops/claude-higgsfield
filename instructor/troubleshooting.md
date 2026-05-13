# Troubleshooting Guide

Install-flow problems that come up when getting attendees to **Claude Desktop installed + Cowork visible + Higgsfield MCP connected**. Match the symptom, follow the fix.

> Format for each entry: **Symptom** (what they see) · **Cause** (why) · **Fix** (do this).

---

## 1. macOS — "Claude.app can't be opened because it is from an unidentified developer"

**Symptom**
After the script copies Claude.app into /Applications, double-clicking it triggers a Gatekeeper dialog refusing to launch.

**Cause**
The setup script attempts to clear the quarantine attribute (`xattr -dr com.apple.quarantine`), but this can fail if the app was installed before the script ran, or if the attendee dragged the DMG manually.

**Fix**
1. Open System Settings → Privacy & Security.
2. Scroll to the Security section. There's a line saying "Claude.app was blocked." Click **Open Anyway**.
3. Confirm with Touch ID or password.
4. Claude Desktop launches.

Alternative (terminal): `sudo xattr -dr com.apple.quarantine /Applications/Claude.app` then double-click again.

---

## 2. Windows — "Windows protected your PC" SmartScreen dialog

**Symptom**
When the script (or the attendee manually) runs the Claude Desktop installer EXE, SmartScreen blocks it with "Windows protected your PC. Microsoft Defender SmartScreen prevented an unrecognized app from starting."

**Cause**
The installer isn't signed by a publisher SmartScreen recognizes yet, or the file was flagged as low-reputation.

**Fix**
1. In the SmartScreen dialog, click **More info**.
2. Click the new **Run anyway** button that appears.
3. Installer proceeds normally.

If the attendee's organization disables "Run anyway" entirely, they likely can't install this on their work machine — escalate to Adam and seat them next to a neighbor.

---

## 3. Cowork tab is missing from the Claude Desktop sidebar

**Symptom**
Claude Desktop is installed and the attendee is signed in, but they only see a Chat tab. No Cowork.

**Cause** (in order of likelihood — the first one is by far the most common)
1. **They don't have a paid Claude plan.** Cowork is gated to Pro, Max, and Team plans. Free accounts will not see the Cowork tab, full stop. The pre-workshop email asks attendees to upgrade before arriving, but a fraction always skip this.
2. They're signed in with a different email than the one on their paid plan (e.g., personal vs. work account).
3. They aren't actually signed in — closed the sign-in tab mid-flow.
4. Out-of-date Claude Desktop build that predates Cowork.

**Fix**
1. **Pro check first.** Have the attendee open https://claude.ai → profile menu → Plan. Confirm they're on **Pro, Max, or Team**. If not, they need to upgrade at https://claude.ai/upgrade before anything else will help.
2. **Account match.** Confirm the email shown in Claude Desktop (top-right profile) is the same email that's on the paid plan. If they signed in with a different email, sign out and sign back in with the right one.
3. **Restart the app.** Quit Claude Desktop fully (⌘Q on Mac, right-click in system tray → Quit on Windows), then reopen. Plan changes sometimes need a restart to propagate.
4. **Check the build.** Help → About Claude. If older than the current release, reinstall from https://claude.ai/download.
5. If all four pass and Cowork still doesn't appear, escalate to Adam — could be an account-level access flag.

---

## 4. Higgsfield MCP doesn't appear in Cowork's MCP settings

**Symptom**
Attendee opens Cowork → Settings → MCP servers. They expected `higgsfield` to be listed. It isn't.

**Cause**
The setup script writes the entry into `claude_desktop_config.json`, but Claude Desktop only reads that file at launch. If Claude Desktop was already running when the script ran, the new entry wasn't loaded.

**Fix**
1. Verify the config file actually contains the entry:
   - macOS: `cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json"`
   - Windows (PowerShell): `Get-Content "$env:APPDATA\Claude\claude_desktop_config.json"`
   You should see a `higgsfield` entry under `mcpServers`.
2. **Fully quit** Claude Desktop. On Mac: ⌘Q (closing the window isn't enough). On Windows: right-click the system tray icon → Quit.
3. Reopen Claude Desktop. The Higgsfield server should now appear in the MCP list.

If the config file is missing the entry entirely, the script didn't complete successfully — re-run the setup script and watch for errors.

---

## 5. Higgsfield OAuth opens a browser tab that won't connect (port 8080 in use)

**Symptom**
Attendee triggers Higgsfield for the first time inside Cowork. A browser tab opens to `http://localhost:8080/...` and shows "This site can't be reached" / connection refused / "port already in use."

**Cause**
The MCP OAuth callback listens on a local port (commonly 8080). Another process — a local dev server, Jenkins, Tomcat — is already bound to that port. Or a corporate security tool is blocking loopback callbacks.

**Fix**
1. Find what's holding the port:
   - Mac: `lsof -i :8080`
   - Windows: `netstat -ano | findstr :8080`
2. Stop that process (usually a dev server the attendee forgot was running).
3. In Cowork, retry the action that triggered Higgsfield — the OAuth flow will reattempt.
4. If a corporate security tool is intercepting localhost (you'll know — the request never reaches the loopback), have the attendee join from a personal hotspot, or seat them next to a neighbor.

---

## Quick triage cheatsheet

| Symptom | Most likely cause | First thing to try |
|---|---|---|
| Script fails mid-run | Network or admin prompt | Re-run in a fresh terminal |
| App won't open on Mac | Gatekeeper | System Settings → Privacy → Open Anyway |
| App won't open on Windows | SmartScreen | More info → Run anyway |
| No Cowork tab | Account is on free plan (most common) | Check plan at claude.ai → upgrade to Pro |
| No Higgsfield in MCP list | Claude wasn't fully quit when config wrote | ⌘Q / Quit, reopen |
| Higgsfield OAuth fails | Port 8080 busy | Stop the local dev server |

---

## Last-resort options (use sparingly)

- **Shadow a neighbor.** The workshop survives even if their machine doesn't.
- **Use the instructor demo machine.** If a single attendee's situation is unfixable in <10 minutes, seat them near the auth station with notes.
- **Promise follow-up.** Take their email. We'll fix it offline.
