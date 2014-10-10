Gui_ConfirmOrphans(OrphanList){
	global Config,OrphanTree,MoveOrphans,DeleteOrphans,CancelOrphans,List,exclusions
	IniRead,X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X,% Config.MainX
	IniRead,Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y,% Config.MainY
	IniRead,W,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W,400
	IniRead,H,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H,400
	Config.OrphanGuiX:=X,Config.OrphanGuiY:=Y,Config.OrphanGuiW:=W,Config.OrphanGuiH:=H
	Gui,Main:+Disabled
	Gui,Orphan:New,+hwndhwnd -DPIScale +ToolWindow +Resize +OwnerMain +MinSize400x400
	Config.OrphanHwnd:=Hwnd
	Gui,Orphan:Add,TreeView,% "w" W-20 " h" H-50 " AltSubmit vOrphanTree gOrphanTree +hwndhwnd +Checked"
	Config.OrphanTVHwnd:=Hwnd
	Gui,Orphan:Add,Button,% "x10 y" H-40 " h30 w" W/3-20 " vMoveOrphans gMoveOrphans", Move
	Gui,Orphan:Add,Button,% "xp+" W/3 " y" H-40 " h30 w" W/3-20 " vDeleteOrphans", Delete
	Gui,Orphan:Add,Button,% "xp+" W/3 " y" H-40 " h30 w" W/3-20 " vCancelOrphans gOrphanButtonCancel", Cancel
	Gui,Orphan:Treeview,% hwnd
	;---- Load Exclusion List if it exists
	ifExist,% A_ScriptDir "\Resources\ExclusionList.Txt"
	{
		FileRead,Exclusions,% A_ScriptDir "\Resources\ExclusionList.Txt"
		Exclusions:=StrSplit(Exclusions,"`n"," `r`n")
	}
	For a,b in OrphanList
	{
		Parent:=TV_Add(a) ;List[a].Name)
		for c,d in b
		{
			If !Exclusions.1
				Child:=TV_Add(d,parent,"+Check")
			else
			{
				InList:=1
				for e,f in Exclusions
				{
					If (f=Config.Location a "\" d||f=Config.Location a )
					{
						InList:=0
						;m(Config.Location a "\" d,">" f "<","+Check" InList)
						break
					}
				}
				Child:=TV_Add(d,parent,"+Check" InList)
			}
		}
	}
	Gui,Orphan:Show,% "x" X " y" Y " w" W " h" H,Orphan Confirmation
	Return
	MoveOrphans:
	{
		tt("Moving Orphaned Files")
		ifNotExist % Config.Location "\Cleaned"
			FileCreateDir, % Config.Location "\Cleaned"
		for a,b in OrphanFiles
			for c,d in b
			{
				tt("Moving " a "\" d)
				ifNotExist % Config.Location "\Cleaned\" a 
					FileCreateDir, % Config.Location "\Cleaned\" a
				FileMove,% Config.Location a "\" d,% Config.Location "Cleaned\" a "\" d
			}
		tt("Moving Complete")
	}
	
	OrphanTree:
	{
		Gui,Orphan:Treeview,% Config.OrphanTVHwnd
		if (A_GuiEvent&&A_GuiEvent = "RightClick")
		{
			ExcludeFolder:=TV_GetParent(A_EventInfo)
			if (!ExcludeFolder)
			{
				TV_GetText(ExcludeFolder,A_EventInfo)
				if Exclusions.1
				{
					found:=0
					for a,b in Exclusions
					{
						if (b=Config.Location ExcludeFolder)
						{
							Exclusions.Remove(a)
							;m("Removing " b " from excluded list")
							found:=1
							TV_Modify(A_EventInfo,"+Select +Check")
						}
					}
					if !found
					{
						Exclusions.Insert(Config.Location ExcludeFolder)
						;m("Added Exclude folder : " Config.Location ExcludeFolder)
						TV_Modify(A_EventInfo,"+Select -Check")
					}
				}
				else 
				{
					;m("Exclude folder : " Config.Location ExcludeFolder)
					Exclusions.Insert(Config.Location ExcludeFolder)
					TV_Modify(A_EventInfo,"+Select -Check")
				}
				
				;---- Add to Exclusion List and change colour to red Here
			}
			else
			{
				TV_GetText(ExcludeFolder,ExcludeFolder)
				TV_GetText(ExcludeFile,A_EventInfo)
				if Exclusions.1
				{
					found:=0
					for a,b in Exclusions
					{
						if (b=Config.Location ExcludeFolder "\" ExcludeFile)
						{
							Exclusions.Remove(a)
							;m("Removing " b " from excluded list")
							found:=1
							TV_Modify(A_EventInfo,"+Select +Check")
							break
						}
					}
					if !found
					{
						Exclusions.Insert(Config.Location ExcludeFolder "\" ExcludeFile)
						;m("Added Exclude file : " Config.Location ExcludeFolder "\" ExcludeFile)
						TV_Modify(A_EventInfo,"+Select -Check")
					}
				}
				else
				{
					;m("Exclude File : " Config.Location ExcludeFolder "\" ExcludeFile)
					Exclusions.Insert(Config.Location ExcludeFolder "\" ExcludeFile)
					TV_Modify(A_EventInfo,"+Select -Check")
				}
				;---- Add to Exclusion List and change colour to red Here
			}
		}
		return
	}
	OrphanGuiEscape:
	OrphanGuiClose:
	OrphanButtonCancel:
	OrphanCancel:
	{
		WinGetPos,X,Y,W,H,% "ahk_id" Config.OrphanHwnd
		IniWrite,% X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X
		IniWrite,% Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y
		IniWrite,% W-16,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W
		IniWrite,% H-34,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H
		Gui,Main:-Disabled
		Gui,Orphan:Destroy
		for a,b in Exclusions
			EList.=Trim(b) "`n"
		m(">" EList "<")
		FileDelete,% A_ScriptDir "\Resources\ExclusionList.Txt"
		FileAppend,% Trim(EList),% A_ScriptDir "\Resources\ExclusionList.Txt"
		Return
	}
	OrphanGuiSize:
	{
		if !OrphanGuiSizeFirstRun{
			OrphanGuiSizeFirstRun:=1
			Return
		}
		GuiControl,Orphan:MoveDraw,OrphanTree,% "w" A_GuiWidth-20 " h" A_GuiHeight-50
		GuiControl,Orphan:MoveDraw,MoveOrphans,% "x10 y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		GuiControl,Orphan:MoveDraw,DeleteOrphans,% "xp+" A_GuiWidth/3 " y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		GuiControl,Orphan:MoveDraw,CancelOrphans,% "xp+" A_GuiWidth/3 " y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		
		return
	}
}