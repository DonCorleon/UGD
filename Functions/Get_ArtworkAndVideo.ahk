Get_ArtworkAndVideo(game){
	Global Config,List
	if List[game].Name contains Movie
	{
		URL:="http://www.gog.com/movie/" List[Game].Folder
		;List[game].DLC.1.Folder
	}
	else
		URL:="http://www.gog.com/game/" List[Game].Folder
	PageData:=URLDownloadToVar(URL)
	;tt("Link - " URL List[Game].Folder)
	if Config.Downloads.Artwork
	{
		;******************** ARTWORK ***********************
		;----ScreenShots
		SizeArray:=[]
		While (Pos:=RegExMatch(PageData,"U)pauseAll\(\)""><img src=""http:\/\/static(.*)""",Artwork,(Pos?Pos+1:1)))
			If !(FileCheck(Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\ScreenShot-" Number:=A_Index<10?"0" A_index ".jpg":A_Index ".jpg",,"http://static" Artwork1))
				DownLoadFile("http://static" Artwork1,Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\ScreenShot-" Number)
		;tt("http://static" Artwork1,Config.Artwork "\" game "\ScreenShot-" A_Index ".jpg")
		
		;---- B&W Background
		If !(List[game].Background="http://static.gog.com")
		{
			If !(FileCheck(Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\Background.jpg",,List[game].Background))
				DownLoadFile(List[game].Background,Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\Background.jpg")
			;tt(List[game].Background)
		}
		
		;----Colour Background
		While (Pos:=RegExMatch(PageData,"U)<meta name=""og\:image"" content=""(.*)"">",Artwork,(Pos?Pos+1:1)))
			If !(FileCheck(Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\Background-2.jpg",,"http:" Artwork1))
				DownLoadFile("http:" Artwork1,Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\Background-2.jpg")
		;tt(Artwork1)
		
		;----BoxArt
		;While (Pos:=RegExMatch(PageData,"U)",Artwork,(Pos?Pos+1:1)))
		If !(List[game].BoxArt="http://static.gog.com")
		{
			If !(FileCheck(Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\BoxArt.jpg",,List[game].GameBox))
				DownLoadFile(List[game].GameBox,Config.Artwork "\" DetermineFolder(List[Game].Folder,"Artwork") "\BoxArt.jpg")
			;tt(List[game].GameBox)
		}
	}
	if Config.Downloads.Videos
	{
		;tt("Download of Game Videos is currently only available in 720P.")
		;******************** VIDEOS ***********************
		While (Pos:=RegExMatch(PageData,"U)src=""(http|https)\:\/\/www\.youtube\.com\/embed\/(.*)\?",Youtube,(Pos?Pos+1:1)))
		{
			Link:=Youtube1 "://www.youtube.com/watch?v=" youtube2
			;URL:=Get_Youtube_Video(Link,"mp4,720P,360P,muxed")
			URL:=Get_Youtube_Vid(Link,"720")
			VideoTitle:=URL.filename ".mp4"
			StringReplace,VideoTitle,VideoTitle,`:,-,All
			if (VideoTitle=".mp4")
				VideoTitle:=game ".mp4"
			If !(FileCheck(Config.Videos "\" DetermineFolder(List[Game].Folder,"Videos") "\" VideoTitle,,URL.Link))
			{
				DownLoadFile(URL.link,Config.Videos "\" DetermineFolder(List[Game].Folder,"Videos") "\" VideoTitle)
				;tt("URL : " URL.Link)
			}
			
		}
	}
	
}
UriEncode(Uri, Enc = "UTF-8"){
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
		|| Code >= 0x61 && Code <= 0x7A) ; a-z
		Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}
UriDecode(Uri, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}
StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

Get_YouTube_Vid(URL,RequestedQuality="720")
{
	global Config
	Response:=UrlDownloadToVar(URL) ; "%A_ScriptDir%\response.txt"
	RegExMatch(Response, "U)<title>(.*) - YouTube</title>", Title)
	TitleName:=URIEncode(Title1)
	FileName:= RegExReplace(Title1,":","-")
	Loop, Parse,Response,`n
	{
		
		IfInString, A_LoopField, bitrate
		{
			Ourline:=A_LoopField
			Break
		}
	}
	LinkFields:=[]
	taglist:=[],urllist:=[]
	for a,b in StrSplit(ourline,","){
		for c,d in StrSplit(b,Chr(34)){
			if InStr(d,"quality"){
				d:=uridecode(d)
				d:=RegExReplace(d,"U)\\u\d\d\d\d","&")
				for e,f in StrSplit(d,"&"){
					if (SubStr(f,1,2)="s=")
						f:=RegExReplace(f,"s=","signature=")
					if InStr(f,"url=http")
						start:=RegExReplace(f,"url=")
					;Else if InStr(f,"ip=")
					;{
					;after.="&ip=" Config.IP
					;tt("Replaced " f " with &ip=" Config.IP )
					;}
					Else if !InStr(f,"type=")&&!InStr(f,"quality=")&&!InStr(f,"fallback_host=")&&!InStr(f,"size="){
						if !taglist[f]
							after.="&" f
						taglist[f]:=1
					}
					Else if InStr(f,"type="){
						type:=f
						
					}
					if InStr(f,"quality=")
						Quality:=f
					
				}
				title:="&title=" title1
				urllist.Insert(start after title)
				if instr(type,"video/mp4")
				if InStr(Quality,RequestedQuality){
					ReturnLink:=Object("Filename",title1,"Link",start after title)	
					break
				}
				;LV_Add("",Quality,start,after,title)
				start:=after:=title:="",taglist:=[]
				type:=""
			}
		}
	}
	Return, ReturnLink	
}
Get_YouTube_Video( YouTubeURL,ParsedIn:="all",GetSizes:="OFF")
{
	URL:=[],LinkFields:=[],LinkList:=[],PreferedIndex:=""	
	If ParsedIn=all
		DoLinkParsing:=0
	Else
		DoLinkParsing:=1
	Response:=UrlDownloadToVar(YouTubeURL) 
	Loop, Parse,Response,`n
	{
		Ourline:=A_LoopField
		If A_LoopField contains bitrate
			Break
	}
	TitleFound:=RegExMatch(Ourline,"U)""title"": ""(.*)"",",Title) ; for title in this line "title": "(.*)"
	Title1:=RegExReplace(Title1,"U)(\\u\d\d\d\d|&amp;)","&")
	Title1:=RegExReplace(Title1,"U)\\.","")
	Loop, Parse, OurLine,`,
	{
		Link:=""
		If A_LoopField contains quality=,index=
		{
			Title:="",Filename:="",Extension:="",MediaType:="",Resolution:="",FinalURL:="",FileSize:="",Expiry:="",Duration:="",Selected:=""
			TagOrder:=[]
			ParameterList:=[]
			ParameterList["title="]:=RemHTMLSC(Title1)
			KeyList:=["bitrate=","clen=","codecs=","dur=","expire=","fallback_host=","fexp=","gcr=","gir=","id=","index=","init=","ip=","ipbits=","itag=","key=","lmt=","ms=","mt=","mv=","mws=","pcm2fr=","quality=","ratebypass=","s=","signature=","size=","source=","sparams=","sver=","title=","type=","upn=","url="]
			LinkNum++
			{
				Link:="&" A_LoopField "&"
				Link:=RegExReplace(Link,"U)(\\u\d\d\d\d|%26|%3B)","&")
				StringReplace,Link,Link,%A_Space%"adaptive_fmts": ",,All
				StringReplace,Link,Link,%A_Space%"url_encoded_fmt_stream_map": ",,All
				StringReplace,Link, Link,`",, All
				StringReplace,Link, Link,`%25,`%, All
				StringReplace,Link, Link,`%22,, All
				StringReplace,Link, Link,`%2F,`/, All
				StringReplace,Link, Link,`%3A,`:, All
				StringReplace,Link, Link,`%3D,`=, All
				StringReplace,Link, Link,`%3F,`?, All
				StringReplace,Link, Link,videoplayback?,videoplayback`&, All
				For i,param in KeyList{
					Found:=RegExMatch(Link,"U)&\+?" Param "(.*)&?",P)
					If Found
						ParameterList[Param]:=P1, TagOrder[Found]:=Param
				}
				ListTheOrder:=""
				for i,Test in TagOrder
					if Test not contains url,type,codecs,size,fallback_host,quality,init,index,bitrate
					{
						If Test=s=
							ListTheOrder.="signature=" ParameterList[Test] "&"
						Else if Test=ip=
							ListTheOrder.=Test Config.IP "&"
						Else
							ListTheOrder.=Test ParameterList[Test] "&"
					}
				FinalURL.=ParameterList["url="] "?" ListTheOrder "title=" OAuth__URIEncode(Title1)
				RegExMatch(ParameterList["type="],"(.*)\/",MediaType)
				If MediaType1					
					MediaType:=MediaType1
				RegExMatch(ParameterList["type="],"\/(.*)",Extension)
				If Extension1{
					If (MediaType1="audio"&&Extension1="mp4")
						Extension:="mp3",MediaType := "audio"
					Else
						Extension:=Extension1
				}
				RegExMatch(ParameterList["size="],"x(.*)",Resolution)
				If Resolution1{
					MediaType := "video"
					Resolution:=Resolution1 "P"
					if PreferedQuality=%Resolution%
						Selected:=1
				}
				If ParameterList["quality="]
				{
					Quality:=ParameterList["quality="]
					MediaType:="muxed"
					if Quality=HIGHRES
						Resolution:="2160P"
					else if Quality=hd1440
						Resolution:="1440P"
					else if Quality=hd1080
						Resolution:="1080P"
					else if Quality=hd720
						Resolution:="720P"
					else if Quality=medium
						Resolution:="360P"
					else if Quality=small
						Resolution:="240P"
					else if Quality=tiny
						Resolution:="144P"
				}
				if MediaType1=audio
					If (ParameterList["bitrate="]<129000&&ParameterList["bitrate="]>127000)
						Resolution:="128Kbs"
				Title:= RemHTMLSC(TitleName)
				if ParameterList["dur="]
					Duration:=ParameterList["dur="]
				if ParameterList["expiry="]
					Expiry:=ParameterList["expire="]
				Title:=RemHTMLSC(Title1)
				StringReplace,Filename,Title,:,,All
				If GetSizes=On
				{
					WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
					WebRequest.Open("HEAD",FinalURL)
					WebRequest.Send()
					FileSize:=WebRequest.GetResponseHeader("Content-Length")
				}
				URL[LinkNum]:=Object("Title",Title,"FileName",Filename,"Extension",Extension,"MediaType",MediaType,"Resolution",Resolution,"Link",FinalURL,"FileSize",FileSize,"Expiry",Expiry,"Duration",Duration,"Selected",Selected)
			}
			LinkList[LinkNum]:=Link
		}
	}
	If DoLinkParsing
	{
		Preferences:=[]
		loop,3
			Preferences[A_Index]:=[]
		Rating:=[]
		for a,b in StrSplit(ParsedIn,",")
		{
			if b contains mp4,3gp,mp3,ogg,webm,wmv
				Preferences.1.Insert(b)
			if b contains medium,small,1080,720,480,360,240,144
				Preferences.2.Insert(b)
			if b contains muxed,video,audio
				Preferences.3.Insert(b)
		}
		for a,b in Preferences
			for index,value in b
			{
				for c,d in URL{
					for i,type in ["Extension","Resolution","MediaType"]
						if (URL[c][type]=value)
						{
						if !Rating[c]
							Rating[c]:=0
						Rating[c]+=b.MaxIndex()+1-index			
						}
				}
		}
		Max:=0
		for a,b in Rating
		{
			if (b>Max)
				Max:=b,MyUrl:=a
			if (b=max)
				Multiples:=Multiples "-" a
		}
		FilteredUrl:=[]
		FilteredURL[1]:=URL[MyUrl]
		Return FilteredURL
	}
	return, URL
}
RemHTMLSC(String){
	Static HTMList
	If !IsObject(HTMList)
	{
		HTMList:=[]
		Loop 16
		{
			if A_Index<11
				Num1:=Chr(A_Index+47)
			Else
				Num1:=Chr(A_Index+54)
			Loop 16
			{
				if A_Index<11
					Num2:=Chr(A_Index+47)
				Else
					Num2:=Chr(A_Index+54)
				HTMList.Insert("&#" num1 num2 ";")
			}
		}
		
		Loop % 256-33 {
			Transform, F, HTML, % Chr( A := A_Index+33 )
			If Strlen(F) > 1 && !Instr( F, "#" )
				HTMlist.Insert("&" SubStr(F,2, StrLen(F)-2) ";") ; Chr(A ))
		}
	}
	For a,b in HTMList
		IfInString,string, % b
			StringReplace,string,string,% b,,All
	return, string
}