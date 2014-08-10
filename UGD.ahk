version=;auto_version
#SingleInstance,force
SetBatchLines = -1
global Cookie

Config:=Resources()
; Create the Basic API Object
API:=Object("Consumer_Key","1f444d14ea8ec776585524a33f6ecc1c413ed4a5"
,"Consumer_Secret","20d175147f9db9a10fc0584aa128090217b9cf88"
,"oauth_get_urls","https://api.gog.com/en/downloader2/status/stable")
;Create
; Create the Basic Test Gui
Gui,Main:New,+OwnDialogs +Resize +MinSize520x430,Ultimate GoG Downloader v%Version%
gui,Main:Add,Checkbox,x0 y0 vDebug_HTTP gDoSubmit,Debug_HTTP
gui,Main:Add,Checkbox,x0 y15 vDebug_API gDoSubmit,Debug_API
gui,Main:Add,Checkbox,x150 y0 vConsoleCheck gConsoleCheck,Console
Gui,Main:Add,Edit,xp-130 yp+35 w200 vUsername,% Config.Username
Gui,Main:Add,Edit,xp+210 w200 vPassword +Password,% Config.Password
Gui,Main:Add,Button,xp+210 vButtonLogin gButtonLogin,Login
Gui,Main:Add,Button,yp-35 vButtonUpdate gButtonUpdate,Update
Gui,Main:Add,ListBox,xp-420 yp+75 w460 r22 +VScroll +Border vStatus,Idle
Gui,Main:Show
Return
ConsoleCheck:
{
	Gui,Submit,NoHide
	if ConsoleCheck
		MyConsole.Show()
	Else
		MyConsole.Hide()
	
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
		myConsole:= new scConsole({"Control Width": 500, "Control Height": 300,"Font":Courier New,"Line Number Color":"yellow"})
		tt("Console Opened")
	}
	MyConsole.Hide()
	Gui,Main:Submit,NoHide
	Success:=HTTP_Login(Username,Password)
	if (Success)
		Success:=API_Login(Username,Password)
	if (Success)
		tt("Logged in to HTTP and API Successfully"),List:=HTTP_GetUserInfo()	
	if (List.Updates.1)
		tt("Updated games as follows:")
	for a,b in List.Updates{
		if b.notify="bdg_new"
			badge:="New Game"
		if b.notify="bdg_update"
			badge:="Update Available"
		tt(A_index ".`t" b.Folder " - " badge)
	}
	for a,b in List
	{
		if (!b.name||a="Updates")
			tt(a)
		Else
			tt(b.name)
	}
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
tt(x*){
	global myconsole
	for a,b in x
		list.=b ;"|"
	;GuiControl,Main:,Status,%list%|
	myConsole.addItem("[Green]" List "[/]",1)
	Return
}
URLDownloadToVar( url, Method:="GET" ){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open(method, url)
	hObject.Send()
	return hObject.ResponseText
}
#Include Classes\Class_Console.ahk
#Include Classes\Class_XML.ahk
#Include Functions\API-Login.ahk
#Include Functions\GetCookies.ahk
#Include Functions\Headers.ahk
#Include Functions\HTTP-GetUserInfo.ahk
#Include Functions\HTTP-Login.ahk
#Include Functions\Resources.ahk
#Include Functions\RSS_Get.ahk
#Include Functions\Update.ahk
#Include Lib\HTTPRequest.ahk
#Include Lib\OAuth.ahk