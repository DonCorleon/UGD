Get_FileFromOneDrive(url,FileExtension:=".dat",NameContains:=""){
	; ************ Step 1
	Options := "+Flag: INTERNET_FLAG_NO_COOKIES" ;+NO_AUTO_REDIRECT
	. (A_IsUnicode ? "`nCharset: UTF-8" : "")
	OneDriveCookie := ""
	HTTPRequest(url, InOutData := "", InOutHeader := Headers(), Options)
	If !ErrorLevel
		MsgBox, Error Occured
	
	OneDriveCookie.=GetCookies(InOutHeader)
	
	; ************ Step 2
	Found:=RegExMatch(InOutdata,"U)url=(.*)"" /",New_URL)
	If Found
	{
		Referer:=URL
		URL:=ReplaceHTML(New_URL1)
		
		HTTPRequest(URL, InOutData := "cookie: " OneDriveCookie, InOutHeader := Headers(referer), Options)
		If !ErrorLevel
			MsgBox, Error Occured
	}
	
	; ************* Step 3
	Found:=RegExMatch(InOutData,"U)""appId"":""(.*)""",APPID)
	IF !Found
		MsgBox, AppID Found`n%APPID1%
	
	Found:=RegExMatch(URL,"\?(.*)",Args)
	if Found
	{
		ArgsArray:=StrSplit(Args,"&")
		for a,b in ArgsArray
		{
			ifinstring,b,cid
				RegExMatch(b,"=(.*)",CID)
			else ifinstring,b,id
				RegExMatch(b,"=(.*)",ID)
			else ifinstring,b,authkey
				RegExMatch(b,"=(.*)",AuthKey)
		}
		
	}
	AuthKey:=OAuth__URIEncode(AuthKey1)
	data =
	(LTrim Join&
	id=%ID1%
	cid=%CID1%
	group=0
	qt=
	ft=
	sb=0
	sd=0
	gb=0`%2C1`%2C2
	d=1
	iabch=1
	caller=
	path=1
	si=0
	ps=100
	pi=5
	m=en-AU
	rset=skyweb&lct=1
	authkey=%AuthKey%
	v=0.9897678782443284
	)
	referer:="https://skyapi.onedrive.live.com/api/proxy?v=3"
	URL:="https://skyapi.onedrive.live.com/API/2/GetItems?" data
	HTTPRequest(URL, InOutData :="cookie: " OneDriveCookie, InOutHeader := Headers(referer) "`nAPPID: " APPID1, Options "`nMETHOD:GET")
	If !ErrorLevel
		MsgBox, Error Occured
	
	FileArray:=StrSplit(InOutData,"`{""commands")
	; Name Match First
	For a,b in FileArray
	{
		FoundExtension:=RegExMatch(b,"U)""extension"":""(.*)""",Extension)
		FoundName:=RegExMatch(b,"U)""name"":""(.*)""",Name)
		FoundLink:=RegExMatch(b,"U)""download"":""(.*)""",Link)
		FoundSize:=RegExMatch(b,"U)""size"":""(.*)""",Size)
		FoundNameMatch:=RegExMatch(name1,NameContains,NameMatch)
		if (FoundName && FoundExtension && Extension1=FileExtension && FoundNameMatch)
		{
			StringReplace,Link,Link1,\/,/,All
			File:= Object("FileName",Name1 Extension1,"Link",Link,"Size",Size1)
			return,File
		}	
	}
	;Now just Extension Match
	For a,b in FileArray
	{
		FoundExtension:=RegExMatch(b,"U)""extension"":""(.*)""",Extension)
		FoundName:=RegExMatch(b,"U)""name"":""(.*)""",Name)
		FoundLink:=RegExMatch(b,"U)""download"":""(.*)""",Link)
		FoundSize:=RegExMatch(b,"U)""size"":""(.*)""",Size)
		if (FoundName && FoundExtension && Extension1=FileExtension){
			StringReplace,Link,Link1,\/,/,All
			File:= Object("FileName",Name1 Extension1,"Link",Link,"Size",Size1)
			return,File
		}	
	}
	File:= Object("FileName",Name1 Extension1,"Link",Link,"Size",Size1)
	return,File
}
ReplaceHTML(URL){
	while ( Pos:=RegExMatch(URL,"U)&#(.*);",Number,(Pos ? Pos+1 : 1)))
		StringReplace,URL,URL,%Number%,% Chr(Number1),All
	return, URL	
}