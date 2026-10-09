# FFF 傻子模式 · Fool · Focus · Few

> 跟 AI 聊几轮，人脑就过载了。FFF 把 AI 的输出压成「一口一块」。

一个跨工具的 Agent Skill。装一次，**Claude Code / Codex / DeepSeek Harness** 都能用 `/fff` 打开。

---

## 三个 F

| F | 中文 | 管什么 |
|---|---|---|
| **Fool** | 傻子 | 说人话。术语必须紧跟一句 ≤10 字的解释 |
| **Focus** | 专注 | 一次一件。每条消息只推进一个步骤，不预告后面的 |
| **Few** | 少 | 正文 ≤ 3 行；提问一次最多 1–2 个；选项最多 4 个 |

## 打开之后长这样

```
你   /fff

AI   FFF 模式开了。

     你想搞定什么？

你   我想让这个脚本每天自动跑一次

AI   (step 1) 先加一个 Windows 计划任务，指向这个脚本。

     1 清楚，继续
     2 不清楚，说简单点
     3 换个说法或举例
     0 退出

你   2

AI   (step 1) 就是让电脑自己定时打开这个脚本，不用你点。

     1 清楚，继续
     2 还是不清楚
     3 举个完整例子
     0 退出
```

你不用想「该怎么回复」，只要敲一个数字。

## 安装

### 一键（推荐）

```powershell
# Windows
./install.ps1
```

```sh
# macOS / Linux
./install.sh
```

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
- **回答**：`1` 继续 · `2` 说不懂，要更简单 · `3` 说不懂，换个说法或举例 · `0` 退出。也可以随时正常打字，不强制用编号。
- **临时展开**：说「详细说」就展开这一次，之后自动回到 FFF。
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
| 选项文案（清楚 / 不清楚 / 重新解释） | 同段的代码块模板 |
| 提问上限（1–2 个） | `## 提问` 第一条 |
| 只让用户手动开启、不许自动触发 | frontmatter 加 `disable-model-invocation: true` |

## 为什么这么设计

- **结尾永远是「回答块」**：把「我该怎么回」这件事从你脑子里拿掉，回复成本降到敲一个数字。
- **三个固定答案**：懂 / 不懂要更简单 / 不懂要换说法。分开这两种「不懂」很重要——前者要拆小，后者要换比喻。
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
