# Codex 快速开始

更新日期：2026-04-04

[English Version](CODEX-QUICKSTART.md)

这是一份面向 Windows 的 gstack + Codex 安装与使用手册。

## 1. 你实际安装的是什么

这份 fork 不会替换原生 Codex。更准确的理解是：

```text
OpenAI 模型大脑 + Codex 运行时 + gstack 工作流包
```

也就是说：

- 底层执行器仍然是原生 Codex
- gstack 负责补技能、浏览器工作流、安全护栏和项目级默认流程
- 这份 fork 保留上游 gstack 的能力，同时把 Windows 下的 Codex 安装和复用路径做得更顺手

## 2. 安装前准备

先装好这 4 个前置：

- Git for Windows，并包含 Git Bash
- Bun
- Node.js
- Codex CLI

如果后面想快速检查环境，可以在这个仓库里执行：

```powershell
Set-Location $HOME\gstack
.\scripts\doctor-codex.ps1
```

## 3. 先选安装方式

最简单的判断规则：

```text
只想让一个仓库用 gstack -> 选项目级安装
希望所有仓库都能看到 gstack -> 选全局安装
想先稳妥试用 -> 先从项目级安装开始
```

### 项目级安装：推荐默认方案

这是最适合真实项目的方式，因为它只影响一个仓库。

在 PowerShell 中执行：

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\bootstrap-codex-project.ps1 -ProjectRoot E:\your-project
```

这条命令会向目标仓库写入：

- `.agents/skills/gstack`
- `.gstack/codex/GSTACK-CODEX.md`
- `.gstack/codex/prompts/review.md`
- `.gstack/codex/prompts/qa.md`
- `.gstack/codex/prompts/ship.md`
- `.gstack/codex/prompts/autoplan.md`
- `AGENTS.md`

它还会顺手完成这些事：

- 检查 Git Bash、Bun、Node.js、Codex CLI
- 运行 `./setup --host codex`
- 生成 Codex skills
- 运行 `scripts/doctor-codex.ps1`

### 全局安装：可选

只有当你希望当前用户下的所有 Codex 仓库都能看到 gstack 时，才建议用它。

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\install-codex.ps1
```

全局安装主要写入：

- `~/.codex/skills/gstack`

这里也要强调：Codex 依然还是原生 Codex，只是所有仓库都能发现 gstack skills 了。

### 已全局安装，后来想接入某个项目

如果你已经做过全局安装，后来又希望某个仓库也获得托管的 `AGENTS.md` 和 `.gstack/codex/` 文件，可以执行：

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

### 手工接入：高级用法

如果你想保留更接近上游的手工方式，也可以直接这样做：

```bash
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git .agents/skills/gstack
cd .agents/skills/gstack && ./setup --host codex
```

这条路也能走通，但在 Windows 下，更推荐前面的 PowerShell bootstrap，因为它会同时把 `AGENTS.md`、`.gstack/codex/` 和 `doctor-codex.ps1` 一起接好。

## 4. 安装完之后怎么开始用

做完项目级安装之后：

```powershell
Set-Location E:\your-project
codex
```

如果这个仓库之前已经打开过 Codex，建议重启一次，让它重新加载新装的 skills 和 `AGENTS.md`。

## 5. 进入 Codex 后第一批该怎么说

尽量一次只下一个明确指令。

做规划时：

```text
Use gstack-office-hours and help me sharpen this feature idea before we implement it.
```

```text
Use gstack-autoplan and create the implementation plan first.
```

做代码审查时：

```text
Use gstack-review and review the current branch.
```

做浏览器 QA 时：

```text
Use gstack-qa and test https://staging.example.com.
```

做发版准备时：

```text
Use gstack-ship and prepare this branch to ship.
```

如果你更喜欢直接引用项目内的 prompt 文件，也可以这样说：

```text
Use .gstack/codex/prompts/review.md and review the current branch.
```

```text
Use .gstack/codex/prompts/qa.md and test https://staging.example.com.
```

```text
Use .gstack/codex/prompts/ship.md and prepare this branch to ship.
```

## 6. 最推荐的日常使用顺序

做一个新功能时：

1. `gstack-office-hours`
2. `gstack-autoplan` 或一组 `gstack-plan-*`
3. 实现功能
4. `gstack-review`
5. `gstack-qa`
6. `gstack-ship`

修 bug 时：

1. `gstack-investigate`
2. 修根因
3. `gstack-review`
4. `gstack-qa` 或 `gstack-qa-only`
5. `gstack-ship`

只做浏览器验证时：

1. `gstack-browse` 或 `gstack-connect-chrome`
2. 如果需要登录态，补 `gstack-setup-browser-cookies`
3. `gstack-qa` 或 `gstack-qa-only`

## 7. 这套系统现在能做什么

在项目级安装里，这套系统给你的是 4 层能力：

- 通过 `AGENTS.md` 和 `.gstack/codex/GSTACK-CODEX.md` 做工作流路由
- 一套可复用的技能包，默认通常是 `gstack-*`
- 浏览器自动化，覆盖 QA、截图、登录态流程、staging 检查、性能检查
- 项目级 prompt 模板，覆盖 review、QA、ship 和规划

落到实际工作里，它可以处理：

- 需求梳理与实施方案规划
- 代码审查与发版准备
- 浏览器测试与带登录态的 QA 流程
- 调试与根因分析
- 高风险命令和限定编辑范围的保护
- 发布后检查、复盘，以及可以复用的项目工作流

## 8. 命令对照表

默认情况下，这份 fork 使用的是带命名空间的技能名，比如 `gstack-review`。如果你的安装是短名，只需要把 `gstack-` 前缀去掉即可。

### 规划与设计

| 命令 | 什么时候用 |
|---|---|
| `gstack` | 不确定该从哪个流程开始时，先用总入口 |
| `gstack-office-hours` | 产品想法还模糊，需要先把问题和范围想清楚 |
| `gstack-plan-ceo-review` | 想从产品或创始人视角重新挑战方案 |
| `gstack-plan-eng-review` | 想在开发前把架构、边界、测试和风险补齐 |
| `gstack-plan-design-review` | 想在开发前把交互与体验问题审清楚 |
| `gstack-autoplan` | 想一条命令把想法变成完整实施方案 |
| `gstack-design-consultation` | 需要更强的设计方向、风格或设计系统建议 |
| `gstack-design-review` | 界面已经做出来了，想对真实实现做设计审查 |
| `gstack-retro` | 想复盘一个迭代、一次交付，或一段开发节奏 |

### 代码、调试与发布

| 命令 | 什么时候用 |
|---|---|
| `gstack-review` | 分支准备合并前，做代码审查 |
| `gstack-investigate` | 出现 bug 或回归时，先查根因再修复 |
| `gstack-ship` | 准备发版、检查测试、整理 PR |
| `gstack-land-and-deploy` | 改动已经批准，继续合并并部署 |
| `gstack-document-release` | 代码已发布，文档也要同步到真实状态 |
| `gstack-setup-deploy` | 在使用发布自动化前，先把部署前提配好 |

### 浏览器、QA 与性能

| 命令 | 什么时候用 |
|---|---|
| `gstack-browse` | 需要浏览器控制、截图、点击、看页面状态 |
| `gstack-qa` | 需要完整浏览器 QA，而且允许流程顺手修问题 |
| `gstack-qa-only` | 只需要 QA 报告，不希望自动改代码 |
| `gstack-benchmark` | 需要检查页面性能、加载速度、资源体积 |
| `gstack-canary` | 需要在部署后持续观察是否有回归或异常 |
| `gstack-connect-chrome` | 想连接一个可见的真实 Chrome，并实时看它操作 |
| `gstack-setup-browser-cookies` | QA 或 staging 测试需要登录态 |

### 安全、护栏与维护

| 命令 | 什么时候用 |
|---|---|
| `gstack-cso` | 想做安全审查或威胁建模 |
| `gstack-careful` | 想在危险命令前得到提醒 |
| `gstack-freeze` | 想把编辑范围锁定在一个目录或一个小范围 |
| `gstack-guard` | 想同时启用命令提醒和编辑范围保护 |
| `gstack-unfreeze` | 想解除之前的 `freeze` 限制 |
| `gstack-upgrade` | 想升级 gstack 自身 |

## 9. 排查与刷新

如果安装脚本提示缺少 `bun`：

```powershell
powershell -c "irm bun.sh/install.ps1|iex"
```

安装后重新打开一个 PowerShell 窗口，或者确认 Bun 已进入 `PATH` 再重试。

如果项目接入内容漂移了：

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

如果项目里已经 vendored 了 `.agents\skills\gstack`，想重建项目内副本：

```powershell
.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .
```

如果 skills 明明在，但行为看起来还是旧的，通常只需要在项目根目录重启一次 Codex。

## 10. 附录

### 关系图

```text
                    你输入：codex
                         |
                         v
                  原生 Codex CLI
                         |
        -----------------------------------------
        |                                       |
        v                                       v
读取全局技能目录                          读取当前项目目录
`~/.codex/skills/...`                    `.agents/skills/gstack`
                                         `.gstack/codex/...`
                                         `AGENTS.md`
        \_______________________   _______________________/
                                \ /
                                 v
                    最终行为 = 原生 Codex
                             + 可选的 gstack 技能
                             + 可选的项目工作流规则
```

gstack 不会替换 Codex。它只是增强原生 Codex 能看到的技能，以及默认遵循的工作流。

### 原生 Codex、全局 gstack、项目级 gstack

| 状态 | 存在什么 | 会发生什么 |
|---|---|---|
| 纯原生 Codex | 没有安装 gstack | Codex 按默认方式工作 |
| 全局 gstack | `~/.codex/skills/gstack` | 所有 Codex 会话都能看到 gstack skills |
| 项目级 gstack | `.agents/skills/gstack`、`.gstack/codex/...`、`AGENTS.md` | 只有这个仓库会得到 gstack 工作流层 |

对大多数人来说，默认仍然最推荐项目级安装。

### 原版 gstack 与这份 fork 的区别

原版 gstack 本身已经支持 Codex。这份 fork 不是从零发明 Codex 支持，而是把这条路径在 Windows 上做得更容易安装、更容易反复复用。

| 维度 | 原版 gstack | 这份 fork |
|---|---|---|
| Codex 支持 | 已支持，`./setup --host codex` 即可 | 保留原版支持，并补强 Windows 接入体验 |
| 安装方式 | 更通用，也更偏 Unix 风格 | `install-codex.ps1` 和 `bootstrap-codex-project.ps1` |
| 项目接入 | 可以做，但更偏手工 | 自动维护 `AGENTS.md` 与 `.gstack/codex/` |
| Windows 兼容 | 可用，但更容易踩坑 | 修复 Git Bash、Bun、Playwright 等 Windows 问题 |
| 自检 | 基础 setup 路径 | 增加 `doctor-codex.ps1` |
| 文档 | 偏通用说明 | 中英文 Codex-first 手册 |

一句话总结：

- 原版 gstack：已经兼容 Codex
- 这份 fork：更适合 Windows 下的 Codex 日常接入与复用

### 以后如何持续跟进上游版本

这份 fork 现在已经带了 overlay 维护结构：

```text
上游最新版 gstack
        +
这份 fork 的 overlay
        =
你持续可维护的 Codex-first 版本
```

当你想把上游新能力并进来时，直接看 [Upstream Sync Guide](UPSTREAM-SYNC.md)。
