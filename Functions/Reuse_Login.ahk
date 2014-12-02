Reuse_Login(option)
{
	global Cookie,HTTP,API,version
	if (Option="SAVE")
	{
		for a,b in HTTP
		{
			StringReplace,b,b,`n,~,ALL
			IniWrite,% b,%A_ScriptDir%\Resources\Config.ini,LoginHTTP,% a
		}
		for a,b in API
		{
			StringReplace,b,b,`n,~,ALL
			IniWrite,% b,%A_ScriptDir%\Resources\Config.ini,LoginAPI,% a
		}
		IniWrite,% A_Now,%A_ScriptDir%\Resources\Config.ini,Login,LastLogin		
		Return	
	}
	if (Option="LOAD")
	{
		IniRead,LastLogin,%A_ScriptDir%\Resources\Config.ini,Login,LastLogin,0
		if(LastLogin&&(A_Now-LastLogin)<2000000)
		{
			tt("Attempting to use previous login cookies...")
			IniRead,IniAPI,%A_ScriptDir%\Resources\Config.ini,LoginAPI
			IniRead,IniHTTP,%A_ScriptDir%\Resources\Config.ini,LoginHTTP
			API:=[]
			HTTP:=[]
			Loop,Parse,IniAPI,`r`n
			{
				RegExMatch(A_LoopField,"U)^(.*)=(.*)$",Ini)
				StringReplace,Ini2,Ini2,~,`n,ALL
				API[Ini1]:=Ini2
				;m("1 - "ini1,"","","2 - "ini2)
			}
			Loop,Parse,IniHTTP,`r`n
			{
				RegExMatch(A_LoopField,"U)^(.*)=(.*)$",Ini)
				StringReplace,Ini2,Ini2,~,`n,ALL
				HTTP[Ini1]:=Ini2
			}
			Cookie:=HTTP.GoGCookie
			
			URL:="https://www.gog.com/account"
			Options := "+Flag: INTERNET_FLAG_NO_COOKIES`n+NO_AUTO_REDIRECT"
			. (A_IsUnicode ? "`nCharset: UTF-8" : "")
			Redo4a:
			HTTPRequest(URL, InOutData, InOutHeader:=Headers(), Options "`nx-requested-with: XMLHttpRequest")
			Found:=RegExMatch(InOutHeader,"U)Location: (.*)`n",New_URL)
			if (found){ ;----------------- Check for Redirect
				url:=New_URL1
				goto Redo4a
			}	
			If RegExMatch(InOutData, "U)id=""currentUsername"" value=""(.*)""", NickName)
			{
				tt("Previous Cookies Successful.")
				Gui,Show,,Ultimate GoG Downloader v%Version% - %NickName1%
				Return 1
			}
		}
	}
	
	Return,0
}