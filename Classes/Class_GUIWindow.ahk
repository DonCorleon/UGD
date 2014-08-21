/*
	#SingleInstance,force
	win:=new window("Named_window")
	for a,b in {myvar1:"w",myvar2:"wh",myvar3:"wy"}
		win.Add("Edit","v" a " w200",info,b,1)
	win.Add("Edit","vmyvar4 x+10 w50","Info","xy",1)
	win.Add("Checkbox","xm vcheck","Checkbox","y",1)
	IniRead,pos,settings.ini,Gui,position,0
	pos:=pos?pos:""
	win.Show()
	ControlGet,hwnd,hwnd,,Edit1,A
	Gui,1:Default
	win1:=new window(1)
	win1.Add("Edit","vMyVar w200","stuff","w",1)
	win1.Add("ListView","w200 h200","Column 1|Column 2|Column 3","wh")
	win1.Add("TreeView","w100 h100","","wy")
	TV_Add("Place Holder")
	Loop,10
		LV_Add("","Col1","Col2","Col3")
	Gui,Show,NA
	win1.Show()
	return
	f1::
	m(win.vars("myvar1"))
	m(win[].myvar2)
	return
	GuiEscape:
	Named_windowGuiEscape:
	Named_windowGuiClose:
	ExitApp
	return
	ExitApp
	return
*/
class Window{
	winlist:=[]
	__New(win){
		OnMessage(5,"Resize")
		OnExit,Exit
		this.win:=win
		Gui,%win%:+hwndhwnd
		this.hwnd:=hwnd,this.ahkid:="ahk_id" hwnd
		this.tracker:=[],this.resize:=[],window.winlist[win]:=this,this.varlist:=[]
		this.type:=[]
		for a,b in {border:32,caption:4}{
			SysGet,%a%,%b%
			this[a]:=%a%
		}
		return this
	}
	Show(x=""){
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
		Gui,% this.win ":Show",%pos%
	}
	track(control,pos){
		ControlGetPos,x,y,w,h,,ahk_id%control%
		for a,b in {x:x,y:y,w:w,h:h}{
			sub:=a="x"?this.border:a="y"?this.caption+this.border:0
			this[control,a]:=b-sub
		}
		VarSetCapacity(size,A_PtrSize*4,0),DllCall("user32\GetClientRect","uint",this.hwnd,"uint",&size),ww:=NumGet(size,8),hh:=NumGet(size,12)
		this.tracker.Insert({control:control,pos:pos,w:ww,h:hh})
	}
	Add(control*){
		RegExMatch(control.2,"U)\bv(.*)\b",variable)
		IniRead,info,settings.ini,% this.win " Variables",%variable1%
		if (control.5&&control.1!="Checkbox"){
			control.3:=info="Error"?"":info
		}Else if (control.1="Checkbox"){
			control.2.=info?" Checked":""
		}
		if (variable1)
			hwnd:=this.vars(control,variable1)
		Else
			Gui,% this.win ":Add",% control.1,% control.2 " hwndhwnd",% control.3
		this[variable1]:=hwnd
		this.type[variable1]:=control.1
		if control.4{
			Gui,% this.win ":+Resize"
			this.resize.Insert({control:hwnd,pos:control.4})
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
		for a,b in window.winlist{
			for c,d in b.vars{
				if (b.type[c]="Checkbox")
					ControlGet,d,Checked,,,% "ahk_id" b[c]
				IniWrite,%d%,settings.ini,% b.win " Variables",%c%
			}
			VarSetCapacity(size,A_PtrSize*4,0),DllCall("user32\GetClientRect","uint",b.hwnd,"uint",&size),w:=NumGet(size,8),h:=NumGet(size,12)
			WinGetPos,x,y,,,% b.ahkid
			for c,d in {x:x,y:y,w:w,h:h}
				IniWrite,%d%,settings.ini,% b.win,%c%
		}
		ExitApp
		return
	}
}
Resize(info*){
	static flip:={x:"w",y:"h"}
	gui:=A_Gui?A_Gui:info.1
	win:=window.winlist[a_gui]
	if info.2>>16
		h:=info.2>>16,w:=info.2&0xffff
	for a,b in win.tracker{
		orig:=win[b.control]
		for c,d in StrSplit(b.pos){
			if (d~="(w|h)")
				GuiControl,Move,% b.control,% d %d%-(b[d]-orig[d])
			if (d~="(x|y)"){
				val:=flip[d],offset:=orig[d]-b[val]
				GuiControl,Move,% b.control,% d %val%+offset
			}
		}
	}
}
/*
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
