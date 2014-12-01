Gui_ConfirmOrphans(OrphanList){
	global Config,List,OrphanTree,MoveOrphans,DeleteOrphans,CancelOrphans,OrphanFiles
	Static FolderColour:="0xff0000",ExclusionColour:="0x0000ff",OrphanColour:="0x00ff00",TV,Exclusions,
	Static TheList,UncheckList,OrphanGuiSizeFirstRun
	TheList:=OrphanList
	
	Config.OrphanExtras:=1
	
	IniRead,X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X,% Config.MainX
	IniRead,Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y,% Config.MainY
	IniRead,W,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W,400
	IniRead,H,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H,400
	Config.OrphanGuiX:=X,Config.OrphanGuiY:=Y,Config.OrphanGuiW:=W,Config.OrphanGuiH:=H
	Gui,Main:+Disabled
	Gui,Orphan:New,+hwndhwnd -DPIScale +ToolWindow +Resize +OwnerMain +MinSize400x400
	Config.OrphanHwnd:=Hwnd
	Gui,Orphan:Add,TreeView,% "w" W-20 " h" H-50 " AltSubmit vOrphanTree gOrphanTree BackgroundBlack +hwndhwnd +Checked"
	Config.OrphanTVHwnd:=Hwnd
	Gui,Orphan:Add,Button,% "x10 y" H-40 " h30 w" W/3-20 " vMoveOrphans gMoveOrphans", Move
	Gui,Orphan:Add,Button,% "xp+" W/3 " y" H-40 " h30 w" W/3-20 " vDeleteOrphans gDeleteOrphans", Delete
	Gui,Orphan:Add,Button,% "xp+" W/3 " y" H-40 " h30 w" W/3-20 " vCancelOrphans gOrphanButtonCancel", Cancel
	tv:=new treeview(Config.OrphanTVHwnd)
	;Gui,TreeView,SysTreeView321
	
	;---- Load Exclusion List if it exists
	ifExist,% A_ScriptDir "\Resources\ExclusionList.Txt"
	{
		FileRead,Temp,% A_ScriptDir "\Resources\ExclusionList.Txt"
		Exclusions:=StrSplit(Temp,"`n"," `r`n")
	}
	UncheckList:=[]
	For a,b in TheList
	{
		if !Exclusions.1
			Node:=TV.Add({Label:a,Fore:OrphanColour})
		else
		{
			for j,k in Exclusions
			{
				SetColour:=FolderColour
				If (k=Config.Location a )
				{
					SetColour:=ExclusionColour
					break
				}
			}
			Node:=TV.Add({Label:a,Fore:SetColour})
		}
		UnCheckList.Insert(Node)
		for c,d in b
		{
			If !Exclusions.1
				Child:=Tv.Add({Label:d,Fore:OrphanColour,parent:node,option:"+Check"})
			else
			{
				InList:=1
				for e,f in Exclusions
				{
					SetColour:=OrphanColour
					FoundFolder:=RegExMatch(f,"^" Config.Location a "\\")
					;If FoundFolder
					;m("Found It ",f,Config.Location a "\\")
					If (f=Config.Location a "\" d||FoundFolder )
					{
						InList:=0
						SetColour:=ExclusionColour
						Tv.modify({hwnd:node,fore:ExclusionColour})
						;m(Config.Location a "\" d,">" f "<","+Check" InList,"Colour - " SetColour,"Node - " Node)
						break
					}
				}
				;Child:=TV_Add(d,parent,"+Check" InList)
				Child:=Tv.Add({Label:d,Fore:SetColour,parent:node,option:"Vis +Check" InList})
				;m(d,SetColour,Node,InList,a)
			}
		}
	}
	Gui,Orphan:Show,% "x" X " y" Y " w" W " h" H,Orphan Confirmation
	
	VarSetCapacity(tvitem,28)
	for index,id in UncheckList
	{ ;loop through the array of id numbers
		info:=A_PtrSize=4?{0:8,4:id,12:0xf000}:{0:8,8:id,20:0xf000} ;there are 2 different offsets for x32 and x64.  This will account for both
		for offset,value in info
			NumPut(value,tvitem,offset)
		SendMessage,4415,0,&tvitem,SysTreeView321,% "ahk_id" Config.OrphanHwnd
		;4415 is tvm_setitemw which is tv_first=0x1100 + 63
	}
	;for a,b in Unchecklist
	;Listing.=a "=" b "`n"
	;m(Listing)
	Return
	
	MoveOrphans:
	{
		MsgBox,4404,Confirmation,Are you sure you want to move all checked orphan files?
		IfMsgBox,No
		{
			tt("Aborted Moving Orphans")
			return
		}
		IfMsgBox,Cancel
		{
			tt("Aborted Moving Orphans")
			return
		}
		OrphanCount:=0,FolderCount:=0
		tt("Moving Orphaned Files")
		for a,b in TheList
		{
			FolderCount++
			for c,d in b
				OrphanCount++
		}
		ifNotExist % Config.Orphans
			FileCreateDir, % Config.Orphans
		ItemID:= 0
		OrphanMoved:=0
		Looper:=OrphanCount+FolderCount
		Loop,% Looper
		{
			ItemID := TV_GetNext(ItemID, "Full")  ; Replace "Full" with "Checked" to find all checkmarked items.
			ParentID:=TV_GetParent(ItemID)
			if !ParentID
				Continue
			TV_GetText(ParentText,ParentID)
			If TV_Get(ItemID,"Check")
			{
				TV_GetText(ItemText, ItemID)
				Splitpath,ItemText,,,FileExt
				;if (Config.OrphanExtras&&FileExt="zip")
				;continue
				;tt("Moving " ParentText "\" ItemText)
				for a,b in TheList
				{
					for c,d in b
					{
						if (a=ParentText&&d=ItemText)
						{
							ifNotExist % Config.Orphans "\" a 
								FileCreateDir, % Config.Orphans "\" a
							FileMove,% Config.Location "\" a "\" d,% Config.Orphans "\" a "\" d,1
							if (!ErrorLevel)
							{
								OrphanMoved++
								tt("[Yellow]Moved[/] - " Config.Orphans "\" a "\" d)
								TheList[a].Remove(c)
								break
							}
							else
								tt("[red]Error moving[/] - " Config.Orphans "\" a "\" d)
						}
					}
					if !(TheList[a].MaxIndex())
					{
						TheList.Remove(a)
					}
				}
			}
		}
		tt("Moved " OrphanMoved " of " OrphanCount " orphaned files.")
		Goto OrphanGuiClose
		return
	}
	DeleteOrphans:
	{
		MsgBox,4404,Confirmation,Are you sure you want to delete all checked orphan files?
		IfMsgBox,No
		{
			tt("Aborted Orphan Deletion")
			return
		}
		IfMsgBox,Cancel
		{
			tt("Aborted Orphan Deletion")
			return
		}
		OrphanCount:=0
		FolderCount:=0
		tt("Deleting Orphaned Files")
		for a,b in TheList
		{
			FolderCount++
			for c,d in b
				OrphanCount++
		}
		ItemID:= 0
		OrphanDeleted:=0
		Looper:=OrphanCount+FolderCount
		Loop,% Looper
		{
			ItemID := TV_GetNext(ItemID, "Full")  ; Replace "Full" with "Checked" to find all checkmarked items.
			ParentID:=TV_GetParent(ItemID)
			if !ParentID
				Continue
			TV_GetText(ParentText,ParentID)
			If TV_Get(ItemID,"Check")
			{
				TV_GetText(ItemText, ItemID)
				Splitpath,ItemText,,,FileExt
				for a,b in TheList
				{
					for c,d in b
					{
						if (a=ParentText&&d=ItemText)
						{
							FileDelete,% Config.Location "\" a "\" d
							if (!ErrorLevel)
							{
								OrphanDeleted++
								tt("[yellow]Deleted[/] - " Config.Orphans "\" a "\" d)
								TheList[a].Remove(c)
								break
							}
							else
								tt("[red]Error deleting[/] - " Config.Orphans "\" a "\" d)
						}
					}
					if !(TheList[a].MaxIndex())
					{
						TheList.Remove(a)
					}
				}
			}
		}
		tt("Deleted " OrphanDeleted " of " OrphanCount " orphaned files.")
		Goto OrphanGuiClose
		return
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
							TV_Modify(A_EventInfo,"+Select +Check")
							Exclusions.Remove(a)
							found:=1
							Tv.modify({hwnd:A_EventInfo,fore:OrphanColour})
							;m("Removing " b " from excluded list",A_EventInfo)
						}
					}
					if !found
					{
						TV_Modify(A_EventInfo,"+Select -Check")
						Exclusions.Insert(Config.Location ExcludeFolder)
						Tv.modify({hwnd:A_EventInfo,fore:ExclusionColour})
						;m("Added Exclude folder : " Config.Location ExcludeFolder,A_EventInfo)
					}
				}
				else 
				{
					TV_Modify(A_EventInfo,"+Select -Check")
					Exclusions.Insert(Config.Location ExcludeFolder)
					Tv.modify({hwnd:A_EventInfo,fore:ExclusionColour})
					;m("Exclude folder : " Config.Location ExcludeFolder,A_EventInfo)
				}
				
				;---- Add to Exclusion List and change colour to red Here
			}
			else
			{
				ParentFolder:=ExcludeFolder
				TV_GetText(ExcludeFolder,ExcludeFolder)
				TV_GetText(ExcludeFile,A_EventInfo)
				if Exclusions.1
				{
					found:=0
					for a,b in Exclusions
					{
						if (b=Config.Location ExcludeFolder "\" ExcludeFile||b=Config.Location ExcludeFolder )
						{
							TV_Modify(A_EventInfo,"+Select +Check")
							Tv.modify({hwnd:A_EventInfo,fore:OrphanColour})
							Tv.modify({hwnd:TV_GetParent(A_EventInfo),fore:OrphanColour})
							Exclusions.Remove(a)
							;m("Removing " b " from excluded list",A_EventInfo,OrphanColour)
							found:=1
							break
						}
					}
					if !found
					{
						TV_Modify(A_EventInfo,"+Select -Check")
						Exclusions.Insert(Config.Location ExcludeFolder "\" ExcludeFile)
						Tv.modify({hwnd:A_EventInfo,fore:ExclusionColour})
						;m("Added Exclude file : " Config.Location ExcludeFolder "\" ExcludeFile,A_EventInfo,ExclusionColour)
					}
				}
				else
				{
					TV_Modify(A_EventInfo,"+Select -Check")
					Exclusions.Insert(Config.Location ExcludeFolder "\" ExcludeFile)
					Tv.modify({hwnd:A_EventInfo,fore:ExclusionColour})
					;m("Exclude File : " Config.Location ExcludeFolder "\" ExcludeFile)
				}
				;---- Add to Exclusion List and change colour to red Here
				;m("Here")
				;WinSet,Redraw,,% "ahk_id" Config.OrphanTVHwnd
			}
		}
		return
	}
	OrphanGuiEscape:
	OrphanGuiClose:
	OrphanButtonCancel:
	OrphanCancel:
	{
		OrphanFiles:=[]
		OrphanFiles:=TheList
		WinGetPos,X,Y,W,H,% "ahk_id" Config.OrphanHwnd
		IniWrite,% X,%A_ScriptDir%\Resources\Config.ini,OrphanGui,X
		IniWrite,% Y,%A_ScriptDir%\Resources\Config.ini,OrphanGui,Y
		IniWrite,% W-16,%A_ScriptDir%\Resources\Config.ini,OrphanGui,W
		IniWrite,% H-34,%A_ScriptDir%\Resources\Config.ini,OrphanGui,H
		Gui,Main:-Disabled
		Gui,Orphan:Destroy
		for a,b in Exclusions
			if b
				EList.=Trim(b) "`n"
		;m(">" EList "<")
		FileDelete,% A_ScriptDir "\Resources\ExclusionList.Txt"
		FileAppend,% Trim(EList),% A_ScriptDir "\Resources\ExclusionList.Txt"
		Return
	}
	OrphanGuiSize:
	{
		if !OrphanGuiSizeFirstRun
		{
			OrphanGuiSizeFirstRun:=1
			Return
		}
		;TrayTip,Gui Size,W %A_GuiWidth%`nH %A_GuiHeight%,2
		GuiControl,Orphan:MoveDraw,OrphanTree,% "x5 w" A_GuiWidth-10 " h" A_GuiHeight-50
		GuiControl,Orphan:MoveDraw,MoveOrphans,% "x10 y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		GuiControl,Orphan:MoveDraw,DeleteOrphans,% "x" A_GuiWidth/3+10 " y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		GuiControl,Orphan:MoveDraw,CancelOrphans,% "x" A_GuiWidth/3*2+10 " y" A_GuiHeight-40 " h30 w" A_GuiWidth/3-20
		return
	}
}