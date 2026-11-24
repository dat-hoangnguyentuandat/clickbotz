ToggleMacro(*) {
    if App.running {
        StopMacro('Đã dừng')
        return
    }
    if App.picking
        return
    try {
        if !App.steps.Length
            throw ValueError('Thêm ít nhất một bước trước khi chạy.')
        App.duration := ParseNumber(DurationInput.Value, 0.1, 86400, 'Thời lượng (giây)')
        App.gap := Integer(ParseNumber(GapInput.Value, 20, 3600000, 'Nghỉ giữa vòng (ms)'))
        for step in App.steps
            ValidateStep(step)
        App.generation += 1
        App.running := true, App.index := 1, App.cycles := 0
        App.phase := 'countdown', App.due := A_TickCount + 3000
        StartButton.Text := 'Dừng (F10)'
        SetStatus('Bắt đầu sau 3 giây — chuyển sang cửa sổ đích. F9 để dừng.')
        SetTimer MacroTick, 15
    } catch as err
        MsgBox err.Message, 'Chưa thể chạy', 'Icon!'
}
StopMacro(message := 'Đã dừng', *) {
    App.generation += 1
    App.running := false
    SetTimer MacroTick, 0
    ToolTip()
    StartButton.Text := 'Chạy (F10)'
    SetStatus(message)
}
MacroTick() {
    if App.busy || !App.running
        return
    App.busy := true
    generation := App.generation
    try {
        now := A_TickCount
        if App.phase = 'countdown' {
            if now < App.due
                return
            App.end := now + Round(App.duration * 1000)
            App.phase := 'ready'
        }
        if now >= App.end {
            StopMacro('Đủ thời lượng — hoàn tất ' App.cycles ' vòng')
            return
        }
        if App.phase = 'delay' || App.phase = 'gap' {
            if now < App.due
                return
            App.phase := 'ready'
        }
        step := App.steps[App.index]
        SetStatus('Bước ' App.index '/' App.steps.Length ' • Vòng ' (App.cycles + 1)
            ' • Còn ' Ceil((App.end-now)/1000) ' giây • F9 dừng')
        if App.phase = 'ready' {
            if step.kind >= 5 {
                App.phase := 'color', App.due := now + step.timeout
            } else {
                if step.kind <= 2
                    MacroClick(step)
                else if step.kind = 3 && App.running
                    SendEvent KeySequence(step.key)
                AdvanceMacro(A_TickCount + step.delay, generation)
                return
            }
        }
        if App.phase = 'color' {
            if now >= App.due {
                StopMacro('Timeout chờ màu ở bước ' App.index)
                return
            }
            actual := PixelGetColor(step.x, step.y)
            if ColorMatches(actual, Integer('0x' step.color), step.tolerance) {
                if step.kind = 6
                    MacroClick(step)
                AdvanceMacro(A_TickCount + step.delay, generation)
            }
        }
    } catch as err {
        if App.generation = generation
            StopMacro('Lỗi bước ' App.index ': ' err.Message)
    } finally {
        App.busy := false
    }
}
MacroClick(step) {
    if !App.running || A_TickCount >= App.end
        return
    MouseGetPos &savedX, &savedY
    try {
        MouseClick step.kind = 2 ? 'Right' : 'Left', step.x, step.y, 1, 0
    } finally {
        MouseMove savedX, savedY, 0
    }
}
AdvanceMacro(due, generation) {
    ; A hotkey can stop/restart while SendEvent yields; old ticks cannot update a new run.
    if !App.running || generation != App.generation
        return
    App.index += 1
    if App.index > App.steps.Length {
        App.index := 1, App.cycles += 1
        App.phase := 'gap', App.due := due + App.gap
    } else {
        App.phase := 'delay', App.due := due
    }
}
