Orphans(){
	global Config,List,myconsole
	ExistingFiles:=[]
	;---- Get a list of folders to Check
	FoldersToCheck:=[]
	for a,b in List
		for c,d in b.DLC
			if !FoldersToCheck[d.Folder]
				FoldersToCheck[d.folder]:=1
	For a in FoldersToCheck
	{
		TempArray:=[]
		Loop,% Config.Location "\" a "\*.*"
		{
			if (A_LoopFileName!="thumbs.db")
				TempArray[A_Index]:=A_LoopFileName
			;myConsole.changeLine("[green]Adding : " A_LoopFileName "[/]", myConsole.currentLine )
		}		
		ExistingFiles[a]:=TempArray
	}
	for a,b in List
	{
		for c,d in b.DLC
			for e,f in Existingfiles[d.folder]
				if (d.filename=f)
					ExistingFiles[d.folder].Remove(A_Index)
		for c,d in b.Extras
			for e,f in Existingfiles[d.folder]
				if (d.filename=f)
					ExistingFiles[d.folder].Remove(A_Index)
	}
	;for a in FoldersToCheck
		;tt("Checked " a)
	return ExistingFiles
	
}