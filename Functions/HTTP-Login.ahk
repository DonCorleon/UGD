HTTP_Login(UserName,UserPass){
	global DEBUG_HTTP,Cookie:=""
	tt("HTTP:`tLogin Started")
	Options := "+Flag: INTERNET_FLAG_NO_COOKIES`n+NO_AUTO_REDIRECT"
	. (A_IsUnicode ? "`nCharset: UTF-8" : "")
	HTTPRequest(url:="https://secure.gog.com/", InOutData := "", InOutHeader := Headers(), Options "`nMETHOD:POST") ; first request to get a gutm and game Ids for initial login request
	if DEBUG_HTTP ;--------------- DEBUG
		m("HTTP:Step 1",URL,cookie,InOutHeader),m("HTTP:Step 1",InOutData)
	if !(RegExMatch(InOutData,"U)id=""auth_url"" value=""(.*)"" />",Auth_URL))
		Return tt("ERROR:`tNo AUTH_URL Found")
	If !(RegExMatch(InOutData,"U)id=""gutm"" value=""(.*)"" />",gutm))
		Return tt("ERROR:`tNo GUTM Found")
	If !(RegExMatch(InOutData,"U)id=""uqid"" value=""(.*)"" />",uqid))
		Return tt("ERROR:`tNo UQID Found")
	tt("HTTP:`tPhase 1 passed")
	While, (Pos:=RegExMatch(InOutData,"data-gameid=""\K\d+",gameid,Pos+StrLen(gameid)))
		games .= "," gameid
	Games:=OAuth__URIEncode(Trim(games,","))
	;*************** Step 2
	StringReplace,Clean_Auth_URL,Auth_URL1,&amp;,&,All
	url := Clean_Auth_URL
	Cookie:=GetCookies(InOutHeader)
	redo2: ;----------------- Redirect
	HTTPRequest(url, InOutData := "", InOutHeader := Headers() , Options)
	if (DEBUG_HTTP) ;--------------- DEBUG
		m("HTTP:Step 2",URL,cookie,InOutHeader),m("HTTP:Step 2",InOutData)
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		goto Redo2
	}
	Found:=RegExMatch(InOutData,"U)name=""login\[_token\]"" value=""(.*)"" \/\>",Login_Token)
	if !Found
		Return tt("ERROR:`tNo login[token] Found")
	tt("HTTP:`tPhase 2 passed")
	Cookie.=GetCookies(InOutHeader)
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
	HTTPRequest(url, InOutData := data, InOutHeader := Headers(Referer), Options "`nMethod:POST")
	if (DEBUG_HTTP) ;--------------- DEBUG
		m("HTTP:Step 3",URL,cookie,InOutHeader),m("HTTP:Step 3",InOutData)
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)`n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		goto Redo3
	}	
	Cookie.=GetCookies(InOutHeader)
	tt("HTTP:`tPhase 3 passed")
	;**************** Step 4
	data =
	(LTrim Join&
	a=get
	c=frontpage
	p1=false
	p2=false
	auth=
	games=%games%
	gutm=%gutm1%
	pp=
	)
	HTTPRequest(URL:="http://www.gog.com/user/ajax", InOutData := data, InOutHeader:=Headers("http://www.gog.com/"), Options "`nx-requested-with: XMLHttpRequest`nMethod: POST")
	if (DEBUG_HTTP) ;--------------- DEBUG
		m("HTTP:Step 4",URL,cookie,InOutHeader),m("HTTP:Step 4",InOutData)
	If RegExMatch(InOutData, """xywka"":""\K[^""]+", NickName)
		tt("HTTP:`tPhase 4 passed"),tt("Welcome " NickName)
	else
		Return tt("HTTP:`tLogin Failed"),tt("HTTP Error:`tSkipping API login")
	return,1 tt("HTTP:`tLogin Successful")
}