DownloadFile(link,SaveAs){
	SplitPath,SaveAs,File,Directory
	tt("Setting Up Download....")
	IfNotExist,%Directory%
		FileCreateDir,%Directory%
	HttpRequest(URL:=link,InOutData,InOutHeader,options:="SAVEAS:" SaveAs "`nCallBack:DownloadProgress," File)
	Progress,Off
	Return
}
DownloadProgress(Percentage,Size,File){
	global myConsole
	myConsole.changeLine("[blue]" Round(Percentage*100,0) "%[/] - [Green]Downloading [/][yellow]" File "[/] - [red]" Round(Size*Percentage,0) "/" Size "[/]", myConsole.currentLine )
	
	;Progress,% Round(Percentage*100,0),% Round(Percentage*100,0) "% of " Round(Size*Percentage,0) "/" Size,% "Downloading " File,Downloading %File%
	Return	
}