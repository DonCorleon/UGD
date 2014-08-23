Get_GameInfo(GameName){
	/*
		This Needs to be refined and add the gather DLC, Installers, LanguagePacks,
	*/
	global List,Config,API
	DEBUG_GetGames:=0 ;---- Set to debug this module
	Extras:=[],DLC:=[]
	Name := List[GameName].Folder
	GameFolder := List[GameName].Folder
	URL := "https://secure.gog.com/en/account/ajax?a=gamesListDetails&g=" . List[GameName].GameId
	HTTPRequest(url, InOutData := "", InOutHeader := Headers(), Options)
	StringReplace,InOutData,InOutData,\,,All
	StringReplace, InOutData, InOutData, a>, a>`n, All
	FileDelete,GameInfo-%Name%.txt
	FileAppend,%InOutData%,GameInfo-%Name%.txt
	ExtraNum := 0
	LangOption:=Object("ar","Arabic","bl","Bulgarian","cn","Chinese","cz","Czech","da","Danish","nl","Dutch","en","English","fi","Finnish","fr","French","de","German","gk","Greek","hu","Hungarian","it","Italian","jp","Japanese","ko","Korean","no","Norwegian","pl","Polish","pt","Portuguese","ro","Romanian","ru","Russian","sb","Serbian","sk","Slovac","es","Spanish","sv","Swedish","tr","Turkish","uk","Ukranian")
	Loop, Parse, InOutData, `n
	{
		; *************  Get Extras Info *************
		IfInString, A_LoopField, bonus_content_list browser		
		{
			Found_DLC = 0
			Found_Extras = 1
		}
		IfInString, A_LoopField, list_down_browser
		{
			DLCNum := 0
			Found_Extras = 0
			Found_DLC = 1
		}
		If (Found_Extras&&Config.Downloads.Extras)
		{
			FoundID := RegExMatch(A_LoopField, "U)secure.gog.com\/downlink\/file\/(.*)\/(.*)""", ExtraID)
			FoundName := RegExMatch(A_LoopField, "U)details-underline"">(.*)<", ExtraName)
			FoundSize := RegExMatch(A_LoopField, "U)size"">(.*) (M|G)B<", ExtraSize)
			If (FoundID&&FoundName&&FoundSize){
				ExtraNum ++
				Extras[ExtraNum] := Object("Folder", ExtraId1, "ID", ExtraId2, "Name", ExtraName1, "FileName", FileName, "Size", ExtraSize1, "Link", API.get_extra_link . "/" . ExtraID1 . "/" ExtraID2)
			}
		}
		If (Found_DLC&&Config.Downloads.Downloadable_Content)
		{
			FoundFolder		:= RegExMatch( A_LoopField, "U)data-gameindex=""(.*)""", DLCFolder)
			FoundLink 		:= RegExMatch( A_LoopField, "U)list_game_item"" href=""(.*)"">", DLCLink)	;	1 = Link to get DLC Link. Add to API_get_installer_link
			FoundSize 		:= RegExMatch( A_LoopField, "U)size""> (.*) (M|G)B <", DLCSize)	;	1 DLC Size
			FoundDLC 			:= RegExMatch( A_LoopField, "U)details-header""> DLC: (.*) <i", DLCName)	; 	1= Name of the DLC
			FoundPlatform 		:= RegExMatch( A_LoopField, "U)details-underline""> (.*)\, (.*) <", DLCPlatform) ;	1 = Platform	2 = Language
			FoundName 		:= RegExMatch( A_LoopField, "U)details-underline""> (.*)<", DLCName)
			FoundLanguage 		:= RegExMatch( A_LoopField, "U)class=""lang-item lang_(.*)( invisible)?""", DLCLanguage)
			FoundLanguagePack 	:= RegExMatch( A_LoopField, "U)""name"":""Language Pack""", LanguagePack)	; 	1= Platform 	2= Language
			Type:="Installer"
			If (FoundDLC||DLCFolder1!=GameFolder)
				Type:="DLC"
			IfInString, DLCLink1, patch
			{
				DLCPlatform1 := Last_Platform
				Type := "Patch"
				DLCLanguage1 := Last_Language
			}
			if FoundLanguagePack
			{
				DLCPlatform2 := Last_Platform
				Type := "Language_Pack"
				DLCLanguage1 := Last_Language
			}
			If FoundLink
			{
				If not FoundDLC
					DLCName1 := PreviousDLCName
				PreviousDLCName := DLCName1
				IfInString, DLCSize, GB
					DLCSize1 := Round(DLCSize1*1000, 0)
				SplitPath, DLCLink1, DLCID
				if FoundLink
				{
					DLCNum++
					If !DLCFolder1
						DLCFolder1:=ExistingFolder
					ExistingFolder := DLCFolder1
					if LangOption[DLCLanguage1]
						DLCLanguage1:=LangOption[DLCLanguage1]
					Else
						DLCLanguage1:=DLCLanguage1
					
					StringReplace, Platform, DLCPlatform1, %A_Space%Installer, , All
					DLC[DLCNum] := Object("Name", DLCName1, "Type",Type,"FileName", "Not Available", "ID", DLCID, "MainFolder", GameFolder, "Folder", DLCFolder1, "Size", DLCSize1, "Platform", Platform, "Language", DLCLanguage1, "Link", API.get_installer_link . "/" . DLCFolder1 . "/" . DLCID . "/")
					Last_Language := DLCLanguage1
					Last_Platform := Platform
					
				}
			}
		}
		IfInString, A_LoopField, list_det_links
			break
	}
	;For j in Extras ;---- Loop Throughthe Extras for the game and get the required info
	;{
	;URL := OAuth_Authorization( API.Basic_Credentials "`n" API.Specific_Credentials, API.get_extra_link . "/" . Extras[j].Folder . "/" . Extras[j].ID, "", "GET" )
	;HTTPRequest(URL,InOutData:="",InOutHeader:="")
	;if (DEBUG_GetGames){
	;tt("Get_GameInfo:" Extras[j].ID,"URL: " URL,"Header: " InOutHeader)
	;tt("Get_GameInfo:" Extras[j].ID,"Response: " InOutData)
	;}
	;StringReplace, InOutData, InOutData, \/, /, All
	;RegExMatch(InOutData, "U)link"":""(.*)""", Link)
	;RegExMatch( Link1, "(.*)\?", ExtraFileName )
	;SplitPath, ExtraFileName1, FileName
	;
	;Extras[j].Link := Link1
	;Extras[j].FileName := FileName
	;}
	List[GameName].DLC := DLC
	List[GameName].Extras := Extras ;----Put the new info into the Object
	return, Success
}

/*
	#SingleInstance,force
	FileRead,info,html.txt
	html:=ComObjCreate("htmlfile")
	ComObjError(0)
	StringReplace,info,info,\,,All
	html.write(info)
	;html.open()
	links:=html.links
	while,ll:=links.item[A_Index-1]{
		if InStr(ll.href,"secure.gog.com"){
			children:=ll.childnodes
			values:=[]
			Loop,% children.length
				values[children.item[A_Index-1].getAttributeNode("class").value]:=children.item[A_Index-1].innertext
			m(ll.href,values.size,values["details-underline"])
		}
	}
*/
