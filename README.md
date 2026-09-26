# ImGui Menu Clone 🎨

> **Rebuild any Dear ImGui menu in clean C++ from a single screenshot.**  
> Give your AI assistant a screenshot of an ImGui menu. Get back a fully buildable, pixel-accurate native Visual Studio (`.sln`) C++ project. No access to the original source code needed.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://microsoft.com/windows)
[![Visual Studio](https://img.shields.io/badge/Visual%20Studio-2022%20%2F%202026-purple.svg)](https://visualstudio.microsoft.com/)
[![ImGui](https://img.shields.io/badge/Dear%20ImGui-v1.91.9b-orange.svg)](https://github.com/ocornut/imgui)

**Author:** [Sharim (GHX4T)](https://github.com/SharimAli)  
**License:** [MIT License](LICENSE)

---

## ⚡ Why This Skill Exists

Asking an AI to "rebuild this menu" from a picture usually yields an approximate "70% right" result: recognizable layout, but wrong paddings, inaccurate corner radii, guessed RGB values, and incorrect widget geometry.

This skill eliminates guessing through a **disciplined 5-phase pipeline**:

```
[ Screenshot ] ──▶ Phase 0: Bootstrap (.sln + Dear ImGui)
               ──▶ Phase 1: Analyse (Exact RGB palette + pixel measurements)
               ──▶ Phase 2: Checkpoint (User reviews & confirms spec.md)
               ──▶ Phase 3: Generate (Theme table + layout + custom widgets)
               ──▶ Phase 4: Compare (Build .exe ──▶ Screenshot ──▶ 4x Zoom Diff)
```

| Phase | What Happens |
| :--- | :--- |
| **0 · Project** | Bootstraps a clean Win32 + DirectX 11 + Dear ImGui native Visual Studio solution (`menu.sln`). |
| **1 · Analyse** | Python script extracts exact bit-for-bit RGB values and pixel bounds into `spec.md`. |
| **2 · Checkpoint** | AI pauses to verify `spec.md` with you before writing a line of C++. |
| **3 · Generate** | Writes theme variables, layout structure, and any custom widgets. |
| **4 · Compare** | Compiles `menu.exe` with MSBuild, captures the window, and runs 4x magnified side-by-side diffing against the reference. |

---

## 🚀 Integration Guide for Major AI Platforms

This repository is designed to work seamlessly across all major AI coding platforms. Follow the setup instructions below for your platform:

---

### 1. Claude Code (CLI)

Claude Code discovers skills placed in its local skills directory.

#### Install Path:
* **Windows**: `%USERPROFILE%\.claude\skills\imgui-menu-clone\`
* **macOS / Linux**: `~/.claude/skills/imgui-menu-clone/`

#### Installation:
```powershell
# Windows PowerShell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills"
Copy-Item -Recurse -Force "imgui-menu-clone" "$env:USERPROFILE\.claude\skills\imgui-menu-clone"
```

#### How to Use in Claude Code:
1. Start `claude` in your terminal.
2. Provide a screenshot path or paste an image:
   ```text
   Clone this menu screenshot into a Visual Studio project: path/to/menu_shot.png
   ```
3. Claude Code detects the skill via `SKILL.md` frontmatter and executes the workflow.

#### How to Uninstall:
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\imgui-menu-clone"
```

---

### 2. Claude Desktop (Anthropic Desktop App)

You can use this skill with Claude Desktop via **Claude Projects** or custom instructions:

#### Method A: Claude Projects (Recommended)
1. In Claude Desktop, click **Projects** in the sidebar and create a new project (e.g. `ImGui Menu Cloner`).
2. In **Project Knowledge**, upload the key skill files:
   * `SKILL.md`
   * `references/analysis-protocol.md`
   * `references/detail-checklist.md`
   * `references/widget-cookbook.md`
   * `references/animation.md`
   * `assets/template/ui/theme.h`
3. In **Custom Instructions for this Project**, paste:
   ```text
   You are an expert ImGui engineer. When given a menu screenshot, follow the 5-phase pipeline in SKILL.md.
   Never invent colors or metrics. First produce spec.md (Phase 1). Wait for confirmation (Phase 2).
   Then generate theme.h and widget code adhering to the Win32 + D3D11 menu.sln template.
   ```
4. Drag and drop your menu screenshot into chat and prompt:
   > *"Analyze this menu screenshot and generate the measured spec.md following our ImGui pipeline."*

#### Method B: Local Filesystem Integration
If using Claude Desktop with an MCP filesystem server, point Claude to this repository directory to read the reference guides and execute the analysis scripts.

---

### 3. Google Antigravity (AGY)

Antigravity provides native first-class support for modular skills.

#### Global Install (Available in all projects & conversations)
Run in PowerShell:
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.gemini\config\skills"
Copy-Item -Recurse -Force "imgui-menu-clone" "$env:USERPROFILE\.gemini\config\skills\imgui-menu-clone"
```

#### Workspace Install (Project-specific)
Place the folder in your project's agent directory:
```
<your-project-root>\.agents\skills\imgui-menu-clone\
```

#### How to Use in Antigravity:
1. Drag and drop or paste your menu screenshot into the chat canvas.
2. Ask: *"Clone this ImGui menu into a new .sln project"* or invoke the slash command:
   ```text
   /imgui-menu-clone
   ```
3. The agent activates [SKILL.md](SKILL.md) and executes the phases autonomously.

#### How to Uninstall:
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.gemini\config\skills\imgui-menu-clone"
```

---

### 4. Cursor

To integrate with Cursor Composer and Chat:

#### Setup via Cursor Rules:
Create a rule file in your workspace at `.cursor/rules/imgui-menu-clone.mdc` (or add to `.cursorrules`):

```markdown
---
description: Rebuild ImGui menus from screenshots into native Visual Studio solutions
globs: **/*
alwaysApply: false
---

When the user asks to clone or rebuild an ImGui menu from a screenshot:
1. Follow the guidelines in `references/analysis-protocol.md` to measure coordinates and colors.
2. Never invent colors: run `python scripts/extract_palette.py <image> --at X,Y` to get exact values.
3. Use the template in `assets/template/` (Win32 + D3D11 + menu.sln).
4. Run `powershell -ExecutionPolicy Bypass -File scripts/bootstrap_project.ps1 -Path <target-dir> -Build` to bootstrap.
5. Always separate theme colors into `ui/theme.h` without hardcoding color literals inside widget functions.
6. Verify geometry against `references/detail-checklist.md`.
```

#### How to Use in Cursor:
1. Attach your reference image to Cursor Composer (`Ctrl+I` / `Cmd+I`) or Chat (`Ctrl+L` / `Cmd+L`).
2. Type:
   ```text
   @imgui-menu-clone Rebuild this menu into a new Visual Studio C++ project
   ```

---

### 5. OpenCode Desktop & CLI

OpenCode supports custom modular skills, agent tools, and dedicated workspaces.

#### Global Install (OpenCode Desktop & CLI):
* **Windows**: `%USERPROFILE%\.opencode\skills\imgui-menu-clone\`
* **macOS / Linux**: `~/.config/opencode/skills/imgui-menu-clone/`

Run in PowerShell:
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.opencode\skills"
Copy-Item -Recurse -Force "imgui-menu-clone" "$env:USERPROFILE\.opencode\skills\imgui-menu-clone"
```

#### Workspace Install (Project-scoped):
Place the skill directly inside your repository:
```text
<your-project-root>\.opencode\skills\imgui-menu-clone\
```

#### How to Use in OpenCode Desktop:
1. Open the **OpenCode Desktop Application**.
2. Drag and drop your menu screenshot into the chat input or project workspace.
3. Prompt OpenCode:
   > *"Rebuild this ImGui menu into a native Visual Studio .sln project following the imgui-menu-clone pipeline."*
4. OpenCode detects the skill procedure from `SKILL.md`, measures the image into `spec.md`, and scaffolds the project.

#### How to Uninstall:
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.opencode\skills\imgui-menu-clone"
```

---

### 6. Windsurf, Roo Code & Cline

For AI developer environments using custom rules or instructions:

#### Windsurf (`.windsurfrules`)
Add the following snippet to your `.windsurfrules` file:
```text
When rebuilding ImGui menus from screenshots:
- Follow imgui-menu-clone pipeline: Image -> Measured spec -> Checkpoint -> C++ -> Visual Compare.
- Always probe colors using python scripts/extract_palette.py rather than guessing.
- Keep custom widgets in namespace ui (do not modify imgui_widgets.cpp).
- Build using MSBuild on menu.sln.
```

#### Cline & Roo Code (`.clinerules`)
Place this repository in your workspace or tools folder and add to `.clinerules`:
```markdown
# ImGui Menu Clone Workflow
Refer to `SKILL.md` and `references/` when asked to clone or design Dear ImGui interfaces.
Run `scripts/bootstrap_project.ps1 -Path <path> -Build` to scaffold a buildable C++ project.
```

---

## 🛠️ Requirements & Prerequisites

* **Operating System**: Windows 10 / 11
* **Compiler & Build Tools**: Visual Studio 2022 / 2026 (Community, Professional, or Enterprise) or Visual Studio Build Tools with the **Desktop development with C++** workload.
* **Git**: Used by `bootstrap_project.ps1` to clone a pinned version of Dear ImGui into `vendor/imgui`.
* **Python 3**: For running palette extraction and zoom-diff scripts.
  * *Note: The palette extractor has a built-in native PNG decoder. If you want to sample JPEG or WebP images, install Pillow: `pip install pillow`.*

---

## 📦 Project Structure

```text
imgui-menu-clone/
├── LICENSE                      # MIT License (Sharim (GHX4T))
├── SKILL.md                     # Core pipeline followed by AI agents
├── README.md                    # Multi-platform setup & usage guide
├── .gitignore                   # Ignores build artifacts and temporary files
├── assets/
│   └── template/                # Ready-to-build native Visual Studio project
│       ├── menu.sln             # Visual Studio Solution (x64 Debug / Release)
│       ├── menu.vcxproj         # C++17 Project (Win32, D3D11, dwmapi)
│       ├── menu.vcxproj.filters # Solution Explorer filter hierarchy
│       ├── main.cpp             # Host window + D3D11 bootstrap + layout
│       └── ui/
│           ├── theme.h          # Single source of truth for all colors & metrics
│           ├── widgets.h/.cpp   # Custom widgets (Toggle, Slider, Combo, etc.)
│           ├── anim.h/.cpp      # Frame-rate independent ImGuiID animations
│           ├── shell_win32.h/.cpp # Borderless layered window with DWM blur
│           └── themes/vision.h  # Worked real-world theme reference
├── references/
│   ├── analysis-protocol.md     # How a screenshot becomes a measured spec
│   ├── detail-checklist.md      # Checklist separating 70% clones from 100% clones
│   ├── widget-cookbook.md       # Recipes for custom controls not in ImGui core
│   ├── animation.md             # Easing curves, transitions, and timing
│   ├── icons.md                 # Icon fonts, glyph merging, and alignment
│   └── pitfalls.md              # Common traps and failure modes
└── scripts/
    ├── bootstrap_project.ps1    # Checks tools, clones ImGui, downloads fonts, builds .sln
    ├── extract_palette.py       # Reads bit-for-bit RGB values from reference pixels
    ├── capture_window.ps1       # Launches menu.exe, grabs screenshot, closes window
    └── crop_zoom.py             # Magnifies matched regions for pixel-level diffing
```

---

## 💡 Quick Manual Test

You can test the scaffolding script directly from PowerShell:

```powershell
# Bootstrap and build a test project into D:\TestMenu
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap_project.ps1 -Path "D:\TestMenu" -Build
```

Once built, open `D:\TestMenu\menu.sln` directly in Visual Studio 2022, press **F5**, and interact with the menu.

---

## 👤 Author

* **Sharim (GHX4T)** — [GitHub Profile](https://github.com/SharimAli)

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute for personal and commercial projects.
