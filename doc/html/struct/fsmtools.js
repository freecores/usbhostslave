
var zoo = 100;
var pzoo = 100;
var zoom_inc = 2; //or 50
var SCHEM = "DIAGRAM"
var ViewX=w;
var ViewY=h;
var DEBUG_MODE = 1;
//----------------------------------------------------------------------------
IRoot = RootProject + "images/fsm/";
OV = "over.gif";
OD = "down.gif";
//----------------------------------------------------------------------------
function CodeView(){
window.parent.location = SchemCode;
}
//----------------------------------------------------------------------------
function GotoPage(){
	if(PageNext==-1){
		alert("no page");
		return;
	}
window.parent.location = "./content"+PageNext+".html"
}
//----------------------------------------------------------------------------
function fubclick(lnk){
	if(lnk!="")
		window.parent.location = lnk;
}
//----------------------------------------------------------------------------
function DUMP() { 
	var dump_msg;
	dump_msg= "w.........."+w+"\n";
	dump_msg+="h.........."+h+"\n";
	dump_msg+="zoo........"+zoo+"\n";
	dump_msg+="pzoo......."+pzoo+"\n";
	dump_msg+="zoo_inc...."+zoom_inc+"\n";
	dump_msg+="schem......"+SCHEM+"\n";
	dump_msg+="viewx......"+ViewX+"\n";
	dump_msg+="viewy......"+ViewY+"\n";
	dump_msg+="pagex......"+PageX+"\n";
	dump_msg+="pagey......"+PageY+"\n";
	dump_msg+="IE........."+ie+"\n";
	dump_msg+="NN........."+nn+"\n";
	alert(dump_msg);
}
function alertd(msg) {
	if(DEBUG_MODE==1)
		alert(msg)
}
//----------------------------------------------------------------------------
var MyImage;
var MyDoc;
var MyWindow;
//----------------------------------------------------------------------------
function Init(){
MyImage = window.parent.frames["xschem"].window.document.images[SCHEM];
MyImage.src = SchemImage.src;
MyDoc = window.parent.frames["xschem"].window.document;
MyWindow =  window.parent.frames["xschem"].window;
//zoomfit();
//Внимание - а что, если страница не загружена?
//alert("init")
}
//----------------------------------------------------------------------------
function ZRefresh(){
	ViewX = w*zoo/100;
	ViewY = h*zoo/100;

	if(ViewX<=0 || ViewY<=0 || ViewX==NaN || ViewY==NaN){
		alertd("Z-Error: " + ViewX + "##" + ViewY + "##" + zoo + "##" + pzoo);
		DUMP();
		ViewX=w;
		ViewX=h;
		zoo=100;
		pzoo=100;		
	}

	MyImage.width  = ViewX;
	MyImage.height = ViewY;

	if(!ie&&!nn) //NN6
		MyImage.src = SchemImage.src;
	if(ie){
		window.top.resizeBy(1, 1);  
		window.top.resizeBy(-1, -1);
	}
}
function zoomin(){
	pzoo=zoo;
	zoo*=zoom_inc;
	ZRefresh();
}
function zoomout(){
	if(zoo<=zoom_inc) return;
	pzoo=zoo;
	zoo/=zoom_inc;
	ZRefresh();
}
function zoomfit(){	
	pw=w;ph=h;
	var cw;var ch;
	if(ie || nn){
		if(!MyDoc.body.clientWidth) {

			if (self.screen) { // for NN4 and IE4 
				cw = screen.width/1.5 ; // What can I do for Opera
				ch = screen.height/1.5; // What can I do for Opera
			} else if (self.java) { // for NN3 with enabled Java 
				var jkit = java.awt.Toolkit.getDefaultToolkit(); 
				var scrsize = jkit.getScreenSize(); 
				cw = scrsize.width; 
				ch = scrsize.height; 
			} else
				{
					cw = w;
					ch = h
				} 
		} 

		else //FOR TRUE IE!!! with clientWidth
		{	
			cw=MyDoc.body.clientWidth;
			ch=MyDoc.body.clientHeight;

			if (Math.round(ViewY)>ch) ch=ch+16;
			if (Math.round(ViewX)>cw) cw=cw+16;
			
		}
	} else { //for TRUE NN :-) cheak It!!!
		//alertd("nn"); //NN6 use it
		
		cw=MyWindow.innerWidth*95/100;
		ch=MyWindow.innerHeight*95/100;
		//alertd("cw"+cw);
		//alertd(""ch);
	}

	fw=100*(cw/pw);
	fh=100*(ch/ph);
	xzoo=fh;
	if(fw<fh)
		xzoo=fw;
	if(xzoo==zoo)
		return;
	pzoo=zoo;
	zoo=xzoo;
	ZRefresh();
}
function zoomfull(){
	pzoo=zoo;
	zoo=100;
	ZRefresh();
}
function zoomprev(){
	tmp=zoo;
	zoo=pzoo;
	pzoo=tmp;
	ZRefresh();
}
//----------------------------------------------------------------------------
// Buttons of ToolBar
//----------------------------------------------------------------------------
BT_TITL = 0
BT_ZMIN = 1
BT_ZOUT = 2
BT_ZFIT = 3
BT_FULL = 4
BT_PREV = 5
BT_CODE = 6
BT_PAGE = 7
BT_PMOD = 8
BT_ZMOD = 9
BT_SMOD =10
BT_OBJV =11
BT_POPP =12 
BT_PRNT =13
BT_NEWW =14
BT_SYSB =15
//----------------------------------------------------------------------------
NRM = 0;
OVR = 1;
DWN = 2;
MES = 3;
//----------------------------------------------------------------------------
BT_NUMBER = 16;
//----------------------------------------------------------------------------
IMRES = new Array()//0..15 images is here
Present = new Array(1,1,1,0,1, 1,0,0,0,0, 0,0,0,0,1, 1)//{1/0} boolean of visibility
//----------------------------------------------------------------------------
function mClick(i){
	switch(i)
	{
		case BT_TITL: return;
		case BT_ZMIN: zoomin();return;
		case BT_ZOUT: zoomout();return;
		case BT_ZFIT: zoomfit();return;
		case BT_FULL: zoomfull();return;
		case BT_PREV: zoomprev();return;
		case BT_CODE: CodeView();return;
		case BT_PAGE: GotoPage();return;
		case BT_PMOD: Grosser(window.top);//Grosser();
						window.top.resizeBy(1, 1);window.resizeBy(-1, -1); //!!!
					  return;
		case BT_ZMOD: return;
		case BT_SMOD: view_source();return;
		case BT_OBJV: DUMP();return;
		case BT_SYSB: window.parent.close();void(0);
					  return;
		case BT_NEWW: fullScreen2(window.parent.location);
						//window.parent.frames["xschem"].window.document.images[SCHEM].src = SchemImage.src;
						return;
		case BT_PRNT: printit();return;
		case BT_POPP: alert(":-(");return;
	}
}
//----------------------------------------------------------------------------
function mOver(i){
	switch(i)
	{	case BT_TITL:
		case BT_SYSB: return;
	}
	var btn = "btn_"+i;
	window.document.images[btn].src=IMRES[i][OVR].src;
	SetStatus(IMRES[i][MES]);
}
//----------------------------------------------------------------------------
function mOut(i){
	switch(i)
	{	case BT_TITL:
		case BT_SYSB: return;
	}
	var btn = "btn_"+i;
	window.document.images[btn].src=IMRES[i][NRM].src;
	SetStatus("");
}
//----------------------------------------------------------------------------
function mDown(i){
	switch(i)
	{	case BT_TITL:
		case BT_SYSB: return;
	}
	var btn = "btn_"+i;
	window.document.images[btn].src=IMRES[i][DWN].src;
	SetStatus(IMRES[i][MES]);
}
//----------------------------------------------------------------------------
function mUp(i){
	switch(i)
	{	case BT_TITL:
		case BT_SYSB: return;
	}
	var btn = "btn_"+i;
	window.document.images[btn].src=IMRES[i][OVR].src;
}
//----------------------------------------------------------------------------
function GetBod(i)
	{
	switch(i)
	{	case BT_TITL: return "bar"
		case BT_ZMIN: return "zoomin"
		case BT_ZOUT: return "zoomout"
		case BT_ZFIT: return "fit"
		case BT_FULL: return "full"
		case BT_CODE: return "code"
		case BT_PREV: return "prev"
		case BT_PAGE: return "goto"
		case BT_PMOD: return "panmode"
		case BT_ZMOD: return "zoommode"
		case BT_SMOD: return "selectmode"
		case BT_OBJV: return "tbl"
		case BT_SYSB: return "frame"
		case BT_NEWW: return "newwindow"
		case BT_PRNT: return "print"
		case BT_POPP: return "pop"
	}
	return "blank"
}
//----------------------------------------------------------------------------
function GetFile(i, mode)
	{
	var bod = GetBod(i)
	var end; 
	switch(mode)
	{	case NRM: end=".gif";break;
		case OVR: end=OV;break;
		case DWN: end=OD;
	}
	return IRoot + bod + end; 
}
//----------------------------------------------------------------------------
function GetIMessage(i){
	switch(i)
	{
		case BT_ZMIN: return "Zooms in view"
		case BT_ZOUT: return "Zooms out view"
		case BT_ZFIT: return "Zooms to fit"
		case BT_FULL: return "Displays full page"
		case BT_CODE: return "View generated code"
		case BT_PREV: return "Displays previously visible area"
		case BT_PAGE: return "Go to page"
		case BT_PMOD: return "Enter panning mode"
		case BT_ZMOD: return "Enter zoom mode"
		case BT_SMOD: return "Enter select mode"
		case BT_OBJV: return "Show Objects Window"
		case BT_NEWW: return "Open in new window"
		case BT_SYSB: return "Close newly opened window"
		case BT_PRNT: return "Print"
		case BT_POPP: return "Enters an upper hierarchical level"
	}
	return ""
}
//----------------------------------------------------------------------------
for(i=0;i<BT_NUMBER;i++){
	IMRES[i] = new Array(new Image(),new Image(),new Image(),"");
}
//----------------------------------------------------------------------------
for(i=0;i<BT_NUMBER;i++){
	IMRES[i][NRM].src = GetFile(i,NRM);
	IMRES[i][OVR].src = GetFile(i,OVR);
	IMRES[i][DWN].src = GetFile(i,DWN);
	IMRES[i][MES]     = GetIMessage(i);
//	IMRES[i][HNT]     = GetIHint(i);
}
//----------------------------------------------------------------------------
function GetToolBar(){
	var tools;
	var open = '<table align="left" border="0" cellspacing="0" cellpadding="0" valign="center" align="center"> <tr bgcolor="silver" background="silver" bordercolordark="silver" >';
	var close = '</tr></table>';

	var std0 = '<td ><img hspace="0" vspace="0" border="0" align="absmiddle" ';
	var std1= 'width=24 height=22 ';
	var std2 = '></td>';

	tools = open;
	for(i=0;i<BT_NUMBER;i++){
		if(Present[i]){
			tools+=std0;
			if(i!=BT_SYSB && i!=BT_TITL)
				tools+=std1;
			//tools+='src='+ GetINorm(i) + ' ';
			tools+='src="'+ IMRES[i][NRM].src + '" ';
			tools+=	'onClick="mClick('    + i + ')" ';
			tools+=	'onMouseDown="mDown(' + i + ')" ';
			tools+=	'onMouseUp="mUp(' + i + ')" ';
			tools+=	'onMouseOver="mOver(' + i + ')" ';
			tools+=	'onMouseOut="mOut('   + i + ')" ';	//	tools+='name="btn_' + i +'" '
			tools+=	'name="btn_' + i +'" ';
			tools+= 'alt="'+GetIMessage(i)+'" ';
			tools+=std2;								
		}
	}
	tools += close;

	return tools;
}
//----------------------------------------------------------------------------
var NIL = -1;
//----------------------------------------------------------------------------
function InRect(x,y,left,top,right,bottom) {
	if(x>=left && x<=right && y>=top  && y<=bottom)
		return 1;
	return 0;	
}
//----------------------------------------------------------------------------
function GetSender(x,y) {
	for(i=0;i<FUBSNUMBER;i++) {
		var left  = FUB[i][0];
		var top   = FUB[i][1];
		var right = FUB[i][2];
		var bottom= FUB[i][3];

	factor = PageX / ViewX;

	xx = x*factor;
	yy = y*factor;

		if(InRect(xx,yy,left,top,right,bottom))
			return i;
	}
	return NIL;
}
//----------------------------------------------------------------------------
function Mapper(MouseX,MouseY) {
	var SENDER = GetSender(MouseX,MouseY);
	if(SENDER != NIL){
		FUB[SENDER][4]();		
	}
}
//----------------------------------------------------------------------------
function MapperOver(MouseX,MouseY) {
	var SENDER = GetSender(MouseX,MouseY);
	if(SENDER != NIL){
		FUB[SENDER][5]();
		SetCursor("hand");
	}
	else {
		SetStatus("");
		SetCursor("default");
	}
	
}
//----------------------------------------------------------------------------
function SetStatus(status){
	if(window.top.status!=status){
		window.top.status=status;
		}
}
//----------------------------------------------------------------------------
function SetCursor(cursor){
	if(ie){
		if(MyImage.style.cursor!=cursor)
			MyImage.style.cursor=cursor;
	} else {
		; 
	}
}
//----------------------------------------------------------------------------
function Grosser(Who) { //in Opera - MDI - some bugs :-( but Ok . IE - nok. NN6 - ok
	//window.moveTo(0,0);
//	window.resizeTo(screen.availWidth,screen.availHeight);
	Who.moveTo(0,0);
	Who.resizeTo(screen.availWidth,screen.availHeight);
}
//----------------------------------------------------------------------------
function fullScreen2(theURL) {
	window.open(theURL, '', 'fullscreen=yes,scrollbars=yes,status=yes,resizable=yes,location=yes');
}
//----------------------------------------------------------------------------
function boom(n){
	if (window.top.moveBy)
	{
		for (i = 10; i > 0; i--){
			for (j = n; j > 0; j--){
				window.top.moveBy(0,i);
				window.top.moveBy(i,0);
				window.top.moveBy(0,-i);
				window.top.moveBy(-i,0);
			}//for
		}//for
	}//if
}
//----------------------------------------------------------------------------
function view_source(){ //Opera - nok; IE - ok. NN6 - ok.
MyWindow.location = "view-source:" + MyWindow.location.href;
} 
//----------------------------------------------------------------------------
function printit(){
	var browser_name = navigator.appName;
	if (browser_name == "Netscape") {
    	MyWindow.print() ;
	} else {
    	var WebBrowser = '<object id="WebBrowser1" width=0 height=0 classid="clsid:8856F961-340A-11D0-A96B-00C04FD705A2"></object>';
	    document.body.insertAdjacentHTML('beforeEnd', WebBrowser);
    	WebBrowser1.ExecWB(6, 2);
	}
}




