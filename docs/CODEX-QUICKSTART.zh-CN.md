# Codex 快速开始

更新日期：2026-04-04

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

### 7. 这套系统现在能做什么

在项目级 Codex 安装里，这套系统实际给你的是 4 层能力：

- 工作流路由：`AGENTS.md` 和 `.gstack/codex/GSTACK-CODEX.md` 会告诉 Codex 什么时候进入规划、审查、QA、发版和安全模式
- 可复用技能包：已经安装好的 28 个 gstack skills，默认通常是 `gstack-*` 命名空间
- 浏览器自动化：真实浏览器驱动的 QA、截图、登录态测试、staging 验证、性能检查
- 项目级 prompt：`.gstack/codex/prompts/review.md`、`qa.md`、`ship.md`、`autoplan.md`

换句话说，这套系统现在已经可以覆盖：

- 需求梳理与实施方案规划
- 代码审查与发布准备
- 浏览器测试与带登录态的 QA 流程
- 调试与根因分析
- 高风险命令和限定编辑范围的保护
- 发布后检查、复盘，以及可重复使用的项目工作流

### 8. 命令对照表

默认情况下，这份 fork 的 Codex 安装使用的是带命名空间的技能名，例如 `gstack-review`。如果你的安装使用短名，只需要把 `gstack-` 前缀去掉即可。

#### 规划与设计

| 命令 | 什么时候用 |
|---|---|
| `gstack` | 不确定该从哪个流程开始时，用总入口先接管 |
| `gstack-office-hours` | 产品想法还模糊，需要先把问题、范围、价值想清楚 |
| `gstack-plan-ceo-review` | 想从产品/创始人视角重新挑战方案 |
| `gstack-plan-eng-review` | 想在开发前把架构、边界、测试、风险补齐 |
| `gstack-plan-design-review` | 想在开发前先把交互与体验问题审清楚 |
| `gstack-autoplan` | 想一条命令把想法变成完整的实施方案 |
| `gstack-design-consultation` | 需要更强的设计方向、风格或设计系统建议 |
| `gstack-design-review` | 界面已经做出来了，想对真实实现做设计审查 |
| `gstack-retro` | 想复盘一个迭代、一次交付，或一段开发节奏 |

#### 代码、调试与发布

| 命令 | 什么时候用 |
|---|---|
| `gstack-review` | 分支准备合并前，做代码审查 |
| `gstack-investigate` | 出现 bug 或回归时，先做根因分析再修复 |
| `gstack-ship` | 准备发版、检查测试、整理 PR |
| `gstack-land-and-deploy` | 改动已经批准，继续合并并部署 |
| `gstack-document-release` | 代码已发布，文档也需要同步到真实状态 |
| `gstack-setup-deploy` | 在使用发布自动化前，先把部署前提配置好 |

#### 浏览器、QA 与性能

| 命令 | 什么时候用 |
|---|---|
| `gstack-browse` | 需要浏览器控制、截图、点击、看页面状态 |
| `gstack-qa` | 需要完整浏览器 QA，而且允许流程顺手修问题 |
| `gstack-qa-only` | 只需要 QA 报告，不希望自动改代码 |
| `gstack-benchmark` | 需要检查页面性能、加载速度、资源体积 |
| `gstack-canary` | 需要在部署后持续观察是否有回归或异常 |
| `gstack-connect-chrome` | 想连接可见的真实 Chrome，并实时看它操作 |
| `gstack-setup-browser-cookies` | QA 或 staging 测试需要登录态 |

#### 安全、护栏与维护

| 命令 | 什么时候用 |
|---|---|
| `gstack-cso` | 想做安全审查或威胁建模 |
| `gstack-careful` | 想在危险命令前得到提醒 |
| `gstack-freeze` | 想把编辑范围锁定在一个目录或一个小范围 |
| `gstack-guard` | 想同时启用命令提醒和编辑范围保护 |
| `gstack-unfreeze` | 想解除之前的 `freeze` 限制 |
| `gstack-upgrade` | 想升级 gstack 自身 |

### 9. 最常用的命令顺序

做一个新功能时，最常见的顺序是：

1. `gstack-office-hours`
2. `gstack-autoplan` 或一组 `gstack-plan-*`
3. 实现功能
4. `gstack-review`
5. `gstack-qa`
6. `gstack-ship`

修一个线上或疑难 bug 时，最常见的顺序是：

1. `gstack-investigate`
2. 实现修复
3. `gstack-review`
4. `gstack-qa` 或 `gstack-qa-only`
5. `gstack-ship`

只做浏览器验证时，最常见的顺序是：

1. `gstack-browse` 或 `gstack-connect-chrome`
2. 如果需要登录态，先接 `gstack-setup-browser-cookies`
3. `gstack-qa` 或 `gstack-qa-only`

### 10. 项目级 Prompt 快捷入口

每个接入过的项目还会得到这 4 个 prompt 文件：

- `.gstack/codex/prompts/review.md`
- `.gstack/codex/prompts/qa.md`
- `.gstack/codex/prompts/ship.md`
- `.gstack/codex/prompts/autoplan.md`

当你不想每次重新解释 review、QA、发版或规划流程时，直接引用这些文件，就能让 Codex 按这个仓库的默认工作流来执行。

### 11. 第一次进入 `E:\your-project` 后怎么开始

完成 bootstrap 之后，最短路径就是：

```powershell
Set-Location E:\your-project
codex
```

进入 Codex 之后，第一句尽量只下一个明确指令，不要一上来塞 5 个目标。

如果你是做一个新功能，可以直接这样说：

```text
Use gstack-office-hours and help me sharpen this feature idea before we implement it.
```

或者：

```text
Use gstack-autoplan and create the implementation plan first.
```

如果你是想审查当前分支，可以直接说：

```text
Use gstack-review and review the current branch.
```

如果你是想对 staging 做浏览器 QA，可以直接说：

```text
Use gstack-qa and test https://staging.example.com.
```

如果你遇到的是一个应该先查根因的 bug，可以直接说：

```text
Use gstack-investigate and find the root cause before making changes.
```

如果你更想直接引用项目里的 prompt 文件，可以这样说：

```text
Use .gstack/codex/prompts/review.md and review the current branch.
```

```text
Use .gstack/codex/prompts/qa.md and test https://staging.example.com.
```

```text
Use .gstack/codex/prompts/ship.md and prepare this branch to ship.
```

对大多数项目来说，第一次真正开始用时，建议这样选：

1. 如果仓库里已经有代码，想最快看到有效信号，就先用 `gstack-review`
2. 如果任务本身还不清楚，就先用 `gstack-office-hours`
3. 如果主要风险在浏览器行为，就先用 `gstack-qa`

### 12. 一套完整链路示例：`review -> qa -> ship`

当一个分支上已经有代码时，最简单也最真实的完整链路通常就是这一套。

先进入项目：

```powershell
Set-Location E:\your-project
codex
```

然后按下面顺序来。

第 1 步：先审查当前分支

```text
Use gstack-review and review the current branch.
```

预期结果：

- Codex 会把当前分支当成合并前审查对象
- 它会指出 bug、回归风险、测试缺口或危险假设
- 你可以先修这些问题，再继续后面的 QA 和发版准备

第 2 步：再做浏览器 QA

```text
Use gstack-qa and test https://staging.example.com.
```

预期结果：

- Codex 会对目标 URL 跑真实的浏览器 QA 流程
- 它会检查页面行为、关键流程、可见异常
- 如果这个流程允许修复，它可以从发现问题继续走到修复和复验

如果你只想拿到问题列表，不希望它改代码，可以改成：

```text
Use gstack-qa-only and test https://staging.example.com.
```

第 3 步：最后准备发版

```text
Use gstack-ship and prepare this branch to ship.
```

预期结果：

- Codex 会检查这个分支是否具备发版准备条件
- 它会整理测试、发布准备、PR readiness
- 最终把发版这件事从临时操作，变成有组织的流程

最短的连续写法是：

```text
Use gstack-review and review the current branch.
Use gstack-qa and test https://staging.example.com.
Use gstack-ship and prepare this branch to ship.
```

但在真实使用中，更推荐还是一步一步来：

1. 先完成 `gstack-review`
2. 处理 review 发现的问题
3. 再跑 `gstack-qa`
4. 处理 QA 发现的问题
5. 最后跑 `gstack-ship`

这样得到的信号最清楚，也最不容易混乱。
