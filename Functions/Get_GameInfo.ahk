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
	;FileDelete,Extras-%Name%.txt
	;FileAppend,%InOutData%,Extras-%Name%.txt
	ExtraNum := 0
	StringReplace, InOutData, InOutData, a>, a>`n, All
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
			If (FoundID&&FoundName&&FoundSize)
			{
				Link := API.get_extra_link . "/" . Extras[j].Folder . "/" . Extras[j].ID
				ExtraNum ++
				Extras[ExtraNum] := Object("Folder", ExtraId1, "ID", ExtraId2, "Name", ExtraName1, "FileName", FileName, "Size", ExtraSize1, "Link", Link)
			}
		}
		If (Found_DLC&&Config.Downloads.Downloadable_Content)
		{
			;Intsaller RegExMatchs
			;Link:="U)list_game_item"" href=""(.*)"">"
			;Size:="U)size""> (.*) (M|G)B <"
			
			FoundFolder := RegExMatch(A_LoopField, "U)data-gameindex=""(.*)""", DLCFolder)
			FoundLink := RegExMatch( A_LoopField, "U)list_game_item"" href=""(.*)"">", DLCLink)	;	1 = Link to get DLC Link. Add to API_get_installer_link
			FoundSize := RegExMatch( A_LoopField, "U)size""> (.*) (M|G)B <", DLCSize)	;	1 DLC Size
			FoundDLC := RegExMatch( A_LoopField, "U)""details-header""> DLC: (.*) <i", DLCName)	; 	1= Name of the DLC
			FoundPlatform := RegExMatch( A_LoopField, "U)details-underline""> (.*)\, (.*) <", DLCPlatform) ;	1 = Platform	2 = Language
			FoundName := RegExMatch( A_LoopField, "U)details-underline""> (.*)<", DLCName)
			FoundLanguage := RegExMatch( A_LoopField, "U)class=""lang-item lang_(.*)( invisible)?""", DLCLanguage)
			If FoundFolder
			{
				If not FoundDLC
					DLCName1 := PreviousDLCName
				PreviousDLCName := DLCName1
				;StringReplace, DLCLink1, DLCLink1, \/, /, All
				StringReplace, Platform, DLCPlatform1, %A_Space%Installer, , All
				IfInString, DLCSize, GB
					DLCSize1 := Round(DLCSize1*1000, 0)
				SplitPath, DLCLink1, DLCID
				;If ( DLCFolder1 != GameFolder && Language_%DLCPlatform2% = 1 && Platform_%Platform% = 1) 
				if FoundLink
				{
					DLCNum++
					ExistingDLC_Folder := DLCFolder1
					if LangOption[DLCLanguage1]
						DLCLanguage1:=LangOption[DLCLanguage1]
					Else
						m(DLCLanguage1 " NotFound")
					DLC[DLCNum] := Object("Name", DLCName1, "FileName", "Not Available", "ID", DLCID, "MainFolder", GameFolder, "Folder", DLCFolder1, "Size", DLCSize1, "Platform", Platform, "Language", DLCLanguage1, "Link", DLCLink1)
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
