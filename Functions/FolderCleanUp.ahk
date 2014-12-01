FolderCleanUp(){
	;#SingleInstance,Force
	Global Config
	;global Config:=[]
	;Config.Location:="C:\Users\Don\Downloads\gog_downloader"
	;Config.NameConvention:="GoG"
	;Config.names:="Renamer - GOG.com Downloader Name to Folder Name (821 + 26 + 61 + 38) (20141101).bat"
	;FileRead,TempVar,% "C:\AutoHotKey Studio\Projects\Ultimate GoG Downloader\Resources\" Config.names
	FileRead,TempVar,% A_ScriptDir "\Resources\" Config.names
	
	GogNames:=[]
	ConnieNames:=[]
	
	Loop,Parse,TempVar,`r
	{
		RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)(| \[DLC\])" Chr(34),Names)
		GogNames[Names1]:=Names2
		ConnieNames[Names2]:=Names1
	}
	loop,% Config.Location "\*.*",2
	{
		if Gognames[A_LoopFileName]
			if (Config.NameConvention="Connie")
			{
				FileMoveDir,% A_LoopFileFullPath,% Config.Location "\" GoGNames[A_LoopFileName]
				If !ErrorLevel
					tt("Renamed folder" A_LoopFileName " to " GoGNames[A_LoopFileName])
			}
		else if Connienames[A_LoopFileName]
			if (Config.NameConvention="GoG")
			{
				FileMoveDir,% A_LoopFileFullPath,% Config.Location "\" ConnieNames[A_LoopFileName]
				If !ErrorLevel
					tt("Renamed folder" A_LoopFileName " to " ConnieNames[A_LoopFileName])
			}			
		else
			continue
	}
	tt("Renamed all folders to [Yellow]" Config.NameConvention "[/] Convention.")	
	return
}
;m(x*){
;for a,b in x
;list.=b "`n"
;msgbox %list%
;}