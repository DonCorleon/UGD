Reuse_Login(option)
{
	global Cookie,HTTP,API
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
		if(LastLogin&&(A_Now-LastLogin)<10000)
		{
			tt("Attempting to Reuse Last Login from " LastLogin)
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
			Return 1
		}
	}
	
	Return,0
}