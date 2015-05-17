Gui_Config(){
	global Config,ConfigTree,ConfigSave,ConfigCancel
	static Locations,Languages,Platforms,Linux,Downloads,Movies,UserID,PassID,BaseDir,PatchDir,DLCDir,ArtworkDir,VideoDir,OrphansDir
	IniRead,X,%A_ScriptDir%\Resources\Config.ini,ConfigGui,X,% Config.MainX
	IniRead,Y,%A_ScriptDir%\Resources\Config.ini,ConfigGui,Y,% Config.MainY
	IniRead,W,%A_ScriptDir%\Resources\Config.ini,ConfigGui,W,200
	IniRead,H,%A_ScriptDir%\Resources\Config.ini,ConfigGui,H,200
	Config.ConfigX:=X,Config.ConfigY:=Y,Config.ConfigW:=W,Config.ConfigH:=H
	Gui,Main:+Disabled
	Gui,Config:New,+hwndhwnd -DPIScale +ToolWindow +Resize +OwnerMain +MinSize200x200,Configuration
	Config.ConfigHwnd:=hwnd
	Gui,Config:Add,TreeView,% "w" Config.ConfigW " h" Config.ConfigH-35 " AltSubmit x0 y0 vConfigTree gConfigCheckClick checked HwndHwnd +0x0800"
	Config.TreeHwnd:=Hwnd
	Gui,Config:Add,Button,% "xp y" Config.ConfigH-30 " w" Config.ConfigW*.48 " vconfigsave gConfigSave",Save
	Gui,Config:Add,Button,% "x" Config.ConfigW*.52 " y" Config.ConfigH-30 " w" Config.ConfigW*.48 " vConfigCancel gConfigCancel",Cancel
	
	Credentials:=TV_Add("Credentials")
	UserID:=TV_Add("User = " Config.Username,Credentials)
	PassID:=TV_Add("Pass = " Config.Password,Credentials)
	Location:=["Base","Patches","DLC","Artwork","Videos","Orphans"]
	
	Locations:=TV_Add("Locations")
	BaseDir:=TV_Add("Base Dir = " Config.Location,Locations)
	PatchDir:=TV_Add("Patches = " Config.Patch,Locations)
	DLCDir:=TV_Add("DLC = " Config.DLC,Locations)
	ArtworkDir:=TV_Add("Artwork = " Config.Artwork,Locations)
	VideoDir:=TV_Add("Videos = " Config.Videos,Locations)
	OrphansDir:=TV_Add("Orphans = " Config.Orphans,Locations)
	
	Downloads:=TV_Add("Downloads")
	for a,b in Config.Downloads
		TV_Add(a,Downloads,"vDownload_%b% +check" b),Config.DownloadCount:=A_Index ;----Create initial count for select all status
	Movies:=TV_Add("Movies")
	for a,b in Config.Movies
		TV_Add(a,Movies,"vMovie_%b% +noSort +check" b),Config.MovieCount:=A_Index ;----Create initial count for select all status
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
	Gui,Config:Show,% "x" Config.ConfigX " y" Config.ConfigY " w" Config.ConfigW " h"  Config.ConfigH,Configuration
	UncheckList:=[Movies,Credentials,UserID,PassID,Downloads,Platforms,Languages,Locations,BaseDir,PatchDir,DLCDir,ArtworkDir,VideoDir,OrphansDir] ; taken from Maestrith >> http://www.autohotkey.com/board/topic/96840-ahk-11-hide-individual-checkboxes-in-a-treeview-x32x64/
	VarSetCapacity(tvitem,28)
	for index,id in UncheckList{ ;loop through the array of id numbers
		info:=A_PtrSize=4?{0:8,4:id,12:0xf000}:{0:8,8:id,20:0xf000} ;there are 2 different offsets for x32 and x64.  This will account for both
		for offset,value in info
			NumPut(value,tvitem,offset)
		SendMessage,4415,0,&tvitem,SysTreeView321,% "ahk_id" Config.ConfigHwnd
		;4415 is tvm_setitemw which is tv_first=0x1100 + 63
	}
	Return
	ConfigGuiSize:
	{
		if !ConfigGuiSizeFirstRun{
			ConfigGuiSizeFirstRun:=1
			Return
		}
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
		TreeItemID:=Movies
		Loop
		{
			TreeItemID:=TV_GetNext(TreeItemID,"Full")
			if (!TreeItemID||TV_GetParent(TreeItemID)!=Movies)
				Break
			TV_GetText(Value,TreeItemID)
			config.Movies[value]:=Chosen:=TV_Get(TreeItemID,"Checked")?1:0
			IniWrite,%Chosen%,%A_ScriptDir%\Resources\Config.ini,Movies,%Value%
		}
		
		ConfigGuiEscape:
		ConfigGuiClose:
		ConfigCancel:
		WinGetPos,X,Y,W,H,% "ahk_id" Config.ConfigHwnd
		IniWrite,% X,%A_ScriptDir%\Resources\Config.ini,ConfigGui,X
		IniWrite,% Y,%A_ScriptDir%\Resources\Config.ini,ConfigGui,Y
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
		else if(A_GuiEvent="DoubleClick"&&A_EventInfo=BaseDir)
			Goto ConfigLocation
		else if(A_GuiEvent="DoubleClick"&&A_EventInfo=ArtworkDir)
			Goto ConfigArtworkLocation
		else if(A_GuiEvent="DoubleClick"&&A_EventInfo=VideoDir)
			Goto ConfigVideoLocation
		else if(A_GuiEvent="DoubleClick"&&A_EventInfo=OrphansDir)
			Goto ConfigOrphansLocation
		;Insert code in here to do select all/none and change check box on main parent accordingly
		Return
	}
	ConfigLocation:
	{
		FileSelectFolder,Location,,,Select a folder to save files to....
		if Location
		{
			InvalidLocation:=RegExMatch(Location,"^\\\\")
			if InvalidLocation
				m("Network locations are not currently supported unless its is a mapped drive.`n`nComing soon to an update near you!!")
			AddIt:=RegExMatch(Location,"\\$")
			if !AddIt
				Location.="\"
			Config.Location:=Location
			IniWrite,% Location,%A_ScriptDir%\Resources\Config.ini,Locations,Base Folder
		}
		If !Config.Location
			Config.Location:=A_ScriptDir
		TV_Modify(BaseDir,,"Location = " Config.Location)
		Return	
	}
	ConfigArtworkLocation:
	{
		FileSelectFolder,Location,,,Select a folder to save artwork to....
		if Location
		{
			InvalidLocation:=RegExMatch(Location,"^\\\\")
			if InvalidLocation
				m("Network locations are not currently supported unless its is a mapped drive.`n`nComing soon to an update near you!!")
			Config.Artwork:=Location
			IniWrite,% Location,%A_ScriptDir%\Resources\Config.ini,Locations,Artwork
		}
		If !Config.Artwork
			Config.Artwork:=Config.Location "\Artwork"
		TV_Modify(ArtworkDir,,"Artwork = " Config.Artwork)
		Return	
	}
	ConfigVideoLocation:
	{
		FileSelectFolder,Location,,,Select a folder to save Youtube Videos to....
		if Location
		{
			InvalidLocation:=RegExMatch(Location,"^\\\\")
			if InvalidLocation
				m("Network locations are not currently supported unless its is a mapped drive.`n`nComing soon to an update near you!!")
			Config.Videos:=Location
			IniWrite,% Location,%A_ScriptDir%\Resources\Config.ini,Locations,Videos
		}
		If !Config.Videos
			Config.Videos:=Config.Location "\Artwork"
		TV_Modify(VideoDir,,"Videos = " Config.Videos)
		Return	
	}
	ConfigOrphansLocation:
	{
		FileSelectFolder,Location,,,Select a folder to move Orphaned files to....
		if Location
		{
			InvalidLocation:=RegExMatch(Location,"^\\\\")
			if InvalidLocation
				m("Network locations are not currently supported unless its is a mapped drive.`n`nComing soon to an update near you!!")
			Config.Orphans:=Location
			IniWrite,% Location,%A_ScriptDir%\Resources\Config.ini,Locations,Orphans
		}
		If !Config.Orphans
			Config.Orphans:=Config.Location "\Cleaned"
		TV_Modify(OrphansDir,,"Orphans = " Config.Orphans)
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