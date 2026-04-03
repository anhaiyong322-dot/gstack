# Codex 快速开始

更新日期：2026-04-03

[English Version](CODEX-QUICKSTART.md)

这份文档给出的是：如何在真实项目里，用最短路径把 gstack 接到 Codex 上并开始使用。

## 前置依赖

- Git for Windows，并包含 Git Bash
- Bun
- Node.js
- Codex CLI

## 首次接入

在 PowerShell 中执行：

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\bootstrap-codex-project.ps1 -ProjectRoot E:\your-project
```

这条命令会完成以下事情：

- 安装或更新 gstack 仓库
- 运行 `./setup --host codex`
- 把 gstack 复制到 `E:\your-project\.agents\skills\gstack`
- 写入或更新 `E:\your-project\AGENTS.md`
- 生成 `.gstack\codex\GSTACK-CODEX.md`
- 生成 `.gstack\codex\prompts\review.md`
- 生成 `.gstack\codex\prompts\qa.md`
- 生成 `.gstack\codex\prompts\ship.md`
- 生成 `.gstack\codex\prompts\autoplan.md`
- 运行 `scripts\doctor-codex.ps1`

## 启动 Codex

接入完成后执行：

```powershell
Set-Location E:\your-project
codex
```

如果这个仓库之前已经打开过 Codex，建议重启一次，让它重新加载 `AGENTS.md` 和安装好的 skills。

## 第一批可直接使用的命令

进入 Codex 后，可以直接输入下面这些话之一：

- `Use the gstack workflow for this task.`
- `Run a gstack-style review of the current branch.`
- `Use .gstack/codex/prompts/review.md and review the current branch.`
- `Use .gstack/codex/prompts/qa.md and test https://staging.example.com.`
- `Use .gstack/codex/prompts/ship.md and prepare this branch to ship.`
- `Use .gstack/codex/prompts/autoplan.md and create the implementation plan first.`

## 默认路由

默认建议这样使用：

- 需求梳理或方案发现：`gstack-office-hours`，然后进入 `gstack-plan-*`
- 合并前代码审查：`gstack-review`
- 浏览器验证或 staging 测试：`gstack-qa` 或 `gstack-qa-only`
- 发版准备：`gstack-ship`
- 高风险命令或限定编辑范围：`gstack-guard`、`gstack-careful`、`gstack-freeze`

项目内的工作流基准文件是 `.gstack/codex/GSTACK-CODEX.md`。

## 排查方式

如果安装脚本提示缺少 `bun`，可以先在 PowerShell 中执行：

```powershell
powershell -c "irm bun.sh/install.ps1|iex"
```

安装完成后，重新打开一个 PowerShell 窗口，或者在当前窗口确认 Bun 已进入 `PATH` 后再重试。

如果安装内容漂移了，可以重新执行：

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

如果你的项目里是 vendored copy，也就是已经存在 `.agents\skills\gstack`，可以在项目根目录重新执行：

```powershell
.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .
```

如果 skills 明明已经存在，但 Codex 的行为还是旧的，通常只需要在项目根目录重启一次 Codex。

## 附录

### 心智模型

当你运行 `codex` 时，底层运行的仍然是原生 Codex。gstack 不会替换 Codex CLI，也不会把 Codex 变成另一套程序。

更准确的理解方式是：

- OpenAI 模型：负责思考、推理和生成动作，相当于“大脑”
- Codex CLI：本地 agent 运行器和执行环境
- gstack：叠加在上面的技能包和工作流层

如果你平时通过 ChatGPT 来发起和协同工作，可以把 ChatGPT 理解成入口，把 Codex 理解成本地运行时。

### 项目级安装与全局安装

这套安装有两种模式：

- 项目级安装：把 `.agents/skills/gstack`、`.gstack/codex/...` 和 `AGENTS.md` 写进某一个仓库
- 全局安装：把 Codex 的运行时写到 `~/.codex/skills/gstack`

如果你希望 gstack 只影响一个项目，默认应该优先选项目级安装。项目级安装下：

- 在该项目里运行 `codex`，Codex 会看到 gstack
- 在其他目录运行 `codex`，基本还是原生 Codex

全局安装会让同一用户下的所有 Codex 会话都能发现 gstack skills，但底层运行器仍然是原生 Codex。

### 这份 Fork 相比原版改了什么

原生 gstack 本身已经支持 Codex。这份 fork 不是从零发明 Codex 支持，而是在 `Windows + Codex` 这条路径上做了更强的落地和加固。

这份 fork 主要新增和强化的是：

- `install-codex.ps1`，更适合 Windows 的安装入口
- `bootstrap-codex-project.ps1`，一条命令把项目接入 Codex 工作流
- 自动维护 `AGENTS.md`，让 Codex 按工作流阶段路由
- 生成 `.gstack/codex/` 下的项目级 playbook 和 prompts
- `doctor-codex.ps1`，用于环境和安装自检
- 针对 Bun、Git Bash、Playwright 的 Windows 兼容修复
- 中英文快速开始文档

一句话总结：

- 原版 gstack：已经兼容 Codex
- 这份 fork：更像面向 Windows 和日常项目接入的 Codex-first 落地版
