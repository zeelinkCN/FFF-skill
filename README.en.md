# FFF mode · Fool · Focus · Few

[中文](README.md) | **English**

> A few rounds with an AI and your brain is full. FFF squeezes its output into one bite at a time.

A cross-tool Agent Skill. Install it once and **Claude Code / Codex / DeepSeek Harness** can all open it with `/fff`.

---

## The three Fs

| F | Means | What it controls |
|---|---|---|
| **Fool** | plain words | No jargon. An unavoidable term gets a ≤10-character explanation right after it |
| **Focus** | one thing | One step per message; never previewing what comes next |
| **Few** | less | Body ≤ 3 lines; **no question when nothing is yours to decide**; at most 1–2 questions per popup (several popups per turn are fine); at most 4 options |

## What it looks like

```
you  /fff

AI   FFF mode is on.

     What do you want to get done?

you  I want this script to run once a day

AI   (step 1) Add a scheduled task that points at the script.

     ┌─ Does this step make sense? ─────────────────────┐
     │  ▸ Got it, next        move to the next step     │
     │    Not clear, simpler  shorter and more concrete │
     │    Not clear, reword   analogy or example        │
     │    Not clear, detail   longer, this time only    │
     └──────────────────────────────────────────────────┘

you  (clicked "Not clear, simpler")

AI   It means the computer opens this script on a timer, without you clicking.

     ┌─ Does this step make sense? ─────────────────────┐
     │  ▸ Got it, next                                  │
     │    Not clear, simpler                            │
     │    Not clear, reword                             │
     │    Not clear, detail                             │
     └──────────────────────────────────────────────────┘
```

**The popup is each agent's own native question UI**, not a text trick: in DSH it is the question card above the composer, in Claude Code it is `AskUserQuestion`, in Codex it is `request_user_input`. You click once — no figuring out "how should I reply", no typing `1` `2` `3`.

Picking "in detail" lifts the length limit for that one answer, then it drops back to short lines.

## Install

### One line (download + install together)

Windows PowerShell:

```powershell
irm https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@v1.0.3/install.ps1 | iex
```

macOS / Linux / WSL:

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@v1.0.3/install.sh | sh
```

The jsDelivr mirror is there because GitHub's own `raw.githubusercontent.com` is frequently unreachable from mainland China; `@v1.0.3` is a tag, so the content is fixed and cannot be cached into an older version. Swap it for `@main` to follow the latest.

Once the script has itself, it still needs `SKILL.md`: that download goes through the **GitHub API** (`api.github.com`, usually reachable from China) and falls back to the official raw URL. jsDelivr is not used for the body because it only 301s `.md` files back to raw, which defeats the point.

`git clone` works as a one-liner too:

```powershell
git clone https://github.com/zeelinkCN/FFF-skill.git "$env:TEMP\FFF-skill"; & "$env:TEMP\FFF-skill\install.ps1"
```

```sh
git clone https://github.com/zeelinkCN/FFF-skill.git /tmp/FFF-skill && sh /tmp/FFF-skill/install.sh
```

Already cloned? Just run `./install.ps1` or `./install.sh` inside the repo.

The script installs into every agent home it finds on the machine:

| Tool | Location | How to invoke |
|---|---|---|
| DeepSeek Harness | `${DSH_HOME:-~/.dsh}/skills/fff/SKILL.md` | type `/` in the composer and pick `fff` |
| Claude Code | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/fff/SKILL.md` | `/fff` |
| Codex | `${CODEX_HOME:-~/.codex}/skills/fff/SKILL.md` | `/skills` or `$fff` |

Just one of them: `./install.ps1 -Only claude` / `./install.sh codex`

### Manual

Copy `SKILL.md` into an `fff/` directory under any path above. It follows the [Agent Skills](https://agentskills.io) open standard, so any compatible tool (Cursor, Amp, other harnesses) can load it as-is.

To share it with a team, commit it to `.claude/skills/fff/` or `.codex/skills/fff/` in the repository.

## Usage

- **On**: `/fff on` (also `开` / `enable`; a bare `/fff` means on).
- **Off**: `/fff off` (also `关` / `关掉傻子模式` / `正常模式` / `退出` / `0`). Turning it off exits cleanly and restores the agent's normal verbosity.
- **Follow your bandwidth**: brain clear → `/fff off`; tired again → `/fff on`. You can also just say "fool mode" / "stop flooding me" / "I'm out of brain". When it is unsure, it asks once (on / off) instead of switching silently.
- **Answer**: click the popup — `Got it, next` / `Not clear, simpler` / `Not clear, reword` / `Not clear, in detail`. Only when the host has no question tool does it fall back to numbered text (`1`–`4`, `0` to exit). You can always type freely; the options are not mandatory.
- **Exit**: type `0` / `退出` / `关` / `/fff off`, or use the popup's free-text field (`custom` in DSH, `other` in Codex). On DSH the popup also carries an extra `退出傻子模式` button.
- **One-off expansion**: pick "in detail" or say "explain fully" — it expands that once, then returns to FFF.
- **Scope**: the mode lives only in the current conversation. A new session starts with it off; run `/fff on` again.

## What FFF does not restrict

FFF compresses only **what is said to a human**, never the work itself:

- Writing files, editing code, running commands, producing deliverables — as large as they need to be.
- Destructive, irreversible, costly, or security-relevant actions are still spelled out in one line, with confirm/cancel among the options.
- Commands, error text, and filenames are quoted verbatim; nothing is mangled to be shorter.

## Customizing

Every rule lives in `SKILL.md`; re-run the installer after an edit (DSH and Claude Code watch the skills directory, so a change lands within the same turn).

`SKILL.md` itself is **bilingual by design**: each rule is one Chinese line followed by one English line, in a single file, so the two versions cannot drift apart. The frontmatter `description` is bilingual too, with trigger words in both languages. The bilingual file is for human readers only — at runtime the agent replies in the user's language alone, never both (that rule is written into the skill, not left to chance).

Common edits:

| Want to change | Where |
|---|---|
| Length caps (3 lines / ~60 characters) | rule 1 of `## 每条消息的样子` |
| Option labels (understood / simpler / reword / in detail) | the option table in `## 选择怎么给` |
| Wire up another agent's question tool | add a row to the host → tool table in the same section |
| Question cap (1–2 per popup) | first bullet of `## 选择怎么给` |
| Manual only, never auto-triggered | add `disable-model-invocation: true` to the frontmatter |

## Why it is built this way

- **Click, don't type**: it takes "how should I reply" out of your head. Native question UIs instead of `1 2 3` written into the body — markdown flattens those onto one line, and you still have to type.
- **No branch, no question**: progress notes and wrap-ups — messages where every possible reply leads to the same place — simply end. No button whose only sensible option is "ok". The test is written into the rules: **if every answer leads to the same next action, there is no branch — do not ask.**
- **Four fixed answers**: understood / not understood, simpler / not understood, reword / not understood, in detail. Separating those kinds of "not understood" matters: the first needs the sentence split smaller, the second needs a different metaphor, and the third genuinely wants depth — which deserves a lifted length limit instead of being squeezed into 3 lines.
- **Tool or text, never both**: the rules pin down one form per segment, so the agent cannot pop a dialog and also list the options in prose.
- **One thing at a time**: the real damage of a wall of text is not the word count, it is being forced to hold several pending decisions at once.
- **Constrain output, not capability**: that is why it makes the agent quieter, not dumber.

## Files

```
fff-skill/
├── SKILL.md       the rules (the only file you need to maintain)
├── README.md      Chinese
├── README.en.md   English
├── LICENSE
├── install.ps1    Windows installer
└── install.sh     macOS / Linux installer
```

## License

MIT
