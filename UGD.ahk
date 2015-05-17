Testing:=0

version:="Alpha"
;auto_version
#SingleInstance,force
SetBatchLines = -1
;******** Global Vars
Global Cookie,status,Config:=[],OrphanFiles:=[],ConfigTree
DEBUG_Times:=0

HTTP:=Object("GoGCookie","") ;----Create the basic HTTP Object
API:=Object("Consumer_Key","1f444d14ea8ec776585524a33f6ecc1c413ed4a5" ; Create the Basic API Object
,"Consumer_Secret","20d175147f9db9a10fc0584aa128090217b9cf88"
,"oauth_get_urls","https://api.gog.com/downloader2/status/stable/")

; Create the Basic Test Gui
Config:=Resources()
Gui,Main:New,+OwnDialogs +Resize +MinSize700x400 +hwndhwnd,Ultimate GoG Downloader v%Version%
Config.Mainhwnd:=hwnd
Gui,Main:Add,Checkbox,% "x0 y0 vChecksums gChecksums Checked" Config.Checksums, Compare Check&sums (Slow)
Gui,Main:Add,Checkbox,% "xp yp+15 vDefinitions gDefinitions Checked" Config.Definitions, &Latest Definitions
Gui,Main:Add,Checkbox,% "xp yp+15 vOrphans gOrphans Checked" Config.CheckOrphans, Check Orp&hans only
Gui,Main:Add,Checkbox,% "xp+160 yp-30 vUsePreviousLogin gUsePreviousLogin Checked" Config.UsePreviousLogin, Use &Previous Login
Gui,Main:Add,Checkbox,% "xp yp+15 vPrettyNames gPrettyNames Checked" Config.PrettyNames, Use Connie's folder names
Gui,Main:Add,Button,% "Disabled xp yp+15 h20 vAligntoDat gAlignToDat", Compare to Dat
Gui,Main:Add,Button,% "x" Config.MainW-200 " y0 w80 vButtonLogin gButtonLogin",&Login
gui,Main:Add,Button,% "x" Config.MainW-130 " y0 w80 vConfigWindow gConfigWindow",&Configure
Gui,Main:Add,Button,% "x" Config.MainW-60 " y0 w80 vButtonUpdate gButtonUpdate",&Update
Gui,Main:Add,Button,% "x" Config.MainW-200 " y22 w80 Disabled vButtonSelectGames gButtonSelectGames",&Selection
Gui,Main:Add,Button,% "x" Config.MainW-130 " y22 w80 Disabled vButtonGetGames gButtonGetGames",&Download
Gui,Main:Add,Button,% "x" Config.MainW-60 " y22 w80  Disabled vButtonOrphans gButtonOrphans",&Orphans
myConsole:= new scConsole({"PosX":"1","PosY":"50","Gui Number":"Main","Control Width": Config.MainW, "Control Height": Config.MainH-50,"Font":Courier New,"Line Number Color":"yellow"})
Gui,Main:Show,% "x" Config.MainX " y" Config.MainY " w" Config.MainW " h" Config.MainH
Gui,Submit,Nohide
If Orphans
	GuiControl,Main:,ButtonGetGames,C&heck Orphans
DoLog(1,"LogFile:Log.txt","Downloader Started")
if !(Config.ConfigFound) ;---- If there is no configuration file, go straight to the config window
	Gui_Config()
CheckSums_TT:="Checks the MD5 checksums for installers and patches during download to make sure the version you have isn't corrupt.`nThis option does increase time taken to do a full check if you have a large number of games."
Definitions_TT:="Checks for the latest version of Connies Dats and downloads them to the resources folder if a new version is found"
Orphans_TT:="Checks all selected games and then lists the files in your base folder that dont exist on the GoG servers. Nothing new is downloaded."
UsePreviousLogin_TT:="Uses your previous login information to speed up the process.`nGood for when you just want to download specific games or run a check for updates."
PrettyNames_TT:="Forces the downloader to use the names provided in Connie's Dats as folder names rather than the default names used by GoG."
AlignToDat_TT:="Check your files against Connie's Dat without having to login to the GoG server.`nNote : Dat may not contain the most uptodate versions of all files."
ButtonLogin_TT:="Click this to login to the GoG server."
ConfigWindow_TT:="Click to setup the downloader with information such as Credentials, Locations, Download Types and Languages"
ButtonUpdate_TT:="Check for a new version of Ultimate GoG Downloader"
ButtonSelectGames_TT:="Select the games to process.`nPress Escape when you are done."
ButtonGetGames_TT:="When you have selected your games to process or the games that are pre-selected with updates etc, this button will start the download process."
ButtonOrphans_TT:="This becomes available after a check has been completed.`nIt brings up a list of all files theat you have that are not on the GoG servers.`nNOTE : Must be used in conjunction with installers, patches, dlcs and extras selected!!"
msHTML_TT:="Terminal window that shows all progress and any errors along the way"
AlignToDat_TT:="Compares the files and folders in the directory set in Configuration \ Locations \ Base Dir`n to those in Connies Dat"

;Config
Credentials_TT:="Enter your GoG credentials"
User__TT:="Your GoG username/email"
Pass__TT:="Your GoG site password"

Locations_TT:="Set locations for you GoG directory, extras and more"
Base_Dir__TT:="This is the location of your GoG downloads"
Patches__TT:="Not Currently Used"
DLC__TT:="Not Currently Used"
Artwork__TT:="Folder to save all the artwork from the GoG game pages when selected"
Videos__TT:="Folder to save all the YouTube Videos from the GoG game pages when selected"
Orphans__TT:="Location to use when moving orphaned files"

Downloads_TT:="Select the type of downloads to perform"
Installers_TT:="Download Installers for selected games"
Patches_TT:="Download Patches for selected games"
Language_Packs_TT:="Download the Language Packs for selected games"
DLCs_TT:="Download the Downloadable Content for selected games"
Extras_TT:="Download all Extras associated with selected games`nNote: Language selection is not taken into account for extras, its all or nothing..."
Artwork_TT:="Download Artwork from the game pages`neg. Screenshots, Backgrounds and Box Art"
Covers_TT:="Not Currently Used"
Videos_TT:="Download YouTube Videos from the game pages"


Platforms_TT:="Select the platforms to download installers, patches and DLC for"
Windows_TT:="Download Windows installers, patches and downloadable content"
MAC_OS_X_TT:="Download Mac installers, patches and downloadable content"
TarBall_Archive_TT:="Download Linux Tarballs for installers, patches and downloadable content"
Debian_Package_TT:="Download Linux Debian Packages for installers, patches and downloadable content"

Movies_TT:="Select the quality of the GoG movies you want to download.`nDeselect all to skip them."
for a in Config.Movies
	%a%_TT:="Download " a " versions of GoG movies"

Languages_TT:="Select the languages you want to download"
for a in Config.Languages
	%a%_TT:="Download installers, Patches and DLC's that are in " a

ConfigCancel_TT:="Exit without saving your changes to the config.ini"
ConfigSave_TT:="Save your new choices to the Config.ini"

; Do Tooltips
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x004E, "WM_NOTIFY_TT")
Return

AlignToDat:
{
	Alignwithdat()
	return
}

PrettyNames:
{
	Gui,Submit,NoHide
	Config.NameConvention:=PrettyNames?"Connie":"GoG"
	tt("Use Connie's Pretty names for folders-" PNState:=PrettyNames?"On":"Off" )
	;tt(Config.NameConvention)
	IniWrite,% PrettyNames,%A_ScriptDir%\Resources\Config.ini,MainGui,PrettyNames
	Return
}
Checksums:
{
	Gui,Submit,NoHide
	tt("Compare Checksums-" CSState:=Checksums?"On":"Off")
	IniWrite,% Checksums,%A_ScriptDir%\Resources\Config.ini,MainGui,Checksums
	Return
}
UsePreviousLogin:
{
	Gui,Submit,NoHide
	tt("Using Previous Login Information - " UPLState:=UsePreviousLogin?"On":"Off")
	IniWrite,% UsePreviousLogin,%A_ScriptDir%\Resources\Config.ini,MainGui,UsePreviousLogin
	Return
}
Definitions:
{
	Gui,Submit,NoHide
	tt("Latest Definitions - " LDState:=Definitions?"On":"Off")
	IniWrite,% Definitions,%A_ScriptDir%\Resources\Config.ini,MainGui,Definitions
	Return
}
ButtonOrphans:
{
	Gui_ConfirmOrphans(OrphanFiles)
	return
}

Orphans:
{
	Gui,Submit,NoHide
	tt("Check Orphans Only - " OState:=Orphans?"On":"Off")
	IniWrite,% Orphans,%A_ScriptDir%\Resources\Config.ini,MainGui,CheckOrphans
	If Orphans
		GuiControl,Main:,ButtonGetGames,C&heck Orphans
	Else
		GuiControl,Main:,ButtonGetGames,&Download
	Return
}

;MoveOrphans:
;{
	;Gui,Submit,NoHide
	;tt("Move Orphans - " MOState:=MoveOrphans?"On":"Off")
	;Return
	;}
	ButtonGetGames:
	{
		ToTalEntries:=0,Downloaded:=[]
		for a,b in List
			if b.Selected
				TotalEntries++
		tt("Found " TotalEntries " selections.")
		tt("Using " Config.NameConvention "'s naming convention for folder names.")
		tock:=A_TickCount
		
		Counter:=0
		TotalExtras:=TotalInstallers:=0 ;---- Reset Var so multiple runs always starts at 0
		;For a,b in List ;----Get all the games base info for the selected games
		;{
		;if b.Selected
		;{
		;Counter++,game:=a,tick:=A_TickCount
		;myConsole.changeLine("[blue]" Round((100/(TotalEntries))*Counter,0) "%[/] [red]" Counter "/" TotalEntries "[/][green]`tInfo Retrieved for [Yellow]" game "[/] in " Round((a_tickcount - tick)/1000,1) " seconds[/] " Convert_Seconds(Round((a_tickcount - tock)/1000,0)), myConsole.currentLine )
		;TotalExtras+=b.Extras.MaxIndex()?b.Extras.MaxIndex():0
		;TotalInstallers+=b.DLC.MaxIndex()?b.DLC.MaxIndex():0
		;}
		;}
		;tt("Process Complete. Collection time was " Round((a_tickcount - tock)/1000,1) " seconds")
		;tt("Total Files counted and added was [yellow]" TotalInstallers " Installers and " TotalExtras " Extras" "[/]")
		FilesAlreadyDone:=[]
		For a,b in List ;----Get the Links for installers, patches, language packs and DLC's then grab the extras links
		{
			if b.Selected ;----Only Process if it has been selected
			{
				Get_GameInfo(a)
				If Duplicate
					myConsole.changeLine("[green]Working on [yellow]" b.Name "[/][/]", myConsole.currentLine )
				else
					tt("Working on [yellow]" b.Name "[/]") ; Convert_seconds(Round((a_tickcount - tick)/1000,0))
				for c in b.DLC ;---- Check against Platform, Language Downloads type parameters
					if (Orphans||(Config.Movies[b.DLC[c].quality]||(Config.Platforms[b.DLC[c].Platform]&&Config.Languages[b.DLC[c].Language]&&((Config.Downloads[b.DLC[c].Type "s"]||Config.Downloads[b.DLC[c].Type "es"]||Config.Linux[b.DLC[c].Type])))))
				{
					Link:=Get_ApiLink(b.DLC[c].Link)
					b.DLC[c].Link:=Link.Link
					b.DLC[c].Filename:=Link.FileName
					
					b.DLC[c].MD5:=Link.MD5
					;tt(Config.Movies[b.DLC[c].quality] " = " b.DLC[c].quality)
					;if !Orphans
					if !Orphans
						if FilesAlreadyDone[b.DLC[c].MD5]
					{
						If Duplicate
							myConsole.changeLine("[green][Red]Duplicate[/] : " b.DLC[c].Filename "," b.DLC[c].Language " is the same as the " FilesAlreadyDone[b.DLC[c].MD5]" Version[/]", myConsole.currentLine )
						else
							tt("[Red]Duplicate[/] : " b.DLC[c].Filename "," b.DLC[c].Language " is the same as the " FilesAlreadyDone[b.DLC[c].MD5]" Version")
						Duplicate:=1
						Continue
					}
					if !Orphans
						If !(FileCheck(Config.Location "\" DetermineFolder(b.DLC[c].Folder,"Location") "\" b.DLC[c].Filename,b.DLC[c].MD5,b.DLC[c].Link))
							DownloadFile(b.DLC[c].Link,Config.Location "\" DetermineFolder(b.DLC[c].Folder,"Location") "\" b.DLC[c].Filename)
					FilesAlreadyDone[b.DLC[c].MD5]:=b.DLC[c].Language
					Duplicate:=0
				}
				
				if (Orphans||Config.Downloads.Extras)
					for d in b.Extras
				{
					;Duplicate:=0
					Link:=Get_ApiLink(b.Extras[d].Link)
					b.Extras[d].Link:=Link.Link
					b.Extras[d].Filename:=Link.FileName
					;info:=""
					;for e,f in b.Extras[d]
					;info.=e "-" f "`n"
					;m(info)
					;tt(b.Extras[d].Link)
					if !Orphans
						If !(FileCheck(Config.Location "\" DetermineFolder(b.Extras[d].Folder,"Location") "\" b.Extras[d].Filename,,b.Extras[d].Link))
					{
						DownloadFile(b.Extras[d].Link,Config.Location "\" DetermineFolder(b.Extras[d].Folder,"Location") "\" b.Extras[d].Filename)
					}
					Duplicate:=0
				}
				;---- Artwork and Video
				if (!Orphans&&(Config.Downloads.Artwork||Config.Downloads.Videos))
				{
					Duplicate:=0
					Get_ArtworkAndVideo(a)
				}
			}
			;Duplicate:=0
		}
		if (downloaded[1])
			tt(""),tt("The following files were downloaded:")
		for a,b in Downloaded
			tt(a ". " b)
		tt("Processed all links in [white]" Convert_Seconds(Round((A_TickCount-tock)/1000,0)) "[/]")
		if errors
			tt("Encountered [red]" Errors "[/] Errors!!")
		
		;if Orphans
		;{
		tt("Checking for Orphaned Files")
		OrphanFiles:=[],OrphanCount:=0
		OrphanFiles:=Orphans()
		for a,b in OrphanFiles
			for c,d in b
				OrphanCount++ ;tt(a "/" d)
		if !OrphanCount
			tt("No Orphan Files Found")
		else
		{
			tt("Found " OrphanCount " files that dont currently exist on GoG.com Servers")
			GuiControl,Main:Enable,ButtonOrphans
		}
		;Gui_ConfirmOrphans(OrphanFiles)
		;}
		Return
	}
	ButtonSelectGames:
	{
		Gui_SelectGames()
		Return
	}
	MainGuiSize:
	{
		if (!MainGuiSizeFirstRun){
			MainGuiSizeFirstRun:=1
			if (A_ScreenWidth<(A_GuiWidth+5)||A_ScreenHeight<(A_GuiHeight+5))
				gui,Maximize
			Return
		}
		GuiControl,Main:MoveDraw,ButtonLogin,% "x"A_Guiwidth*.44
		GuiControl,Main:MoveDraw,configWindow,% "x"A_Guiwidth*.63
		GuiControl,Main:MoveDraw,ButtonUpdate,% "x"A_Guiwidth*.82
		GuiControl,Main:MoveDraw,ButtonSelectGames,% "x"A_Guiwidth*.44
		GuiControl,Main:MoveDraw,ButtonGetGames,% "x"A_Guiwidth*.63
		GuiControl,Main:MoveDraw,ButtonOrphans,% "x"A_Guiwidth*.82
		myConsole.Resize(A_GuiWidth,A_GuiHeight)
		
		Return
	}
	ConfigWindow:
	{
		Gui_Config()
		return
	}
	ButtonUpdate:
	{
		Update()
		Return
	}
	ButtonLogin:
	{
		GuiControl,Main:Disable,ButtonLogin
		GuiControl,Main:-Redraw,configWindow
		GuiControl,Main:Disable,configWindow
		GuiControl,Main:+Redraw,configWindow
		GuiControl,Main:Disable,ButtonUpdate
		GuiControl,Main:+Redraw,ButtonUpdate
		Username:=Config.Username
		Password:=Config.Password
		;IP:=URLDownloadToVar("http://7fw.de/ipraw.php")
		;tt("Your IP is : " IP)
		;Config.IP:=URLDownloadToVar("http://7fw.de/ipraw.php")
		If UsePreviousLogin
			ReUsingLogin:=ReUse_Login("LOAD")
		if (!Username||!Password) ;----Break if no Username or password
			tt("[Red]Username[/] or [Red]Password[/] isn't set."),tt("Set your Credentials in [red]Configuration[/]."),Return
		if (!Loggedin&&!ReUsingLogin) ;---- Do The Http login if not already logged in
			SuccessHTTP:=HTTP_Login(Username,Password)
		if (!LoggedIn&&SuccessHTTP) ;---- Do the Api login if not already logged in
			SuccessAPI:=API_Login(Username,Password)
		if ((!LoggedIn&&SuccessAPI)||ReUsingLogin){
			if !ReUsingLogin
				ReUse_Login("SAVE")
			LoggedIn:=1
			tt("Logged in to [Yellow]HTTP[/] and [Yellow]API[/] Successfully")
			If Definitions
			{
				tt("Getting Latest Definitions....")
				Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".dat","Games") ;----Games Dat File
				if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
					DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
				Config.Dat:=connie.filename
				IniWrite,% Config.Dat,%A_ScriptDir%\Resources\Config.ini,Definitions,Dat
				Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".dat","Movies") ;----Movies Dat File
				if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
					DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
				Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".bat","to GOG") ;----Renamer - Folder Name to GOG.com Downloader Name
				if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
					DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
				Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".bat","to Folder") ;----Renamer - GOG.com Downloader Name to Folder Name
				if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
					DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
				Config.Names:=connie.filename
				IniWrite,% Config.Names,%A_ScriptDir%\Resources\Config.ini,Definitions,Names
			}
			List:=[]
			If (!FileExist(A_ScriptDir "\Resources\GameList.ini")||!UsePreviousLogin)
			{
				tt("Getting a list of your [aqua]Games[/]....")
				List:=HTTP_GetUserInfo()
				tt("Getting a list of your [aqua]Movies[/]....")
				Movies:=HTTP_GetUserMovieInfo()
				for a,b in movies
				{
					List[a]:=b
				}
				tt("Writing List to file for faster future logins.")
				Obj2File(List,A_ScriptDir "\Resources\GameList.ini")
				myConsole.changeLine("[green]Writing List to file for faster future logins....Complete[/]", myConsole.currentLine )
			}
		}
		If UsePreviousLogin
		{
			tt("Loading Previous Login Database.")
			List:=File2Obj(List,A_ScriptDir "\Resources\GameList.ini")
			myConsole.changeLine("[green]Loading Previous Database....Complete[/]", myConsole.currentLine )
			{
				tt("You Have " Updates " New/Update Notifications")
				for a,b in List
					if (b.notification){
					b.Selected:=1
					UpdateType:=(b.notification="bdg_update") ? "has updated content." : "is available for download"
					tt("[yellow]" b.Name "[/] " UpdateType ".")
					GuiControl,Main:Enable,ButtonGetGames
				}
				tt("The above games have been automatically selected for download")
			}
		}
		If !LoggedIn
			Return
		GuiControl,Main:Enable,ButtonSelectGames
		GuiControl,Main:Enable,ButtonLogin
		GuiControl,Main:Enable,ConfigWindow
		GuiControl,Main:Enable,ButtonUpdate
		Return
	}
	MainGuiEscape:
	MainGuiClose:
	WinGetPos,X,Y,W,H,% "ahk_id" Config.MainHwnd
	IniWrite,%X%,%A_ScriptDir%\Resources\Config.ini,MainGui,X
	IniWrite,%Y%,%A_ScriptDir%\Resources\Config.ini,MainGui,Y
	IniWrite,% W-16,%A_ScriptDir%\Resources\Config.ini,MainGui,W
	IniWrite,% H-38,%A_ScriptDir%\Resources\Config.ini,MainGui,H
	;Obj2File(List,A_ScriptDir "\Resources\GameList.ini")
	ExitApp
	;****** Time Saver Functions
	m(x*){
		for a,b in x
			list.=b "`n"
		msgbox ,8192,,%list%
		Return
	}
	t(x*){
		for a,b in x
			list.=b "`n"
		ToolTip,%list%
		Return
	}
	tr(x*){
		for a,b in x
			list.=b "`n"
		TrayTip,Info,%list%,1
		Return
	}
	tt(x*){
		global myconsole
		for a,b in x
			list.=b "<br>"
		;StringTrimRight,List,List,42
		myConsole.addItem("[Green]" List "[/]",1)
		Return
	}
	tto(x*){
		global myconsole
		for a,b in x
			list.=b "<br>"
		;StringTrimRight,List,List,42
		;myConsole.addItem("[Green]" List "[/]",1)
		myConsole.changeLine("[Green]" List "[/]", myConsole.currentLine )
		Return
	}
	URLDownloadToVar( url, Method:="GET" ){
		hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		hObject.Open(method, url)
		hObject.Send()
		return hObject.ResponseText
	}
	Convert_Seconds(Seconds){
		vSec60 := Mod( Seconds, 60 )
		vMin60 := Mod( (Floor( Seconds / 60 )), 60)
		vHrsxx := (Floor( Seconds / 3600 ))
		If ( vSec60 < 10 )    ; pad with zeros
			vSec60 = 0%vSec60%
		If ( vMin60 < 10 )
			vMin60 = 0%vMin60%
		vTime = %vHrsxx%:%vMin60%:%vSec60%
		Return, vtime
	}
	return
	
	#Include Classes\Class_Console.ahk
	#Include Classes\Class_GUIWindow.ahk
	#Include Classes\Class_XML.ahk
	#Include Functions\API-Login.ahk
	#Include Functions\DownloadFile.ahk
	#Include Functions\FileCheck.ahk
	#Include Functions\Get_APILink.ahk
	#Include Functions\Get_GameInfo.ahk
	#Include Functions\GetCookies.ahk
	#Include Functions\Headers.ahk
	#Include Functions\HTTP-GetUserInfo.ahk
	#Include Functions\HTTP-Login.ahk
	#Include Functions\Log.ahk
	#Include Functions\Resources.ahk
	#Include Functions\Reuse_Login.ahk
	#Include Functions\RSS_Get.ahk
	#Include Functions\Update.ahk
	#Include Lib\HTTPRequest.ahk
	#Include Lib\OAuth.ahk
	#Include Windows\Gui_Config.ahk
	#Include Windows\Gui_SelectGames.ahk
	#Include Functions\Get_ArtworkAndVideo.ahk
	#Include Functions\HTTP-GetUserMovieInfo.ahk
	#Include Functions\Get_FileFromOneDrive.ahk
	#Include Functions\Orphans.ahk
	#Include Functions\Gui_ConfirmOrphans.ahk
	#Include Functions\Obj2File.ahk
	#Include Classes\Class_TreeView.ahk
	#Include Functions\FolderCleanUp.ahk
	#Include Functions\DetermineFolder.ahk
	#Include Functions\alignwithdat.ahk
	#Include Functions\DatReadandWrite.ahk
	#Include Functions\WM_Mousemove.ahk
	