# Changelog

All notable changes to **TogglePin** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com),
and this project adheres to [Semantic Versioning](https://semver.org).

## [Unreleased]

## v1.0.0 - 2026-11-23
### Added
- Initial release of `TogglePin.bat` and `TogglePin.ps1`.
- Click-to-target window selection using cursor hit-testing (`WindowFromPoint` and `GetAncestor` with `GA_ROOT`).
- Automatic toggle between `HWND_TOPMOST` (`-1`) and `HWND_NOTOPMOST` (`-2`) via `SetWindowPos`.
- Edge-triggered mouse button detection (`GetAsyncKeyState`) to prevent accidental double-click misfires.
- Console self-exclusion via `GetConsoleWindow()` and desktop/taskbar shell filtering (`Progman`, `WorkerW`, `Shell_TrayWnd`, `Shell_SecondaryTrayWnd`).
- Post-operation verification of `WS_EX_TOPMOST` (`0x8`) via `GetWindowLongPtrW` / `GetWindowLongW` for 64-bit and 32-bit compatibility.
- Esc-key cancellation and explicit Win32 error reporting.
