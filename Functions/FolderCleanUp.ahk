FolderCleanUp(){
	;#SingleInstance,Force
	global Config
	GogNames:=[]
	ConnieNames:=[]
	ConnieNamesNoDates:=[]
	
	FileRead,TempVar,% A_ScriptDir "\Resources\" Config.names
	Loop,Parse,TempVar,`r
	{
		RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)(| \[DLC\])" Chr(34),foundpretty)
		RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)\(((january|february|march|april|may|june|july|august|september|october|november|december).*)\)(| \[DLC\])" Chr(34),found)
		GogNames[FoundPretty1]:=FoundPretty2
		ConnieNames[FoundPretty2]:=FoundPretty1
		ConnieNamesNoDates[Found2]:=Found1
	}
	loop,z:\*.*,2 ;% Config.Location "\*.*",2
	{
		if Gognames[A_LoopFileName]
		{
			MsgBox,GoG Standard Naming
			if Config.NameConvention="GoG"
				continue
			else if Config.NameConvention="Connie"
				m(A_LoopFileFullPath,Config.Location "\" GoGNames[A_LoopFileName])
			;FileMoveDir,% A_LoopFileFullPath,% Config.Location "\" GoGNames[A_LoopFileName]
			else if Config.NameConvention="Hybrid"
				m(A_LoopFileFullPath,Config.Location "\" RegExReplace(GoGNames[A_LoopFileName],"\((.*)\)"))
			;FileMoveDir,% A_LoopFileFullPath,% Config.Location "\" RegExReplace(GoGNames[A_LoopFileName],"\((.*)\)")
		}
		if Connienames[A_LoopFileName]
		{
			MsgBox,Connie .dat Naming
		}
		if ConnieNamesNoDates[A_LoopFileName]
		{
			MsgBox,Connie Hybrid Naming
		}
	}
}