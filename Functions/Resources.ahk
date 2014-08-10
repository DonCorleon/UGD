Resources(){
	Config:=[]
	IfNotExist %A_ScriptDir%\Resources
		FileCreateDir,%A_ScriptDir%\Resources
	IfNotExist %A_ScriptDir%\Resources\Config.ini
		m("No configuration file found.`nDo you want to create one?")
	Else
	{
		IniRead,Username,%A_ScriptDir%\Resources\Config.ini,Credentials,Username
		IniRead,Password,%A_ScriptDir%\Resources\Config.ini,Credentials,Password
		Config.Username:=Username
		Config.Password:=Password
	}
	Return, Config
}