<h1 align="center">Codex Superpower Quick Confirm 中文说明</h1>

<p align="center">
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/GitHub-Coder-xu/codex-superpower-quick-confirm?include_prereleases&label=release&labelColor=000000&color=2f80ed"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/stargazers"><img alt="stars" src="https://img.shields.io/github/stars/GitHub-Coder-xu/codex-superpower-quick-confirm?label=stars&labelColor=000000&color=facc15"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/issues"><img alt="issues" src="https://img.shields.io/github/issues/GitHub-Coder-xu/codex-superpower-quick-confirm?label=issues&labelColor=000000&color=f472b6"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/blob/main/LICENSE"><img alt="license" src="https://img.shields.io/github/license/GitHub-Coder-xu/codex-superpower-quick-confirm?label=license&labelColor=000000&color=111111"></a>
</p>

<p align="center">
  <a href="https://deepwiki.com/GitHub-Coder-xu/codex-superpower-quick-confirm"><img alt="Ask DeepWiki" src="https://deepwiki.com/badge.svg"></a>
</p>

<p align="center">
  <a href="../README.md">English</a> | <a href="./README.zh-CN.md">简体中文</a>
</p>

这是一个 Windows 桌面小工具，适合搭配 Codex 桌面应用和 Superpowers 工作流使用。它把常见确认语放到一个置顶小窗口里，点击按钮后自动把对应内容粘贴到 Codex 输入框并发送。

## 用途

在使用 Codex 和 Superpowers 流程时，经常会遇到很短的人工确认输入，例如：

- 确认计划
- 继续执行
- 回答是/否
- 选择 1/2/3/4
- 选择 A/B/C/D

这个工具的目标是减少重复输入，同时保留人工确认动作。

## 默认短语

第一版包含以下固定按钮：

```text
确认  继续  是  否
1     2     3   4
A     B     C   D
```

## 启动

```powershell
git clone https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm.git
cd codex-superpower-quick-confirm
.\scripts\start.ps1
```

如果 PowerShell 执行策略拦截，可以使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start.ps1
```

## 使用方式

1. 打开 Codex 桌面应用。
2. 先点击 Codex 输入框，让输入框获得焦点。
3. 点击本工具里的常用语按钮。
4. 工具会粘贴对应内容并自动发送 Enter。

## 窗口控制

- `最小化`：把工具窗口最小化到任务栏。
- `取消置顶`：关闭窗口置顶。
- `恢复置顶`：重新让窗口保持置顶。

## 工作方式

工具会记录最近一个非自身窗口作为目标窗口。点击按钮时，它会重新激活目标窗口，把短语临时写入剪贴板，发送 `Ctrl+V` 和 Enter，然后尽量恢复原来的剪贴板内容。

## 验证

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\smoke.ps1
```

GUI 启动自测：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start.ps1 -SelfTest
```

看到 `Self-test window shown.` 即表示窗口可以正常创建并关闭。

