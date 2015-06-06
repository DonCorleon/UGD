Get_APILink(Origlink){
	global API
	If (DebugMode)
		tick:=A_tickcount
	HTTPRequest(URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, Origlink, "", "GET" ),InOutData:="",InOutHeader:="")
	If (DebugMode)
		tt("[Aqua]Url[/] : " URL,"[Aqua]Header[/] : " InOutHeader)
	StringReplace, InOutData, InOutData, \,, All
	RegExMatch(InOutData, "U)link"":""(.*)""", Link)
	RegExMatch( Link1, "([^/]*)\?", LinkFileName )
	if Checksums
	{
		HTTPRequest(URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, Origlink "crc/", "", "GET" ),InOutData:="",InOutHeader:="")
		If (DebugMode)
			tt("[Aqua]Url[/] : " URL,"[Aqua]Header[/] : " InOutHeader)
		StringReplace, InOutData, InOutData, \,, All
		RegExMatch(InOutData, "U)link"":""(.*)""", CRCLink)
		HTTPRequest(URL := CRCLink1,InOutData:="",InOutHeader:="")
		If (DebugMode)
			tt("[Aqua]Url[/] : " URL,"[Aqua]Header[/] : " InOutHeader)
		CRC:=new XML("crc")
		CRC.xml.loadxml(InOutData)
		MD5:=crc.ssn("//file/@md5").text
	}
	else
		MD5="ABCDEF1234567890"
	If (DebugMode)
		tt("Retrieved in " A_TickCount-tick " ms")
	Return {FileName:LinkFileName1,Link:Link1,MD5:MD5}
}