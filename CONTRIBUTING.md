# Contributing to ImGui Menu Clone

Thank you for your interest in contributing! Whether you're adding new custom widget recipes, submitting a theme preset measured from a real menu, or improving AI assistant instructions, your contributions are welcome.

## Ways to Contribute

1. **Add Custom Widgets**: Write new recipes in `references/widget-cookbook.md` or add ready-to-use widgets to `assets/template/ui/widgets.*`.
2. **Add Theme Presets**: Measure real screenshots using `scripts/extract_palette.py` and submit a new header in `assets/template/ui/themes/`.
3. **Enhance Assistant Guides**: Improve prompt templates and rules for Antigravity, Claude, Cursor, Windsurf, or OpenCode.
4. **Fix Bugs**: Improve script cross-platform compatibility, encoding, or MSBuild detection.

## Guidelines

* **Clean Code**: Follow modern C++17 conventions.
* **No Hardcoded Colors in Widgets**: Always route colors and dimensions through `ui::Theme` in `theme.h`.
* **State Management**: Key animation states by `ImGuiID` using `ui::GetAnim(id)`.
* **ASCII-safe Scripts**: Keep PowerShell `.ps1` files ASCII-compatible for default Windows environments.

## Submitting Pull Requests

1. Fork the repository.
2. Create a descriptive branch: `git checkout -b feature/my-new-widget`.
3. Test your changes locally:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap_project.ps1 -Path "D:\TestMenu" -Build
   ```
4. Commit and push your changes.
5. Open a Pull Request on GitHub!
