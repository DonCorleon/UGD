FileCheck(SaveAs,MD5="",Link:=""){
	global myConsole,Duplicate,Checksums
	;---- Insert checking for existance of file and file hashing here
	EmptyMem()
	IfExist,%SaveAs%
	{
		SplitPath,SaveAs,Filename
		if (MD5&&Checksums){
			If Duplicate
				myConsole.changeLine("[green]Checking MD5 for [yellow]" Filename "[/]....[/]", myConsole.currentLine )
			else
				tt("Checking MD5 for [yellow]" Filename "[/]....")
			CheckMD5:=CheckFileMD5(SaveAs)
			if (MD5=CheckMD5){
				;tt("Pass " SaveAs " [aqua]" CheckMD5 "[/]")
				myConsole.changeLine("[green]Pass[/] " FileName "[green] MD5 = [/][aqua]" CheckMD5 "[/]", myConsole.currentLine )
				Return,1
			}else{
				;tt("[Red]Fail " CheckMD5 "[/]")
				myConsole.changeLine("[Red]Fail[/] " FileName "[red] MD5 = [/][aqua]" CheckMD5 "[/]", myConsole.currentLine )
				FileMove,%SaveAs%,%SaveAs%.old,1
				Return,0
			}
		}else{
			HeaderFileCheck:=0
			RetryHeaderFileCheck:
			Try
			{
				HeaderFileCheck++
				WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
				WebRequest.Open("HEAD", Link)
				WebRequest.Send()
				;Store the header which holds the file size in a variable:
			}
			Catch
			{
				if HeaderFileCheck<5
				{
					If DebugMode
						tt("Retrying Header : " SaveAs)
					goto RetryHeaderFileCheck
				}
				if HeaderFileCheck>=5
				{
					tt("[Red]Failed to get Header for [/]" SaveAs)
					tt("[yellow]LINK:[/]" Link)
					tt("[Yellow]Skipping....[/]")
					return,1
				}
			}
			
			ServerSize := WebRequest.GetResponseHeader("Content-Length") ;GetAllResponseHeaders()
			FileGetSize,ExistingSize,%SaveAs%
			Same:=ExistingSize=ServerSize?1:0
			If Duplicate
			{
				if same
					myConsole.changeLine("[yellow]" Filename "[/] [green]- The File is up-to-date[/]", myConsole.currentLine)
				else
				{
					myConsole.changeLine("[yellow]" Filename "[/] [red]- The File is not up-to-date[/]", myConsole.currentLine)
					FileMove,%SaveAs%,%SaveAs%.old,1
					Return,0
				}
			}
			else
			{
				if same
					tt("[yellow]" Filename "[/] [green]- The File is up-to-date[/]")
				else
				{
					tt("[yellow]" Filename "[/] [red]- The File is not up-to-date[/]")
					FileMove,%SaveAs%,%SaveAs%.old,1
					return,0
				}
			}
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
CheckFileSHA1( sFile="", cSz=5 ) { ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
;0 = 256 KB, 1 = 512 KB, 2 = 1.00 MB, 3 = 2.00 MB, 4 = 4.00 MB, 5 = 8.00 MB, 6 = 16.0 MB, 7 = 32.0 MB, 8 = 64.0 MB
global myConsole
Iteration:=0
SetTimer, ShowPercentageSHA1,10
cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 09-Oct-2012
hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
IfLess,hFil,1, Return,hFil
	hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
VarSetCapacity( SHA_CTX,136,0 ),  DllCall( "advapi32\A_SHAInit", UInt,&SHA_CTX )
Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
	DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
, DllCall( "advapi32\A_SHAUpdate", UInt,&SHA_CTX, UInt,&Buffer, UInt,bytesRead )
, Iteration++
DllCall( "advapi32\A_SHAFinal", UInt,&SHA_CTX, UInt,&SHA_CTX + 116 )
DllCall( "CloseHandle", UInt,hFil )
Loop % StrLen( Hex:="123456789ABCDEF0" ) + 4
	N := NumGet( SHA_CTX,115+A_Index,"Char"), SHA1 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
SetTimer, ShowPercentageMD5,Off
gosub ShowPercentageSHA1
StringLower,SHA1,SHA1
Return SHA1, DllCall( "FreeLibrary", UInt,hMod )
ShowPercentageSHA1:
{
	BytesDone:=Round(Iteration*cSz)>fSz?fSz:Round(Iteration*cSz)
	SplitPath,sFile,sFilename
	myConsole.changeLine("Checking SHA1 for " sFilename "...." Round((BytesDone/fSz)*100) "%", myConsole.currentLine )
	return
}
}