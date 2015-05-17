alignwithdat(){
	global Config
	BaseFolder:=Config.Location
	DatInfo:=DatRead(Config.Dat)
	Files:=[]
	tick:=A_TickCount
	loop,% Config.Location "*.*",0,1
	{
		if (A_LoopFileDir=Config.Orphans||A_LoopFileDir=Config.Videos||A_LoopFileDir=Config.Artwork||A_LoopFileExt="jpg"||A_LoopFileExt="old"||A_LoopFileName="thumbs.db")
			continue
		StringReplace,Folder,A_LoopFileDir,% Config.Location
		if files[Folder "\" A_LoopFileName]
		{
			;m("File Exists in array : " A_LoopFileName)
			continue
		}
		FileGetSize,Size,% A_LoopFileFullPath
		skip:=0
		CorrectFolder:=(Config.NameConvention="GoG")?"GoGFolder":"ConnieFolder"
		IncorrectFolder:=(Config.NameConvention="GoG")?"ConnieFolder":"GoGFolder"
		for a,b in DatInfo
		{
			if (b.name=A_LoopFileName&&b.size=Size&&b[CorrectFolder]=Folder)
			{
				MD5:=CheckFileMD5(A_LoopFileFullPath)
				if (b.MD5=MD5)
				{
					skip:=1
					Correct++
					continue
				}
				wrongmd5++
			}
			else if (b.name=A_LoopFileName&&b.size=Size&&b[IncorrectFolder]=Folder)
			{
				MD5:=CheckFileMD5(A_LoopFileFullPath)
				if (b.MD5=MD5)
				{
					skip:=1
					WrongFolder++
					continue
				}
			}
		}
		if skip
			continue
		Files[Folder "\" A_LoopFileName]:=Object("Folder",Folder,"Size",Size)
		;tt(Files[Folder "\" A_LoopFileName].Folder)
		;tt(Files[Folder "\" A_LoopFileName].Size)
		Index++
	}
	tto("Done. Found " Index " obsolete files in " Round((A_TickCount-tick)/1000,2) " seconds")
	tt("Found " wrongmd5 " files with incorrect MD5 checsums.")
	tt("Found " correct " correct files and " Wrongfolder " files in the wrong folders.")
	;for a in Files
	;temp:=a
	;tt(temp)
	;tt(Files[temp].Folder "  " Files[temp].size)
	return
}