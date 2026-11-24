#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\lib\pixel-profiles.ahk
CoordMode 'Pixel', 'Client'
passed := 0
skipped := []
canvas := 0
appPid := 0
report := A_ScriptDir '\test-report.md'
if FileExist(report)
    FileDelete report
try {
    for size in [[1280,720], [1920,1080], [2560,1080]] {
        w := size[1], h := size[2], profiles := BuildProfiles(w,h)
        for name in ['primary','secondary','play','stop','option'] {
            for p in profiles.%name%
                Check(p[1] >= 0 && p[1] < w && p[2] >= 0 && p[2] < h, 'geometry ' w 'x' h ' ' name)
        }
        if w > A_ScreenWidth || h > A_ScreenHeight {
            skipped.Push(w 'x' h ' real pixels (desktop is ' A_ScreenWidth 'x' A_ScreenHeight '); geometry checked')
            continue
        }
        for scenario in ['none','primary','play','stop','option','manual','secondary'] {
            canvas := Gui('+AlwaysOnTop -Caption -DPIScale', 'ClickBotz pixel test')
            canvas.BackColor := '000000'
            if scenario = 'primary' || scenario = 'play' || scenario = 'stop'
                Paint(canvas, profiles.primary)
            if scenario = 'play' || scenario = 'stop'
                Paint(canvas, profiles.%scenario%)
            if scenario = 'option' || scenario = 'manual'
                Paint(canvas, profiles.option)
            if scenario = 'secondary'
                Paint(canvas, profiles.secondary)
            canvas.Show('x0 y0 w' w ' h' h)
            WinActivate('ahk_id ' canvas.Hwnd)
            WinWaitActive('ahk_id ' canvas.Hwnd,,3)
            Sleep 150
            actual := ChooseAction(profiles, scenario = 'manual')
            expected := scenario = 'play' || scenario = 'stop' ? 'space' : scenario = 'option' ? 'option' : scenario = 'primary' || scenario = 'secondary' ? 'click' : 'none'
            Check(actual.kind = expected, w 'x' h ' ' scenario ': expected ' expected ', got ' actual.kind)
            canvas.Destroy()
            canvas := 0
        }
    }
    Run '"' A_AhkPath '" /ErrorStdOut "' A_ScriptDir '\..\clickbotz.ahk"', A_ScriptDir '\..',, &appPid
    hwnd := WinWait('ClickBotz — Genshin Dialogue Assistant ahk_pid ' appPid,,10)
    Check(!!hwnd, 'app startup window')
    WinActivate('ahk_id ' hwnd)
    WinWaitActive('ahk_id ' hwnd,,3)
    SendEvent '{F10}'
    Sleep 600
    controls := WinGetText('ahk_id ' hwnd)
    Check(InStr(controls, 'Dừng (F10)') > 0, 'F10 enables')
    Check(InStr(controls, 'Đang chờ GenshinImpact.exe / YuanShen.exe') > 0, 'no-game waiting status')
    Check(InStr(controls, 'Đã gửi: 0') > 0, 'no-game sends no actions')
    SendEvent '{F10}'
    Sleep 300
    Check(InStr(WinGetText('ahk_id ' hwnd), 'Bắt đầu (F10)') > 0, 'F10 disables')
    FileAppend '# ClickBotz test report`n`nPASS: ' passed ' assertions. Real GUI pixels use production BuildProfiles, MatchPixels/PixelSearch and ChooseAction. Covered none, primary click, play/stop Space, option, manual option suppression, secondary fallback at each desktop-supported size. Source app starts; F10 toggles; absent game waits and sends zero actions.`n`n', report, 'UTF-8'
    for item in skipped
        FileAppend '- Skipped: ' item '.`n', report, 'UTF-8'
    FileAppend '`nOriginal executable was not executed. Only owned test windows/processes were created and cleaned up. No live game integration test performed.`n', report, 'UTF-8'
    FileAppend 'PASS ' passed ' assertions`n', '*'
} catch as err {
    FileAppend 'FAIL: ' err.Message '`n', '*'
    FileAppend '# ClickBotz test report`n`nFAIL: ' err.Message '`n', report, 'UTF-8'
    ExitApp 1
} finally {
    if IsObject(canvas)
        canvas.Destroy()
    if appPid && ProcessExist(appPid)
        ProcessClose appPid
}
ExitApp 0

Paint(g, profile) {
    for p in profile
        g.AddText('x' Round(p[1]) ' y' Round(p[2]) ' w1 h1 Background' Format('{:06X}',p[3]), '')
}
Check(ok, label) {
    global passed
    if !ok
        throw Error(label)
    passed += 1
}
