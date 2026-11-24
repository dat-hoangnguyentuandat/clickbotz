#Requires AutoHotkey v2.0
#SingleInstance Force
;@Ahk2Exe-SetName ClickBotz
;@Ahk2Exe-SetDescription Custom screen color macro
;@Ahk2Exe-SetVersion 2.0.1
#Include lib\macro-model.ahk
#Include lib\macro-storage.ahk
#Include lib\macro-engine.ahk
#Include lib\macro-editor.ahk
#Include lib\app-window.ahk
CoordMode 'Mouse', 'Screen'
CoordMode 'Pixel', 'Screen'
SendMode 'Event'
SetMouseDelay -1
SetKeyDelay 10, 20
App := {steps: [], running: false, picking: false, index: 1, cycles: 0,
    busy: false, duration: 60, gap: 200, phase: '', due: 0, generation: 0}
MacroPath := A_ScriptDir '\macro.ini'
BuildWindow()
try LoadMacro()
catch as err
    SetStatus('Không nạp macro: ' err.Message)
OnExit((*) => ToolTip())
F10::ToggleMacro()
F9::StopMacro('Đã dừng bằng F9')
#HotIf App.picking
F8::CapturePixel()
Esc::CancelCapture()
#HotIf
