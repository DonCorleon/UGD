/*#SingleInstance,force
	win:=new window("Named_window")
	win.Add(["Text,Section,Version:","Edit,x+5 ys-2 w200 vversion,,w,1","text,x+5,.,x","Edit,x+5 w50,,x","UpDown,gincrement vincrement Range0-2000 0x80,,x,1","Text,xs,Version Information:","Edit,w306 h200 vversioninfo,,wh,1"
	,"Text,Section,Upload directory:,y","Edit,vdir w200 x+10 ys-2,,yw,1","Text,section xm,Ftp Server:,y","DDL,x+10 ys-2 w200 vserver,1|2|3,yw","Checkbox,vcompile xm,Compile,y","Checkbox,vgistversion xm Disabled,Update Gist Version,y","Checkbox,vupver,Upload without progress bar (a bit more stable),y","Checkbox,vversstyle,Remove (Version=) from the " chr(59) "auto_version,y"
	,"Checkbox,vupgithub,Update GitHub,y","Button,w200 gupload1 xm Default,Upload,y","radio,vradio1,Info,y","radio,vradio2,Info1,y"])
	Gui,named_window:Add,Button,hwndhwnd,Button
	win.resize.Insert({control:hwnd,pos:"y"})
	win.Show("Upload")
	return
	increment:
	upload1:
	return
	f1::
	m(win.vars("version"))
	m(win[].increment)
	for a,b in win[]
		m(a,b)
	return
	GuiEscape:
	Named_windowGuiEscape:
	Named_windowGuiClose:
	ExitApp
	return
	ExitApp
	return
	t(x*){
		for a,b in x
			list.=b "`n"
		ToolTip,%list%
	}
	m(x*){
		for a,b in x
			list.=b "`n"
		msgbox %list%
	}	
*/
class Window{
	winlist:=[]
	__New(win){
		OnMessage(5,"Resize"),OnMessage(0x232,"Resize")
		OnExit,Exit
		Gui,%win%:+hwndhwnd
		this.win:=win,this.hwnd:=hwnd,this.ahkid:="ahk_id" hwnd,this.type:=[]
		this.tracker:=[],this.resize:=[],window.winlist[win]:=this,this.varlist:=[]
		for a,b in {border:32,caption:4}{
			SysGet,%a%,%b%
			this[a]:=%a%
		}
		return this
	}
	Show(title:=""){
		Gui,% this.win ":Show",Hide
		for a,b in this.resize
			this.track(b.control,b.pos)
		Gui,% this.win ":+MinSize"
		for a,b in ["x","y","w","h"]{
			IniRead,var,settings.ini,% this.win,%b%
			if (var="error"||var=""){
				pos:=""
				Break
			}
			pos.=b var " "
		}
		Gui,% this.win ":Show",%pos%,%title%
		IniRead,minmax,settings.ini,% this.win,minmax
		if MinMax
			WinMaximize,% this.ahkid
	}
	track(control,pos){
		ControlGetPos,x,y,w,h,,ahk_id%control%
		for a,b in {x:x,y:y,w:w,h:h}{
			sub:=a="x"?this.border:a="y"?this.caption+this.border:0
			this[control,a]:=b-sub
		}
		VarSetCapacity(size,16,0),DllCall("user32\GetClientRect","uint",this.hwnd,"uint",&size),ww:=NumGet(size,8),hh:=NumGet(size,12)
		this.tracker.Insert({control:control,pos:pos,w:ww,h:hh})
	}
	Add(control){
		for a,b in Control{
			b:=StrSplit(b,",")
			RegExMatch(b.2,"U)\bv(.*)\b",variable)
			IniRead,info,settings.ini,% this.win " Variables",%variable1%
			if (b.5&&b.1!="Checkbox"){
				b.3:=info="Error"?"":info
			}Else if (b.1~="i)(Checkbox|Radio)"&&info!="Error"){
				b.2.=info?" Checked":""
			}
			if (variable1)
				hwnd:=this.vars(b,variable1)
			Else
				Gui,% this.win ":Add",% b.1,% b.2 " hwndhwnd",% b.3
			if (b.1~="i)(ComboBox|DDL|DropDownList)"&&info!="Error")
				GuiControl,% this.win ":ChooseString",%hwnd%,%info%
			this[variable1]:=hwnd
			this.type[variable1]:=control.1
			if b.4{
				Gui,% this.win ":+Resize"
				this.resize.Insert({control:hwnd,pos:b.4})
			}
		}
	}
	vars(control="",var=""){
		static
		if IsObject(control){
			this.varlist.Insert(var)
			Gui,% this.win ":Add",% control.1,% control.2 " hwndhwnd",% control.3
			return hwnd
		}if Control{
			Gui,% this.win ":Submit",NoHide
			return _:=%control%
		}Else{
			list:=[]
			for a,b in this.varlist{
				Gui,% this.win ":Submit",NoHide
				ControlGet,check,Checked,,,% "ahk_id" this[b]
				List[b]:=%b%
			}
			return list
		}
	}
	__Get(a*){
		return this.vars()
	}
	Exit(){
		exit:
		size:=Resize("get")
		for a,b in window.winlist{
			for c,d in b.vars{
				if (b.type[c]~="i)(Checkbox|Radio)")
					ControlGet,d,Checked,,,% "ahk_id" b[c]
				IniWrite,%d%,settings.ini,% b.win " Variables",%c%
			}
			WinGet,MinMax,MinMax,% b.ahkid
			IniWrite,%minmax%,settings.ini,% b.win,MinMax
			for c,d in size[b.win]
				IniWrite,%d%,settings.ini,% b.win,%c%
		}
		ExitApp
		return
	}
}
Resize(info*){
	static size:=[]
	if(info.1="get")
		return size
	gui:=A_Gui?A_Gui:info.1,win:=window.winlist[gui]
	if (info.1=0&&info.2=0&&win.ahkid){
		WinGetPos,x,y,,,% win.ahkid
		size[gui,"x"]:=x,size[gui,"y"]:=y
		return
	}
	static flip:={x:"w",y:"h"}
	if (info.2>>16){
		w:=info.2&0xffff,h:=info.2>>16
		if info.1!=2
			size[gui,"w"]:=w,size[gui,"h"]:=h
	}
	for a,b in win.tracker{
		orig:=win[b.control]
		for c,d in StrSplit(b.pos){
			if (d~="(w|h)")
				GuiControl,MoveDraw,% b.control,% d %d%-(b[d]-orig[d])
			if (d~="(x|y)"){
				val:=flip[d],offset:=orig[d]-b[val]
				GuiControl,MoveDraw,% b.control,% d %val%+offset
			}
		}
	}
}