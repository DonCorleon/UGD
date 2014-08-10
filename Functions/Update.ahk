Update(){
	global version
	GuiControl,Main:Disable,ButtonUpdate
	HTTPRequest(URL:="http://doncorleon.no-ip.org/ahk/ugd/ugd.text",InOutData,InOutHeader)
	GuiControl,Main:Enable,ButtonUpdate
	UpdateText:=StrSplit(InOutData,"`n","`r`n")
	if (UpdateText.1=Version)
		m("No update is available")
	Else
		MsgBox,4388,Update Available, % "Version " UpdateText.1 " is available.`nUpdate to new version?"
	IfMsgBox Yes
	{
		FileMove,UGD.exe,UGD-Old.exe,1
		HttpRequest(URL:="http://doncorleon.no-ip.org/ahk/ugd/ugd.exe",InOutData,InOutHeader,options:="SAVEAS:UGD.exe`nCallBack:UpdateProgress")
		Progress,Off
		Run,UGD.exe
	}
	IfMsgBox No
		m("Update cancelled.")
	Return
}
UpdateProgress(Percentage,Param2){
	Progress,% Round(Percentage*100,0),% Round(Percentage*100,0) "%",Updating. Please Wait,Update
	Return	
}