FindGame() {
    ; Prefer the active supported window if more than one client exists.
    for exe in ['GenshinImpact.exe', 'YuanShen.exe'] {
        if hwnd := WinActive('ahk_exe ' exe)
            return hwnd
    }
    for exe in ['GenshinImpact.exe', 'YuanShen.exe'] {
        if hwnd := WinExist('ahk_exe ' exe)
            return hwnd
    }
    return 0
}

CanAct(hwnd) {
    return App.enabled && hwnd && WinActive('ahk_id ' hwnd) && !GetKeyState('Alt', 'P')
}

Tick() {
    if App.busy
        return
    App.busy := true
    try {
        ToolTip()
        if !App.enabled {
            UpdateStatus('Đã dừng')
            return
        }
        hwnd := FindGame()
        App.target := hwnd
        if !hwnd {
            UpdateStatus('Đang chờ GenshinImpact.exe / YuanShen.exe')
            return
        }
        if !WinActive('ahk_id ' hwnd) {
            UpdateStatus('Tạm nghỉ: game không ở phía trước')
            return
        }
        if GetKeyState('Alt', 'P') {
            UpdateStatus('Tạm nghỉ: đang giữ Alt')
            return
        }
        WinGetClientPos(, , &w, &h, 'ahk_id ' hwnd)
        if w < 1 || h < 1
            return
        profiles := BuildProfiles(w, h)
        action := ChooseAction(profiles, App.manual)
        if action.kind != 'none' && PerformAction(hwnd, action) {
            App.count += 1
            App.last := action.kind = 'space' ? 'Space' : action.kind = 'option' ? 'Chọn câu trả lời' : 'Tiếp hội thoại'
            CountText.Text := 'Đã gửi: ' App.count '   |   ' App.last
        }
        UpdateStatus('Đang dò hội thoại — ' w ' × ' h)
        if App.debug && CanAct(hwnd)
            ToolTip(action.kind = 'none' ? 'Chưa thấy mẫu pixel' : App.last)
    } catch as err {
        UpdateStatus('Không đọc được cửa sổ: ' err.Message)
    } finally {
        App.busy := false
    }
}

PerformAction(hwnd, action) {
    ; Keep the final guard adjacent to input, including physical Alt state.
    if !CanAct(hwnd)
        return false
    if action.kind = 'space' {
        SendEvent '{Space}'
        return true
    }
    ; Screen coordinates allow restoring the pointer even if focus changes.
    CoordMode 'Mouse', 'Screen'
    MouseGetPos &oldX, &oldY
    try {
        CoordMode 'Mouse', 'Client'
        if !CanAct(hwnd)
            return false
        Click action.x, action.y
    } finally {
        CoordMode 'Mouse', 'Screen'
        MouseMove oldX, oldY, 0
        CoordMode 'Mouse', 'Client'
    }
    return true
}
