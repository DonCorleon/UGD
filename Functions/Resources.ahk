Resources(){
	Config:=[]
	;---- Ini Vars
	LanguageList:=Object("Arabic",0,"Bulgarian",0,"Chinese",0,"Czech",0,"Danish",0,"Dutch",0,"English",0,"Finnish",0,"French",0,"German",0,"Greek",0,"Hungarian",0,"Italian",0,"Japanese",0,"Korean",0,"Norwegian",0,"Polish",0,"Portuguese",0,"Romanian",0,"Russian",0,"Serbian",0,"Slovac",0,"Spanish",0,"Swedish",0,"Turkish",0,"Ukranian",0)
	TypeList:=Object("Installers",0,"Patches",0,"DLCs",0,"Language Packs",0,"Extras",0,"Artwork",0,"Covers",0,"Videos",0)
	PlatformList:=Object("Windows",0,"Mac OS X",0,"Linux",0)
	LinuxList:=Object("Tarball Archive",0,"Debian Package",0)
	MovieList:=Object("1080p",0,"720p",0,"576p",0)
	;---- Resources dir
	IfNotExist %A_ScriptDir%\Resources
		FileCreateDir,%A_ScriptDir%\Resources
	IfNotExist %A_ScriptDir%\Resources\renamer.bat ;---- File used for pretty name of the games
		tt("..\Resources\renamer.bat is missing","GoG Folder Names will be used instead")
	IfNotExist %A_ScriptDir%\Resources\GoG.Dat ;----Used for checking crc's and validity of files
		tt("..\Resources\GoG.Dat is missing","Dat creation disabled")
	
	;---- Config File
	IfNotExist %A_ScriptDir%\Resources\Config.ini
	{
		tt("No Config File Found. Opening Configuration page....")
		Config.ConfigFound:=0
		Config.MainX:=200
		Config.MainY:=200
		Config.MainW:=350
		Config.MainH:=300
		
	}
	
	Else ;---- Readin config File Here
	{
		Config.ConfigFound:=1		
		IniRead,X,%A_ScriptDir%\Resources\Config.ini,MainGui,X,200
		IniRead,Y,%A_ScriptDir%\Resources\Config.ini,MainGui,Y,200
		IniRead,W,%A_ScriptDir%\Resources\Config.ini,MainGui,W,350
		IniRead,H,%A_ScriptDir%\Resources\Config.ini,MainGui,H,200
		IniRead,Username,%A_ScriptDir%\Resources\Config.ini,Credentials,Username
		IniRead,Password,%A_ScriptDir%\Resources\Config.ini,Credentials,Password
		IniRead,BaseLocation,%A_ScriptDir%\Resources\Config.ini,Locations,Base Folder,% A_ScriptDir
		IniRead,ArtLocation,%A_ScriptDir%\Resources\Config.ini,Locations,Artwork,% BaseLocation "\Artwork"
		IniRead,VideoLocation,%A_ScriptDir%\Resources\Config.ini,Locations,Videos,% BaseLocation "\Videos"
		Config.MainX:=X,Config.MainY:=Y,Config.MainW:=W,Config.MainH:=H
		Config.Username:=Username,Config.Password:=Password,Config.Location:=BaseLocation,Config.Artwork:=ArtLocation,Config.Videos:=VideoLocation
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
		For a in LinuxList
		{
			IniRead,Value,%A_ScriptDir%\Resources\Config.ini,Linux,%a%
			If (Value="ERROR")
				continue
			LinuxList[a]:=value
		}
	}
	Config.Languages:=LanguageList
	Config.Downloads:=TypeList
	Config.Platforms:=PlatformList
	Config.Linux:=LinuxList
	Config.Movies:=MovieList
	Return, Config
}