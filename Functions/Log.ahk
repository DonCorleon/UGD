DoLog(Level,Params*){
	static Logfile:="Log.txt",LogLevel:=1,Default:="time" ,FileLogging:=0,ControlName:="Status"
	global status
	{
		For a,b in params
		{
			if InStr(b,":"){
				RegExMatch(b,"(.*):(.*)",Found)
				if (Found1="Default")
					Default:=Found2
				if (Found1="LogFile")
					LogFile:=Found2
				if (Found1="Level")
					LogLevel:=Found2
				if (Found1="ToFile")
					FileLogging:=Found2
				if (Found1="Control")
					ControlName:=Found2
			}
			else
			{
				Message.=b
			}
		}
		if (FileLogging)
			m(Message "Logged to file") ;FileAppend,%Message%,%LogFile%
		
	}
	if (default="time")
		default:= LogLength(A_Hour ":" A_Min ":" A_Sec,10) ":`t"
	
	tt(default "[Red]" Message "[/]")
	GuiControl,Main:,%ControlName%,%Message%|
	;m("Default " Default,"LogFile " LogFile,"LogLevel " LogLevel,"FileLogging " FileLogging,"ControlName " ControlName,"Message " Message)
	Return
}
LogLength(string,maxlength)
{
	if (StrLen(string)<maxlength)
		while(StrLen(string)<maxlength)
			string.=" "
	if (StrLen(string)>maxlength)
		while(StrLen(string)>maxlength)
			StringTrimRight,String,String,1
	return, string
}