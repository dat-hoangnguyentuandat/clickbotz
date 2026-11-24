Editable() {
    if App.running || App.picking {
        SetStatus('Dừng macro / hoàn tất Setup trước khi chỉnh sửa.')
        return false
    }
    return true
}
ReadEditor() {
    return ValidateStep({kind: KindInput.Value, x: XInput.Value, y: YInput.Value,
        color: Trim(ColorInput.Value), key: Trim(KeyInput.Value), delay: DelayInput.Value,
        tolerance: ToleranceInput.Value, timeout: TimeoutInput.Value})
}
AddStep(*) {
    if !Editable()
        return
    try {
        if App.steps.Length >= 500
            throw ValueError('Tối đa 500 bước.')
        App.steps.Push(ReadEditor())
        RefreshSteps(App.steps.Length)
    } catch as err
        MsgBox err.Message, 'Bước không hợp lệ', 'Icon!'
}
EditStep(*) {
    if !Editable() || !(row := StepList.GetNext())
        return
    try {
        App.steps[row] := ReadEditor()
        RefreshSteps(row)
    } catch as err
        MsgBox err.Message, 'Bước không hợp lệ', 'Icon!'
}
DeleteStep(*) {
    if !Editable() || !(row := StepList.GetNext())
        return
    App.steps.RemoveAt(row)
    RefreshSteps(Min(row, App.steps.Length))
}
MoveStep(direction) {
    if !Editable() || !(row := StepList.GetNext())
        return
    target := row + direction
    if target < 1 || target > App.steps.Length
        return
    step := App.steps.RemoveAt(row)
    App.steps.InsertAt(target, step)
    RefreshSteps(target)
}
RefreshSteps(selected := 0) {
    StepList.Delete()
    for i, step in App.steps
        StepList.Add('', i, StepKinds[step.kind], step.x, step.y,
            step.kind = 3 ? step.key : '#' step.color, step.delay)
    if selected
        StepList.Modify(selected, 'Select Focus Vis')
}
SelectStep(control, row, selected) {
    if !selected || !row || App.running || App.picking
        return
    step := App.steps[row]
    KindInput.Value := step.kind
    XInput.Value := step.x, YInput.Value := step.y
    ColorInput.Value := step.color, KeyInput.Value := step.key
    DelayInput.Value := step.delay, ToleranceInput.Value := step.tolerance
    TimeoutInput.Value := step.timeout
}
BeginCapture(*) {
    if !Editable()
        return
    App.picking := true
    MainWindow.Hide()
    SetTimer PreviewPixel, 50
}
PreviewPixel() {
    if !App.picking
        return
    try {
        MouseGetPos &x, &y
        color := PixelGetColor(x, y)
        ToolTip('SETUP  X: ' x '  Y: ' y '  #' Format('{:06X}', color) '`nF8: lấy điểm / Esc: hủy')
    }
}
CapturePixel() {
    if !App.picking
        return
    try {
        ToolTip()
        MouseGetPos &x, &y
        color := PixelGetColor(x, y)
        XInput.Value := x, YInput.Value := y
        ColorInput.Value := Format('{:06X}', color)
        CancelCapture()
        SetStatus('Đã lấy (' x ', ' y ') #' Format('{:06X}', color) '. Bấm Thêm bước / Cập nhật bước.')
    } catch as err {
        CancelCapture()
        SetStatus('Không lấy được màu: ' err.Message)
    }
}
CancelCapture() {
    App.picking := false
    SetTimer PreviewPixel, 0
    ToolTip()
    MainWindow.Show()
}
