# TogglePin

[![Latest Release](https://img.shields.io/github/v/release/simulator7/TogglePin)](https://github.com/simulator7/TogglePin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight, zero-install Windows utility to toggle any application window **Always on Top** with a single click—using only built-in PowerShell and Win32 APIs.

## Features
- **Zero Dependencies:** Works natively on Windows 10 and Windows 11 without installing third-party tools or heavy suites.
- **Click-to-Target Selection:** Click directly on any application window to pin or unpin it (press **Esc** to cancel).
- **Smart Toggle:** Automatically detects whether a window is already pinned (`WS_EX_TOPMOST`) and toggles between **Pinned on Top** and **Unpinned**.
- **Safe & Reliable:**
  - Excludes its own console window via `GetConsoleWindow()`.
  - Ignores desktop and taskbar shell surfaces (`Progman`, `WorkerW`, `Shell_TrayWnd`).
  - Edge-triggered mouse detection prevents accidental double-click triggers.
  - Verifies the window's extended style after calling `SetWindowPos()` to confirm the change succeeded.
  - Compatible with both 64-bit and 32-bit Windows.

## Installation
1. Download **`TogglePin.bat`** and **`TogglePin.ps1`** (or download the repository as a ZIP via **Code → Download ZIP** and extract it).
2. Keep both files together in the **same folder** (e.g., on your Desktop or in a `Tools` folder).

## Usage
1. Double-click **`TogglePin.bat`**.
2. Click directly anywhere inside the application window you want to keep on top (or press **Esc** to cancel).
3. To unpin the window later, double-click **`TogglePin.bat`** again and click the same window.

### Optional: Assign a Keyboard Shortcut
1. Right-click **`TogglePin.bat`** → **Send to → Desktop (create shortcut)**.
2. Right-click the new shortcut → **Properties**.
3. Click the **Shortcut key** field, press your preferred combination (e.g., `Ctrl + Alt + P`), and click **OK**.

## How It Works
- **`TogglePin.bat`** launches `TogglePin.ps1` with `-NoProfile -ExecutionPolicy Bypass` for that single invocation without altering your system's global PowerShell execution policy.
- **`TogglePin.ps1`** captures the cursor position on a fresh left-button press (`GetAsyncKeyState`), resolves the top-level application window (`WindowFromPoint` + `GetAncestor` with `GA_ROOT`), and toggles `HWND_TOPMOST` (`-1`) / `HWND_NOTOPMOST` (`-2`) via `SetWindowPos`.

## Limitations
- Windows security restrictions (UIPI) prevent standard-privilege processes from modifying the z-order of windows running as **Administrator** (such as Task Manager).

## Contributing
Suggestions and improvements are welcome! Feel free to open an **Issue** or submit a **Pull Request**.

## Acknowledgments
Developed with coding and debugging assistance from **Google AI Mode**, with code review and Win32 API edge-case verification by **OpenAI ChatGPT** (free tier, standard non-thinking model).

## License
This project is licensed under the [MIT License](LICENSE).
