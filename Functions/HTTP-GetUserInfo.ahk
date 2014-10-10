HTTP_GetUserInfo(){
	Global API,HTTP,Updates:=[],myConsole,Testing
	page:=0,IndexNum:=0,TotalOwned:=0,UpdateNotifications:=0,List:=[]
	html:=ComObjCreate("htmlfile")
	ComObjError(0)
	tt("INFO:`tRetrieving Page " page+1)
	HTTPnextpage:
	page++	; increment the page number we are trying to get
	myConsole.changeLine("[Green]INFO:`tRetrieving Page " page "[/]", myConsole.currentLine )
	HTTPRequest(url:="https://www.gog.com/account/ajax?a=gamesShelfMore&s=title&q=&t=0&p=" page, InOutData := "", InOutHeader := Headers(Http.GoGCookie), Http.GoGOptions)
	;HTTPRequest(url:="https://www.gog.com/account/ajax?a=moviesListMore&s=title&q=&t=0&p=" page, InOutData := "", InOutHeader := Headers(Http.GoGCookie), Http.GoGOptions)
	If (ErrorLevel!=200)
		tt("Failed to Get Page with Error Code : " Errorlevel),Return
	If Testing
	{
		;FileDelete,%A_ScriptDir%\Testing\GetUserInfo-Page%Page%.txt
		;FileAppend,% "Header Response:`n" InOutHeader "`n`nData :`n" InOutData,%A_ScriptDir%\Testing\GetUserInfo-Page%Page%.txt
	}
	StringReplace,InOutData,InOutData,\,,All
	html.write(InOutData)
	PageInfo:=html.all
	while,ll:=PageInfo.item[A_Index-1]
		if game:=ll.getattribute("data-gameindex")
			List[ll["data-gameindex"]]:=Object("Name",ll["data-gameindex"],"Folder",ll["data-gameindex"],"OrderID",ll["data-orderid"],"GameID",ll["data-gameid"],"HasDLC",RegExReplace(ll.childnodes.item[1].outertext,"[^0-9]",$1),"Notification",ll.lastchild.firstchild.classname,"Background","http://static.gog.com" ll["data-background"],"GameBox","http://static.gog.com" RegExReplace(RegExReplace(ll.firstchild.src,"about:"),"_bbC_20"),"Selected",Testing)
	RegExMatch( InOutData, "U)count"":(.*)\,",  TotalGames)	; get the number of games returned in the last call
	TotalOwned +=TotalGames1 ;----Add the the number of games found to the total number
	if (TotalGames1 >= 45) ;----If its greater than 45 then check the next page	
		goto HTTPnextpage
	DLCs:=0,Updates:=0
	for a,b in List
		DLCs+=(!b.HasDLC)?0:b.HasDLC,Updates+=(b.Notification&&(b.notification!="bdg_soon"))?1:0
	if DLCs
		tt("INFO:`tYou Own " TotalOwned " Games & " DLCs " DLC Addons.")
	Else
		tt("INFO:`tYou Own " TotalOwned " Games")
	if Updates
	{
		tt("You Have " Updates " New/Update Notifications")
		for a,b in List
		if (b.notification){
			b.Selected:=1
			tt("[yellow]" a "[/] has new content. " b.notification)
		}
		GuiControl,Main:Enable,ButtonGetGames
	}
	
	;***********************************************
	FileRead,TempVar,% A_ScriptDir "\Resources\" Config.names
	Loop,Parse,TempVar,`r
	{
		RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)\(((january|february|march|april|may|june|july|august|september|october|november|december).*)\)(| \[DLC\])" Chr(34),found)
		List[Found1].Name:=Found2
	}
	;***********************************************
	return, List
}