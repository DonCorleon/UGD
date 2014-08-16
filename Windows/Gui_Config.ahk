Gui_Config(){
	global Config
	static Languages,Platforms,Downloads,UserID,PassID
	Gui,Main:+Disabled
	Gui,Config:New,+ToolWindow +OwnerMain,Configuration
	Gui,Config:Add,TreeView, w300 r10 vConfigs gConfigCheckClick checked +Wrap
	Gui,Config:Add,Button,gConfigSave,Save
	Gui,Config:Add,Button,xp+40 yp gConfigCancel,Cancel
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
	Gui,Config:Show
	Return
	
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