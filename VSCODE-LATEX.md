# Editing the books in VS Code

The complete installation, build, navigation and troubleshooting guide lives in
[`.latex-setup/README.md`](.latex-setup/README.md).

1. Open **UTP-TA-LABS** as the VS Code workspace.
2. Open the course's `main.tex`, build with **Ctrl+Alt+B**, and preview with **Ctrl+Alt+V**.
3. Edit a chapter or lab and press **Ctrl+S**. The PDF refreshes after compilation.
4. **Double-click PDF text** to jump to source; **Ctrl+Alt+J** goes from source to PDF.

Use **Ctrl+Shift+B** to choose a course explicitly. Use **Tasks: Run Task** for
**LaTeX: check local setup** or **LaTeX: build all courses**.

The default recipe checks references and contents. The optional one-pass preview
recipe may leave them stale: see the complete guide before using it. Neither
recipe provides instantaneous typesetting. Auto-save remains off for LaTeX;
`onFileChange` reacts to saved changes, including Ctrl+S and external edits.

Local output is in `.build/<COURSE>/main.pdf`; published PDFs remain separate.
