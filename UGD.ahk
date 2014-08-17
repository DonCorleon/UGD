version=;auto_version
#SingleInstance,force
SetBatchLines = -1
;******** Global Vars
Global Cookie,status

; Create the Basic API Object
API:=Object("Consumer_Key","1f444d14ea8ec776585524a33f6ecc1c413ed4a5"
,"Consumer_Secret","20d175147f9db9a10fc0584aa128090217b9cf88"
,"oauth_get_urls","https://api.gog.com/en/downloader2/status/stable")


; Create the Basic Test Gui
Config:=Resources()
Gui,Main:New,+OwnDialogs +Resize,Ultimate GoG Downloader v%Version%
gui,Main:Add,DropDownList,x0 y0 w40 vDebug_HTTP gDoSubmit,0||1|2
gui,Main:Add,DropDownList,x0 y20 w40 vDebug_API gDoSubmit,0||1|2
gui,Main:Add,Text,x45 y5,Debug Level : HTTP 
gui,Main:Add,Text,x45 y25,Debug Level : API 
Gui,Main:Add,Button,x270 y0 w60 vButtonLogin gButtonLogin,Login
gui,Main:Add,Button,x350 y0 w60 vConfigWindow gConfigWindow,Configure
Gui,Main:Add,Button,x430 y0 w60 vButtonUpdate gButtonUpdate,Update

;Gui,Main:Add,ListBox,xp-420 yp+75 w460 r22 +VScroll +Border vStatus,Idle
myConsole:= new scConsole({"Control Width": 490, "Control Height": 85,"Font":Courier New,"Line Number Color":"yellow"})
Gui,Main:Show,h140
DoLog(1,"LogFile:Log.txt","Downloader Started")
Return
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
	Username:=Config.Username
	Password:=Config.Password
	if (!Username||!Password)
	{
		tt("[Red]Username[/] or [Red]Password[/] isn't set."),tt("Set your Credentials in [red]Configuration[/].")
		Return
	}
	Success:=HTTP_Login(Username,Password)
	if (Success)
		Success:=API_Login(Username,Password)
	if (Success)
		tt("Logged in to [Yellow]HTTP[/] and [Yellow]API[/] Successfully"),tt("Getting a list of your games...."),ter("Logged in to HTTP and API Successfully","Getting a list of your games...."),List:=HTTP_GetUserInfo()	
	if (List.Updates.1)
		tt("Updated games as follows:")
	for a,b in List.Updates
	{
		if b.notify="bdg_new"
			badge:="New Game"
		if b.notify="bdg_update"
			badge:="Update Available"
		tt(A_index ".`t[03F]" b.Folder "[/] - [Yellow]" badge "[/]")
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