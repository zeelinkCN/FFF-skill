# FFF 傻子模式 · Fool · Focus · Few

> 跟 AI 聊几轮，人脑就过载了。FFF 把 AI 的输出压成「一口一块」。

一个跨工具的 Agent Skill。装一次，**Claude Code / Codex / DeepSeek Harness** 都能用 `/fff` 打开。

---

## 三个 F

| F | 中文 | 管什么 |
|---|---|---|
| **Fool** | 傻子 | 说人话。术语必须紧跟一句 ≤10 字的解释 |
| **Focus** | 专注 | 一次一件。每条消息只推进一个步骤，不预告后面的 |
| **Few** | 少 | 正文 ≤ 3 行；**不需要你拍板就不问**；每次弹窗最多 1–2 个问题（一轮可以弹多次）；选项最多 4 个 |

## 打开之后长这样

```
你   /fff

AI   FFF 模式开了。

     你想搞定什么？

你   我想让这个脚本每天自动跑一次

AI   (step 1) 先加一个 Windows 计划任务，指向这个脚本。

     ┌─ 这一步清楚吗？ ────────────────────┐
     │  ▸ 懂了，继续         进入下一步      │
     │    不懂，说简单点      更短、更具体    │
     │    不懂，换个说法      打比方、举例    │
     │    不懂，详细讲        这次可以长      │
     └──────────────────────────────────────┘

你   （点了「不懂，说简单点」）

AI   就是让电脑自己定时打开这个脚本，不用你点。

     ┌─ 这一步清楚吗？ ────────────────────┐
     │  ▸ 懂了，继续                        │
     │    不懂，说简单点                     │
     │    不懂，换个说法                     │
     │    不懂，详细讲                       │
     └──────────────────────────────────────┘
```

**弹窗是各家 agent 自己的原生提问界面**，不是文字游戏：DSH 是输入框上方的提问卡片，Claude Code 是 `AskUserQuestion` 的选择框，Codex 是 `request_user_input`。你点一下就行，不用想「该怎么回复」，也不用敲 `1` `2` `3`。

选「详细讲」那一次，它会把长度限制放开，讲透了再回到短句节奏。

## 安装

### 一键（一行搞定下载 + 安装）

Windows PowerShell：

```powershell
irm https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@v1.0.3/install.ps1 | iex
```

macOS / Linux / WSL：

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@v1.0.3/install.sh | sh
```

走 jsDelivr 镜像是因为 GitHub 官方的 `raw.githubusercontent.com` 在国内经常连不上；地址里的 `@v1.0.3` 是一个 tag，内容是固定的，不会被 CDN 缓存成旧版本。想跟最新就把它换成 `@main`。

脚本拿到自己之后，还要再去取 `SKILL.md`：这一步走 **GitHub API**（`api.github.com`，国内通常可达），失败才退回官方 raw 地址。没用 jsDelivr 当正文源，是因为它遇到 `.md` 只会 301 跳回 raw，等于没绕开。

用 git 克隆也是一行：

```powershell
git clone https://github.com/zeelinkCN/FFF-skill.git "$env:TEMP\FFF-skill"; & "$env:TEMP\FFF-skill\install.ps1"
```

```sh
git clone https://github.com/zeelinkCN/FFF-skill.git /tmp/FFF-skill && sh /tmp/FFF-skill/install.sh
```

已经克隆好了，就在仓库里直接跑 `./install.ps1` 或 `./install.sh`。

脚本会把它装到本机存在的每一个 agent 目录：

| 工具 | 安装位置 | 调用方式 |
|---|---|---|
| DeepSeek Harness | `${DSH_HOME:-~/.dsh}/skills/fff/SKILL.md` | 输入框打 `/` 选 `fff` |
| Claude Code | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/fff/SKILL.md` | `/fff` |
| Codex | `${CODEX_HOME:-~/.codex}/skills/fff/SKILL.md` | `/skills` 或 `$fff` |

只装某一个：`./install.ps1 -Only claude` / `./install.sh codex`

### 手动

把 `SKILL.md` 复制到上面任意一行路径下的 `fff/` 目录里即可。它遵循 [Agent Skills](https://agentskills.io) 开放标准，任何支持该标准的工具（Cursor、Amp、其他 harness）都能直接吃。

项目内共享：放进仓库的 `.claude/skills/fff/` 或 `.codex/skills/fff/`，提交即可，全队生效。

## 怎么用

- **开**：`/fff on`（也认 `开` / `enable`；不带参数直接 `/fff` 就是开）。
- **关**：`/fff off`（也认 `关` / `关掉傻子模式` / `正常模式` / `退出` / `0`）。关掉就干净退出，回到 AI 原本的说话方式，篇幅不再受限。
- **随带宽切换**：脑子清醒了 `/fff off` 让它恢复大带宽；又累了 `/fff on` 再压回来。也可以直接说「开傻子模式 / 别一次说那么多 / 我脑子不够用了」，判断不准时它会先问一句「开不开」，不会偷偷切。
- **回答**：直接点弹窗——`懂了，继续` / `不懂，说简单点` / `不懂，换个说法` / `不懂，详细讲`。宿主没有提问工具时才会退回文字编号（`1`–`4`，`0` 退出）。也可以随时正常打字，不强制用选项。
- **追问 / 退出**：退出可以直接打字 `0` / `退出` / `关` / `/fff off`，或者用弹窗里的自由输入框（DSH 的 `custom`、Codex 的 `other`）。DSH 上弹窗还会多一个 `退出傻子模式` 按钮。
- **临时展开**：选「详细讲」或说「详细说」，展开这一次，之后自动回到 FFF。
- **状态范围**：模式只活在当前对话里。新开一个会话默认是关的，要重新 `/fff on`。

## 它不管什么

FFF 只压缩**说给人看的话**，不压缩工作本身：

- 写文件、改代码、跑命令、产出交付物，该多大就多大。
- 破坏性、不可逆、有安全风险的操作，仍然会用一句话把风险讲清楚，再把「确认 / 取消」放进选项里。
- 命令、报错原文、文件名照抄，不为了短而篡改。

## 想改规则

全部规则都在 `SKILL.md` 里，改完重新跑一次安装脚本即可生效（DSH 和 Claude Code 都会监听 skill 目录，改完当轮就刷新）。

`SKILL.md` 是**中英对照**的：每条规则一行中文、一行英文，同一份文件、不会各写一遍各改一遍。frontmatter 的 `description` 也是双语的，中英触发词都在里面。文件双语只是为了给人读——真跑起来时，AI 只说你用的那一种语言，不会中英各回一遍（这条写在规则里，不是靠自觉）。

常见改法：

| 想改什么 | 改哪 |
|---|---|
| 字数上限（3 行 / 60 字） | `## 每条消息的样子` 第 1 条 |
| 选项文案（懂了 / 说简单点 / 换说法 / 详细讲） | `## 选择怎么给` 的选项表 |
| 接别的 agent 的提问工具 | 同节的「宿主 → 工具」表加一行 |
| 提问上限（1–2 个） | `## 选择怎么给` 第一条 |
| 只让用户手动开启、不许自动触发 | frontmatter 加 `disable-model-invocation: true` |

## 为什么这么设计

- **能点就别打字**：把「我该怎么回」从你脑子里拿掉。用各家 agent 原生的提问 UI，而不是让模型在正文里写 `1 2 3`——后者会被 markdown 压成一行，还得你动手敲。
- **没分支就不问**：进度汇报、收尾总结这类「你回什么都一样」的消息，直接一句话结束，不给你一个只能点「好」的按钮。判断法写在规则里：**用户回答什么都一样，就没有分支，别问。**
- **四个固定答案**：懂 / 不懂要更简单 / 不懂要换说法 / 不懂要详细讲。分开这几种「不懂」很重要——第一种要把话拆小，第二种要换比喻，第三种是真的想深入，那就该放开长度，而不是硬憋在 3 行里。
- **工具与文字二选一**：规则里写死了「回答块只有一种形式」，避免模型既弹窗又在正文里列一遍选项。
- **一次只推进一件事**：长篇回复的真正伤害不是字数，是你被迫同时处理多个待决事项。
- **限制输出而不是限制能力**：所以它不会让 agent 变笨，只让它闭嘴。

## 文件

```
fff-skill/
├── SKILL.md      规则本体（唯一需要维护的文件）
├── README.md
├── LICENSE
├── install.ps1   Windows 安装脚本
└── install.sh    macOS / Linux 安装脚本
```

## License

MIT

---

## English

**FFF mode — Fool · Focus · Few.** A low-bandwidth talking mode for a tired human brain: reply in at most 3 short lines, advance exactly one step per message, and end every message with a small numbered choice. When the agent needs input, it asks 1 question (2 only when they must be answered together) — never a wall of questions.

- **Fool** — plain words; any unavoidable term gets a short explanation.
- **Focus** — one thing at a time.
- **Few** — few words, few questions, few options.

Install: run `./install.ps1` (Windows) or `./install.sh` (macOS/Linux), which copies `SKILL.md` into `<home>/skills/fff/` for DeepSeek Harness, Claude Code, and Codex. Or copy it manually — it follows the [Agent Skills](https://agentskills.io) open standard, so any compatible tool can load it.

Use: `/fff` to turn it on, `1` understood / `2` say it simpler / `3` say it differently / `0` exit. It constrains only what the agent says to you — never the work itself, and never safety warnings.
