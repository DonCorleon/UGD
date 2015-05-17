HTTP_Login(UserName,UserPass){
	global DEBUG_HTTP:=0,HTTP,Cookie:="",myConsole,Version
	tt("HTTP:`tLogin Started")
	Options := "+Flag: INTERNET_FLAG_NO_COOKIES`n+NO_AUTO_REDIRECT"
	. (A_IsUnicode ? "`nCharset: UTF-8" : "")
	HTTPRequest(url:="http://www.gog.com/", InOutData := "", InOutHeader := Headers(), Options "`nMETHOD:POST") ; first request to get a gutm and game Ids for initial login request
	if (DEBUG_HTTP) ;--------------- DEBUG
		tt("HTTP:Step 1","URL : "URL,"Cookie : "cookie,"Header`n"InOutHeader)
	if (DEBUG_HTTP>1) ;----------- DEBUG
	{
		;tt("HTTP:Step 1",InOutData)
		FileDelete,HTTP-Step1.txt
		FileAppend, URL`n%URL%`n`nHeader`n%InOutHeader%`n`nCookie`n%Cookie%`n`nInOutData`n%InOutData%,HTTP-Step1.txt
	}
	if !(RegExMatch(InOutData,"U)GalaxyAccounts\(\'(.*)\'",Auth_URL))
	{
		tt("[red]ERROR[/]:`tNo AUTH_URL Found")
		goto HTTPFailed
	}
	;If !(RegExMatch(InOutData,"U)id=""gutm"" value=""(.*)"" />",gutm))
	;Return tt("[red]ERROR[/]:`tNo GUTM Found")
	;If !(RegExMatch(InOutData,"U)id=""uqid"" value=""(.*)"" />",uqid))
	;Return tt("[red]ERROR[/]:`tNo UQID Found")
	tto("[green]HTTP:`tPhase 1 passed[/]")
	;tt("HTTP:`tPhase 1 passed")
	;While, (Pos:=RegExMatch(InOutData,"data-gameid=""\K\d+",gameid,Pos+StrLen(gameid)))
	;games .= "," gameid
	;Games:=OAuth__URIEncode(Trim(games,","))
	;*************** Step 2
	StringReplace,Clean_Auth_URL,Auth_URL1,&amp;,&,All
	url := Clean_Auth_URL
	Cookie:= GetCookies(InOutHeader)
	Redo2: ;----------------- Redirect
	HTTPRequest(url, InOutData := "", InOutHeader := Headers() , Options)
	if (DEBUG_HTTP) ;--------------- DEBUG
		tt("HTTP:Step 2","URL : "URL,"Cookie : "cookie,"Header`n"InOutHeader)
	if (DEBUG_HTTP>1) ;----------- DEBUG
	{
		;tt("HTTP:Step 2",InOutData)
		FileDelete,HTTP-Step2.txt
		FileAppend, URL`n%URL%`n`nHeader`n%InOutHeader%`n`nCookie`n%Cookie%`n`nInOutData`n%InOutData%,HTTP-Step2.txt
	}
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		tto("[Red]Redirecting[/]")
		goto Redo2
	}
	FoundToken:=RegExMatch(InOutData,"U)name=""login\[_token\]"" value=""(.*)"" \/\>",Login_Token)
	if !FoundToken
	{
		tt("[Red]ERROR[/]:No login token Found")
		goto HTTPFailed
	}
	FoundID:=RegExMatch(URL,"U)client_id=(.*)\&",Login_ID)
	if !FoundID
	{
		tt("[Red]ERROR[/]:No Client ID Found")
		goto HTTPFailed
	}
	tto("[green]HTTP:`tPhase 2 passed[/]")
	;**************** Step 3
	Referer:=URL
	url:="https://login.gog.com/login_check"
	data =
	(LTrim Join&
	login`%5Busername`%5D=%UserName%
	login`%5Bpassword`%5D=%UserPass%
	login`%5Blogin`%5D=
	login`%5B_token`%5D=%Login_Token1%
	)
	Redo3: ;----------------- Redirect
	Cookie.=GetCookies(InOutHeader)
	HTTPRequest(url, InOutData := data, InOutHeader := Headers(Referer), Options "`nMethod:POST")
	if (DEBUG_HTTP) ;--------------- DEBUG
		tt("HTTP:Step 3","URL : "URL,"Data : " data ,"Cookie : "cookie,"Header`n"InOutHeader)
	if (DEBUG_HTTP>1) ;----------- DEBUG
	{
		;tt("HTTP:Step 3",InOutData)
		FileDelete,HTTP-Step3.txt
		FileAppend, URL`n%URL%`n`nHeader`n%InOutHeader%`n`nData`n%Data%`n`nCookie`n%Cookie%`n`nInOutData`n%InOutData%,HTTP-Step3.txt
	}
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		tto("[Red]Redirecting[/]")
		goto Redo3
	}
	Cookie.=GetCookies(InOutHeader)
	tto("[green]HTTP:`tPhase 3 passed[/]")
	;**************** Step 4
	
	URL:="https://www.gog.com/account/settings/personal"
	Referer:=URL
	Redo4:
	HTTPRequest(URL, InOutData, InOutHeader := Headers(Referer), Options)
	if (DEBUG_HTTP) ;--------------- DEBUG
		tt("HTTP:Step 4","URL : "URL,"Cookie : "cookie,"Header`n"InOutHeader)
	if (DEBUG_HTTP>1) ;----------- DEBUG
	{
		tt("HTTP:Step 4",InOutData)
		FileDelete,HTTP-Step4.txt
		FileAppend, URL`n%URL%`n`nHeader`n%InOutHeader%`n`nData`n%InOutData%,HTTP-Step4.txt
	}
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		;if (New_URL1 != "/")
		url:=New_URL1
		Cookie.=GetCookies(InOutHeader)
		tto("[Red]Redirecting[/]")
		goto Redo4
	}
	If RegExMatch(InOutData, "U)Username<\/span><strong class=""settings-item__value settings-item__section"">(.*)<\/strong>", NickName)
	{
		tto("[green]HTTP:`tPhase 4 passed[/]")
		;tt("HTTP:`tPhase 4 passed")
		;tt("Welcome " NickName1)
		Gui,Show,,Ultimate GoG Downloader v%Version% - %NickName1%
	}
	else
		goto HTTPFailed
	
	HTTP.GoGCookie:=Cookie
	HTTP.GoGOptions:=Options
	tto("[green]HTTP:`tLogin Successful[/]")
	;tt("HTTP:`tLogin Successful")
	return,1
	
	HTTPFailed:
	{
		GuiControl,Main:Enable,ButtonSelectGames
		GuiControl,Main:Enable,ButtonLogin
		GuiControl,Main:Enable,ConfigWindow
		GuiControl,Main:Enable,ButtonUpdate
		tt("HTTP:`tLogin Failed"),
		tt("HTTP Error:`tSkipping API login")
		Return,0
	}
}