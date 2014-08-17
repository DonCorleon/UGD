Update(){
	global version
	static BaseURL:="http://doncorleon.no-ip.org"
	GuiControl,Main:Disable,ButtonUpdate
	HTTPRequest(URL:=BaseURL "/ahk/ugd/ugd.text",InOutData,InOutHeader)
	GuiControl,Main:Enable,ButtonUpdate
	UpdateText:=StrSplit(InOutData,"`n","`r`n")
	if !UpdateText.1
	{
		m("Error Contacting Update Server"),tt("Error contacting Update Server")
		Return	
	}
	if (UpdateText.1=Version)
		return m("No update is available"),tt("No update is available")
	
	Gui,Update:New,+ToolWindow +OwnerMain,Update Available
	Gui,Update:Add,Text,,% "Version " UpdateText.1 " is available.`nSelect your update type."
	Gui,Update:Add,Button,gUpdateScript,UGD.ahk
	Gui,Update:Add,Button,xp+60 gUpdateExe,UGD.exe
	Gui,Update:Add,Button,xp+60 gUpdateCancel,Cancel
	Gui,Update:Show
	Gui,Main:+Disabled
	tt("Version " UpdateText.1 " is available.")
	Return
	UpdateGuiClose:
	UpdateCancel:
	Gui,Main:-Disabled
	Gui,Update:Destroy
	m("Update cancelled."),tt("Update cancelled.")
	Return
	UpdateScript:
	FileMove,UGD.ahk,UGD.ahk.old,1
	HttpRequest(URL:=BaseURL "/ahk/ugd/UGD.ahk",InOutData,InOutHeader,options:="SAVEAS:UGD.ahk`nCallBack:UpdateProgress")
	Progress,Off
	Gui,Main:-Disabled
	Gui,Update:Destroy
	Run,UGD.ahk
	ExitApp
	UpdateExe:
	FileMove,UGD.exe,UGD.exe.old,1
	HttpRequest(URL:=BaseURL "/ahk/ugd/UGD.exe",InOutData,InOutHeader,options:="SAVEAS:UGD.exe`nCallBack:UpdateProgress")
	Progress,Off
	Gui,Main:-Disabled
	Gui,Update:Destroy
	Run,UGD.exe
	ExitApp
}
UpdateProgress(Percentage,Param2){
	Progress,% Round(Percentage*100,0),% Round(Percentage*100,0) "%",Updating. Please Wait,Update
	Return	
}

