HTTP_GetUserMovieInfo(){
	Global Config,API,HTTP,Updates:=[],myConsole,Testing:=0
	page:=0,IndexNum:=0,TotalOwned:=0,UpdateNotifications:=0,List:=[]
	html:=ComObjCreate("htmlfile")
	ComObjError(0)
	tt("INFO:`tRetrieving Movie Page " page+1)
	HTTPMovienextpage:
	page++	; increment the page number we are trying to get
	myConsole.changeLine("[Green]INFO:`tRetrieving Movie Page " page "[/]", myConsole.currentLine )
	HTTPRequest(url:="https://www.gog.com/account/ajax?a=moviesListMore&s=title&q=&t=0&p=" page, InOutData := "", InOutHeader := Headers(Http.GoGCookie), Http.GoGOptions)
	If (ErrorLevel!=200)
		tt("Failed to Get Page with Error Code : " Errorlevel),Return
	StringReplace,InOutData,InOutData,\,,All
	;FileDelete,MovieInfo-Page%Page%.txt
	;FileAppend,%InOutData%,MovieInfo-Page%Page%.txt
	html.write(InOutData)
	PageInfo:=html.getelementsbytagname("div")
	while,ll:=PageInfo.item[A_Index-1]
	if ll.getattribute("id"){
		ll2:=ll.getelementsbytagname("div")
		List[Trim(ll2.item[4].innertext)]:=Object("Name","Movie:" Trim(ll2.item[4].innertext),"OrderID",ll["data-orderid"],"GameID",RegExReplace(ll.id,"game_li_"),"Background","http://static.gog.com" ll["data-background"],"GameBox","http://static.gog.com" RegExReplace(ll.getelementsbytagname("img").item[0].src,"about:"),"Notification",Trim(ll.getelementsbyTagName("i").item[0].classname),"Selected",Testing)
	}
	RegExMatch( InOutData, "U)count"":(.*)\,",  TotalMovies)	; get the number of games returned in the last call
	TotalMoviesOwned +=TotalMovies1 ;----Add the the number of games found to the total number
	if (TotalMovies1 >= 45) ;----If its greater than 45 then check the next page	
		goto HTTPMovienextpage
	tt("INFO:`tYou Own " TotalMoviesOwned " Movies")
	for a,b in List
		Updates+=(b.Notification&&b.notification!="bdg_soon")?1:0
	if Updates
	{
		tt("You Have " Updates " New/Update Notifications")
		for a,b in List
			if (b.notification)
			{
				b.Selected:=1
				tt("[yellow]" a "[/] has new content.")
			}
	}
	return, List
}
