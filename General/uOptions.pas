unit uOptions;

interface

uses
  SysUtils, Classes, Graphics;

type
  { Item Options }
  TItemOptions = class
  public
    dataWideString : WideString;
  end;

  {OwnFont}
  TOwnFont = record
    OwnFont        : Boolean;
    Font           : TFont;
    FontColor      : WideString;
  end;

  procedure LoadOptions(sOptions: WideString; var slOptions: TStringList);
  function SaveOptions(slOptions: TStringList): WideString;
  procedure AddOptions(slOptions: TStringList; sItem: WideString; sValue: WideString);

  procedure LoadFont(sFont: WideString; var fFont: TOwnFont);
  function SaveFont(var fFont: TOwnFont): WideString;
implementation

uses TextSearch;


procedure LoadOptions(sOptions: WideString; var slOptions: TStringList);
var Pos, Pos2, Pos3, LastPos: Integer;
    hIndex : Integer;
Label Retry;
begin
  slOptions := TStringList.Create;
  slOptions.Clear;

  LastPos:= 1;

  Retry:
  Pos := StrPosE(sOptions,'[',LastPos,False);
  if Pos<>0 then
  begin
    Pos2 := StrPosE(sOptions,']="',Pos,False);
    if Pos2<>0 then
    begin
      Pos3 := StrPosE(sOptions,'";',Pos2+3,False);
      if Pos3<>0 then
      begin
        slOptions.Add(Copy(sOptions,Pos + 1, Pos2 - Pos - 1));
        hIndex:= slOptions.Count - 1;
        slOptions.Objects[hIndex] := TItemOptions.Create;
        TItemOptions(slOptions.Objects[hIndex]).dataWideString := Copy(sOptions,Pos2 + 3, Pos3 - Pos2 - 3);

        LastPos := Pos3 + 2;
        Goto Retry;
      end;

    end;

  end;

end;

function SaveOptions(slOptions: TStringList): WideString;
var i: Integer;
    sResult: WideString;

begin

  sResult := '';

  i:=0;
  while ( i<= slOptions.Count - 1 ) do
  begin

    sResult := sResult +
               '[' + slOptions.Strings[i] + ']="' +
                  TItemOptions(slOptions.Objects[i]).dataWideString +
                  '";';

    Inc(i);
  end;

  Result := sResult

end;

procedure AddOptions(slOptions: TStringList; sItem: WideString; sValue: WideString);
var
  IdxOf: Integer;
begin

  IdxOf := slOptions.IndexOf(sItem);

  if IdxOf = -1 then
  begin
    slOptions.Add( sItem );
    IdxOf := slOptions.Count - 1;
    slOptions.Objects[IdxOf] := TItemOptions.Create;
  end;

  TItemOptions(slOptions.Objects[IdxOf]).dataWideString := sValue;

end;


procedure LoadFont(sFont: WideString; var fFont: TOwnFont);
var//iFS    : Integer;
    sValue : WideString;
    r      : Integer;

begin
  //  Name="Tahoma";Size="8";Color="NotInList";Style="";

  //  Name="Tahoma";Size="8";Color="0";Style="Bold;Italic;Underline;StrikeOut;";

  fFont.Font := TFont.Create;
{
  if sFont='' then
  begin
    fFont := fontDefaultCLFont;
  end;
}
  sValue := FoundStr(sFont,'Name="','";',1);
  if sValue<>'' then fFont.Font.Name := sValue;

  sValue := FoundStr(sFont,'Size="','";',1);
  if sValue<>'' then fFont.Font.Size := StrToInt( sValue );

  sValue := FoundStr(sFont,'Color="','";',1);
  if sValue<>'' then fFont.FontColor := sValue;

  sValue := FoundStr(sFont,'Style="','";',1);
  if sValue<>'' then
  begin
    r := StrPosE( sValue, 'Bold;', 1, False);
    if r <> 0 then fFont.Font.Style := fFont.Font.Style + [fsBold];

    r := StrPosE( sValue, 'Italic;', 1, False);
    if r <> 0 then fFont.Font.Style := fFont.Font.Style + [fsItalic];

    r := StrPosE( sValue, 'Underline;', 1, False);
    if r <> 0 then fFont.Font.Style := fFont.Font.Style + [fsUnderline];

    r := StrPosE( sValue, 'StrikeOut;', 1, False);
    if r <> 0 then fFont.Font.Style := fFont.Font.Style + [fsStrikeOut];
  end;

end;


function SaveFont(var fFont: TOwnFont): WideString;
var sResult : WideString;

begin

  //  Name="Tahoma";Size="8";Color="0";Style="Bold;Italic;Underline;StrikeOut;";
  sResult := '';

  sResult := sResult + 'Name="' + fFont.Font.Name + '";';

  sResult := sResult + 'Size="' + IntToStr(fFont.Font.Size) + '";';

  sResult := sResult + 'Color="' + fFont.FontColor + '";';

  sResult := sResult + 'Style="';


  if (fsBold IN fFont.Font.Style) then   sResult := sResult + 'Bold;';
  if (fsItalic IN fFont.Font.Style) then   sResult := sResult + 'Italic;';
  if (fsUnderline IN fFont.Font.Style) then   sResult := sResult + 'Underline;';
  if (fsStrikeOut IN fFont.Font.Style) then   sResult := sResult + 'StrikeOut;';

  sResult := sResult + '";';

  Result := sResult;

end;

end.
