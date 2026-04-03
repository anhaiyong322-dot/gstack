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
