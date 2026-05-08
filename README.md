<h1 align="center">Codex Superpower Quick Confirm</h1>

<p align="center">
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/GitHub-Coder-xu/codex-superpower-quick-confirm?include_prereleases&label=release&labelColor=000000&color=2f80ed"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/graphs/contributors"><img alt="contributors" src="https://img.shields.io/github/contributors/GitHub-Coder-xu/codex-superpower-quick-confirm?label=contributors&labelColor=000000&color=a3e635"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/network/members"><img alt="forks" src="https://img.shields.io/github/forks/GitHub-Coder-xu/codex-superpower-quick-confirm?label=forks&labelColor=000000&color=67e8f9"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/stargazers"><img alt="stars" src="https://img.shields.io/github/stars/GitHub-Coder-xu/codex-superpower-quick-confirm?label=stars&labelColor=000000&color=facc15"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/issues"><img alt="issues" src="https://img.shields.io/github/issues/GitHub-Coder-xu/codex-superpower-quick-confirm?label=issues&labelColor=000000&color=f472b6"></a>
  <a href="https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm/blob/main/LICENSE"><img alt="license" src="https://img.shields.io/github/license/GitHub-Coder-xu/codex-superpower-quick-confirm?label=license&labelColor=000000&color=111111"></a>
  <img alt="platform" src="https://img.shields.io/badge/platform-Windows-0078D4?labelColor=000000">
  <img alt="runtime" src="https://img.shields.io/badge/runtime-PowerShell-5391FE?labelColor=000000">
</p>

<p align="center">
  <a href="./README.md">English</a> | <a href="./docs/README.zh-CN.md">简体中文</a>
</p>

A tiny Windows desktop helper for people who use Codex Desktop with Superpowers-style workflows and want one-click replies for frequent confirmation prompts.

It keeps a compact always-on-top panel beside Codex. Click a phrase such as `Confirm`, `Continue`, `Yes`, `No`, `1`, `2`, `A`, or `B`, and the app pastes the matching text into the previously focused Codex input box and submits it with Enter.

English is the default documentation language. Use the language switcher above for Simplified Chinese.

## Why

Codex Desktop and Superpowers workflows often pause for short human confirmations:

- confirm a proposed plan
- continue to the next implementation step
- choose option `1`, `2`, `3`, or `4`
- choose option `A`, `B`, `C`, or `D`
- answer yes/no quickly

This tool removes repeated typing while keeping the human decision explicit.

## Features

- One-click quick replies for common Codex prompts.
- Clipboard paste for reliable Chinese and ASCII text input.
- Automatic Enter after each phrase.
- Always-on-top window by default.
- Title-bar controls for `Minimize` and topmost on/off beside `Close`.
- No installer, no background service, no network access.

## Phrase Set

The first release includes these fixed phrases:

| Row | Buttons |
| --- | --- |
| 1 | 确认, 继续, 是, 否 |
| 2 | 1, 2, 3, 4 |
| 3 | A, B, C, D |

## Requirements

- Windows
- Windows PowerShell 5.1 or later
- A target input box that accepts normal paste and Enter keyboard events

## Quick Start

Clone the repository and start the helper:

```powershell
git clone https://github.com/GitHub-Coder-xu/codex-superpower-quick-confirm.git
cd codex-superpower-quick-confirm
.\scripts\start.ps1
```

If PowerShell execution policy blocks the script, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start.ps1
```

## Usage

1. Open Codex Desktop.
2. Focus the Codex input box.
3. Click one of the quick-confirm buttons.
4. The helper pastes the phrase and sends Enter.

Use the buttons beside `Close` to minimize the window or toggle topmost mode. Turning topmost off allows other windows to cover the helper; the same button restores topmost mode when needed.

## How It Works

The app tracks the last foreground window that is not the helper itself. When you click a phrase button, it reactivates that target window, temporarily places the phrase on the clipboard, sends `Ctrl+V`, sends Enter, and then restores the previous clipboard data when possible.

## Test

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\smoke.ps1
```

For a GUI startup smoke test:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start.ps1 -SelfTest
```

Expected output:

```text
Self-test window shown.
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=GitHub-Coder-xu/codex-superpower-quick-confirm&type=Date)](https://www.star-history.com/#GitHub-Coder-xu/codex-superpower-quick-confirm&Date)

## Release

Current release: `0.0.1`

## License

MIT


