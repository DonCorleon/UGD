Get_APILink(Origlink){
	global API,DEBUG_Times
	DEBUG_GetAPILink:=0
	If (DEBUG_Times)
		tick:=A_tickcount
	HTTPRequest(URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, Origlink, "", "GET" ),InOutData:="",InOutHeader:="")
	if (ErrorLevel!=200){
		tt("Get_APILink:`tError code ""[red]" ErrorLevel "[/]""")
		Return
	}
	StringReplace, InOutData, InOutData, \,, All
	if DEBUG_GetAPILink
		tt("Get_APILink:","URL: " URL,"Header: " InOutHeader),tt("Get_APILink:","Response: " InOutData)
	RegExMatch(InOutData, "U)link"":""(.*)""", Link)
	RegExMatch( Link1, "([^/]*)\?", LinkFileName )
	HTTPRequest(URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, Origlink "crc/", "", "GET" ),InOutData:="",InOutHeader:="")
	StringReplace, InOutData, InOutData, \,, All
	RegExMatch(InOutData, "U)link"":""(.*)""", CRCLink)
	HTTPRequest(URL := CRCLink1,InOutData:="",InOutHeader:="")
	CRC:=new XML("crc")
	CRC.xml.loadxml(InOutData)
	MD5:=crc.ssn("//file/@md5").text
	If (DEBUG_Times)
		tt("Retrieved in " A_TickCount-tick " ms")
	Return {FileName:LinkFileName1,Link:Link1,MD5:MD5}
}