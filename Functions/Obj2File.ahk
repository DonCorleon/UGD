Obj2File(ObjectToSave,Filename){
	FileDelete,% FileName
	OTS:=""
	for a,b in ObjectToSave
	{
		OTS.="[" a "]`n"
		if (IsObject(b)){
			for c,d in b
			{
				if (IsObject(d)){
					for e,f in d
					{
						if (IsObject(f)){
							for g,h in f
							{
								OTS.=c "." e "." g "=" h "`n"
								;IniWrite,% h,% Filename,%a%,% c "." e "." g
							}
						}
						else
						{
							OTS.=c "." e "=" f "`n"
							;IniWrite,% f,% Filename,%a%,% c "." e	
						}
					}
				}
				else
				{
					OTS.=c "=" d "`n"
					;IniWrite,% d,% Filename,%a%,% c	
				}
			}
		}
		else
		{
			OTS.= a "=" b "`n"
			;IniWrite,% b,% Filename,%a%,% a	
		}
	}
	FileAppend,% OTS,% FileName
	return	
}
File2Obj(ObjectToSave,Filename){
	CreateObject:=[]
	FileRead,FileMem,% Filename
	Loop,Parse,FileMem,`n,`r`n
	{
		FoundBase:=RegExMatch(A_LoopField,"^\[(.*)\]$",Base)
		FoundEntry:=RegExMatch(A_LoopField,"^(.*)=(.*)$",Entry)
		if FoundBase
		{
			;m("New Catagory - " Base1)
			Node:=Trim(Base1)
			Child:=[]
		}
		else if FoundEntry
		{
			;m("Entry - " Entry1,"Value - " Entry2)
			Child[Trim(Entry1)]:=Trim(Entry2)
			CreateObject[Node]:=Child
		}
		;else 
		;m("Error on Line " A_Index)
	}
	
	return, CreateObject
}