#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\lib\macro-model.ahk
#Include ..\lib\macro-storage.ahk
#Include ..\lib\macro-engine.ahk
#Include ..\lib\macro-editor.ahk
#Include ..\lib\app-window.ahk
CoordMode 'Mouse', 'Screen'
CoordMode 'Pixel', 'Screen'
SendMode 'Event'
SetKeyDelay 10,20
App := {steps: [], running: false, picking: false, index: 1, cycles: 0, busy: false, duration: 60, gap: 200, phase: '', due: 0, generation:0}
DirCreate A_ScriptDir '\results'
MacroPath := A_ScriptDir '\results\test-macro.ini'
passed := 0, events := [], target := 0
report := A_ScriptDir '\macro-test-report.md'
HotIfWinActive 'ClickBotz owned test target'
Hotkey 'F9', (*) => StopMacro('Đã dừng bằng F9')
HotIf
try {
    BuildWindow()
    Check(KindInput.Text = StepKinds[1], 'production window startup and StepKinds initialization')
    target := Gui('+AlwaysOnTop -DPIScale', 'ClickBotz owned test target')
    target.BackColor := '123456'
    a := target.AddButton('x20 y20 w100 h40', 'A')
    b := target.AddButton('x150 y20 w100 h40', 'B')
    a.OnEvent('Click', (*) => events.Push({name:'A', time:A_TickCount}))
    b.OnEvent('Click', (*) => events.Push({name:'B', time:A_TickCount}))
    targetEdit := target.AddEdit('x20 y90 w250 h30')
    target.Show('x1050 y100 w300 h220')
    WinGetClientPos &cx,&cy,,, 'ahk_id ' target.Hwnd
    ax:=cx+60, ay:=cy+40, bx:=cx+190, by:=cy+40, px:=cx+280, py:=cy+180
    BeginCapture()
    MouseMove px,py,0
    Sleep 100
    CapturePixel()
    Check(Integer(XInput.Value)=px && Integer(YInput.Value)=py && ColorInput.Value='123456', 'capture real screen position and RGB')
    Check(!App.picking, 'capture ends picking')
    KindInput.Value:=1, DelayInput.Value:=100
    AddStep()
    Check(App.steps.Length=1 && App.steps[1].color='123456', 'add captured step')
    XInput.Value:=ax, YInput.Value:=ay
    EditStep()
    Check(App.steps[1].x=ax, 'edit selected step')
    XInput.Value:=bx, YInput.Value:=by
    AddStep()
    MoveStep(-1)
    Check(App.steps[1].x=bx && App.steps[2].x=ax, 'move up')
    MoveStep(1)
    Check(App.steps[2].x=bx, 'move down')
    DeleteStep()
    Check(App.steps.Length=1 && App.steps[1].x=ax, 'delete selected')
    DurationInput.Value:=2, GapInput.Value:=1000
    SaveMacro()
    App.steps:=[]
    LoadMacro()
    Check(App.steps.Length=1 && App.steps[1].x=ax && App.duration=2 && App.gap=1000, 'persist and reload')
    IniWrite 'invalid',MacroPath,'Step1','color'
    rejected:=false
    try LoadMacro()
    catch
        rejected:=true
    Check(rejected && App.steps.Length=1 && App.steps[1].x=ax, 'malformed load preserves prior steps')
    App.steps:=[Step(1,ax,ay,0),Step(4,0,0,160),Step(1,bx,by,0)]
    ActivateTarget()
    StartNow(1000)
    MacroTick()
    Sleep 60
    MacroTick()
    Sleep 60
    MacroTick()
    Check(events.Length=1, 'wait holds second click')
    Sleep 130
    MacroTick()
    Sleep 60
    Check(events.Length=2 && events[1].name='A' && events[2].name='B', 'sequential real clicks A then B')
    Check(events[2].time-events[1].time >= 160, 'wait delay observed')
    StopMacro()
    targetEdit.Focus()
    App.steps:=[Step(3,0,0,0,'a')]
    StartNow(500)
    MacroTick()
    Sleep 60
    Check(targetEdit.Value='a', 'key delivered to owned edit')
    StopMacro()
    App.steps:=[Step(6,px,py,0)]
    StartNow(500)
    MacroTick()
    Check(App.cycles=1, 'wait color match advances and clicks')
    StopMacro()
    App.steps:=[Step(5,px,py,0)]
    App.steps[1].color:='FFFFFF', App.steps[1].timeout:=100
    StartNow(1000)
    MacroTick()
    Check(App.phase='color' && App.index=1, 'mismatched color waits')
    Sleep 140
    MacroTick()
    Check(!App.running && InStr(StatusText.Text,'Timeout'), 'color timeout stops')
    App.steps:=[Step(1,ax,ay,0)]
    before:=events.Length
    StartNow(-1)
    MacroTick()
    Sleep 60
    Check(!App.running && events.Length=before, 'expired duration sends no extra click')
    DurationInput.Value:=1
    ToggleMacro()
    Check(App.running && App.phase='countdown', 'start enters countdown')
    Sleep 100
    MacroTick()
    Check(App.phase='countdown' && events.Length=before, 'countdown prevents actions')
    ActivateTarget()
    SendLevel 1
    SendEvent '{F9}'
    SendLevel 0
    Sleep 100
    Check(!App.running && InStr(StatusText.Text,'F9'), 'manual F9 cancels countdown')
    ToggleMacro()
    ActivateTarget()
    Sleep 3200
    Sleep 80
    Check(events.Length>before, 'countdown starts real macro after three seconds')
    SendLevel 1
    SendEvent '{F9}'
    SendLevel 0
    Sleep 100
    Check(!App.running, 'manual F9 stops running macro')
    stale:=App.generation
    ToggleMacro()
    AdvanceMacro(A_TickCount,stale)
    Check(App.phase='countdown' && App.index=1, 'stale tick cannot advance restarted macro')
    StopMacro()
    ActivateTarget()
    rightClicks:=0
    OnMessage(0x205, RecordRightClick)
    MouseMove px,py,0
    for kind in [1,2,6] {
        before:=events.Length, rightBefore:=rightClicks
        testStep:=Step(kind,ax,ay,0)
        testStep.color:=Format('{:06X}',PixelGetColor(ax,ay))
        App.steps:=[testStep]
        StartNow(1000)
        MacroTick()
        Sleep 80
        MouseGetPos &afterX,&afterY
        Check(afterX=px && afterY=py, 'pointer restored after click kind ' kind)
        Check(kind=2 ? rightClicks=rightBefore+1 : events.Length=before+1 && events[-1].name='A', 'real target receives click kind ' kind)
        StopMacro()
    }
    before:=events.Length
    MacroClick(Step(1,ax,ay,0))
    Sleep 50
    MouseGetPos &afterX,&afterY
    Check(afterX=px && afterY=py && events.Length=before, 'stopped click neither moves pointer nor sends click')
    StartNow(-1)
    MacroClick(Step(1,ax,ay,0))
    Sleep 50
    MouseGetPos &afterX,&afterY
    Check(afterX=px && afterY=py && events.Length=before, 'expired click neither moves pointer nor sends click')
    StopMacro()
    OnMessage(0x205, RecordRightClick, 0)
    WriteReport('PASS: ' passed ' assertions. Tested production modules with real GUI RGB capture, editor add/edit/move/delete, persistence and invalid-load preservation, real sequential clicks, key delivery, wait delay, color match/mismatch timeout, duration expiry, countdown, F9 stop and stale-generation guard. Pointer restored after left/right/color clicks while actual owned target receives each click; stopped/expired clicks neither move pointer nor send input. Test storage: tests/results/test-macro.ini. Owned GUI windows cleaned; no original executable or user macro.ini used.')
    FileAppend 'PASS ' passed ' assertions`n','*'
} catch as err {
    WriteReport('FAIL after ' passed ' assertions: ' err.Message ' (line ' err.Line ')')
    FileAppend 'FAIL: ' err.Message ' line ' err.Line '`n','*'
    ExitApp 1
} finally {
    StopMacro()
    if IsObject(target)
        target.Destroy()
    MainWindow.Destroy()
}
ExitApp 0
Step(kind,x,y,delay,key:='Enter') {
    return {kind:kind,x:x,y:y,color:'123456',key:key,delay:delay,tolerance:0,timeout:500}
}
StartNow(ms) {
    App.running:=true,App.index:=1,App.cycles:=0,App.phase:='ready',App.end:=A_TickCount+ms
}
ActivateTarget() {
    WinActivate('ahk_id ' target.Hwnd)
    WinWaitActive('ahk_id ' target.Hwnd,,3)
}
Check(ok,label) {
    global passed
    if !ok
        throw Error(label)
    passed+=1
}
WriteReport(message) {
    f:=FileOpen(report,'w','UTF-8')
    f.Write('# ClickBotz custom macro test report`n`n' message '`n')
    f.Close()
}
RecordRightClick(wParam,lParam,msg,hwnd) {
    global rightClicks
    if hwnd=a.Hwnd
        rightClicks+=1
}
