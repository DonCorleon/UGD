HTTP_GetUserMovieInfo(){
	Global API,HTTP,Updates:=[],myConsole,Testing:=0
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
		List[Trim(ll2.item[4].innertext)]:=Object("Name","Movie:" Trim(ll2.item[4].innertext),"OrderID",ll["data-orderid"],"GameID",RegExReplace(ll.id,"game_li_"),"Background","http://static.gog.com" ll["data-background"],"MovieBox","http://static.gog.com" RegExReplace(ll.getelementsbytagname("img").item[0].src,"about:"),"Notification",Trim(ll.getelementsbyTagName("i").item[0].classname),"Selected",Testing)
	}
	RegExMatch( InOutData, "U)count"":(.*)\,",  TotalMovies)	; get the number of games returned in the last call
	TotalMoviesOwned +=TotalMovies1 ;----Add the the number of games found to the total number
	if (TotalMovies1 >= 45) ;----If its greater than 45 then check the next page	
		goto HTTPMovienextpage
	tt("INFO:`tYou Own " TotalMoviesOwned " Movies")
	for a,b in List
		Updates+=(!b.Notification)?0:1
	if Updates
	{
		tt("You Have " Updates " New/Update Notifications")
		for a,b in List
			if b.notification
				tt("[yellow]" a "[/] has new content." )
	}
	return, List
}
/*
	<div class=\"game-item\" 
	data-title=\"gamer age animatronic ackbar animatronic ackbar unknown unknown unknown\" 
	id=\"game_li_1207665321\" 
	data-background=\"\/upload\/images\/2014\/08\/78993806270413ff0b16f6c1470376d0aa39e05d.jpg\" 
	data-orderid=\"97e91e6b8f28\"> 
	<img class=\"list_image\" src=\"\/upload\/images\/2014\/08\/27fc9f1c85fef6be1908f46d87e5dc4239b1629c.jpg\" alt=\"\" \/> 
	<div class=\"progress_track css3pie\"> <div class=\"progress_bar css3pie\">
	<\/div> 
	<\/div> 
	<div class=\"list_arrow\">
	<\/div> 
	<div class=\"game-item-title\"> 
	<div class=\"game-item-title-in\"> 
	<span class=\"game-title-link\"> Gamer Age <\/span> 
	<span class="list_badges"> <i class="bdg_new"></i> </span>
	<\/div> 
	<\/div> 
	<\/div> 
*/
