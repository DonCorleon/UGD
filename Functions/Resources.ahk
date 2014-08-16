Resources(){
	Config:=[]
	;---- Ini Vars
	LanguageList:=Object("Arabic",0,"Chinese",0,"Czech",0,"Danish",0,"Dutch",0,"English",0,"Finnish",0,"French",0,"German",0,"Hungarian",0,"Italian",0,"Japanese",0,"Norwegian",0,"Polish",0,"Russian",0,"Spanish",0,"Swedish",0,"Turkish",0)
	TypeList:=Object("Installers",0,"Patches",0,"Downloadable_Content",0,"Language_Packs",0,"Extras",0,"Artwork",0,"Covers",0,"Videos",0)
	PlatformList:=Object("Windows",0,"MacOS",0,"Linux",0)
	
	;---- Resources dir
	IfNotExist %A_ScriptDir%\Resources
		FileCreateDir,%A_ScriptDir%\Resources
	IfNotExist %A_ScriptDir%\Resources\renamer.bat ;---- File used for pretty name of the games
		tt("..\Resources\renamer.bat is missing","GoG Folder Names will be used instead")
	IfNotExist %A_ScriptDir%\Resources\GoG.Dat ;----Used for checking crc's and validity of files
		tt("..\Resources\GoG.Dat is missing","Dat creation disabled")
	
	;---- Config File
	IfNotExist %A_ScriptDir%\Resources\Config.ini
		m("No configuration file found.`nDo you want to create one?")
	Else ;---- Readin config File Here
	{
		IniRead,Username,%A_ScriptDir%\Resources\Config.ini,Credentials,Username
		IniRead,Password,%A_ScriptDir%\Resources\Config.ini,Credentials,Password
		Config.Username:=Username
		Config.Password:=Password
		For a in LanguageList
		{
			IniRead,Value,%A_ScriptDir%\Resources\Config.ini,Languages,%a%
			If (Value="ERROR")
				continue
			LanguageList[a]:=value
			
		}
		For a in PlatformList
		{
			IniRead,Value,%A_ScriptDir%\Resources\Config.ini,Platforms,%a%
			If (Value="ERROR")
				continue
			PlatformList[a]:=value
		}
		For a in TypeList
		{
			IniRead,Value,%A_ScriptDir%\Resources\Config.ini,Downloads,%a%
			If (Value="ERROR")
				continue
			TypeList[a]:=value
		}
	}
	Config.Languages:=LanguageList
	Config.Downloads:=TypeList
	Config.Platforms:=PlatformList
	Return, Config
}