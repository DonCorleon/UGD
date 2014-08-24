Gui_Config(){
	global Config,ConfigTree,ConfigSave,ConfigCancel
	static Languages,Platforms,Linux,Downloads,UserID,PassID
	IniRead,ConfigX,%A_ScriptDir%\Resources\Config.ini,ConfigGui,X,0
	IniRead,ConfigY,%A_ScriptDir%\Resources\Config.ini,ConfigGui,Y,0
	IniRead,ConfigW,%A_ScriptDir%\Resources\Config.ini,ConfigGui,W,200
	IniRead,ConfigH,%A_ScriptDir%\Resources\Config.ini,ConfigGui,H,200
	Config.ConfigX:=ConfigX,Config.ConfigY:=ConfigY,Config.ConfigW:=ConfigW,Config.ConfigH:=ConfigH
	Gui,Main:+Disabled
	Gui,Config:New,+hwndhwnd -DPIScale +ToolWindow +Resize +OwnerMain +MinSize200x200,Configuration
	Config.ConfigHwnd:=hwnd
	Gui,Config:Add,TreeView,% "w" Config.ConfigW " h" Config.ConfigH-35 " AltSubmit x0 y0 vConfigTree gConfigCheckClick checked +Wrap"
	Gui,Config:Add,Button,% "xp y" Config.ConfigH-30 " w" Config.ConfigW*.48 " vconfigsave gConfigSave",Save
	Gui,Config:Add,Button,% "x" Config.ConfigW*.52 " y" Config.ConfigH-30 " w" Config.ConfigW*.48 " vConfigCancel gConfigCancel",Cancel
	Credentials:=TV_Add("Credentials")
	UserID:=TV_Add("User = " Config.Username,Credentials)
	PassID:=TV_Add("Pass = " Config.Password,Credentials)
	Downloads:=TV_Add("Downloads")
	for a,b in Config.Downloads
		TV_Add(a,Downloads,"vDownload_%b% +check" b),Config.DownloadCount:=A_Index ;----Create initial count for select all status
	Platforms:=TV_Add("Platforms")
	for a,b in Config.Platforms
	{
		if (a="Linux")
			Linux:=TV_Add(a,Platforms,"vPlatform_%b% +check" b),Config.PlatformCount:=A_Index ;----Create initial count for select all status
		Else
			TV_Add(a,Platforms,"vPlatform_%b% First +check" b),Config.PlatformCount:=A_Index ;----Create initial count for select all status
	}
	Languages:=TV_Add("Languages")
	for a,b in Config.Languages
		TV_Add(a,Languages,"vLanguage_%b% +check" b),Config.LanguageCount:=A_Index ;----Create initial count for select all status
	For a,b in Config.Linux
		TV_Add(a,Linux,"vPlatform_Tarballs +check" Config.Linux[a])
	Gui,Config:Show, x%ConfigX% y%ConfigY% w%ConfigW% h%ConfigH%,Configuration
	UncheckList:=[Credentials,UserID,PassID,Downloads,Platforms,Languages] ; taken from Maestrith >> http://www.autohotkey.com/board/topic/96840-ahk-11-hide-individual-checkboxes-in-a-treeview-x32x64/
	VarSetCapacity(tvitem,28)
	for index,id in UncheckList{ ;loop through the array of id numbers
		info:=A_PtrSize=4?{0:8,4:id,12:0xf000}:{0:8,8:id,20:0xf000} ;there are 2 different offsets for x32 and x64.  This will account for both
		for offset,value in info
			NumPut(value,tvitem,offset)
		SendMessage,4415,0,&tvitem,SysTreeView321,ahk_id%hwnd%
		;4415 is tvm_setitemw which is tv_first=0x1100 + 63
	}
	Return
	ConfigGuiSize:
	{
		;tt(A_GuiWidth "x" A_GuiHeight,Config.ConfigW "x" Config.ConfigH)
		if !ConfigGuiSizeFirstRun{
			ConfigGuiSizeFirstRun:=1
			Return
		}
		Gui,Config:Default
		GuiControl,Config:MoveDraw,Configsave,% "y" A_Guiheight-30 " w" A_GuiWidth*.48
		GuiControl,Config:MoveDraw,ConfigCancel,% "x" A_Guiwidth*.52 " y" A_Guiheight-30 " w" A_GuiWidth*.48
		GuiControl,Config:MoveDraw,ConfigTree,% "w" A_Guiwidth " h" A_GuiHeight-35
		return
	}
	ConfigSave:
	{
		TreeItemID:=Languages
		Loop
		{
			TreeItemID:=TV_GetNext(TreeItemID,"Full")
			if !TreeItemID
				Break
			TV_GetText(Value,TreeItemID)
			config.Languages[value]:=Chosen:=TV_Get(TreeItemID,"Checked")?1:0
			IniWrite,%Chosen%,%A_ScriptDir%\Resources\Config.ini,Languages,%Value%
		}
		TreeItemID:=Downloads
		Loop
		{
			TreeItemID:=TV_GetNext(TreeItemID,"Full")
			if (!TreeItemID||TV_GetParent(TreeItemID)!=Downloads)
				Break
			TV_GetText(Value,TreeItemID)
			config.Downloads[value]:=Chosen:=TV_Get(TreeItemID,"Checked")?1:0
			IniWrite,%Chosen%,%A_ScriptDir%\Resources\Config.ini,Downloads,%Value%
		}
		TreeItemID:=Platforms
		Loop
		{
			TreeItemID:=TV_GetNext(TreeItemID,"Full")
			if (!TreeItemID||TV_GetParent(TreeItemID)!=Platforms)
				Break
			TV_GetText(Value,TreeItemID)
			config.Platforms[value]:=Chosen:=TV_Get(TreeItemID,"Checked")?1:0
			IniWrite,%Chosen%,%A_ScriptDir%\Resources\Config.ini,Platforms,%Value%
		}
		TreeItemID:=Linux
		Loop
		{
			TreeItemID:=TV_GetNext(TreeItemID,"Full")
			if (!TreeItemID||TV_GetParent(TreeItemID)!=Linux)
				Break
			TV_GetText(Value,TreeItemID)
			config.Linux[value]:=Chosen:=TV_Get(TreeItemID,"Checked")?1:0
			IniWrite,%Chosen%,%A_ScriptDir%\Resources\Config.ini,Linux,%Value%
		}
		
		ConfigGuiEscape:
		ConfigGuiClose:
		ConfigCancel:
		WinGetPos,X,Y,W,H,% "ahk_id" Config.ConfigHwnd
		IniWrite,%X%,%A_ScriptDir%\Resources\Config.ini,ConfigGui,X
		IniWrite,%Y%,%A_ScriptDir%\Resources\Config.ini,ConfigGui,Y
		IniWrite,% W-16,%A_ScriptDir%\Resources\Config.ini,ConfigGui,W
		IniWrite,% H-34,%A_ScriptDir%\Resources\Config.ini,ConfigGui,H
		Gui,Main:-Disabled
		Gui,Config:Destroy
		Return
	}
	ConfigCheckClick:
	{
		if !ConfigCheckClickFirstRun
			ConfigCheckClickFirstRun:=1
		if(A_GuiEvent="DoubleClick"&&A_EventInfo=UserID)
			Goto ConfigUsername
		else if(A_GuiEvent="DoubleClick"&&A_EventInfo=PassID)
			Goto ConfigPassword
		;Else
		;{
		;if ( TV_GetParent(A_EventInfo)=Downloads){ ;---- Count the checks in the Downloads Section
		;TotalChecked:=0
		;for a,b in Config.Downloads
		;TotalChecked+=Config.Downloads[a]
		;}
		;if ( TV_GetParent(A_EventInfo)=Platforms){ ;---- Count the checks in the Platforms section
		;TotalChecked:=0
		;for a,b in Config.Platforms
		;TotalChecked+=Config.Platforms[a]
		;}
		;if ( TV_GetParent(A_EventInfo)=Languages){ ;---- Count the checks in the Languages section
		;for a,b in Config.Languages
		;TotalChecked+=Config.Languages[a]
		;}
		;TV_Modify(A_EventInfo)
		;IsChecked:=,ClickedItem:=
		;TV_GetText(Parent,TV_GetParent(A_EventInfo))
		;if (Parent&&Parent!="Credentials")
		;{
		;TV_GetText(ClickedItem,A_EventInfo)
		;IsChecked:=TV_Get(A_EventInfo,"Check")?1:0
		;if (Config[Parent][ClickedItem]!=IsChecked)
		;tr(Parent "/" ClickedItem " Toggled`nOriginal State - " Config[Parent][ClickedItem],"Current State - " IsChecked)
		;}
		;Return
		;}
		Return
	}
	ConfigUsername:
	{
		InputBox,ConfigUsername,Credentials,Enter your GoG.com Username,,,,,,,,% Config.Username
		TV_Modify(UserID,,"User = " ConfigUserName)
		Config.Username:=ConfigUsername
		IniWrite,%ConfigUsername%,%A_ScriptDir%\Resources\Config.ini,Credentials,Username
		Return
	}
	ConfigPassword:
	{
		InputBox,ConfigPassword,Credentials,Enter your GoG.com Password,,,,,,,,% Config.Password
		TV_Modify(PassID,,"Pass = " ConfigPassword)
		Config.Password:=ConfigPassword
		IniWrite,%ConfigPassword%,%A_ScriptDir%\Resources\Config.ini,Credentials,Password
		Return
	}
}