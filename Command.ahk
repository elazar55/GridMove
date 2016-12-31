;GridMove
;By jgpaiva
;date: May 2006
;function: Adjusts windows to a predefined or user-defined desktop grid.

Command:
    GoSub, ShowGroups
    OSDwrite("- -")
    Input, FirstNumber, I L1 T60, {esc}, 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 0 , m , r , n , M , v , a , e

    If (ErrorLevel = "Timeout" OR ErrorLevel = "EndKey")
    {
        GoSub, Command_Hide
        return
    }

    If FirstNumber is not number
    {
        If (FirstNumber = "M")
        {
            winget,state,minmax,A
            if state = 1
                WinRestore,A
            else
                PostMessage, 0x112, 0xF030,,, A,
            }
        Else If (FirstNumber = "e")
        {
            GoSub, Command_Hide
            exitapp
            return
        }
        Else If (FirstNumber = "A")
        {
            GoSub, Command_Hide
            gosub, AboutHelp
            return
        }
        Else If (FirstNumber = "R")
        {
            GoSub, Command_Hide
            Reload
        }
        Else If FirstNumber = n
        {
            gosub, NextGrid
            gosub, command
            return
        }

        GoSub, Command_Hide
        return
    }
    If (NGroups < FirstNumber * 10)
    {
        If (FirstNumber = "0")
        {
            GoSub, Command_Hide
            WinMinimize,A
            return
        }

        GoSub, Command_Hide
        MoveToGrid(FirstNumber)
        return
    }
    GoSub, Command_Hide
    return

OSDCreate()
{
    global OSD
    Gui, 4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
    Gui, 4: Font,S13
    Gui, 4: Add, Button, vOSD x0 y0 w100 h30 ,
    Gui, 4: Color, EEAAEE
    Gui, 4: Show, x0 y0 w0 h0 noactivate, OSD
    Gui, 4: hide
    WinSet, TransColor, EEAAEE,OSD
    return
}

OSDWrite(Value)
{
    Global OSD
    Global Monitor1Width
    Global Monitor1Height
    Global Monitor1Top
    Global Monitor1Left
    XPos := Monitor1Left + Monitor1Width / 2 - 50
    YPos := Monitor1Top + Monitor1Height / 2 - 15
    GuiControl, 4:Text, OSD, %value%
    Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
    Gui,4:Show, x%Xpos% y%Ypos% w100 h30 noactivate
    return
}

OSDHide()
{
    Gui, 4:hide,
    return
}

MoveToGrid(GridToMove)
{
    global
    triggerTop    := %GridToMove%TriggerTop
    triggerLeft   := %GridToMove%TriggerLeft
    triggerRight  := %GridToMove%TriggerRight
    triggerBottom := %GridToMove%TriggerBottom
    GridTop       := %GridToMove%GridTop
    GridLeft      := %GridToMove%GridLeft
    GridRight     := %GridToMove%GridRight
    GridBottom    := %GridToMove%GridBottom

    WinGetClass, WinClass, A
    WinGet,      WindowId, id,     A
    WinGet,      WinStyle, Style,  A
    WinGetPos,   WinLeft,  WinTop, WinWidth, WinHeight, A

    if SafeMode
    if not (WinStyle & 0x40000)
    {
        return
    }
    if (WinClass = "DV2ControlHost" OR Winclass = "Progman"OR Winclass = "Shell_TrayWnd")
        return
    If Winclass in %Exceptions%
        return
    If (GridTop = )
        return

  If (GridLeft = "WindowWidth" AND GridRight = "WindowWidth")
  {
    WinGetClass,WinClass,A
    WinMove, A, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,
    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }
  If (GridTop = "WindowHeight" AND GridBottom = "WindowHeight")
  {
    WinGetClass,WinClass,A
    WinMove, A, ,%GridLeft%,%WinTop%, % GridRight - GridLeft,%WinHeight%,

    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }

    GridLeft   := round(GridLeft)
    GridTop    := round(GridTop)
    GridRight  := round(GridRight)
    GridBottom := round(GridBottom)
    GridWidth  := GridRight  - GridLeft
    GridHeight := GridBottom - GridTop

    ; TODO: Window border padding in Grid*
    GridLeft   := GridLeft   + offset_left
    GridWidth  := GridWidth  + offset_width
    GridTop    := GridTop    + offset_top
    GridHeight := GridHeight + offset_height

    WinMove,     A, , %GridLeft%, %GridTop%, %GridWidth%, %GridHeight%
    WinRestore,  A
    WinGetClass, WinClass, A
    StoreWindowState(WindowId, WinLeft, WinTop, WinWidth, WinHeight)
}

Command_Hide:
  critical,on
  Gosub, Cancel
  critical,off
  GoSub, HideGroups
  OSDHide()
  return

DefineHotkeys:
    loop,9
    {
        Hotkey, %FastMoveModifiers%%A_Index%, WinHotkeys
        Hotkey, %FastMoveModifiers%Numpad%A_Index%, WinHotkeys
    }

    Hotkey, %FastMoveModifiers%0, WinHotkeys10
    Hotkey, #e, FileManager
    if FastMoveMeta <>
    Hotkey, %FastMoveModifiers%%FastMoveMeta%, WinHotkeysMeta
    return

FileManager:
    Run Explorer++.exe
    return

WinHotkeys:
    StringRight,Number,A_ThisHotkey,1
    MoveToGrid(Number)
    return
WinHotkeys10:
    StringRight,Number,A_ThisHotkey,1
    MoveToGrid(10)
    return

MoveToPrevious:
    direction = back

MoveToNext:
  if direction <> back
    direction = forward

  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,A
  current = 0
  loop %NGroups%
  {
    triggerTop := %A_Index%TriggerTop
    triggerBottom := %A_Index%TriggerBottom
    triggerRight := %A_Index%TriggerRight
    triggerLeft := %A_Index%TriggerLeft

    GridToMove := A_index
    GridTop := %GridToMove%GridTop
    GridBottom := %GridToMove%GridBottom
    GridRight := %GridToMove%GridRight
    GridLeft := %GridToMove%GridLeft

    If GridTop = WindowHeight
      continue
    If GridLeft = WindowWidth
      continue
    If GridTop = AlwaysOnTop
      continue
    If GridTop = Maximize
      continue
    If GridTop = Run
      continue
    If GridTop = Restore
      continue

    GridTop := round(GridTop)
    GridBottom := round(GridBottom)
    GridRight := round(GridRight)
    GridLeft := round(GridLeft)

    GridHeight := GridBottom - GridTop
    GridWidth := GridRight - GridLeft

    ; TODO: Window border padding in Grid*
    GridLeft   := GridLeft   + offset_left
    GridWidth  := GridWidth  + offset_width
    GridTop    := GridTop    + offset_top
    GridHeight := GridHeight + offset_height

    if (WinTop    >= GridTop    - 200 && WinTop    <= GridTop    + 200
     && WinLeft   >= GridLeft   - 200 && WinLeft   <= GridLeft   + 200
     && WinHeight >= GridHeight - 200 && WinHeight <= GridHeight + 200
     && WinWidth  >= GridWidth  - 200 && WinWidth  <= GridWidth  + 200)
    {
      current := a_index
      break
    }
  }
  if (current = 0 AND direction = "back")
    current := ngroups + 1

  if direction = forward
  {
    loop %NGroups%
    {
      if (a_index <= current)
        continue

      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
  }

  if direction = back
  {
    loop %NGroups%
    {
      if (Ngroups - a_index + 1 >= current)
        continue

      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
  }
  direction =
  return
