Gui_SelectGames(){
	Global Config,GameListView,List
	IniRead,X,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,X,% Config.MainX
	IniRead,Y,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,Y,% Config.MainY
	IniRead,W,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,W,400
	IniRead,H,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,H,400
	Config.SelectGamesX:=X,Config.SelectGamesY:=Y,Config.SelectGamesW:=W,Config.SelectGamesH:=H
	Gui,Main:+Disabled
	Gui,SelectGames:New,+hwndhwnd -Caption -border +Resize +OwnerMain +MinSize400x400
	Config.SelectGamesHwnd:=hwnd
	Gui,SelectGames:Font, s12 q2
	Gui,SelectGames:Add,ListView,% "+AltSubmit +NoSort -border checked Background000000 c0x00F003 +LV0x4000 -hScroll +vScroll x0 y0 w" Config.SelectGamesW " h" Config.SelectGamesH " vGameListView gListViewClick",game
	Gui,SelectGames:Show,% "x" Config.SelectGamesX " y" Config.SelectGamesY " w" Config.SelectGamesW " h" Config.SelectGamesH ,Select Games
	GuiControl,SelectGames:-Redraw,GameListView
	tick:=A_TickCount
	For a,b in List
		LV_Add("+check"b.Selected,b.Name) ;b.name)
	GuiControl,SelectGames:+Redraw,GameListView
	Return
}
ListViewClick:
{
	If (A_GuiEvent = "ColClick"){
		RowsChecked:=RowsChecked=1?0:1
		LV_Modify(0, "+Check" RowsChecked) 
		for a,b in List
			List[a].Selected:=RowsChecked
	}
	Return	
}
SelectGamesGuiSize:
{
	if !GameSelectGuiSizeFirstRun{
		GameSelectGuiSizeFirstRun:=1
		Return
	}LV_ModifyCol(1,A_GuiWidth-4,A_GuiWidth "/" A_GuiWidth)
	GuiControl,SelectGames:MoveDraw,GameListView,% "h" A_Guiheight " w" A_GuiWidth
	return
}

SelectGamesGuiSaveselection:
{
	SelectGamesGuiEscape:
	SelectGamesGuiClose:
	for a,b in List
		b.Selected:=0
	While, RowNumber := LV_GetNext(Rownumber,"Checked"){ ;Do the checking of selections here and modify List[a].Selected
		LV_GetText(game,Rownumber)
		for a,b in List
		{
			if (game=b.name){
				b.Selected:=1
				;m(game,Rownumber)
				break
			}
		}
	}
	WinGetPos,X,Y,W,H,% "ahk_id" Config.SelectGamesHwnd
	IniWrite,%X%,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,X
	IniWrite,%Y%,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,Y
	IniWrite,% W-14,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,W
	IniWrite,% H-14,%A_ScriptDir%\Resources\Config.ini,SelectGamesGui,H
	Gui,Main:-Disabled
	Gui,SelectGames:Destroy
	GuiControl,Main:Enable,ButtonGetGames
	Return
}