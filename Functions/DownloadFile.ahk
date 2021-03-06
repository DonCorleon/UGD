DownloadFile(link,SaveAs){
	global Downloaded,Duplicate,myConsole,DLSpeed:=[]
	SplitPath,SaveAs,File,Directory
	If Duplicate
		myConsole.changeLine("[green]Setting Up Download....[/]", myConsole.currentLine )
	else
		tt("Setting Up Download....")
	Duplicate:=0
	IfNotExist,%Directory%
		FileCreateDir,%Directory%
	HttpRequest(URL:=link,InOutData,InOutHeader,options:="SAVEAS:" SaveAs "`nBINARY`nCallBack:DownloadProgress," File)
	If (ErrorLevel!=200)
	{
		tt("Download Failed with Error Code : " Errorlevel)
		tt("URL: " URL)
		tt("File: " SaveAs)
		Return
	}
	AvgSpeed:=0
	for a,b in DLSpeed
		AvgSpeed+=b
	AvgSpeed:=Round(AvgSpeed/DLSpeed.MaxIndex(),0)
	tto("[Yellow]100%[/] - [Green]Downloaded [/][yellow]" File "[/] @ [Green]" AvgSpeed "Kb/s[/]")
	RegExMatch(Directory,"U)[\w-]*$",Dir)
	Downloaded.Insert(Dir "\" File)
	Return,InOutHeader
}
DownloadProgress(Percentage,Size,File){
	global myConsole,DLSpeed
	static Lasttick,LastSize,Speed
	If (!LastSize||!Speed||!LastTick)
		LastSize:=1,Speed:="???",LastTick:=A_TickCount
	if ((A_TickCount-LastTick>=1000)||Percentage=1)
	{
		CurrentSize:=Round(Size*Percentage,0)
		Speed := Round((CurrentSize/1024-LastSize/1024)/((A_TickCount-LastTick)/1000))
		LastTick:=A_TickCount
		LastSize:=Round(Size*Percentage,0)
		DLSpeed.Insert(Speed)
		myConsole.changeLine("[Yellow]" Round(Percentage*100,0) "%[/] - [Green]Downloading [/][yellow]" File "[/] - [red]" Round(Size*Percentage,0) "/" Size "[/] @ " Speed "Kb/s", myConsole.currentLine)
	}
	Return
}