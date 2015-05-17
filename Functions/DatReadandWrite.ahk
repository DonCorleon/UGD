DatRead(File){
	Dat:=[],GoGFileArray:=[],Files:=[]
	IfNotExist,% A_ScriptDir "\Resources\" File
	{
		tt("Read Dat : " File " couldn't be found.")
		return
	}
	if !Config.ConventionNaming
	{
		FileRead,TempVar,% A_ScriptDir "\Resources\" Config.names
		ConventionNaming:=[]
		Loop,Parse,TempVar,`r
		{
			RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)(| \[DLC\])" Chr(34),found)
			ConventionNaming[Found1]:=Object("GoGFolder",Found1,"ConnieFolder",Found2)
			DiffFolders++
		}
		Config.ConventionNaming:=ConventionNaming
		tt("Naming Conventions loaded. Found " DiffFolders " different folders.")
	}
	tt("Read Dat :`tReading " File "...")
	FileRead,DatFile,% A_ScriptDir "\Resources\" File
	DatArray:=StrSplit(DatFile,"game `(")
	For a,b in DatArray
	{
		FolderArray:=StrSplit(b,"rom `(")
		For c,d in FolderArray
		{
			FNAME:=RegExMatch(d,"U)name (.*) ",Name)
			FSIZE:=RegExMatch(d,"U)size (.*) ",Size)
			FCRC:=RegExMatch(d,"U)crc (.*) ",CRC)
			FMD5:=RegExMatch(d,"U)md5 (.*) ",MD5)
			FSHA1:=RegExMatch(d,"U)sha1 (.*) ",SHA1)
			if (FNAME && FSIZE && FCRC && FMD5 && FSHA1)
			{
				index++
				Dat[index]:=Object("GoGFolder",FOLDER1,"Name",NAME1,"ConnieFolder",Config.ConventionNaming[Folder1].ConnieFolder,"Size",SIZE1,"CRC",CRC1,"MD5",MD51,"SHA1",SHA11)
				Files[name1]:=Object("Size",SIZE1,"CRC",CRC1,"MD5",MD51,"SHA1",SHA11,"TimeStamp",A_Now)
				GoGFileArray[Folder1]:=Files
				TotalSize+=Size1
			}
			Else
			{
				Files:=[]
				FNAME:=RegExMatch(d,"name (.*)",Folder)
			}	
		}
	}
	if ((TotalSize/1024)>1){
		If (((TotalSize/1024)/1024)>1){
			If ((((TotalSize/1024)/1024)/1024)>1){
				If (((((TotalSize/1024)/1024)/1024)/1024)>1)
					TotalSize:=Round((((TotalSize/1024)/1024)/1024)/1024,2) "Tb"
				else
					TotalSize:=Round(((TotalSize/1024)/1024)/1024,2) "Gb"
			}else
				TotalSize:=Round((TotalSize/1024)/1024,2) "Mb"
		}else
			TotalSize:=Round(TotalSize/1024,2) "Kb"
	}else
		TotalSize:=TotalSize "bytes"
	tt("Read Dat : Dat loaded. Total of " TotalSize)
	return, Dat
}