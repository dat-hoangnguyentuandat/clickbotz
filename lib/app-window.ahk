BuildWindow() {
    global MainWindow, StepList, KindInput, XInput, YInput, ColorInput, KeyInput
    global DelayInput, ToleranceInput, TimeoutInput, DurationInput, GapInput, StartButton, StatusText
    MainWindow := Gui(, 'ClickBotz — Custom Macro')
    MainWindow.SetFont('s10', 'Segoe UI')
    MainWindow.MarginX := 18, MainWindow.MarginY := 14
    MainWindow.AddText('xm w800', 'CLICKBOTZ  •  Macro click / phím / màu màn hình')
    MainWindow.AddText('xm y+8 w800', 'Setup → trỏ chuột vào điểm cần lấy → F8 lưu vị trí + màu; Esc hủy.')
    StepList := MainWindow.AddListView('xm y+12 w800 r9 Grid -Multi', ['#','Thao tác','X','Y','Màu / Phím','Chờ sau (ms)'])
    StepList.OnEvent('ItemSelect', SelectStep)
    for col, width in [36,200,70,70,180,130]
        StepList.ModifyCol(col, width)
    MainWindow.AddText('xm y+14', 'Loại bước')
    KindInput := MainWindow.AddDropDownList('x+10 yp-3 w220 Choose1', StepKinds)
    MainWindow.AddButton('x+14 w220', 'Setup: lấy vị trí + màu (F8)').OnEvent('Click', BeginCapture)
    MainWindow.AddText('xm y+15', 'X')
    XInput := MainWindow.AddEdit('x+8 yp-3 w90', '0')
    MainWindow.AddText('x+12 yp+3', 'Y')
    YInput := MainWindow.AddEdit('x+8 yp-3 w90', '0')
    MainWindow.AddText('x+14 yp+3', 'Màu HEX')
    ColorInput := MainWindow.AddEdit('x+8 yp-3 w100', 'FFFFFF')
    MainWindow.AddText('x+14 yp+3', 'Sai số 0–255')
    ToleranceInput := MainWindow.AddEdit('x+8 yp-3 w60', '10')
    MainWindow.AddText('xm y+15', 'Phím (Enter, Space, ^a)')
    KeyInput := MainWindow.AddEdit('x+8 yp-3 w100', 'Enter')
    MainWindow.AddText('x+14 yp+3', 'Chờ sau / Chờ (ms)')
    DelayInput := MainWindow.AddEdit('x+8 yp-3 w80', '300')
    MainWindow.AddText('x+14 yp+3', 'Timeout màu (ms)')
    TimeoutInput := MainWindow.AddEdit('x+8 yp-3 w85', '10000')
    MainWindow.AddButton('xm y+15 w115', 'Thêm bước').OnEvent('Click', AddStep)
    MainWindow.AddButton('x+8 w115', 'Cập nhật bước').OnEvent('Click', EditStep)
    MainWindow.AddButton('x+8 w95', 'Xóa bước').OnEvent('Click', DeleteStep)
    MainWindow.AddButton('x+8 w95', 'Lên').OnEvent('Click', (*) => MoveStep(-1))
    MainWindow.AddButton('x+8 w95', 'Xuống').OnEvent('Click', (*) => MoveStep(1))
    MainWindow.AddText('xm y+20', 'Lặp trong (giây)')
    DurationInput := MainWindow.AddEdit('x+8 yp-3 w85', App.duration)
    MainWindow.AddText('x+16 yp+3', 'Nghỉ giữa vòng (ms)')
    GapInput := MainWindow.AddEdit('x+8 yp-3 w85', App.gap)
    MainWindow.AddButton('xm y+15 w120', 'Lưu macro').OnEvent('Click', SaveMacro)
    MainWindow.AddButton('x+8 w120', 'Nạp lại').OnEvent('Click', ReloadMacro)
    StartButton := MainWindow.AddButton('x+16 w150', 'Chạy (F10)')
    StartButton.OnEvent('Click', ToggleMacro)
    MainWindow.AddButton('x+8 w120', 'Dừng (F9)').OnEvent('Click', (*) => StopMacro())
    StatusText := MainWindow.AddText('xm y+16 w800 h45', 'Chưa có bước. Setup lấy điểm, rồi bấm Thêm bước.')
    MainWindow.AddText('xm y+6 w800', 'Tọa độ màn hình tuyệt đối • Chạy sau 3 giây • Macro thao tác trên cửa sổ đang mở.')
    MainWindow.OnEvent('Close', CloseWindow)
    A_TrayMenu.Delete()
    A_TrayMenu.Add('Mở ClickBotz', (*) => MainWindow.Show())
    A_TrayMenu.Add('Dừng macro (F9)', (*) => StopMacro())
    A_TrayMenu.Add('Thoát', (*) => ExitApp())
    A_TrayMenu.Default := 'Mở ClickBotz'
    MainWindow.Show()
}
SetStatus(message) {
    StatusText.Text := message
}
CloseWindow(*) {
    if App.picking
        CancelCapture()
    StopMacro('Đã dừng và thu xuống khay')
    MainWindow.Hide()
}
