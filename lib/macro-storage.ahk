SaveMacro(*) {
    if !Editable()
        return
    temp := MacroPath '.tmp'
    try {
        duration := ParseNumber(DurationInput.Value, 0.1, 86400, 'Thời lượng (giây)')
        gap := Integer(ParseNumber(GapInput.Value, 20, 3600000, 'Nghỉ giữa vòng (ms)'))
        if FileExist(temp)
            FileDelete temp
        IniWrite duration, temp, 'Macro', 'Duration'
        IniWrite gap, temp, 'Macro', 'Gap'
        IniWrite App.steps.Length, temp, 'Macro', 'Count'
        for i, step in App.steps {
            ValidateStep(step)
            for field in ['kind','x','y','color','key','delay','tolerance','timeout']
                IniWrite step.%field%, temp, 'Step' i, field
        }
        FileMove temp, MacroPath, true
        App.duration := duration, App.gap := gap
        SetStatus('Đã lưu macro.ini — ' App.steps.Length ' bước')
    } catch as err
        MsgBox err.Message, 'Không lưu được macro', 'Icon!'
}
LoadMacro(*) {
    if !Editable() || !FileExist(MacroPath)
        return
    steps := []
    count := Integer(ParseNumber(IniRead(MacroPath, 'Macro', 'Count'), 0, 500, 'Số bước'))
    duration := ParseNumber(IniRead(MacroPath, 'Macro', 'Duration'), 0.1, 86400, 'Thời lượng')
    gap := Integer(ParseNumber(IniRead(MacroPath, 'Macro', 'Gap'), 20, 3600000, 'Nghỉ giữa vòng'))
    Loop count {
        step := {}
        section := 'Step' A_Index
        for field in ['kind','x','y','color','key','delay','tolerance','timeout']
            step.%field% := IniRead(MacroPath, section, field)
        step.kind := Integer(step.kind)
        steps.Push(ValidateStep(step))
    }
    App.steps := steps, App.duration := duration, App.gap := gap
    DurationInput.Value := duration, GapInput.Value := gap
    RefreshSteps()
    SetStatus('Đã nạp ' count ' bước từ macro.ini')
}
ReloadMacro(*) {
    try LoadMacro()
    catch as err
        MsgBox err.Message, 'Không nạp được macro', 'Icon!'
}
