FileCheck(SaveAs,MD5=""){
	;---- Insert checking for existance of file and file hashing here
	IfExist,%SaveAs%
	{
		SplitPath,SaveAs,Filename
		if (MD5){
			tt("Checking MD5 for " Filename "....")
			CheckMD5:=CheckFileMD5(SaveAs)
			if (MD5=CheckMD5){
				tt("Pass [aqua]" CheckMD5 "[/]")
				Return,1
			}else{
				tt("[Red]Fail " CheckMD5 "[/]")
				Return,0
			}
		}else{
			CheckMD5:=CheckFileMD5(SaveAs)
			tt("[yellow]" Filename "[/] exists with the checksum [aqua]" CheckMD5 "[/]")
			Return, 1
		}
	}
}
CheckFileMD5( sFile="", cSz=5 ) {  ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
	;0 = 256 KB, 1 = 512 KB, 2 = 1.00 MB, 3 = 2.00 MB, 4 = 4.00 MB, 5 = 8.00 MB, 6 = 16.0 MB, 7 = 32.0 MB, 8 = 64.0 MB
	global myConsole
	Iteration:=0	
	SetTimer, ShowPercentageMD5,10
	cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 18-Jun-2009
	hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
	IfLess,hFil,1, Return,hFil
		hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
	DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
	VarSetCapacity( MD5_CTX,104,0 ),    DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
	Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
		DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
	, DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, UInt,&Buffer, UInt,bytesRead )
	, Iteration++
	DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
	DllCall( "CloseHandle", UInt,hFil )
	Loop % StrLen( Hex:="123456789ABCDEF0" )
		N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
	SetTimer, ShowPercentageMD5,Off
	gosub ShowPercentageMD5
	StringLower,MD5,MD5
	Return MD5, DllCall( "FreeLibrary", UInt,hMod )
	ShowPercentageMD5:
	{
		BytesDone:=Round(Iteration*cSz)>fSz?fSz:Round(Iteration*cSz)
		SplitPath,sFile,sFilename
		myConsole.changeLine("Checking MD5 for " sFilename "...." Round((BytesDone/fSz)*100) "%", myConsole.currentLine )
		return
	}
}