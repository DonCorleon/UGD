Get_GameInfo(GameName){
	/*
		This Needs to be refined and add the gather DLC, Installers, LanguagePacks,
	*/
	global List,Config
	Extras:=[]
	Name := List[GameName].Folder
	GameFolder := List[GameName].Folder
	URL := "https://secure.gog.com/en/account/ajax?a=gamesListDetails&g=" . List[GameName].GameId
	HTTPRequest(url, InOutData := "", InOutHeader := Headers(), Options)
	FileAppend,% InOutData,Extras-%GameName%.txt
	Return
	ExtraNum := 0
	StringReplace, InOutData, InOutData, a>, a>`n, All
	DLC := []
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
			Found_DLC = 1
		}
		If ((Found_Extras = 1 && Config.Downloads.Extras = 1 ) || (Found_Extras = 1 && GatherGameInfo = 1))
		{
			FoundID := RegExMatch(A_LoopField, "U)secure.gog.com\\\/downlink\\\/file\\\/(.*)\\\/(.*)\\", ExtraID)
			FoundName := RegExMatch(A_LoopField, "U)details-underline\\"">(.*)<", ExtraName)
			FoundSize := RegExMatch(A_LoopField, "U)size\\"">(.*) (M|G)B<", ExtraSize)
			If (FoundID&&FoundName&&FoundSize)
			{
				Link := "None"
				ExtraNum ++
				Extras[ExtraNum] := Object("Folder", ExtraId1, "ID", ExtraId2, "Name", ExtraName1, "FileName", FileName, "Size", ExtraSize1, "Link", Link)
			}
		}
		If ((Found_DLC&&Config.Downloads.DLCs)||(Found_DLC&& GatherGameInfo))
		{
			FoundDLC := RegExMatch(A_LoopField, "U)data-gameindex=\\""(.*)\\""", DLCFolder)
			FoundLink := RegExMatch( A_LoopField, "U)list_game_item\\"" href=\\""(.*)\\"">", DLCLink)	;	1 = Link to get DLC Link. Add to API_get_installer_link
			FoundSize := RegExMatch( A_LoopField, "U)size\\""> (.*) (M|G)B <", DLCSize)	;	1 DLC Size
			FoundName := RegExMatch( A_LoopField, "U)""details-header\\""> DLC: (.*) <i", DLCName)	; 	1= Name of the DLC
			FoundPlatform := RegExMatch( A_LoopField, "U)details-underline\\""> (.*)\, (.*) <", DLCPlatform) ;	1 = Platform	2 = Language
			If FoundDLC > 0
			{
				If not FoundName
					DLCName1 := PreviousDLCName
				PreviousDLCName := DLCName1
				StringReplace, DLCLink1, DLCLink1, \/, /, All
				StringReplace, Platform, DLCPlatform1, %A_Space%Installer, , All
				StringReplace, Platform, Platform, %A_Space%, _, All
				IfInString, DLCSize, GB
					DLCSize1 := Round(DLCSize1*1000, 0)
				SplitPath, DLCLink1, DLCID
				If ( DLCFolder1 != GameFolder && Language_%DLCPlatform2% = 1 && Platform_%Platform% = 1) 
				{
					DLCNum++
					ExistingDLC_Folder := DLCFolder1
					DLC[DLCNum] := Object("Name", DLCName1, "FileName", "", "ID", DLCID, "MainFolder", GameFolder, "Folder", DLCFolder1, "Size", DLCSize1, "Platform", DLCPlatform1, "Language", DLCPlatform2, "Link", DLCLink1)
					GameList[GameNumber].DLC := DLC
				}
			}
		}
		IfInString, A_LoopField, list_det_links
			break
	}
	For j in Extras ;---- Loop Throughthe Extras for the game and get the required info
	{
		ExtraID := Extras[j].ID
		ExtraName := Extras[j].Name
		ExtraFolder := Extras[j].Folder
		URL := API_get_extra_link . "/" . ExtraFolder . "/" . ExtraID
		Encoded_Formed_URL := OAuth_Authorization( Basic_Credentials "`n" Specific_Credentials, URL, "", "GET" )
		Signed_URL := Unencoded_Formed_URL . "&oauth_signature=" . Unencoded_Signed_URL
		Response:= URLDownloadToVar(Signed_URL)
		StringReplace, Response, Response, \/, /, All
		RegExMatch(Response, "U)link"":""(.*)""", Link)
		RegExMatch( Link1, "(.*)\?", ExtraFileName )
		SplitPath, ExtraFileName1, FileName
		Extras[j].Link := Link1
		Extras[j].FileName := FileName
	}
	List[GameName].Extras := Extras ;----Put the new info into the Object
	return, Success
}