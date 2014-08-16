version=;auto_version
#SingleInstance,force
SetBatchLines = -1
;******** Global Vars
Global Cookie,status,UpdateType

; Create the Basic API Object
API:=Object("Consumer_Key","1f444d14ea8ec776585524a33f6ecc1c413ed4a5"
,"Consumer_Secret","20d175147f9db9a10fc0584aa128090217b9cf88"
,"oauth_get_urls","https://api.gog.com/en/downloader2/status/stable")


; Create the Basic Test Gui
Config:=Resources()
Gui,Main:New,+OwnDialogs +Resize,Ultimate GoG Downloader v%Version%
gui,Main:Add,Checkbox,x0 y0 vDebug_HTTP gDoSubmit,Debug_HTTP
gui,Main:Add,Checkbox,x0 y15 vDebug_API gDoSubmit,Debug_API
gui,Main:Add,Button,x150 y0 vConfigWindow gConfigWindow,Configure
Gui,Main:Add,Edit,xp-130 yp+35 w200 vUsername,% Config.Username
Gui,Main:Add,Edit,xp+210 w200 vPassword,% Config.Password
Gui,Main:Add,Button,xp+210 vButtonLogin gButtonLogin,Login
Gui,Main:Add,Button,yp-35 vButtonUpdate gButtonUpdate,Update
gui,Main:Add,Checkbox,xp-80 y0 vGetScript gChangeCheckS,Script
gui,Main:Add,Checkbox,xp y15 vGetExe gChangeCheckE,Executable
GuiControl,,GetScript,1

;Gui,Main:Add,ListBox,xp-420 yp+75 w460 r22 +VScroll +Border vStatus,Idle
myConsole:= new scConsole({"Control Width": 490, "Control Height": 90,"Font":Courier New,"Line Number Color":"yellow"})
Gui,Main:Show,h155
DoLog(1,"LogFile:Log.txt","Downloader Started")
Return
ChangeCheckS:
{
	Gui,Submit,NoHide
	GuiControl,,GetExe,0
	UpdateType:="SCRIPT"
	Return
}
ChangeCheckE:
{
	Gui,Submit,NoHide
	GuiControl,,GetScript,0
	UpdateType:="EXE"
	Return
}
ConfigWindow:
{
	Gui_Config()
	return
}
DoSubmit:
{
	Gui,Main:Submit,NoHide
	Return
}
ButtonUpdate:
{
	Update()
	Return
}
ButtonLogin:
{
	if !IsObject(myConsole)
	{
		myConsole:= new scConsole({"Control Width": 600, "Control Height": 250,"Font":Courier New,"Line Number Color":"yellow"})
		;MyConsole.Hide()
	}
	Gui,Main:Submit,NoHide
	Success:=HTTP_Login(Username,Password)
	if (Success)
		Success:=API_Login(Username,Password)
	if (Success)
		tt("Logged in to HTTP and API Successfully","Getting a list of your games...."),ter("Logged in to HTTP and API Successfully","Getting a list of your games...."),List:=HTTP_GetUserInfo()	
	if (List.Updates.1)
		tt("Updated games as follows:")
	for a,b in List.Updates
	{
		if b.notify="bdg_new"
			badge:="New Game"
		if b.notify="bdg_update"
			badge:="Update Available"
		tt(A_index ".`t" b.Folder " - " badge)
	}
	;for a,b in List
	;{
	;if (!b.name||a="Updates")
	;tt(a)
	;Else
	;tt(b.name)
	;}
	Return
}
MainGuiClose:
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
tt(x*){
	global myconsole
	for a,b in x
		list.=b "`n"
	myConsole.addItem("[Green]" List "[/]",1)
	Return
}
ter(x*){
	for a,b in x
		list.=b "|"
	GuiControl,Main:,Status,%list%|
	Return
}
URLDownloadToVar( url, Method:="GET" ){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open(method, url)
	hObject.Send()
	return hObject.ResponseText
}
#Include Classes\Class_Console.ahk
#Include Classes\Class_GUIWindow.ahk
#Include Classes\Class_XML.ahk
#Include Functions\API-Login.ahk
#Include Functions\GetCookies.ahk
#Include Functions\Headers.ahk
#Include Functions\HTTP-GetUserInfo.ahk
#Include Functions\HTTP-Login.ahk
#Include Functions\Log.ahk
#Include Functions\Resources.ahk
#Include Functions\RSS_Get.ahk
#Include Functions\Update.ahk
#Include Lib\HTTPRequest.ahk
#Include Lib\OAuth.ahk
#Include Windows\Gui_Config.ahk