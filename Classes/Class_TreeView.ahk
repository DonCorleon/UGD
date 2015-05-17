class treeview{
	static TVlist:=[]
	__New(hwnd){
		this.TVlist[hwnd]:=this
		;OldFunction:=OnMessage(0x004E)
		;if (OldFunction!="WM_NOTIFY"){
		;OnMessage(0x004E,"WM_NOTIFY")
		;tt("Onmessage 0x004E - Set to WM_NOTIFY - New")
		;}
		
		this.hwnd:=hwnd
		
		;if (OldFunction!="WM_NOTIFY"){
		;OnMessage(0x004E, OldFunction)
		;tt("Onmessage 0x004E - Set to " OldFunction " - New")
		;}
	}
	add(info){
		;OldFunction:=OnMessage(0x004E)
		;if (OldFunction!="WM_NOTIFY"){
		;OnMessage(0x004E,"WM_NOTIFY")
		;tt("Onmessage 0x004E - Set to WM_NOTIFY - Add")
		;}
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		this.control[hwnd]
		;if (OldFunction!="WM_NOTIFY"){
		;OnMessage(0x004E, OldFunction)
		;tt("Onmessage 0x004E - Set to " OldFunction " - Add")
		;}
		return hwnd
	}
	modify(info){
		;OldFunction:=OnMessage(0x004E)
		;if (OldFunction!="WM_NOTIFY"){
			;OnMessage(0x4E,"WM_NOTIFY")
			;tt("Onmessage 0x004E - Set to WM_NOTIFY - Modify")
			;sleep, 50
		;}
		;Gui,TreeView,% this.hwnd
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,% "ahk_id" this.hwnd
		;if (OldFunction!="WM_NOTIFY"){
			;OnMessage(0x004E, OldFunction)
			;tt("Onmessage 0x004E - Set to " OldFunction " - Modify")
			;sleep, 50
		;}
	}
	Remove(hwnd){
		;OldFunction:=OnMessage(0x004E)
		;if (OldFunction!="WM_NOTIFY"){
			;OnMessage(0x004E,"WM_NOTIFY")
			;tt("Onmessage 0x004E - Set to WM_NOTIFY - Modify")
			;sleep, 50
		;}
		this.control.Remove("|" hwnd)
		WinSet,Redraw,,% "ahk_id" this.hwnd
		;if (OldFunction!="WM_NOTIFY"){
			;OnMessage(0x004E, OldFunction)
			;tt("Onmessage 0x004E - Set to " OldFunction " - Remove")
			;sleep, 50
		;}
	}
}
WM_NOTIFY(Param*){
	control:=
	;Critical 
	if (this:=treeview.TVlist[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the TVlist
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}