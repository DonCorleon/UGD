DetermineFolder(game,DownloadType){
	global Config
	if !Config.ConventionNaming
	{
		FileRead,TempVar,% A_ScriptDir "\Resources\" Config.names
		ConventionNaming:=[]
		Loop,Parse,TempVar,`r
		{
			RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)(| \[DLC\])" Chr(34),found)
			ConventionNaming[Found1]:=Object("GoGFolder",Found1,"ConnieFolder",Found2)
		}
		Config.ConventionNaming:=ConventionNaming
		tt("Naming Conventions loaded")
	}
	if Config.ConventionNaming[game]
	{
		if (Config.NameConvention="Connie")
		{
			IfExist,% Config[DownloadType] "\" Config.ConventionNaming[Game].GoGFolder
			{
				FileMoveDir,% Config[DownloadType] "\" Config.ConventionNaming[Game].GoGFolder,% Config[DownloadType] "\" Config.ConventionNaming[Game].ConnieFolder,2
				if !Errorlevel
					tt("Converted folder " Config.ConventionNaming[Game].GoGFolder " to Connie's naming convention.")
				else
				{
					tt("Error renaming folder " Config.ConventionNaming[Game].GoGFolder)
					tt(Config[DownloadType])
					tt(Config.NameConvention)
				}
			}
			Folder:=Config.ConventionNaming[game].ConnieFolder
		}
		Else if (Config.NameConvention="GoG")
		{
			IfExist,% Config[DownloadType] "\" Config.ConventionNaming[Game].ConnieFolder
			{
				FileMoveDir,% Config[DownloadType] "\" Config.ConventionNaming[Game].ConnieFolder,% Config[DownloadType] "\" Config.ConventionNaming[Game].GoGFolder,2
				if !Errorlevel
					tt("Converted folder " Config.ConventionNaming[Game].ConnieFolder " to Connie's naming convention.")
				else
				{
					tt("Error renaming folder " Config.ConventionNaming[Game].ConnieFolder)
					tt(Config[DownloadType])
					tt(Config.NameConvention)
				}
			}
			Folder:=Config.ConventionNaming[game].GoGFolder
		}
		else
			Folder:=game
	}
	else
		Folder:=game
	Return, Folder
}