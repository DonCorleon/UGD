Orphans(){
	global Config,List,myconsole
	ExistingFiles:=[]
	;---- Get a list of folders to Check
	FoldersToCheck:=[]
	for a,b in List
		for c,d in b.DLC
			if (b.selected&&!FoldersToCheck[d.Folder])
				FoldersToCheck[d.folder]:=1
	For a in FoldersToCheck
	{
		TempArray:=[]
		Loop,% Config.Location "\" DetermineFolder(a,"Location") "\*.*"
		{
			if (A_LoopFileName!="thumbs.db")
				TempArray[A_Index]:=A_LoopFileName
			;myConsole.changeLine("[green]Adding : " A_LoopFileName "[/]", myConsole.currentLine )
		}		
		ExistingFiles[DetermineFolder(a,"Location")]:=TempArray
	}
	for a,b in List
	{
		for c,d in b.DLC
			for e,f in Existingfiles[DetermineFolder(d.folder,"Location")]
				if (d.filename=f)
					ExistingFiles[DetermineFolder(d.folder,"Location")].Remove(A_Index)
		for c,d in b.Extras
			for e,f in Existingfiles[DetermineFolder(d.folder,"Location")]
				if (d.filename=f)
					ExistingFiles[DetermineFolder(d.folder,"Location")].Remove(A_Index)
	}
	TempArray:=[]
	;TempArray:=ExistingFiles
	for a,b in ExistingFiles
	{
		if b[1]
			TempArray[a]:=b
		;if !b[1]
		;ExistingFiles.Remove(a)
	}
	ExistingFiles:=TempArray
	return ExistingFiles
	
}