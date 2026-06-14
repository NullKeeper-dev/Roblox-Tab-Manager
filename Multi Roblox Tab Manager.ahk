; Multi Roblox Tab Manager
; Credit: NullKeeper-dev
; GitHub: https://github.com/NullKeeper-dev

if !A_IsAdmin
{
    Run, *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines, -1
SetTitleMatchMode, 2
SendMode, Input
CoordMode, Mouse, Screen

AppName := "Multi Roblox Tab Manager"
AppVersion := "2.0"
AuthorName := "NullKeeper-dev"
AuthorUrl := "https://github.com/NullKeeper-dev"
RobloxExe := "RobloxPlayerBeta.exe"

RobloxMinW := 800
RobloxMinH := 600
OffsetLeft := -5
OffsetRight := 10
OffsetTop := 0
OffsetBottom := 30
LayoutMode := "Auto Grid"
TargetMonitorMode := "Mouse Monitor"
ScaleToFit := 1
ArrangeRestoreMinimized := 1
CascadeStep := 36

AutoMaintenanceEnabled := 1
MaintenanceIntervalMin := 10
MaintenanceCountdownSec := 30
NormalEscCount := 4
FastEscCount := 2
PreDelayMs := 50
EscDelayMs := 100
PreserveMinimized := 1
TrimAfterMaintenance := 1
UseControlSendFallback := 1
MaintenanceMode := "normal"
CountdownValue := 0
NextMaintenanceTick := 0

LastAction := "Ready"
GuiReady := 0
DashboardVisible := 1
ClientMap := {}
InteractiveHwnds := []

BuildTray()
BuildDashboard()
RefreshClients()
ApplyMaintenanceTimer()
SetTimer, RefreshStatus, 1000
Gui, Main:Show, w1040 h760, %AppName% v%AppVersion%
return

F7::Gosub, DoArrange
F6::Gosub, DoTrimAll
F4::Gosub, DoFastMaintenance
F9::Gosub, DoMinimizeAll
F10::Gosub, DoRestoreAll
F12::Gosub, ToggleDashboard
F8::Gosub, ExitScript

DoArrange:
ReadLayoutSettings()
clients := GetRobloxClients()
clientCount := GetClientCount(clients)
if (clientCount = 0)
{
    ShowNotice("No Roblox clients found.", 1500)
    SetLastAction("No Roblox clients found for arrange.")
    return
}
area := GetTargetWorkArea(TargetMonitorMode)
AreaL := area.L + OffsetLeft
AreaR := area.R - OffsetRight
AreaT := area.T + OffsetTop
AreaB := area.B - OffsetBottom
targetW := AreaR - AreaL
targetH := AreaB - AreaT
if (targetW < 240 || targetH < 180)
{
    ShowNotice("Target monitor area is too small after offsets.", 1800)
    SetLastAction("Arrange blocked by invalid monitor offsets.")
    return
}
if (LayoutMode = "Cascade")
{
    ArrangeCascade(clients, AreaL, AreaT, AreaR, AreaB)
}
else
{
    ArrangeGrid(clients, AreaL, AreaT, targetW, targetH)
}
RefreshClients()
ShowNotice("Arranged " . clientCount . " Roblox clients.", 1200)
SetLastAction("Arranged " . clientCount . " clients using " . LayoutMode . ".")
return

DoTrimAll:
clients := GetRobloxClients()
clientCount := GetClientCount(clients)
if (clientCount = 0)
{
    ShowNotice("No Roblox clients found.", 1500)
    SetLastAction("No Roblox clients found for RAM trim.")
    return
}
trimmed := TrimClientMemory(clients)
ShowNotice("RAM trimmed for " . trimmed . " Roblox clients.", 1200)
SetLastAction("Trimmed RAM for " . trimmed . " clients.")
return

DoFastMaintenance:
ReadMaintenanceSettings()
ResetMaintenanceTimer()
MaintenanceMode := "fast"
Gosub, MaintenanceCycle
return

DoNormalMaintenance:
ReadMaintenanceSettings()
ResetMaintenanceTimer()
MaintenanceMode := "normal"
Gosub, MaintenanceCycle
return

DoMinimizeAll:
clients := GetRobloxClients()
clientCount := GetClientCount(clients)
if (clientCount = 0)
{
    ShowNotice("No Roblox clients found.", 1500)
    SetLastAction("No Roblox clients found to minimize.")
    return
}
SetRobloxWindowState(clients, 2)
RefreshClients()
ShowNotice("Minimized " . clientCount . " Roblox clients.", 1200)
SetLastAction("Minimized " . clientCount . " clients.")
return

DoRestoreAll:
clients := GetRobloxClients()
clientCount := GetClientCount(clients)
if (clientCount = 0)
{
    ShowNotice("No Roblox clients found.", 1500)
    SetLastAction("No Roblox clients found to restore.")
    return
}
SetRobloxWindowState(clients, 9)
RefreshClients()
ShowNotice("Restored " . clientCount . " Roblox clients.", 1200)
SetLastAction("Restored " . clientCount . " clients.")
return

DoRefreshClients:
RefreshClients()
SetLastAction("Client list refreshed.")
return

DoActivateSelected:
selected := GetSelectedClientHandles()
if (GetClientCount(selected) = 0)
{
    ShowNotice("Select a Roblox client first.", 1400)
    return
}
hwnd := selected[1].hwnd
DllCall("ShowWindow", "Ptr", hwnd, "Int", 9)
WinActivate, ahk_id %hwnd%
SetLastAction("Activated selected Roblox client.")
return

DoMinimizeSelected:
selected := GetSelectedClientHandles()
selectedCount := GetClientCount(selected)
if (selectedCount = 0)
{
    ShowNotice("Select a Roblox client first.", 1400)
    return
}
SetRobloxWindowState(selected, 2)
RefreshClients()
ShowNotice("Minimized " . selectedCount . " selected clients.", 1200)
SetLastAction("Minimized " . selectedCount . " selected clients.")
return

DoRestoreSelected:
selected := GetSelectedClientHandles()
selectedCount := GetClientCount(selected)
if (selectedCount = 0)
{
    ShowNotice("Select a Roblox client first.", 1400)
    return
}
SetRobloxWindowState(selected, 9)
RefreshClients()
ShowNotice("Restored " . selectedCount . " selected clients.", 1200)
SetLastAction("Restored " . selectedCount . " selected clients.")
return

DoTrimSelected:
selected := GetSelectedClientHandles()
selectedCount := GetClientCount(selected)
if (selectedCount = 0)
{
    ShowNotice("Select a Roblox client first.", 1400)
    return
}
trimmed := TrimClientMemory(selected)
ShowNotice("RAM trimmed for " . trimmed . " selected clients.", 1200)
SetLastAction("Trimmed RAM for " . trimmed . " selected clients.")
return

ApplyLayoutSettings:
ReadLayoutSettings()
SetLastAction("Layout settings applied.")
ShowNotice("Layout settings applied.", 1100)
return

ApplyMaintenanceSettings:
ReadMaintenanceSettings()
ApplyMaintenanceTimer()
SetLastAction("Maintenance settings applied.")
ShowNotice("Maintenance settings applied.", 1100)
return

StartMaintenanceCountdownNow:
ReadMaintenanceSettings()
CountdownValue := MaintenanceCountdownSec
MaintenanceMode := "normal"
SetTimer, UpdateMaintenanceCountdown, 1000
SetLastAction("Manual maintenance countdown started.")
return

StopMaintenanceTimers:
SetTimer, StartMaintenanceCountdown, Off
SetTimer, UpdateMaintenanceCountdown, Off
CountdownValue := 0
NextMaintenanceTick := 0
GuiControl, Main:, GuiAutoMaintenance, 0
AutoMaintenanceEnabled := 0
ToolTip
SetLastAction("Auto maintenance stopped.")
ShowNotice("Auto maintenance stopped.", 1100)
return

StartMaintenanceCountdown:
if (!AutoMaintenanceEnabled)
    return
NextMaintenanceTick := A_TickCount + (MaintenanceIntervalMin * 60000)
CountdownValue := MaintenanceCountdownSec
MaintenanceMode := "normal"
if (CountdownValue <= 0)
{
    Gosub, MaintenanceCycle
    return
}
SetTimer, UpdateMaintenanceCountdown, 1000
SetLastAction("Auto maintenance countdown started.")
return

UpdateMaintenanceCountdown:
if (CountdownValue > 0)
{
    ShowNotice("Maintenance starting in: " . CountdownValue . "s", 0)
    CountdownValue--
}
else
{
    ToolTip
    SetTimer, UpdateMaintenanceCountdown, Off
    MaintenanceMode := "normal"
    Gosub, MaintenanceCycle
}
UpdateStatus()
return

MaintenanceCycle:
ReadMaintenanceSettings()
ToolTip
SetTimer, UpdateMaintenanceCountdown, Off
clients := GetRobloxClients()
clientCount := GetClientCount(clients)
if (clientCount = 0)
{
    ShowNotice("No Roblox clients found for maintenance.", 1500)
    SetLastAction("Maintenance skipped. No Roblox clients found.")
    return
}
escCount := (MaintenanceMode = "fast") ? FastEscCount : NormalEscCount
Loop, % clientCount
{
    client := clients[A_Index]
    hwnd := client.hwnd
    originalState := client.minmax
    if (originalState = -1)
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 9)
    WinActivate, ahk_id %hwnd%
    Sleep, %PreDelayMs%
    Loop, %escCount%
    {
        SendInput, {Esc}
        Sleep, %EscDelayMs%
    }
    if (UseControlSendFallback)
        ControlSend,, {Esc}, ahk_id %hwnd%
    if (PreserveMinimized && originalState = -1)
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 2)
}
if (TrimAfterMaintenance)
    trimmed := TrimClientMemory(clients)
else
    trimmed := 0
RefreshClients()
ShowNotice("Maintenance [" . MaintenanceMode . "] completed for " . clientCount . " clients.", 1300)
if (TrimAfterMaintenance)
    SetLastAction("Maintenance " . MaintenanceMode . " completed. Trimmed " . trimmed . " clients.")
else
    SetLastAction("Maintenance " . MaintenanceMode . " completed.")
return

ToggleDashboard:
if (DashboardVisible)
{
    Gui, Main:Hide
    DashboardVisible := 0
}
else
{
    RefreshClients()
    Gui, Main:Show, w1040 h760, %AppName% v%AppVersion%
    DashboardVisible := 1
}
return

ClientLV:
if (A_GuiEvent = "DoubleClick")
    Gosub, DoActivateSelected
return

OpenGitHub:
Run, %AuthorUrl%
return

RefreshStatus:
UpdateStatus()
return

HideNotice:
ToolTip
return

MainGuiClose:
MainGuiEscape:
Gui, Main:Hide
DashboardVisible := 0
return

ExitScript:
ExitApp
return

BuildTray()
{
    global AppName, AuthorName
    Menu, Tray, NoStandard
    Menu, Tray, Add, Show Dashboard`tF12, ToggleDashboard
    Menu, Tray, Add
    Menu, Tray, Add, Arrange Tabs`tF7, DoArrange
    Menu, Tray, Add, Trim RAM`tF6, DoTrimAll
    Menu, Tray, Add, Fast Maintenance`tF4, DoFastMaintenance
    Menu, Tray, Add, Minimize All`tF9, DoMinimizeAll
    Menu, Tray, Add, Restore All`tF10, DoRestoreAll
    Menu, Tray, Add
    Menu, Tray, Add, Exit`tF8, ExitScript
    Menu, Tray, Default, Show Dashboard`tF12
    Menu, Tray, Tip, %AppName% by %AuthorName%
}

BuildDashboard()
{
    global AppName, AppVersion, AuthorName, AuthorUrl, MainHwnd, InteractiveHwnds
    global MainTabs, ClientLV, ClientCountText, TimerStateText, NextMaintenanceText, LastActionText
    global GuiRobloxMinW, GuiRobloxMinH, GuiLayoutMode, GuiTargetMonitorMode, GuiCascadeStep
    global GuiScaleToFit, GuiArrangeRestoreMinimized, GuiOffsetLeft, GuiOffsetRight, GuiOffsetTop, GuiOffsetBottom
    global GuiAutoMaintenance, GuiMaintenanceIntervalMin, GuiMaintenanceCountdownSec, GuiNormalEscCount, GuiFastEscCount
    global GuiPreDelayMs, GuiEscDelayMs, GuiPreserveMinimized, GuiTrimAfterMaintenance, GuiUseControlSendFallback
    global RobloxMinW, RobloxMinH
    global OffsetLeft, OffsetRight, OffsetTop, OffsetBottom, LayoutMode, TargetMonitorMode
    global ScaleToFit, ArrangeRestoreMinimized, CascadeStep, AutoMaintenanceEnabled
    global MaintenanceIntervalMin, MaintenanceCountdownSec, NormalEscCount, FastEscCount
    global PreDelayMs, EscDelayMs, PreserveMinimized, TrimAfterMaintenance, UseControlSendFallback
    global GuiReady

    InteractiveHwnds := []
    Gui, Main:New, +HwndMainHwnd -MaximizeBox +MinSize1040x760, %AppName%
    Gui, Main:Color, 09090F, 15131B
    Gui, Main:Margin, 0, 0

    Gui, Main:Font, s23 cFFFFFF Bold, Segoe UI
    Gui, Main:Add, Text, x24 y24 w590 h34, Multi Roblox Tab Manager
    Gui, Main:Font, s9 cC4B5FD Norm, Segoe UI
    Gui, Main:Add, Text, x26 y61 w420 h20, Control center for Roblox client windows
    Gui, Main:Font, s9 cA78BFA Underline, Segoe UI
    Gui, Main:Add, Text, x748 y31 w266 h20 Right gOpenGitHub, Credit: %AuthorName%
    Gui, Main:Font, s8 cC4B5FD Norm, Segoe UI
    Gui, Main:Add, Text, x748 y56 w266 h18 Right gOpenGitHub, %AuthorUrl%

    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x24 y92 w312 h122 c7C3AED, Live Status
    Gui, Main:Font, s10 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Text, x44 y126 w250 h22 vClientCountText, Roblox clients: scanning...
    Gui, Main:Add, Text, x44 y154 w250 h22 vTimerStateText, Auto maintenance: checking...
    Gui, Main:Add, Text, x44 y182 w250 h22 vNextMaintenanceText, Next maintenance: --

    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x356 y92 w660 h136 c7C3AED, Command Center
    AddTextButton(376, 132, 144, 31, "Arrange Tabs", "DoArrange", "1A1625", "F5F3FF")
    AddTextButton(532, 132, 144, 31, "Trim RAM", "DoTrimAll", "1A1625", "F5F3FF")
    AddTextButton(688, 132, 144, 31, "Normal Run", "DoNormalMaintenance", "1A1625", "F5F3FF")
    AddTextButton(844, 132, 144, 31, "Fast Run", "DoFastMaintenance", "1A1625", "F5F3FF")
    AddTextButton(376, 170, 144, 31, "Minimize All", "DoMinimizeAll", "16141D", "E5E7EB")
    AddTextButton(532, 170, 144, 31, "Restore All", "DoRestoreAll", "16141D", "E5E7EB")
    AddTextButton(688, 170, 144, 31, "Start Countdown", "StartMaintenanceCountdownNow", "16141D", "E5E7EB")
    AddTextButton(844, 170, 144, 31, "Stop Timer", "StopMaintenanceTimers", "16141D", "E5E7EB")
    Gui, Main:Font, s8 cD6D3D1 Norm, Segoe UI
    Gui, Main:Add, Text, x376 y204 w612 h18, Hotkeys: F7 arrange, F6 trim, F4 fast maintenance, F9 minimize, F10 restore, F12 show/hide, F8 exit

    Gui, Main:Font, s10 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Tab3, x24 y246 w992 h442 vMainTabs, Layout|Maintenance|Clients

    Gui, Main:Tab, Layout
    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x46 y292 w454 h324 c7C3AED, Window Layout
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Text, x68 y338 w116 h22 BackgroundTrans, Window width
    Gui, Main:Add, Edit, x190 y334 w86 h24 vGuiRobloxMinW Number, %RobloxMinW%
    Gui, Main:Add, Text, x314 y338 w112 h22 BackgroundTrans, Window height
    Gui, Main:Add, Edit, x398 y334 w82 h24 vGuiRobloxMinH Number, %RobloxMinH%
    Gui, Main:Add, Text, x68 y374 w116 h22 BackgroundTrans, Layout mode
    Gui, Main:Add, DropDownList, x190 y370 w290 vGuiLayoutMode, Auto Grid|Horizontal Row|Vertical Stack|Cascade
    GuiControl, Main:ChooseString, GuiLayoutMode, %LayoutMode%
    Gui, Main:Add, Text, x68 y410 w116 h22 BackgroundTrans, Target monitor
    Gui, Main:Add, DropDownList, x190 y406 w290 vGuiTargetMonitorMode, Mouse Monitor|Primary Monitor|All Monitors
    GuiControl, Main:ChooseString, GuiTargetMonitorMode, %TargetMonitorMode%
    Gui, Main:Add, Text, x68 y446 w116 h22 BackgroundTrans, Cascade step
    Gui, Main:Add, Edit, x190 y442 w86 h24 vGuiCascadeStep Number, %CascadeStep%
    checkedScale := ScaleToFit ? "Checked" : ""
    checkedRestore := ArrangeRestoreMinimized ? "Checked" : ""
    Gui, Main:Add, CheckBox, x68 y492 w400 h24 vGuiScaleToFit %checkedScale%, Scale windows down when the monitor is crowded
    Gui, Main:Add, CheckBox, x68 y524 w400 h24 vGuiArrangeRestoreMinimized %checkedRestore%, Restore minimized clients before arranging
    AddTextButton(68, 570, 410, 32, "Apply Layout Settings", "ApplyLayoutSettings", "1A1625", "F5F3FF")

    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x536 y292 w438 h324 c7C3AED, Monitor Offsets
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Text, x560 y338 w60 h22 BackgroundTrans, Left
    Gui, Main:Add, Edit, x628 y334 w96 h24 vGuiOffsetLeft, %OffsetLeft%
    Gui, Main:Add, Text, x762 y338 w60 h22 BackgroundTrans, Right
    Gui, Main:Add, Edit, x844 y334 w96 h24 vGuiOffsetRight, %OffsetRight%
    Gui, Main:Add, Text, x560 y374 w60 h22 BackgroundTrans, Top
    Gui, Main:Add, Edit, x628 y370 w96 h24 vGuiOffsetTop, %OffsetTop%
    Gui, Main:Add, Text, x762 y374 w60 h22 BackgroundTrans, Bottom
    Gui, Main:Add, Edit, x844 y370 w96 h24 vGuiOffsetBottom, %OffsetBottom%
    Gui, Main:Font, s8 c9CA3AF Norm, Segoe UI
    Gui, Main:Add, Text, x560 y430 w380 h62 BackgroundTrans, Offsets trim the usable monitor work area before Roblox windows are placed. Negative left/top values can pull windows slightly past the work area when tighter alignment is needed.
    AddTextButton(560, 570, 390, 32, "Apply and Arrange Now", "DoArrange", "1A1625", "F5F3FF")

    Gui, Main:Tab, Maintenance
    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x46 y292 w454 h324 c7C3AED, Maintenance Schedule
    checkedAuto := AutoMaintenanceEnabled ? "Checked" : ""
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, CheckBox, x68 y334 w230 h24 vGuiAutoMaintenance %checkedAuto%, Enable auto maintenance
    Gui, Main:Add, Text, x68 y374 w170 h22 BackgroundTrans, Interval minutes
    Gui, Main:Add, Edit, x274 y370 w96 h24 vGuiMaintenanceIntervalMin, %MaintenanceIntervalMin%
    Gui, Main:Add, Text, x68 y410 w170 h22 BackgroundTrans, Countdown seconds
    Gui, Main:Add, Edit, x274 y406 w96 h24 vGuiMaintenanceCountdownSec Number, %MaintenanceCountdownSec%
    Gui, Main:Add, Text, x68 y446 w170 h22 BackgroundTrans, Normal Esc presses
    Gui, Main:Add, Edit, x274 y442 w96 h24 vGuiNormalEscCount Number, %NormalEscCount%
    Gui, Main:Add, Text, x68 y482 w170 h22 BackgroundTrans, Fast Esc presses
    Gui, Main:Add, Edit, x274 y478 w96 h24 vGuiFastEscCount Number, %FastEscCount%
    AddTextButton(68, 570, 410, 32, "Apply Maintenance Settings", "ApplyMaintenanceSettings", "1A1625", "F5F3FF")

    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x536 y292 w438 h324 c7C3AED, Maintenance Behavior
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Text, x560 y338 w160 h22 BackgroundTrans, Pre-send delay ms
    Gui, Main:Add, Edit, x760 y334 w96 h24 vGuiPreDelayMs Number, %PreDelayMs%
    Gui, Main:Add, Text, x560 y374 w160 h22 BackgroundTrans, Esc delay ms
    Gui, Main:Add, Edit, x760 y370 w96 h24 vGuiEscDelayMs Number, %EscDelayMs%
    checkedPreserve := PreserveMinimized ? "Checked" : ""
    checkedTrim := TrimAfterMaintenance ? "Checked" : ""
    checkedFallback := UseControlSendFallback ? "Checked" : ""
    Gui, Main:Add, CheckBox, x560 y418 w350 h24 vGuiPreserveMinimized %checkedPreserve%, Re-minimize clients that started minimized
    Gui, Main:Add, CheckBox, x560 y450 w350 h24 vGuiTrimAfterMaintenance %checkedTrim%, Trim RAM after maintenance
    Gui, Main:Add, CheckBox, x560 y482 w350 h24 vGuiUseControlSendFallback %checkedFallback%, Send fallback Esc with ControlSend
    AddTextButton(560, 530, 184, 32, "Run Normal Now", "DoNormalMaintenance", "1A1625", "F5F3FF")
    AddTextButton(766, 530, 184, 32, "Run Fast Now", "DoFastMaintenance", "1A1625", "F5F3FF")
    AddTextButton(560, 570, 390, 32, "Start Countdown Now", "StartMaintenanceCountdownNow", "16141D", "E5E7EB")

    Gui, Main:Tab, Clients
    Gui, Main:Font, s8 cA78BFA Bold, Segoe UI
    Gui, Main:Add, GroupBox, x46 y292 w928 h324 c7C3AED, Client Manager
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, ListView, x68 y330 w884 h220 vClientLV gClientLV Grid AltSubmit, #|PID|State|Window Title
    AddTextButton(68, 570, 154, 32, "Refresh List", "DoRefreshClients", "16141D", "E5E7EB")
    AddTextButton(238, 570, 154, 32, "Activate", "DoActivateSelected", "1A1625", "F5F3FF")
    AddTextButton(408, 570, 154, 32, "Minimize", "DoMinimizeSelected", "16141D", "E5E7EB")
    AddTextButton(578, 570, 154, 32, "Restore", "DoRestoreSelected", "16141D", "E5E7EB")
    AddTextButton(748, 570, 154, 32, "Trim RAM", "DoTrimSelected", "1A1625", "F5F3FF")

    Gui, Main:Tab
    Gui, Main:Font, s9 cF8FAFC Norm, Segoe UI
    Gui, Main:Add, Text, x24 y714 w992 h22 vLastActionText, Ready
    GuiReady := 1
    RaiseDashboardControls()
}

AddTextButton(x, y, w, h, label, actionLabel, bgColor, fgColor)
{
    global InteractiveHwnds
    Gui, Main:Font, s9 Norm, Segoe UI
    opts := "x" . x . " y" . y . " w" . w . " h" . h . " HwndbtnHwnd g" . actionLabel
    Gui, Main:Add, Button, %opts%, %label%
    InteractiveHwnds.Push(btnHwnd)
}

RaiseDashboardControls()
{
    global InteractiveHwnds
    controlNames := ["ClientCountText", "TimerStateText", "NextMaintenanceText"
        , "GuiRobloxMinW", "GuiRobloxMinH", "GuiLayoutMode", "GuiTargetMonitorMode", "GuiCascadeStep"
        , "GuiScaleToFit", "GuiArrangeRestoreMinimized", "GuiOffsetLeft", "GuiOffsetRight", "GuiOffsetTop", "GuiOffsetBottom"
        , "GuiAutoMaintenance", "GuiMaintenanceIntervalMin", "GuiMaintenanceCountdownSec", "GuiNormalEscCount", "GuiFastEscCount"
        , "GuiPreDelayMs", "GuiEscDelayMs", "GuiPreserveMinimized", "GuiTrimAfterMaintenance", "GuiUseControlSendFallback"
        , "ClientLV", "LastActionText"]
    Gui, Main:Default
    Loop, % controlNames.MaxIndex()
    {
        controlName := controlNames[A_Index]
        GuiControlGet, ctrlHwnd, Hwnd, %controlName%
        RaiseHwnd(ctrlHwnd)
    }
    Loop, % InteractiveHwnds.MaxIndex()
        RaiseHwnd(InteractiveHwnds[A_Index])
}

RaiseHwnd(hwnd)
{
    if (!hwnd)
        return
    DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
}

ReadLayoutSettings()
{
    global GuiReady, GuiRobloxMinW, GuiRobloxMinH, GuiOffsetLeft, GuiOffsetRight, GuiOffsetTop, GuiOffsetBottom
    global GuiLayoutMode, GuiTargetMonitorMode, GuiScaleToFit, GuiArrangeRestoreMinimized, GuiCascadeStep
    global RobloxMinW, RobloxMinH, OffsetLeft, OffsetRight, OffsetTop, OffsetBottom
    global LayoutMode, TargetMonitorMode, ScaleToFit, ArrangeRestoreMinimized, CascadeStep

    if (GuiReady)
        Gui, Main:Submit, NoHide
    RobloxMinW := ClampNumber(GuiRobloxMinW, 320, 3840, 800)
    RobloxMinH := ClampNumber(GuiRobloxMinH, 240, 2160, 600)
    OffsetLeft := ClampNumber(GuiOffsetLeft, -1000, 1000, -5)
    OffsetRight := ClampNumber(GuiOffsetRight, -1000, 1000, 10)
    OffsetTop := ClampNumber(GuiOffsetTop, -1000, 1000, 0)
    OffsetBottom := ClampNumber(GuiOffsetBottom, -1000, 1000, 30)
    CascadeStep := ClampNumber(GuiCascadeStep, 8, 240, 36)
    LayoutMode := GuiLayoutMode ? GuiLayoutMode : "Auto Grid"
    TargetMonitorMode := GuiTargetMonitorMode ? GuiTargetMonitorMode : "Mouse Monitor"
    ScaleToFit := GuiScaleToFit ? 1 : 0
    ArrangeRestoreMinimized := GuiArrangeRestoreMinimized ? 1 : 0

    if (GuiReady)
    {
        GuiControl, Main:, GuiRobloxMinW, %RobloxMinW%
        GuiControl, Main:, GuiRobloxMinH, %RobloxMinH%
        GuiControl, Main:, GuiOffsetLeft, %OffsetLeft%
        GuiControl, Main:, GuiOffsetRight, %OffsetRight%
        GuiControl, Main:, GuiOffsetTop, %OffsetTop%
        GuiControl, Main:, GuiOffsetBottom, %OffsetBottom%
        GuiControl, Main:, GuiCascadeStep, %CascadeStep%
    }
}

ReadMaintenanceSettings()
{
    global GuiReady, GuiAutoMaintenance, GuiMaintenanceIntervalMin, GuiMaintenanceCountdownSec
    global GuiNormalEscCount, GuiFastEscCount, GuiPreDelayMs, GuiEscDelayMs
    global GuiPreserveMinimized, GuiTrimAfterMaintenance, GuiUseControlSendFallback
    global AutoMaintenanceEnabled, MaintenanceIntervalMin, MaintenanceCountdownSec
    global NormalEscCount, FastEscCount, PreDelayMs, EscDelayMs
    global PreserveMinimized, TrimAfterMaintenance, UseControlSendFallback

    if (GuiReady)
        Gui, Main:Submit, NoHide
    AutoMaintenanceEnabled := GuiAutoMaintenance ? 1 : 0
    MaintenanceIntervalMin := ClampNumber(GuiMaintenanceIntervalMin, 1, 1440, 10)
    MaintenanceCountdownSec := ClampNumber(GuiMaintenanceCountdownSec, 0, 300, 30)
    NormalEscCount := ClampNumber(GuiNormalEscCount, 1, 20, 4)
    FastEscCount := ClampNumber(GuiFastEscCount, 1, 20, 2)
    PreDelayMs := ClampNumber(GuiPreDelayMs, 0, 5000, 50)
    EscDelayMs := ClampNumber(GuiEscDelayMs, 0, 5000, 100)
    PreserveMinimized := GuiPreserveMinimized ? 1 : 0
    TrimAfterMaintenance := GuiTrimAfterMaintenance ? 1 : 0
    UseControlSendFallback := GuiUseControlSendFallback ? 1 : 0

    if (GuiReady)
    {
        GuiControl, Main:, GuiMaintenanceIntervalMin, %MaintenanceIntervalMin%
        GuiControl, Main:, GuiMaintenanceCountdownSec, %MaintenanceCountdownSec%
        GuiControl, Main:, GuiNormalEscCount, %NormalEscCount%
        GuiControl, Main:, GuiFastEscCount, %FastEscCount%
        GuiControl, Main:, GuiPreDelayMs, %PreDelayMs%
        GuiControl, Main:, GuiEscDelayMs, %EscDelayMs%
    }
}

ApplyMaintenanceTimer()
{
    global AutoMaintenanceEnabled, MaintenanceIntervalMin, NextMaintenanceTick, CountdownValue
    SetTimer, StartMaintenanceCountdown, Off
    SetTimer, UpdateMaintenanceCountdown, Off
    CountdownValue := 0
    if (AutoMaintenanceEnabled)
    {
        intervalMs := MaintenanceIntervalMin * 60000
        NextMaintenanceTick := A_TickCount + intervalMs
        SetTimer, StartMaintenanceCountdown, %intervalMs%
    }
    else
    {
        NextMaintenanceTick := 0
    }
    UpdateStatus()
}

ResetMaintenanceTimer()
{
    ApplyMaintenanceTimer()
}

GetRobloxClients()
{
    global RobloxExe
    WinGet, robloxList, List, ahk_exe %RobloxExe%
    clients := []
    Loop, %robloxList%
    {
        hwnd := robloxList%A_Index%
        WinGetTitle, title, ahk_id %hwnd%
        WinGet, pid, PID, ahk_id %hwnd%
        WinGet, minmax, MinMax, ahk_id %hwnd%
        if (minmax = -1)
            state := "Minimized"
        else if (minmax = 1)
            state := "Maximized"
        else
            state := "Normal"
        clients.Push({hwnd: hwnd, pid: pid, minmax: minmax, state: state, title: title})
    }
    return clients
}

GetClientCount(clients)
{
    count := clients.MaxIndex()
    return count ? count : 0
}

RefreshClients()
{
    global GuiReady, ClientMap
    clients := GetRobloxClients()
    clientCount := GetClientCount(clients)
    ClientMap := {}
    if (GuiReady)
    {
        Gui, Main:Default
        Gui, Main:ListView, ClientLV
        LV_Delete()
        Loop, % clientCount
        {
            client := clients[A_Index]
            ClientMap[A_Index] := client.hwnd
            title := client.title ? client.title : "(untitled Roblox client)"
            LV_Add("", A_Index, client.pid, client.state, title)
        }
        LV_ModifyCol(1, 44)
        LV_ModifyCol(2, 86)
        LV_ModifyCol(3, 100)
        LV_ModifyCol(4, 560)
    }
    UpdateStatus()
    return clientCount
}

GetSelectedClientHandles()
{
    global ClientMap
    selected := []
    Gui, Main:Default
    Gui, Main:ListView, ClientLV
    row := 0
    Loop
    {
        row := LV_GetNext(row)
        if (!row)
            break
        if (ClientMap.HasKey(row))
        {
            hwnd := ClientMap[row]
            WinGetTitle, title, ahk_id %hwnd%
            WinGet, pid, PID, ahk_id %hwnd%
            WinGet, minmax, MinMax, ahk_id %hwnd%
            selected.Push({hwnd: hwnd, pid: pid, minmax: minmax, title: title})
        }
    }
    return selected
}

ArrangeGrid(clients, areaL, areaT, targetW, targetH)
{
    global RobloxMinW, RobloxMinH, LayoutMode, ScaleToFit, ArrangeRestoreMinimized
    clientCount := GetClientCount(clients)
    if (LayoutMode = "Horizontal Row")
    {
        cols := clientCount
        rows := 1
    }
    else if (LayoutMode = "Vertical Stack")
    {
        cols := 1
        rows := clientCount
    }
    else
    {
        cols := Ceil(Sqrt(clientCount))
        rows := Ceil(clientCount / cols)
    }

    winW := RobloxMinW
    winH := RobloxMinH
    if (ScaleToFit)
    {
        fitW := Floor(targetW / cols)
        fitH := Floor(targetH / rows)
        if (fitW < winW)
            winW := fitW
        if (fitH < winH)
            winH := fitH
        if (winW < 320)
            winW := 320
        if (winH < 240)
            winH := 240
    }

    hGap := (cols > 1) ? Floor((targetW - (cols * winW)) / (cols - 1)) : 0
    vGap := (rows > 1) ? Floor((targetH - (rows * winH)) / (rows - 1)) : 0
    if (hGap < 0)
        hGap := 0
    if (vGap < 0)
        vGap := 0

    Loop, % clientCount
    {
        client := clients[A_Index]
        hwnd := client.hwnd
        if (!ArrangeRestoreMinimized && client.minmax = -1)
            continue
        cCol := Mod(A_Index - 1, cols)
        cRow := Floor((A_Index - 1) / cols)
        posX := areaL + (cCol * (winW + hGap))
        posY := areaT + (cRow * (winH + vGap))
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 9)
        DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", posX, "Int", posY, "Int", winW, "Int", winH, "UInt", 0x0040)
    }
}

ArrangeCascade(clients, areaL, areaT, areaR, areaB)
{
    global RobloxMinW, RobloxMinH, CascadeStep, ScaleToFit, ArrangeRestoreMinimized
    clientCount := GetClientCount(clients)
    targetW := areaR - areaL
    targetH := areaB - areaT
    winW := RobloxMinW
    winH := RobloxMinH
    if (ScaleToFit)
    {
        maxW := targetW - ((clientCount - 1) * CascadeStep)
        maxH := targetH - ((clientCount - 1) * CascadeStep)
        if (maxW < winW)
            winW := maxW
        if (maxH < winH)
            winH := maxH
        if (winW < 320)
            winW := 320
        if (winH < 240)
            winH := 240
    }

    Loop, % clientCount
    {
        client := clients[A_Index]
        hwnd := client.hwnd
        if (!ArrangeRestoreMinimized && client.minmax = -1)
            continue
        offset := (A_Index - 1) * CascadeStep
        posX := areaL + offset
        posY := areaT + offset
        if (posX + winW > areaR)
            posX := areaL + Mod(offset, CascadeStep * 3)
        if (posY + winH > areaB)
            posY := areaT + Mod(offset, CascadeStep * 3)
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 9)
        DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", posX, "Int", posY, "Int", winW, "Int", winH, "UInt", 0x0040)
    }
}

GetTargetWorkArea(mode)
{
    SysGet, monCount, MonitorCount
    if (mode = "All Monitors")
    {
        Loop, %monCount%
        {
            SysGet, mon, MonitorWorkArea, %A_Index%
            if (A_Index = 1)
            {
                left := monLeft
                top := monTop
                right := monRight
                bottom := monBottom
            }
            else
            {
                if (monLeft < left)
                    left := monLeft
                if (monTop < top)
                    top := monTop
                if (monRight > right)
                    right := monRight
                if (monBottom > bottom)
                    bottom := monBottom
            }
        }
        return {L: left, T: top, R: right, B: bottom}
    }

    if (mode = "Primary Monitor")
    {
        SysGet, primary, MonitorPrimary
        SysGet, mon, MonitorWorkArea, %primary%
        return {L: monLeft, T: monTop, R: monRight, B: monBottom}
    }

    MouseGetPos, mx, my
    Loop, %monCount%
    {
        SysGet, mon, MonitorWorkArea, %A_Index%
        if (mx >= monLeft && mx <= monRight && my >= monTop && my <= monBottom)
            return {L: monLeft, T: monTop, R: monRight, B: monBottom}
    }
    SysGet, mon, MonitorWorkArea, 1
    return {L: monLeft, T: monTop, R: monRight, B: monBottom}
}

SetRobloxWindowState(clients, showCommand)
{
    clientCount := GetClientCount(clients)
    Loop, % clientCount
    {
        hwnd := clients[A_Index].hwnd
        DllCall("ShowWindow", "Ptr", hwnd, "Int", showCommand)
    }
}

TrimClientMemory(clients)
{
    trimmed := 0
    clientCount := GetClientCount(clients)
    Loop, % clientCount
    {
        pid := clients[A_Index].pid
        hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "UInt", pid, "Ptr")
        if (hProcess)
        {
            if (DllCall("psapi.dll\EmptyWorkingSet", "Ptr", hProcess))
                trimmed++
            DllCall("CloseHandle", "Ptr", hProcess)
        }
    }
    return trimmed
}

UpdateStatus()
{
    global GuiReady, ClientCountText, TimerStateText, NextMaintenanceText, LastActionText
    global AutoMaintenanceEnabled, NextMaintenanceTick, CountdownValue, LastAction, MaintenanceMode
    clients := GetRobloxClients()
    clientCount := GetClientCount(clients)
    if (!GuiReady)
        return
    GuiControl, Main:, ClientCountText, % "Roblox clients: " . clientCount
    if (CountdownValue > 0)
    {
        timerText := "Maintenance countdown: " . CountdownValue . "s"
        nextText := "Mode: " . MaintenanceMode
    }
    else if (AutoMaintenanceEnabled && NextMaintenanceTick > 0)
    {
        remaining := NextMaintenanceTick - A_TickCount
        if (remaining < 0)
            remaining := 0
        timerText := "Auto maintenance: On"
        nextText := "Next maintenance: " . FormatDuration(remaining)
    }
    else
    {
        timerText := "Auto maintenance: Off"
        nextText := "Next maintenance: disabled"
    }
    GuiControl, Main:, TimerStateText, %timerText%
    GuiControl, Main:, NextMaintenanceText, %nextText%
    GuiControl, Main:, LastActionText, %LastAction%
}

SetLastAction(text)
{
    global LastAction
    LastAction := text
    UpdateStatus()
}

ShowNotice(text, duration := 1200)
{
    ToolTip, %text%
    if (duration > 0)
    {
        hideAfter := -1 * duration
        SetTimer, HideNotice, %hideAfter%
    }
}

FormatDuration(ms)
{
    totalSeconds := Ceil(ms / 1000)
    minutes := Floor(totalSeconds / 60)
    seconds := Mod(totalSeconds, 60)
    return minutes . "m " . Format("{:02}", seconds) . "s"
}

ClampNumber(value, minValue, maxValue, fallback)
{
    if value is not number
        return fallback
    value := value + 0
    if (value < minValue)
        return minValue
    if (value > maxValue)
        return maxValue
    return Round(value)
}
