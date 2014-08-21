;URL:=URLDownloadToVar("Http://www.gog.com/frontpage/rss/feed.xml")
RSS_Get(URL){
	
	;url:="http://www.gog.com/frontpage/rss"
	;xx:=new xml("flan")
	;xx.xml.loadxml(URLDownloadToVar(url))
	;Titles:=xx.sn("//item/title")
	;Descriptions:=xx.sn("//item/description")
	;while,in:=Titles.item[A_Index-1]
		;list.=in.xml "`n`n"
	;m(list)
	Feeds:=[]
	while(Pos:=RegExMatch(URL,"U)<item>(.*)</item>",Info,(Pos ? Pos+1 : 1)))
	{
		RegExMatch(Info1,"U)<title>(.*)</title>",Title)
		RegExMatch(Info1,"U)<link>(.*)</link>",Link)
		RegExMatch(Info1,"U)<description>(.*)</description>",Description)
		StringReplace,Description1,Description1,<br/>,`n,ALL
		StringReplace,Description1,Description1,</a>,,All
		StringReplace,Description1,Description1,<![CDATA[,,All
		StringReplace,Description1,Description1,</p>]]>,,All
		While(Found:=RegExMatch(Description1,"U)<a(.*)href(.*)>",This,(Found?Found:1)))
			StringReplace,Description1,Description1,%This%,***Link***
		While(Found:=RegExMatch(Description1,"U)<img(.*)>",This,(Found?Found:1)))
			StringReplace,Description1,Description1,%This%,***Image***
		While(Found:=RegExMatch(Description1,"U)(^)?<(.*)>($)?",This,(Found?Found:1)))
			StringReplace,Description1,Description1,%This%
		
		Feeds[A_Index]:=Object("Name",Title1,"Link",Link1,"Description",Description1)
	}
	; Show the items found
	;for a,b in Feeds
	;Msgbox,% "Name" b.Name "`nLink" b.Link "`nDescription" b.description
	Return,Feeds
}