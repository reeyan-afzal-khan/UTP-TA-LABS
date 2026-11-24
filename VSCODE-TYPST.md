# VS Code preview

Follow the [numbered setup steps](.typst-setup/README.md).

Open the repository root and install the recommended **Tinymist Typst** extension. Open a course's `main.typ`, pin it as the main file, and start Tinymist's preview; keep it pinned while you edit chapters. The preview refreshes when you save (**Ctrl+S**), because redrawing a 500-page book on every keystroke kept the preview busy. The preview is separate from the official CLI builds.

If the whole VS Code window keeps flashing blank, turn off VS Code's hardware acceleration: Command Palette → **Preferences: Configure Runtime Arguments** → `"disable-hardware-acceleration": true`, then quit and reopen VS Code. See the [setup guide](.typst-setup/README.md#live-preview).

If the preview does not start on Windows and the **Tinymist Typst** output panel is empty, Smart App Control is blocking Tinymist's unsigned `tinymist.exe`. Turn it off in **Windows Security → App & browser control → Smart App Control settings**, then run **Developer: Reload Window**. See the [setup guide](.typst-setup/README.md#live-preview).

Do not also run **Megamist Typst**: it recompiles on every keystroke, cannot resolve the books' imports, and makes the editor flicker. If you installed it from an earlier version of this guide, disable it for this workspace or uninstall it.

Press **Ctrl+Shift+B** to build a selected course. Use **Tasks: Run Task** for installation, checks, watching, and all-course builds.
