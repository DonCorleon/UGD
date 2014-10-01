GetCookies(CookieJar,crumb=""){
	ArrayofCookies:=[]
	CrumbArray:=StrSplit(crumb,";")
	for a,b in CrumbArray
	{
		Found:=RegExMatch(b,"U)^(.*)=(.*)$",CookieName)
		if Found
		{
			ArrayofCookies[trim(CookieName1)]:=trim(CookieName2)
		}
		;m(a,b,CookieName1,CookieName2)
	}
	While (Pos:=RegExMatch(CookieJar,"U)Cookie: (.*)`n",CookiePacket,(Pos ? Pos+1 : 1))){
		CookieArray:=StrSplit(CookiePacket1,";")
		for a,b in CookieArray
		{
			If b contains path,domain,expires,httponly,Max-Age,Secure
				continue
			Found:=RegExMatch(b,"U)^(.*)=(.*)$",CookieName)
			if Found
				ArrayofCookies[trim(CookieName1)]:=trim(CookieName2)
		}
	}
	for a,b in ArrayOfCookies
		Cookies.=a "=" b "; "
	Return, Cookies
}