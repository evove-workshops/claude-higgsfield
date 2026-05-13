# Pre-Workshop Email — 48 Hours Out

**Send:** ~48 hours before workshop start
**From:** Gia Anderson · OPEN Interactive
**Subject:** Before our workshop on [DATE] — please set up Claude Pro first
**Audience:** All confirmed registrants

> Editing note for Gia: anything in `[BRACKETS]` is a fill-in. Everything else is final copy. This email is **only about getting attendees installed and connected** — the workshop content will be sent separately.

---

Hi [FIRST_NAME],

You're registered for our workshop on **[DATE] at [VENUE]** — doors at **[DOORS_TIME]**, start at **[START_TIME]**.

There's one thing to do before you arrive that's important, and we want to flag it clearly so there are no surprises at the door:

## Step 1 — Get your two accounts in place (do this first)

The workshop uses **Cowork**, which is part of the Claude Desktop app. Cowork currently requires a **paid Claude plan** — most attendees use **Claude Pro**. If you don't have a paid plan when you arrive, the Cowork tab simply won't appear, and our installer can't fix that.

Please set up both of the following before you run the installer:

- **Claude Pro** (required for Cowork) — sign up at **https://claude.ai/upgrade**
  Max and Team plans also include Cowork access if you already have one of those.
- **Higgsfield** (free account) — sign up at **https://higgsfield.ai**

If a paid Claude plan isn't an option for you, please reply to this email — we may be able to pair you with a neighbor or arrange another solution. Don't wait until the morning of.

## Step 2 — Run the installer

Once both accounts exist, run the installer. It downloads the Claude Desktop app and wires up the Higgsfield MCP server inside Cowork. About 3–5 minutes on most networks.

**Easiest route:** open the installer page → **[INSTALLER_URL]**

**Direct command** (if you prefer the terminal):

- macOS:
  ```
  curl -fsSL https://raw.githubusercontent.com/evove-workshops/claude-higgsfield/main/scripts/workshop-setup-mac.sh | bash
  ```
- Windows (PowerShell):
  ```
  iwr -useb https://raw.githubusercontent.com/evove-workshops/claude-higgsfield/main/scripts/workshop-setup-windows.ps1 | iex
  ```

When the script finishes, Claude Desktop will open. Sign in with the email on your **Claude Pro** account — that's what unlocks the Cowork tab. Click into **Cowork**, and the Higgsfield MCP should already be listed under MCP settings. The first time you use it, a browser window will open asking you to sign in to Higgsfield. Approve it. Done.

## If you'd rather wait

That's fine. The auth station opens at **[DOORS_TIME]** and can walk you through it before we start. Just please show up early enough — we don't want to push the start time.

## Logistics

- **Venue:** [VENUE_ADDRESS]
- **Parking / transit:** [PARKING_NOTE]
- **Wi-Fi:** Provided on the welcome card at check-in.
- **Bring:** laptop, charger, photo ID.

Questions before then? Just reply to this email.

See you [DAY_OF_WEEK],

**Gia Anderson**
Director of Communications · OPEN Interactive Global, LLC
gia@madebyopen.com

---

*P.S. — A short reminder with the door address and the installer link will land in your inbox the morning of the workshop.*
