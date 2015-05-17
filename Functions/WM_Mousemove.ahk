WM_MOUSEMOVE()
{
	global Config
	static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
	CurrControl := A_GuiControl
	;if (currcontrol="ConfigTree")
	;return
	;else if (currcontrol="GameListView")
	;return
	;else if (currcontrol="OrphanTree")
	;return
	If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
	{
		ToolTip  ; Turn off any previous tooltip.
		SetTimer, DisplayToolTip, 1000
		PrevControl := CurrControl
	}
	return
	
	DisplayToolTip:
	SetTimer, DisplayToolTip, Off
	;if !(%CurrControl%_TT)
	;%CurrControl%_TT:="No tooltip set for " CurrControl
	if (currcontrol="ConfigTree"||currControl="GameListView"||currControl="OrphanTree")
	{
		goto RemoveToolTip
	}
	ToolTip % %CurrControl%_TT
	SetTimer, RemoveToolTip, 10000
	return
	
	RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	return
	
	return
}

WM_NOTIFY_TT(Param*) {
	global Config,List
	Static TVN_GETINFOTIPA := -412, TVN_GETINFOTIPW := -414, LVN_GETINFOTIPA := -157, LVN_GETINFOTIPW := -158, _TT
	Critical 500
	HWND := NumGet(Param.2 + 0, 0, "UPtr")
	Code := NumGet(Param.2 + 0, A_PtrSize * 2, "Int")
	If (((HWND = Config.TreeHwnd)||(Hwnd = Config.OrphanTVHwnd)) && ((Code = TVN_GETINFOTIPW) || (Code = TVN_GETINFOTIPA))) {
		;gui,Treeview,% HWND
		HITEM  := NumGet(Param.2 + 0, A_PtrSize * 5, "UPtr")
		TipPtr := NumGet(Param.2 + 0, A_PtrSize * 3, "UPtr")
		TipLen := NumGet(Param.2 + 0, A_Ptrsize * 4, "Int")
		TV_GetText(ItemText,HItem)
		;insert Treeview tips code here
		ItemText:=RegExReplace(ItemText," ","_")
		ItemText:=RegExReplace(ItemText,"\.","_")
		ItemText:=RegExReplace(ItemText,"\W(.*)","")
		TipTxt := %ItemText%_TT
		if !TipTxt
			TipTxt:="Nothing set for " ItemText
		StrPut(TipTxt, TipPtr, TipLen, Code = TVN_GETINFOTIPW ? "UTF-16" : "CP0")
		Return 0
	}
	else if (HWND=Config.ListHwnd) && ((Code = LVN_GETINFOTIPW) || (Code = LVN_GETINFOTIPA)) {
		Item   := NumGet(Param.2 + 4, A_PtrSize * 5, "UPtr")
		TipPtr := NumGet(Param.2 + 0, A_PtrSize * 4, "UPtr")
		TipLen := NumGet(Param.2 + 0, A_PtrSize * 5, "Int")
		Gui,Listview, % Config.ListHwnd
		GetText:=LV_GetNext(Item,"F")
		ItemText:=Config.TooltipArray[item+1]
		;Insert Listview tips here
		ItemText:=RegExReplace(ItemText,"[\W]*","")
		if List[ItemText]
			Title:=List[ItemText].Name,Rating:=List[itemtext].Rating,Description:=List[itemtext].Description,Genre:=List[itemtext].Genre
		else
			Title:="Not Scraped",Rating:="Not Scraped",Description:="Not Scraped",Genre:="Not Scraped"
		TipTxt := "GetText: " GetText "`nTitle: " Title "`nFolder: " List[ItemText].Folder "`nGenre: " Genre "`nRating: " Rating "`nDescription: " Description
		StrPut(TipTxt, TipPtr, TipLen, Code = LVN_GETINFOTIPW ? "UTF-16" : "CP0")
		Return 0
	}
	return
}
;Need to add something to not do a tooltip if none exists