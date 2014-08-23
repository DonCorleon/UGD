Get_APILink(link){
	global API
	DEBUG_GetAPILink:=0
	URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, link, "", "GET" )
	HTTPRequest(URL,InOutData:="",InOutHeader:="")
	if (DEBUG_GetAPILink){
		tt("Get_GameInfo:","URL: " URL,"Header: " InOutHeader)
		tt("Get_GameInfo:","Response: " InOutData)
	}
	StringReplace, InOutData, InOutData, \/,/, All
	RegExMatch(InOutData, "U)link"":""(.*)""", Link)
	RegExMatch( Link1, "(.*)\?", LinkFileName )
	SplitPath, LinkFileName1, FileName
	NewLink:=Object("FileName",Filename,"Link",Link1)
	Return,NewLink	
}