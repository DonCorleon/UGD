API_Login(Username, Password){
	global DebugMode,API,myConsole
	tt("API:`tLogin Started")
	; Step one : Get the URL's and a few other bits of info
	HTTPRequest(API.oauth_get_urls "/",InOutData:="",InOutHeader:="")
	if (DebugMode) ;----------- DEBUG
		tt("API:Step 1","URL : " API.oauth_get_urls,"Header : " InOutHeader)
	;FileDelete, APIStep1.txt
	;FileAppend,%InOutData%,APIStep1.txt
	for a,b in ["status","version","url","mac_signature","mac_length","mac_sparkle_bundle","current_timestamp","oauth_get_temp_token","oauth_authorize_temp_token","oauth_get_token","get_user_details","get_user_games","get_game_details","get_installer_link","get_extra_link","set_app_status","error_log_endpoint","status_update_timer","link_expiration"]{
		RegExMatch(InOutData,"U)\b" b "\b.*:(.*)(,|})",found)
		value:=RegExReplace(found1,"(" Chr(34) "|\\)")
		if b=version
			b:="current_version"
		if (value="")
			Return tt("ERROR:`tStep 1. URL Error or Timeout")
		API[b]:=value
	}
	if (API.oauth_get_temp_token)
	{
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[green]API:`tPhase 1 passed[/]")
	}
	;tt("API:`tPhase 1 passed")
	; Step two : Get the temp keys
	API.Basic_Credentials :="oauth_consumer_secret=" API.Consumer_Secret "`noauth_consumer_key=" API.Consumer_Key
	URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, API.oauth_get_temp_token "/", "", "GET" )
	HTTPRequest(URL,InOutData:="",InOutHeader:="")
	if (DebugMode) ;----------- DEBUG
		tt("API:Step 2","URL : " URL,"Header : " InOutHeader)
	While(Pos:=RegExMatch(InOutData,"U)oauth_(.*)=(.*)(&|$)",Oauth,(Pos ? Pos+1 : 1)))
	{
		oauth1:="Temp_" oauth1
		API[oauth1]:=oauth2
	}
	if (API.Temp_Token&&Api.Temp_Token_Secret)
	{
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[green]API:`tPhase 2 passed[/]")
	}
	;tt("API:`tPhase 2 passed")
	else
		Return tt("ERROR:`tStep 2. We did not get the Temp token or the Temp Token Secret")
	; Step three : Get the verifier token
	Username:=OAuth__URIEncode(Username)
	Api.Specific_Credentials := "oauth_token=" API.Temp_Token "`noauth_token_secret=" API.Temp_Token_Secret
	URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, API.oauth_authorize_temp_token "/", "&password=" Password "&username=" Username, "GET" )
	HTTPRequest(URL,InOutData:="",InOutHeader:="")
	if (DebugMode) ;----------- DEBUG
		tt("API:`tStep 3","URL : " URL,"Header : " InOutHeader)
	While(Pos:=RegExMatch(InOutData,"U)oauth_(.*)=(.*)(&|$)",Oauth,(Pos ? Pos+1 : 1)))
		oauth1:="Temp_" oauth1,API[oauth1]:=oauth2
	If (API.Temp_Token&&API.Temp_Token_Secret&&API.Temp_Verifier)
	{
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[green]API:`tPhase 3 passed[/]")
	}
	;tt("API:`tPhase 3 passed")
	else
		return tt("ERROR:`tStep 3. Did NOT confirm Temp Token or find Verifier Key")
	; Step Four : Final Verification to get the token secret key
	Api.Specific_Credentials := "oauth_token=" API.Temp_Token "`noauth_token_secret=" API.Temp_Token_Secret	"`noauth_verifier=" API.Temp_Verifier
	URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, API.oauth_get_token "/", "", "GET" )
	HTTPRequest(URL,InOutData:="",InOutHeader:="")
	if (DebugMode)
		tt("API:Step 4","URL : " URL,"Header : " InOutHeader)
	While(Pos:=RegExMatch(InOutData,"U)oauth_(.*)=(.*)(&|$)",Oauth,(Pos ? Pos+1 : 1)))
		API[oauth1]:=oauth2
	If (API.Token&&API.Token_Secret)
	{
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[green]API:`tPhase 4 passed[/]")
	}
	;tt("API:`tPhase 4 passed")
	else
		return,0 tt("[Red]ERROR:`tStep 4. Did NOT confirm Temp Token or find Token Secret key[/]")
	if (DebugMode) ;--------------- DEBUG
		tt("Debug Mode")
	tto("[green]API:`tLogin Successful[/]")
	;tt("API:`tLogin Successful")
	Api.Specific_Credentials := "oauth_token=" API.Token "`noauth_token_secret=" API.Token_Secret
	return,1
}