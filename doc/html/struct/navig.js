
// styles definition

document.writeln ('<style>');
document.writeln ('body { margin: 0px}');
document.writeln ('#tabs { margin: 0px; border-width: 0px }');
document.writeln ('</style>');

// paths

var TreePath = "./" + RootProject + "images/tree/";
var TabsPath = "./" + RootProject + "images/tab/";
if (DownTabs == 1)
 TabsPath = "./" + RootProject + "images/itab/";
var ExtPath = "./" + RootProject + "images/ext/";

// preloading images

LeftNot = new Image ();
RightNot = new Image ();

LeftSel = new Image ();
RightSel = new Image ();

SelNot = new Image ();
NotSel = new Image ();
NotNot = new Image ();

TabNot = new Image ();
TabSel = new Image ();

Project = new Image ();
VHD = new Image ();
V = new Image ();
EDN = new Image ();
BDE = new Image ();
AWF = new Image ();
ASF = new Image ();
LST = new Image ();
TXT = new Image ();
PL = new Image ();
TCL = new Image ();
DO = new Image ();
CPP = new Image ();
UNDEF = new Image ();

Empty = new Image ();

LeftNot.src = TabsPath + "left_n.bmp";
RightNot.src = TabsPath + "right_n.bmp";

LeftSel.src = TabsPath + "left_s.bmp";
RightSel.src = TabsPath + "right_s.bmp";

SelNot.src = TabsPath + "s_n.bmp";
NotSel.src = TabsPath + "n_s.bmp";
NotNot.src = TabsPath + "n_n.bmp";

TabNot.src = TabsPath + "tab_n.bmp";
TabSel.src = TabsPath + "tab_s.bmp";

Project.src = TreePath + "project.bmp";

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
UNDEF.src = ExtPath + "undef.gif";

Empty.src = TabsPath + "empty.gif";

// working with tab

var ID = 0;

function SetTab (Type, Name, URL)
 {
  var str;
  str = '<td id=tab background="' + TabNot.src + '" valign="middle"><nobr>';
  str += '<a style="text-decoration: none; font-size: 12px" href="' + URL + '" target=' + Target + ' onClick="ChangeButtons(\'' + ID + '\')">';         ChangeButtons
  str += '&nbsp;<img hspace="0" vspace="0" border="0" align="absmiddle" width="18" height="16" src="' + Type.src + '">&nbsp;';
  str += '&nbsp;' + Name + '&nbsp;';
  str += '</a>';
  str += '</td>';
  this.document.writeln (str);
  ++ID;
 }

// working with limiters

function SetLeft ()
 {
  this.document.writeln ('<td><img width="7" height="21" src="' + LeftNot.src + '"></td>');
 }

function SetRight ()
 {
  this.document.writeln ('<td><img width="7" height="21" src="' + RightNot.src + '"></td>');
 }

function SetBTab ()
 {
  this.document.writeln ('<td><img width="7" height="21" src="' + NotNot.src + '"></td>');
 }

var CurTab = 1;

function ChangeButtons (ID)
 {

  var off = 1 - DownTabs;

  if (CurTab == ID)
   return;

  if (CurTab == 0)
   {
    this.document.images(off+0).src = LeftNot.src;
    this.document.images(off+2).src = NotNot.src;
   }
  if (CurTab == (ColTabs - 1))
   {
    this.document.images(off+ColTabs*2 - 2).src = NotNot.src;
    this.document.images(off+ColTabs*2).src = RightNot.src;
   }
  if (CurTab > 0 && CurTab < (ColTabs - 1))
   {
    this.document.images(off+CurTab*2).src = NotNot.src;
    this.document.images(off+CurTab*2 + 2).src = NotNot.src;
   }
  if(ColTabs!=1)
  this.document.all ('tab', CurTab).background = TabNot.src;

  CurTab = ID;

  if (CurTab == 0)
   {
    this.document.images(off+0).src = LeftSel.src;
    this.document.images(off+2).src = SelNot.src;
   }
  if (CurTab == (ColTabs - 1))
   {
    this.document.images(off+ColTabs*2 - 2).src = NotSel.src;
    this.document.images(off+ColTabs*2).src = RightSel.src;
   }
  if (CurTab > 0 && CurTab < (ColTabs - 1))
   {
    this.document.images(off+CurTab*2).src = NotSel.src;
    this.document.images(off+CurTab*2 + 2).src = SelNot.src;
   }

  this.document.all ('tab', CurTab).background = TabSel.src;

 }

// working with tabs

function BeginTabs ()
 {
  if (!DownTabs)
   this.document.writeln ('<img height="4" src="' + Empty.src + '"><br>');
  this.document.writeln ('<table id=tabs cellspacing="0" cellpadding="0"><tr>');
 }

function EndTabs ()
 {
  document.writeln ('</tr></table>');
  ChangeButtons (0);
 }

