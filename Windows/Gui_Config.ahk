Gui_Config(){
	global Config,ConfigTree,ConfigSave,ConfigCancel
	static Languages,Platforms,Downloads,UserID,PassID
	Main_GuiHeight:=A_GuiHeight,Main_GuiWidth:=A_GuiWidth
	Gui,Main:+Disabled
	Gui,Config:New,+hwndhwnd +ToolWindow +Resize +OwnerMain +MinSize200x200,Configuration
	Gui,Config:Add,TreeView,AltSubmit x0 y0 vConfigTree gConfigCheckClick checked +Wrap
	Gui,Config:Add,Button,vconfigsave gConfigSave,Save
	Gui,Config:Add,Button,vConfigCancel gConfigCancel,Cancel
	Credentials:=TV_Add("Credentials")
	UserID:=TV_Add("User = " Config.Username,Credentials)
	PassID:=TV_Add("Pass = " Config.Password,Credentials)
	Downloads:=TV_Add("Downloads")
	for a,b in Config.Downloads
		TV_Add(a,Downloads,"vDownload_%b% +check" b " +Vis"),Config.DownloadCount:=A_Index ;----Create initial count for select all status
	Platforms:=TV_Add("Platforms")
	for a,b in Config.Platforms
		TV_Add(a,Platforms,"vPlatform_%b% +check" b " +Vis" b),Config.PlatformCount:=A_Index ;----Create initial count for select all status
	Languages:=TV_Add("Languages")
	for a,b in Config.Languages
		TV_Add(a,Languages,"vLanguage_%b% +check" b " +Vis" b),Config.LanguageCount:=A_Index ;----Create initial count for select all status
	Gui,Config:Show, w200 h200,Configuration
	List:=[Credentials,UserID,PassID,Downloads,Platforms,Languages] ; taken from Maestrith >> http://www.autohotkey.com/board/topic/96840-ahk-11-hide-individual-checkboxes-in-a-treeview-x32x64/
	VarSetCapacity(tvitem,28)
	for index,id in list{ ;loop through the array of id numbers
		info:=A_PtrSize=4?{0:8,4:id,12:0xf000}:{0:8,8:id,20:0xf000} ;there are 2 different offsets for x32 and x64.  This will account for both
		for offset,value in info
			NumPut(value,tvitem,offset)
		SendMessage,4415,0,&tvitem,SysTreeView321,ahk_id%hwnd%
		;4415 is tvm_setitemw which is tv_first=0x1100 + 63
	}
	Return
	ConfigGuiSize:
	{
		if !ConfigGuiSizeFirstRun
			ConfigGuiSizeFirstRun:=1
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
		ConfigGuiClose:
		ConfigCancel:
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
		Else
		{
			if ( TV_GetParent(A_EventInfo)=Downloads){ ;---- Count the checks in the Downloads Section
				TotalChecked:=0
				for a,b in Config.Downloads
					TotalChecked+=Config.Downloads[a]
			}
			if ( TV_GetParent(A_EventInfo)=Platforms){ ;---- Count the checks in the Platforms section
				TotalChecked:=0
				for a,b in Config.Platforms
					TotalChecked+=Config.Platforms[a]
			}
			if ( TV_GetParent(A_EventInfo)=Languages){ ;---- Count the checks in the Languages section
				for a,b in Config.Languages
					TotalChecked+=Config.Languages[a]
			}
			TV_Modify(A_EventInfo)
			IsChecked:=,ClickedItem:=
			TV_GetText(Parent,TV_GetParent(A_EventInfo))
			if Parent
			{
				TV_GetText(ClickedItem,A_EventInfo)
				IsChecked:=TV_Get(A_EventInfo,"Check")?1:0
				;if (Config[Parent][ClickedItem]!=IsChecked)
				tr(Parent "/" ClickedItem " Toggled`nOriginal State - " Config[Parent][ClickedItem],"Current State - " IsChecked)
			}
			Return
		}
	}
	ConfigUsername:
	{
		InputBox,ConfigUsername,Credentials,Enter your GoG.com Username
		TV_Modify(UserID,,"User = " ConfigUserName)
		Config.Username:=ConfigUsername
		IniWrite,%ConfigUsername%,%A_ScriptDir%\Resources\Config.ini,Credentials,Username
		Return
	}
	ConfigPassword:
	{
		InputBox,ConfigPassword,Credentials,Enter your GoG.com Password
		TV_Modify(PassID,,"Pass = " ConfigPassword)
		Config.Password:=ConfigPassword
		IniWrite,%ConfigPassword%,%A_ScriptDir%\Resources\Config.ini,Credentials,Password
		Return
	}
}