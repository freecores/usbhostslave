
// styles definition

document.writeln ('<style>');
document.writeln ('body    { font-size: 12px }');
document.writeln ('#tree   { font-size: 12px }');
document.writeln ('#folder { cursor: hand }');
document.writeln ('a { color: #000080; text-decoration: none }');
document.writeln ('</style>');

// paths

if ((ie) || (nn))
{
	var TreePath = "./images/tree/";
	var ExtPath = "./images/ext/";
	var DocPath = "./../src/";
}
if ((!ie) && (!nn))
{
	var TreePath = "./../images/tree/";
	var ExtPath = "./../images/ext/";
	var DocPath = "./../src/";
}


// preloading images

Empty = new Image ();

Join = new Image ();
JoinBottom = new Image ();
JoinTop = new Image ();
JoinLeft = new Image ();

Line = new Image ();

Minus = new Image ();
MinusBottom = new Image ();
MinusOnly = new Image ();
MinusTop = new Image ();

Plus = new Image ();
PlusBottom = new Image ();
PlusOnly = new Image ();
PlusTop = new Image ();

FolderOpened = new Image ();
FolderClosed = new Image ();

Project = new Image ();

VHD = new Image ();VHDL = new Image ();//VHDL Source cod
V = new Image (); //Verilog Source cod
EDN = new Image (); //edif...
BDE = new Image ();
AWF = new Image ();
ASF = new Image (); //"State diagram"
LST = new Image ();
TXT = new Image ();
PL = new Image ();
TCL = new Image ();
DO = new Image ();
CPP = new Image ();
SDF = new Image (); //"SDF File"

XNF = new Image (); //"XNF Netlist"
VLS = new Image (); //"ViewLogic Schematic"
VTB = new Image (); //"VHDL Test bench"  || "Verilog Test bench"
HTM = new Image ();HTML = new Image ();   //"HTML Document"
BAS = new Image ();
UND = new Image (); //undefined        || "External File"

CONF = new Image (); //"Configuration file"
DRW = new Image (); //"Drawing" ????
SYMB = new Image (); //"Symbol Sheet" ????

ACP = new Image (); //Active-CAD Project
AHW = new Image (); //Active-HDL Workspace

///////////////////////////////////////////
Empty.src = TreePath + "empty.gif";

Join.src = TreePath + "join.gif";
JoinBottom.src = TreePath + "join_b.gif";
JoinTop.src = TreePath + "join_t.gif";
JoinLeft.src = TreePath + "join_l.gif";

Line.src = TreePath + "line.gif";

Minus.src = TreePath + "minus.gif";
MinusBottom.src = TreePath + "minus_b.gif";
MinusOnly.src = TreePath + "minus_o.gif";
MinusTop.src = TreePath + "minus_t.gif";

Plus.src = TreePath + "plus.gif";
PlusBottom.src = TreePath + "plus_b.gif";
PlusOnly.src = TreePath + "plus_o.gif";

FolderOpened.src = TreePath + "folder_o.gif";
FolderClosed.src = TreePath + "folder_c.gif";
///////////////////////////////////////////
Project.src = TreePath + "project.gif";
///////////////////////////////////////////
VHD.src = ExtPath + "vhd.gif";
V.src = ExtPath + "v.gif";
EDN.src = ExtPath + "edn.gif";
BDE.src = ExtPath + "bde.gif";
AWF.src = ExtPath + "awf.gif";
ASF.src = ExtPath + "asf.gif";
LST.src = ExtPath + "lst.gif";
TXT.src = ExtPath + "txt.gif";
PL.src = ExtPath + "pl.gif";
TCL.src = ExtPath + "tcl.gif";
DO.src = ExtPath + "do.gif";
CPP.src = ExtPath + "cpp.gif";
SDF.src = ExtPath + "sdf.gif";

XNF.src = ExtPath + "xnf.gif";
VLS.src = ExtPath + "vls.gif"; 
VTB.src = ExtPath + "vtb.gif"; 
HTM.src = ExtPath + "htm.gif"; HTML.src = HTM.src;
BAS.src = ExtPath + "bas.gif"; 
UND.src = ExtPath + "und.gif"; 

CONF.src = ExtPath + "conf.gif"; 
DRW.src = ExtPath + "drw.gif"; 
SYMB.src = ExtPath + "symb.gif"; 

ACP.src = ExtPath + "acp.gif"; 
AHW.src = ExtPath + "ahw.gif"; 

// working with tree

function BeginTree ()
 {
  return '<table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody align="left" valign="middle">';
 }

function EndTree ()
 {
  return '</table>';
 }

function FirstCreateTree()
{
  window.frames["Map"].document.writeln(DrawMapTree());
}

function CreateTree ()
 {
  if (!ie)
  {
  window.frames["Map"].document.open();
  window.frames["Map"].document.writeln("<html>");
  window.frames["Map"].document.writeln ('<style>');
  window.frames["Map"].document.writeln ('body    { font-size: 12px }');
  window.frames["Map"].document.writeln ('#tree   { font-size: 12px }');
  window.frames["Map"].document.writeln ('#folder { cursor: hand }');
  window.frames["Map"].document.writeln ('a { color: #000080; text-decoration: none }');
  window.frames["Map"].document.writeln ('</style>');
  window.frames["Map"].document.writeln("<body background=\"./../images/aldec.gif\" bgproperties=\"fixed\">");
  window.frames["Map"].document.writeln("<script language=\"JavaScript\">");
  window.frames["Map"].document.writeln("<!--");
  for(i=0;i<Expanded.length;++i)
    window.frames["Map"].document.writeln("parent.Expanded["+i+"]="+Expanded[i]+";");  
  window.frames["Map"].document.writeln("//-->");
  window.frames["Map"].document.writeln("</script>");
  window.frames["Map"].document.writeln(DrawMapTree());
  window.frames["Map"].document.writeln("</body>");
  window.frames["Map"].document.writeln("</html>");
  window.frames["Map"].document.close();
  }
  else
    window.frames["Map"].document.body.innerHTML = DrawMapTree ();
 }

 function CollapseIt ()
 {
  for(i=0;i<Expanded.length;++i)
   Expanded[i]=false;  
  CreateTree();
 }

 function ExpandIt ()
 {
  for(i=0;i<Expanded.length;++i)
   Expanded[i]=true;  
  CreateTree();
 }

 function NormalIt ()
 {
  for(i=0;i<Expanded.length;++i)
   Expanded[i]=false;
  Expanded[0]=true;
  CreateTree();
 }

// working with group

function Invert (Number)
 {
   Expanded[Number] = ! Expanded[Number];
   CreateTree ();
 }

function BR ()
 {
  return '<tr><td id=tree><nobr>';
 }

function ER ()
 {
  return '</nobr></td></tr>';
 }

// working with elements

function Ver (ImgName,Number)
 {
  if (Number != -1)
    return '<a href="#"  onClick="parent.Invert('+Number+');"><img border=0 src="' + ImgName.src + '" width=18 height=20 align=left hspace=0 vspace=0></a>';
  else
  return '<img src="' + ImgName.src + '" width=18 height=20 align=left hspace=0 vspace=0>';
 }

function Ext (ImgName)
 {
  return '<img src="' + ImgName.src + '" width=18 height=16 align=left hspace=0 vspace=0>';
 }

function Tit (Name, URL, Type)
 {
  if (Type != "folder")
   {
    var URL_doc = DocPath + URL;
    if ((Type != "project")&&(Type != "HTM"))
     URL_doc += "/index.htm";
    if (Type=="project")
    return ' <a href=' + "./../info/index.htm"+ ' class=k target="Information">' + Name + '</a>';
    
    if ((Type!="project")&&(URL==""))
     return '<font color="#888888"> '+Name;
    else
     return ' <a href=' + URL_doc + ' class=k target="Information">' + Name + '</a>';
   }
  return Name;
 }
