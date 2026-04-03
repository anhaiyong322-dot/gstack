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

### 1. 关系图

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

核心点是：gstack 不会替换 Codex。它只是增强原生 Codex 在某个目录里能看到的技能，以及默认遵循的工作流。

### 2. 心智模型

当你运行 `codex` 时，底层运行的仍然是原生 Codex。更准确的理解方式是：

- OpenAI 模型：负责思考、推理和生成动作，相当于“大脑”
- Codex CLI：本地 agent 运行器和执行环境
- gstack：叠加在上面的技能包和工作流层

如果你平时通过 ChatGPT 来发起和协同工作，也可以这样理解：

- ChatGPT：入口和对话界面
- Codex：本地运行时和执行器
- gstack：可复用的工作流包

一句话版本：

```text
OpenAI 模型大脑 + Codex 运行时 + gstack 工作流包
```

### 3. 原生 Codex、全局 gstack、项目级 gstack

实际使用里，通常只有三种状态：

| 状态 | 存在什么 | 会发生什么 |
|---|---|---|
| 纯原生 Codex | 没有安装 gstack | Codex 按默认方式工作 |
| 全局 gstack | `~/.codex/skills/gstack` | 所有 Codex 会话都能看到 gstack skills |
| 项目级 gstack | `.agents/skills/gstack`、`.gstack/codex/...`、`AGENTS.md` | 只有这个仓库会得到 gstack 工作流层 |

对大多数人来说，默认更推荐项目级安装。

它的好处是：

- 目标项目里能用 gstack
- 其他目录里的 Codex 仍然基本保持原生
- 团队成员可以通过仓库内的提交文件继承同一套工作流

### 4. 项目级安装与全局安装

这两种安装模式的影响范围不同：

| 模式 | 会写入哪里 | 影响范围 | 适合场景 |
|---|---|---|---|
| 项目级安装 | `.agents/skills/gstack`、`.gstack/codex/...`、`AGENTS.md` | 单个仓库 | 正在维护的真实项目 |
| 全局安装 | `~/.codex/skills/gstack` | 当前用户的所有 Codex 会话 | 你希望所有仓库默认都能用 gstack |

更适合使用项目级安装的情况：

- 你希望每个仓库有自己的工作流规则
- 你不想影响无关项目
- 你希望团队成员通过仓库文件继承相同行为

更适合使用全局安装的情况：

- 你希望任何目录下都能看到 gstack
- 你接受一套用户级的统一技能包
- 你清楚这依然不是替换 Codex 本身

### 5. 原版 gstack 与这份 fork 的区别

原生 gstack 本身已经支持 Codex。这份 fork 不是从零发明 Codex 支持，而是把 `Windows + Codex` 这条路径做得更顺手、更稳定。

| 维度 | 原版 gstack | 这份 fork |
|---|---|---|
| Codex 支持 | 已支持，`./setup --host codex` 即可 | 保留原版支持，并补强 Windows 接入体验 |
| 核心技能 | 原版全部已有 | 核心技能基本不变 |
| 安装方式 | 更通用，也更偏 Unix 风格 | 提供 `install-codex.ps1` 和 `bootstrap-codex-project.ps1` |
| 项目接入 | 可以做，但更偏手工 | 自动维护 `AGENTS.md` 与 `.gstack/codex/` |
| Windows 兼容 | 可用，但更容易踩坑 | 修复 Git Bash、Bun、Playwright 等 Windows 问题 |
| 自检 | 基础 setup 路径 | 增加 `doctor-codex.ps1` |
| 文档 | 偏通用英文说明 | 增加 Codex-first 中英文说明 |

一句话总结：

- 原版 gstack：已经兼容 Codex
- 这份 fork：更像面向 Windows 和日常项目接入的 Codex-first 落地版

### 6. 到底该选哪种安装方式

最简单的判断规则：

```text
只想让一个仓库用 gstack -> 选项目级安装
希望所有仓库都能看到 gstack -> 选全局安装
想先稳妥试用 -> 先从项目级安装开始
```

对于 `Windows + Codex` 这条使用路径，建议顺序是：

1. 先拿一个真实项目做项目级接入
2. 确认这套流程符合你的习惯
3. 如果后面你希望每个仓库都默认可用，再补全局安装
