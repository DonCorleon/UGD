Gui_ConfirmOrphans(OrphanList){
	global Config
	IniRead,X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X,% Config.MainX
	IniRead,Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y,% Config.MainY
	IniRead,W,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W,400
	IniRead,H,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H,400
	Gui,Main:+Disabled
	Gui,Orphan:New,+hwndhwnd -DPIScale +ToolWindow +Resize +OwnerMain +MinSize400x400,Orphan Confirmation
	OrphanHwnd:=Hwnd
	Gui,Orphans:Show,% "x" X " y" Y " w" W " h" H
	Return
	OrphanGuiEscape:
	OrphanGuiClose:
	OrphanCancel:
	{
		WinGetPos,X,Y,W,H,% "ahk_id" Config.OrphanHwnd
		IniWrite,% X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X
		IniWrite,% Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y
		IniWrite,% W-16,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W
		IniWrite,% H-34,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H
		Gui,Main:-Disabled
		Gui,Orphan:Destroy
		Return
	}
	OrphanGuiSize:
	{
		if !OrphanGuiSizeFirstRun{
			OrphanGuiSizeFirstRun:=1
			Return
		}
		return
	}
}