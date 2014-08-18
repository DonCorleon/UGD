Gui_Config(){
	global Config,ConfigTree,ConfigSave,ConfigCancel
	static Languages,Platforms,Downloads,UserID,PassID
	Main_GuiHeight:=A_GuiHeight,Main_GuiWidth:=A_GuiWidth
	Gui,Main:+Disabled
	Gui,Config:New,+ToolWindow +Resize +OwnerMain +MinSize200x200,Configuration
	Gui,Config:Add,TreeView,x0 y0 vConfigTree gConfigCheckClick checked +Wrap
	Gui,Config:Add,Button,vconfigsave gConfigSave,Save
	Gui,Config:Add,Button,vConfigCancel gConfigCancel,Cancel
	Credentials:=TV_Add("Credentials")
	UserID:=TV_Add("User = " Config.Username,Credentials)
	PassID:=TV_Add("Pass = " Config.Password,Credentials)
	Downloads:=TV_Add("What To Download")
	for a,b in Config.Downloads
		TV_Add(a,Downloads,"vDownload_%b% +check" b)
	Platforms:=TV_Add("Platforms")
	for a,b in Config.Platforms
		TV_Add(a,Platforms,"vPlatform_%b% +check" b)
	Languages:=TV_Add("Languages")
	for a,b in Config.Languages
		TV_Add(a,Languages,"vLanguage_%b% +check" b)
	Gui,Config:Show, w200 h200,Configuration
	Return
	ConfigGuiSize:
	{
		Gui,Config:Default
		GuiControl,Config:MoveDraw,Configsave,% "y" A_Guiheight-30 " w" A_GuiWidth*.48
		GuiControl,Config:MoveDraw,ConfigCancel,% "x" A_Guiwidth*.52 " y" A_Guiheight-30 " w" A_GuiWidth*.48
		GuiControl,Config:MoveDraw,ConfigTree,% "w" A_Guiwidth " h" A_GuiHeight-35
		TrayTip,Config,% "w" A_Guiwidth " h" A_GuiHeight
		return
	}
	ConfigSave:
	{
		;Gui,Config:Submit,NoHide
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
		if(A_GuiEvent="DoubleClick"&&A_EventInfo=UserID)
			Goto ConfigUsername
		if(A_GuiEvent="DoubleClick"&&A_EventInfo=PassID)
			Goto ConfigPassword
		Return
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