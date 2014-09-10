Get_GameInfo(GameName){
	/*
		This Needs to be refined and add the gather DLC, Installers, LanguagePacks,
	*/
	global List,Config,HTTP,API
	DEBUG_GetGames:=0 ;---- Set to debug this module
	Extras:=[],DLC:=[]
	If List[GameName].Folder
		Name := List[GameName].Folder
	else
		Name:=List[GameName].Name
	GameFolder := List[GameName].Folder
	URL := "https://www.gog.com/en/account/ajax?a=gamesListDetails&g=" . List[GameName].GameId
	HTTPRequest(url, InOutData := "", InOutHeader := Headers(Http.GoGCookie),Options)
	StringReplace,InOutData,InOutData,\,,All
	StringReplace, InOutData, InOutData, a>, a>`n, All
	Name:=RegExReplace(Name,"\W")
	FileDelete,GameInfo-%Name%.txt
	FileAppend,%InOutData%,GameInfo-%Name%.txt
	ExtraNum := 0
	LangOption:=Object("ar","Arabic","bl","Bulgarian","cn","Chinese","cz","Czech","da","Danish","nl","Dutch","en","English","fi","Finnish","fr","French","de","German","gk","Greek","hu","Hungarian","it","Italian","jp","Japanese","ko","Korean","no","Norwegian","pl","Polish","pt","Portuguese","ro","Romanian","ru","Russian","sb","Serbian","sk","Slovac","es","Spanish","sv","Swedish","tr","Turkish","uk","Ukranian")
	Loop, Parse, InOutData, `n
	{
		FoundPurchaseDate:=RegExMatch(A_LoopField,"U)""list_purchased""> Purchased on (.*)<",PurchaseDate)
		If FoundPurchaseDate
			List[GameName].Purchased:=PurchaseDate1
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
			FoundID := RegExMatch(A_LoopField, "U)www.gog.com\/downlink\/file\/(.*)\/(.*)""", ExtraID)
			FoundName := RegExMatch(A_LoopField, "U)details-underline"">(.*)<", ExtraName)
			FoundSize := RegExMatch(A_LoopField, "U)size"">(.*) (M|G)B<", ExtraSize)
			If (FoundID&&FoundName&&FoundSize){
				ExtraNum ++
				Extras[ExtraNum] := Object("Folder", ExtraId1, "ID", ExtraId2, "Name", ExtraName1, "FileName", FileName, "Size", ExtraSize1, "Link", API.get_extra_link . "/" . ExtraID1 . "/" ExtraID2)
			}
		}
		If (Found_DLC&&(Config.Downloads.Downloadable_Content||Config.Downloads.Installers||Config.Downloads.LanguagePacks||Config.Downloads.Patches))
		{
			FoundFolder		:= RegExMatch( A_LoopField, "U)data-gameindex=""(.*)""", DLCFolder)
			FoundLink 		:= RegExMatch( A_LoopField, "U)list_game_item"" href=""(.*)"">", DLCLink)	;	1 = Link to get DLC Link. Add to API_get_installer_link
			FoundSize 		:= RegExMatch( A_LoopField, "U)size""> (.*) (M|G)B <", DLCSize)	;	1 DLC Size
			FoundDLC 			:= RegExMatch( A_LoopField, "U)details-header""> DLC: (.*) <i", DLCName)	; 	1= Name of the DLC
			FoundPlatform 		:= RegExMatch( A_LoopField, "U)details-underline""> (.*)\, (.*) <", DLCPlatform) ;	1 = Platform	2 = Language
			FoundName 		:= RegExMatch( A_LoopField, "U)details-underline""> (.*) <", DLCName)
			IfInstring,DLCName,Tarball
				Type:="Tarball Archive",DLCPlatform1:="Linux"
			Else IfInString,DLCName,Linux
				Type:="Debian Package",DLCPlatform1:="Linux"
			Else 
				Type:="Installer"
			If (FoundDLC||DLCFolder1!=GameName)
				Type:="DLC"
			IfInString, DLCLink1, patch
				Type := "Patch"
			IfInstring,DLCLink1, LangPack
				Type := "Language Pack"
			If FoundLink
			{
				If not FoundDLC
					DLCName1 := list[gamename].name
				PreviousDLCName := DLCName1
				IfInString, DLCSize, GB
					DLCSize1 := Round(DLCSize1*1000, 0)
				SplitPath, DLCLink1, DLCID
				if DLCID contains subtitle ;---- Remove extra links for movies
					continue
				if FoundLink
				{
					
					DLCNum++
					If !DLCFolder1
						DLCFolder1:=ExistingFolder
					ExistingFolder := DLCFolder1
					TempPlatform:=Object(1,"Windows",2,"Mac OS X",3,"Linux")
					Platform:=TempPlatform[SubStr(DLCID,3,1)]
					Language:=LangOption[SubStr(DLCID,1,2)]
					DLC[DLCNum] := Object("Name", DLCName1, "Type",Type,"FileName", "Not Available", "ID", DLCID, "MainFolder", GameFolder, "Folder", DLCFolder1, "Size", DLCSize1, "Platform", Platform, "Language", Language, "Link", API.get_installer_link . "/" . DLCFolder1 . "/" . DLCID . "/")
					Last_Platform := Platform
					
				}
			}
		}
		IfInString, A_LoopField, list_det_links
			break
	}
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
