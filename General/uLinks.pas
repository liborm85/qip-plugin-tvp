unit uLinks;

interface

uses
  Windows, StdCtrls, Graphics, ShellApi;

  procedure OnMouseOverLink(Sender: TObject);
  procedure OnMouseOutLink(Sender: TObject);
  procedure OnClickLinkUrl(Sender: TObject; Info: WideString);
  procedure LinkUrl(sLinkUrl: WideString);

implementation

procedure OnMouseOverLink(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure OnMouseOutLink(Sender: TObject);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
end;

procedure OnClickLinkUrl(Sender: TObject; Info: WideString);
begin
  LinkUrl('mailto:' + TLabel(Sender).Caption + Info);
end;

procedure LinkUrl(sLinkUrl: WideString);
begin
  if Length(sLinkUrl) > 0 then
    ShellExecute(0, 'open', PChar(sLinkUrl), nil, nil, SW_SHOWNORMAL);
end;

end.
