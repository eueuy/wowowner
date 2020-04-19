unit NotifyUnit;

interface

uses
  Windows,WinInet;

function HtmlEncode(s: string): string;
function PostURL(const aUrl: string; FTPostQuery: string; const strPostOkResult: string = 'Send OK!'): Boolean;

implementation

function UpperCase(AStr: string): string; overload;
var
  LI: Integer;
begin
  Result := AStr;
  for LI := 1 to Length(Result) do
    Result[LI] := System.UpCase(Result[LI]);
end;

function HtmlEncode(s: string): string;
var
  i, v1, v2: integer;
  function i2s(b: byte): char;
  begin
    if b <= 9 then result := chr($30 + b)
    else result := chr($41 - 10 + b);
  end;
begin
  result := '';
  for i := 1 to length(s) do
    if s[i] = ' ' then result := result + '+'
    else if (s[i] < ' ') or (s[i] in ['/', '\', ':', '&', '?', '|']) then
    begin
      v1 := ord(s[i]) mod 16;
      v2 := ord(s[i]) div 16;
      result := result + '%' + i2s(v2) + i2s(v1);
    end
    else result := result + s[i];
end;

function PostURL(const aUrl: string; FTPostQuery: string; const strPostOkResult: string = 'Send OK!'): Boolean;
var
  hSession: HINTERNET;
  hConnect, hRequest: hInternet;
  lpBuffer: array[0..1024 + 1] of Char;
  dwBytesRead: DWORD;
  HttpStr: string;
  HostName, FileName: string;
  FTResult: Boolean;
  AcceptType: LPStr;
  Buf: Pointer;
  dwBufLen, dwIndex: DWord;

  procedure ParseURL(URL: string; var HostName, FileName: string);
    procedure ReplaceChar(c1, c2: Char; var St: string);
    var
      p: Integer;
    begin
      while True do
      begin
        p := Pos(c1, St);
        if p = 0 then Break
        else St[p] := c2;
      end;
    end;
  var
    i: Integer;
  begin
    if Pos(UpperCase('http://'), UpperCase(URL)) <> 0 then System.Delete(URL, 1, 7);
    i:= Pos('/', URL);
    HostName := Copy(URL, 1, i);
    FileName := Copy(URL, i, Length(URL) - i + 1);
    if (Length(HostName) > 0) and (HostName[Length(HostName)] = '/') then SetLength(HostName, Length(HostName) - 1);
  end;
begin
  Result := False;
  hSession := InternetOpen('DNACoder', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    if Assigned(hSession) then
    begin
      ParseURL(aUrl, HostName, FileName);
      hConnect := InternetConnect(hSession, PChar(HostName),INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
      AcceptType := PChar('Accept: */*');
      hRequest := HttpOpenRequest(hConnect,'POST', PChar(FileName), 'HTTP/1.0',nil, @AcceptType, INTERNET_FLAG_RELOAD, 0);
      HttpSendRequest(hRequest, 'Content-Type: application/x-www-form-urlencoded', 47,PChar(FTPostQuery), Length(FTPostQuery));
      dwIndex := 0;
      dwBufLen := 1024;
      GetMem(Buf, dwBufLen);
      FTResult := HttpQueryInfo(hRequest, HTTP_QUERY_CONTENT_LENGTH,
        Buf, dwBufLen, dwIndex);
      if FTResult = True then
      try
        while True do
        begin
          dwBytesRead := 1024;
          InternetReadFile(hRequest, @lpBuffer, 1024, dwBytesRead);
          if dwBytesRead = 0 then break;
          lpBuffer[dwBytesRead] := #0;
          HttpStr := HttpStr + lpBuffer;
        end;
        Result := pos(strPostOkResult, HttpStr) > 0;
      finally
        InternetCloseHandle(hRequest);
        InternetCloseHandle(hConnect);
      end;
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;


end.
 