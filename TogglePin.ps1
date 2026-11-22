$ErrorActionPreference = 'Stop'

try {
    $code = @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public class Win {
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT { public int X; public int Y; }

    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT lpPoint);
    [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(POINT Point);
    [DllImport("user32.dll")] public static extern IntPtr GetAncestor(IntPtr hwnd, uint gaFlags);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hwnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int c);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int c);
    [DllImport("user32.dll", EntryPoint = "GetWindowLongPtrW")] private static extern IntPtr GetWindowLongPtr64(IntPtr h, int i);
    [DllImport("user32.dll", EntryPoint = "GetWindowLongW")] private static extern IntPtr GetWindowLong32(IntPtr h, int i);
    [DllImport("user32.dll", SetLastError = true)] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int cx, int cy, uint f);
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);

    public static IntPtr GetWindowLongPtr(IntPtr h, int i) {
        return IntPtr.Size == 8 ? GetWindowLongPtr64(h, i) : GetWindowLong32(h, i);
    }
}
'@

    Add-Type -TypeDefinition $code

    $selfConsole = [Win]::GetConsoleWindow()
    $ignoredClasses = @('Progman', 'WorkerW', 'Shell_TrayWnd', 'Shell_SecondaryTrayWnd')

    # Initialize button state to ignore the click/double-click that launched the script
    $wasDown = ([Win]::GetAsyncKeyState(0x01) -band 0x8000) -ne 0

    Write-Host "Click directly on an application window to PIN or UNPIN (Esc to cancel)..." -ForegroundColor Cyan

    while ($true) {
        if (([Win]::GetAsyncKeyState(0x1B) -band 0x8000) -ne 0) {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }

        $isDown = ([Win]::GetAsyncKeyState(0x01) -band 0x8000) -ne 0

        if ($isDown -and -not $wasDown) {
            $pt = New-Object Win+POINT
            if ([Win]::GetCursorPos([ref]$pt)) {
                $child = [Win]::WindowFromPoint($pt)
                $hwnd = [Win]::GetAncestor($child, 2) # GA_ROOT = 2

                if ($hwnd -ne [IntPtr]::Zero -and $hwnd -ne $selfConsole -and [Win]::IsWindow($hwnd) -and [Win]::IsWindowVisible($hwnd)) {
                    $clsSb = New-Object System.Text.StringBuilder 256
                    [void][Win]::GetClassName($hwnd, $clsSb, 256)
                    $cls = $clsSb.ToString()

                    $titleSb = New-Object System.Text.StringBuilder 256
                    [void][Win]::GetWindowText($hwnd, $titleSb, 256)
                    $title = $titleSb.ToString()

                    if ($cls -notin $ignoredClasses -and -not [string]::IsNullOrWhiteSpace($title)) {
                        break
                    } else {
                        Write-Host "Ignored non-application surface ($cls). Click an application window..." -ForegroundColor DarkYellow
                    }
                }
            }
        }

        $wasDown = $isDown
        Start-Sleep -Milliseconds 15
    }

    # Re-verify window validity immediately before reading/modifying state
    if (-not [Win]::IsWindow($hwnd)) {
        throw "The selected window closed before its state could be updated."
    }

    $exStyle = [Win]::GetWindowLongPtr($hwnd, -20).ToInt64()
    $wasTop = ($exStyle -band 0x8) -ne 0
    $wantTop = -not $wasTop
    $target = if ($wantTop) { [IntPtr](-1) } else { [IntPtr](-2) }

    # 0x0013 = SWP_NOSIZE (0x0001) | SWP_NOMOVE (0x0002) | SWP_NOACTIVATE (0x0010)
    $ok = [Win]::SetWindowPos($hwnd, $target, 0, 0, 0, 0, 0x0013)

    if (-not $ok) {
        $winErr = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "SetWindowPos failed on '$title' (Win32 Error $winErr)."
    }

    # Re-verify that the WS_EX_TOPMOST bit actually matches the requested state
    if (-not [Win]::IsWindow($hwnd)) {
        throw "The window closed immediately after SetWindowPos was called."
    }

    $newExStyle = [Win]::GetWindowLongPtr($hwnd, -20).ToInt64()
    $isNowTop = ($newExStyle -band 0x8) -ne 0

    if ($isNowTop -ne $wantTop) {
        throw "SetWindowPos returned success, but '$title' did not retain the requested topmost state."
    }

    $state = if ($isNowTop) { "PINNED ON TOP" } else { "UNPINNED" }
    Write-Host "Success: '$title' is now $state." -ForegroundColor Green
    Start-Sleep -Seconds 2
    exit 0
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
