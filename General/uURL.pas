unit uURL;

interface

uses Windows, ShellApi;

  procedure LinkUrl(sLinkUrl: WideString);

implementation

procedure LinkUrl(sLinkUrl: WideString);
{var ret: Integer;  }

begin
  if Length(sLinkUrl) > 0 then
  {begin
    ret := }ShellExecute(0, 'open', PChar(sLinkUrl), nil, nil, SW_SHOWNORMAL);
  { if ret < 33 then
      MessageBox(0, PChar('Can not open ' + sLinkUrl + #13'Error Code: ' + IntToStr(ret)), 'Error', MB_OK + MB_ICONERROR + MB_SETFOREGROUND);
  end;}
end;

end.
