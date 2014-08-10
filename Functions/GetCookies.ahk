GetCookies(CookieJar){
	While (Pos:=RegExMatch(CookieJar,"U)Cookie: (.*)`n",CookiePacket,(Pos ? Pos+1 : 1))){
		CookieArray:=StrSplit(CookiePacket1,";")
		for a,b in CookieArray
		{
			If b contains path,domain,expires,httponly,Max-Age,Secure
				continue
			Cookies.=trim(b) "; "
		}
	}
	Return, Cookies
}