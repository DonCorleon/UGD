Testing:=0

version=;auto_version
#SingleInstance,force
SetBatchLines = -1
;******** Global Vars
Global Cookie,status,Config:=[]

DEBUG_Times:=0

HTTP:=Object("GoGCookie","") ;----Create the basic HTTP Object
API:=Object("Consumer_Key","1f444d14ea8ec776585524a33f6ecc1c413ed4a5" ; Create the Basic API Object
,"Consumer_Secret","20d175147f9db9a10fc0584aa128090217b9cf88"
,"oauth_get_urls","https://api.gog.com/en/downloader2/status/stable")

; Create the Basic Test Gui
Config:=Resources()
Gui,Main:New,+OwnDialogs +Resize +MinSize350x300 +hwndhwnd,Ultimate GoG Downloader v%Version%
Config.Mainhwnd:=hwnd
Gui,Main:Add,Checkbox,x0 y0 vChecksums gChecksums, C&ompare Checksums
Gui,Main:Add,Button,% "x" Config.MainW-200 " y0 w60 vButtonLogin gButtonLogin",&Login
gui,Main:Add,Button,% "x" Config.MainW-130 " y0 w60 vConfigWindow gConfigWindow",&Configure
Gui,Main:Add,Button,% "x" Config.MainW-60 " y0 w60 vButtonUpdate gButtonUpdate",&Update
Gui,Main:Add,Button,% "x" Config.MainW-200 " y22 w60 Disabled vButtonSelectGames gButtonSelectGames",&Selection
Gui,Main:Add,Button,% "x" Config.MainW-130 " y22 w60 Disabled vButtonGetGames gButtonGetGames",&Download
myConsole:= new scConsole({"PosX":"1","PosY":"50","Gui Number":"Main","Control Width": Config.MainW, "Control Height": Config.MainH-50,"Font":Courier New,"Line Number Color":"yellow"})
Gui,Main:Show,% "x" Config.MainX " y" Config.MainY " w" Config.MainW " h" Config.MainH
DoLog(1,"LogFile:Log.txt","Downloader Started")
if !(Config.ConfigFound) ;---- If there is no configuration file, go straight to the config window
	Gui_Config()
Return

Checksums:
{
	Gui,Submit,NoHide
	tt("Compare Checksums-" Checksums)
	Return
}
ButtonGetGames:
{
	ToTalEntries:=0
	for a,b in List
		if b.Selected
			TotalEntries++
	tt("Found " TotalEntries " selections.")
	tt("")
	tock:=A_TickCount
	
	Counter:=0
	TotalExtras:=TotalInstallers:=0 ;---- Reset Var so multiple runs always starts at 0
	For a,b in List ;----Get all the games base info for the selected games
	{
		if b.Selected
		{
			Counter++,game:=a,tick:=A_TickCount
			Get_GameInfo(game)
			myConsole.changeLine("[blue]" Round((100/(TotalEntries))*Counter,0) "%[/] [red]" Counter "/" TotalEntries "[/][green]`tInfo Retrieved for [Yellow]" game "[/] in " Round((a_tickcount - tick)/1000,1) " seconds[/] " Convert_Seconds(Round((a_tickcount - tock)/1000,0)), myConsole.currentLine )
			TotalExtras+=b.Extras.MaxIndex()?b.Extras.MaxIndex():0
			TotalInstallers+=b.DLC.MaxIndex()?b.DLC.MaxIndex():0
		}
	}
	tt("Process Complete. Collection time was " Round((a_tickcount - tock)/1000,1) " seconds")
	tt("Total Files counted and added was [yellow]" TotalInstallers " Installers and " TotalExtras " Extras" "[/]")
	FilesAlreadyDone:=[]
	For a,b in List ;----Get the Links for installers, patches, language packs and DLC's then grab the extras links
	{
		if b.Selected ;----Only Process if it has been selected
		{
			If Duplicate
				myConsole.changeLine("[green]Working on [yellow]" a "[/][/]", myConsole.currentLine )
			else
				tt("Working on [yellow]" a "[/]") ; Convert_seconds(Round((a_tickcount - tick)/1000,0))
			for c in b.DLC ;---- Check against Platform, Language Downloads type parameters
				if (Config.Platforms[b.DLC[c].Platform]&&Config.Languages[b.DLC[c].Language]&&((Config.Downloads[b.DLC[c].Type "s"]||Config.Downloads[b.DLC[c].Type "es"]||Config.Linux[b.DLC[c].Type])))
				{
					Link:=Get_ApiLink(b.DLC[c].Link)
					b.DLC[c].Link:=Link.Link
					b.DLC[c].Filename:=Link.FileName
					
					b.DLC[c].MD5:=Link.MD5
					;tt(b.DLC[c].Link)
					if FilesAlreadyDone[b.DLC[c].MD5]
					{
					If Duplicate
						myConsole.changeLine("[green][Red]Duplicate[/] : " b.DLC[c].Filename "," b.DLC[c].Language " is the same as the " FilesAlreadyDone[b.DLC[c].MD5]" Version[/]", myConsole.currentLine )
					else
						tt("[Red]Duplicate[/] : " b.DLC[c].Filename "," b.DLC[c].Language " is the same as the " FilesAlreadyDone[b.DLC[c].MD5]" Version")
					Duplicate:=1
					Continue
					}
				If !(FileCheck(Config.Location "\" b.DLC[c].Folder "\" b.DLC[c].Filename,b.DLC[c].MD5))
					DownloadFile(b.DLC[c].Link,Config.Location "\" b.DLC[c].Folder "\" b.DLC[c].Filename)
				FilesAlreadyDone[b.DLC[c].MD5]:=b.DLC[c].Language
				Duplicate:=0
				}
			if (Config.Downloads.Extras)
				for d in b.Extras
				{
					Link:=Get_ApiLink(b.Extras[d].Link)
					b.Extras[d].Link:=Link.Link
					b.Extras[d].Filename:=Link.FileName
					info:=""
					for e,f in b.Extras[d]
						info.=e "-" f "`n"
					m(info)
					;tt(b.Extras[d].Link)
					If !(FileCheck(Config.Location "\" b.Extras[d].Folder "\" b.Extras[d].Filename,,b.Extras[d].Link))
						DownloadFile(b.Extras[d].Link,Config.Location "\" b.Extras[d].Folder "\" b.Extras[d].Filename)
					Duplicate:=0
				}
			;---- Artwork and Video
			if (Config.Downloads.Artwork||Config.Downloads.Videos)
			{
				Get_ArtworkAndVideo(a)
				Duplicate:=0
			}
		}
	}
	tt("Grabbed all links in [white]" Convert_Seconds(A_TickCount-tock) "[/]")
	if errors
		tt("Encountered [red]" Errors "[/] Errors!!")
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
		tt("Getting Latest Definitions....")
		Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT") ;----Dat File
		if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
			DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
		Config.Dat:=connie.filename
		Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".bat","to GOG") ;----Renamer - Folder Name to GOG.com Downloader Name
		if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
			DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
		Connie:=Get_FileFromOneDrive(URL:="http://1drv.ms/1nFp6OT",".bat","to Folder") ;----Renamer - GOG.com Downloader Name to Folder Name
		if !(Filecheck(A_ScriptDir "\resources\" connie.filename,,connie.link))
			DownloadFile(Connie.link,A_ScriptDir "\resources\" connie.filename)
		Config.Names:=connie.filename
		List:=[]
		tt("Getting a list of your [aqua]Games[/]....")
		List:=HTTP_GetUserInfo()
		tt("Getting a list of your [aqua]Movies[/]....")
		Movies:=HTTP_GetUserMovieInfo()
		for a,b in movies
		{
			List[a]:=b
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