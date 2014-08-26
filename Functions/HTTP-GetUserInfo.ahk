HTTP_GetUserInfo(){
	Global API,Cookie,Updates:=[],myConsole,Testing
	page:=0,IndexNum:=0,TotalOwned:=0,UpdateNotifications:=0,List:=[]
	tt("INFO:`tRetrieving Page " page+1)
	HTTPnextpage:
	page++	; increment the page number we are trying to get
	HTTPRequest(url:="https://secure.gog.com/account/ajax?a=gamesShelfMore&s=title&q=&t=0&p=" page, InOutData := "", InOutHeader := Headers(), Options)
	Fields:=StrSplit(InOutData,"<div class=\""shelf_game\")
	for a,b in Fields
	{
		FoundName:=RegExMatch( b, "U)data-title=..(.*)\\",  gamename)
		FoundFolder:=RegExMatch( b, "U)data-gameindex=..(.*)\\",  gamefolder)
		FoundGameID:=RegExMatch( b, "U)data-gameid=..(.*)\\", gameid)
		FoundOrderID:=RegExMatch( b, "U)data-orderid=..(.*)\\", OrderId)
		FoundBox:=RegExMatch( b, "U)shelf_game_box...src=..(.*)\\", GameBox)
		DLCFound:=RegExMatch( b, "U)shelf-game-dlc-counter\\""> \+(.*) DLC", DLC)
		Badges:=RegExMatch( b, "U)class=\\""shelf_badges\\""> <i class=\\""(.*)\\",Badge)
		If (FoundFolder && FoundGameID){
			StringReplace, GameBox1, GameBox1,\,,All
			List[GameFolder1] := Object( "DisplayName", "","Name","","ServerName", GameName1,"Folder",GameFolder1,"Size","","Installer", Game_Installers,"Extras","","Notify",Badge1,"DLC", DLC1,"GameID", GameID1,"OrderID", OrderID1,"GameCard", "http://www.gog.com/game/" GameFolder1,"Icon", Icon_Link,"Game_Box", "http://static.gog.com" GameBox1,"Selected",Testing)
		}
		if (Badges&&Badge1!="bdg_soon") ;---- Only increment the update if the badge is not a Coming Soon notification
			Updates[Gamefolder1]:=List[GameFolder1]
		IF DLCFound ; Increment the number of DLC's owned if found 
			DLCs+=DLC1
	}
	RegExMatch( InOutData, "U)count"":(.*)\,",  TotalGames)	; get the number of games returned in the last call
	TotalOwned +=TotalGames1 ;----Add the the number of games found to the total number
	if (TotalGames1 >= 45){ ;----If its greater than 45 then check the next page	
		myConsole.changeLine("[Green]INFO:`tRetrieving Page " page+1 "[/]", myConsole.currentLine )
		goto HTTPnextpage
	}
	if DLCs
		tt("INFO:`tYou Own " TotalOwned " Games & " DLCs " DLC Addons.")
	Else
		tt("INFO:`tYou Own " TotalOwned " Games")
	if Updates.MaxIndex()
		tt("You Have " Updates.MaxIndex() " New/Update Notifications")
	List["Updates"]:=Updates
	;***********************************************
	FileName:="Renamer - GOG.com Downloader Name to Folder Name (791 + 22 + 24) (20140809).bat"
	FileRead,TempVar,%A_ScriptDir%\Resources\%Filename%
	Loop,Parse,TempVar,`r
	{
		RegExMatch(A_LoopField,"Ui)rename (\w*)\b " Chr(34) "(.*)\(((january|february|march|april|may|june|july|august|september|october|november|december).*)\)(| \[DLC\])" Chr(34),found)
		List[Found1].Name:=Found2
		;m(found1, found2)
	}
	;***********************************************
	return, List
}