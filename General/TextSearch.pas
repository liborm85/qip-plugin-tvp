unit TextSearch;

interface

uses SysUtils, Classes;

  function StrPosE(str1, str2: WideString;  Start: Int64; CaseSensitive: Boolean) : Int64;
  procedure DecodeID(ID: WideString; sChar: WideString; var First: WideString; var Second: WideString);
  function FoundStr(sText: WideString; sStart: WideString; sEnd: WideString; Start: Integer): WideString; overload;
  function FoundStr(sText: WideString; sStart: WideString; sEnd: WideString; Start: Integer; var FoundPos: Integer; var iPosStart : Integer; var iPosEnd : Integer): WideString; overload;
  function FoundLastChar(sText: WideString): WideString;
  function FoundLastChar2(sText: WideString): WideString;
  function FoundFirstChar(sText: WideString): WideString;
  function PHPToText(sText: WideString): WideString;
  function WordExists(str1, str2: WideString): Boolean;

  function ReplCondBlocks(sText : WideString) : WideString;

implementation


procedure DecodeID(ID: WideString; sChar: WideString; var First: WideString; var Second: WideString);
var r: Int64;
begin
  { sChar @}

  r := StrPosE(ID, sChar, 1, False);

  Second := Copy( ID, r+1, Length(ID) - (r+1) + 1 );
  First  := Copy( ID, 1, r-1 );

end;

function FoundStr(sText: WideString; sStart: WideString; sEnd: WideString; Start: Integer): WideString; overload;
var
  I1, I2, I3: Integer;
begin
  Result := FoundStr(sText, sStart, sEnd, Start, I1, I2, I3);
end;

function FoundStr(sText: WideString; sStart: WideString; sEnd: WideString; Start: Integer; var FoundPos: Integer; var iPosStart : Integer; var iPosEnd : Integer): WideString; overload;
var r1,r2: Integer;

begin
{
  sStart := PHPToText(sStart);
  sEnd   := PHPToText(sEnd);
}
  result := '';
  r1:=StrPosE(sText, sStart, Start, False);
  if r1<>0 then
  begin
    r2:=StrPosE(sText, sEnd, r1 + Length(sStart) , False);
    if r2<>0 then
    begin
      result := Copy(sText,r1 + Length(sStart), r2 - (r1 + Length(sStart)));
      FoundPos := r1 + Length(sStart) + Length(sEnd);  // CHYBNE!!!!

      iPosStart := r1;
      iPosEnd   := r1 + Length(sStart) + Length(sEnd) + length(result);
    end;
  end;

end;

function FoundLastChar(sText: WideString): WideString;
var i: Integer;
begin

  Result := sText;

  for i := Length(sText) downto 1 do
  begin
    if Copy(sText,i,1) = '>' then
    begin
      Result := Copy(sText,i + 1, Length(sText));
      Exit;
    end;
  end;

end;

function FoundLastChar2(sText: WideString): WideString;
var i: Integer;
begin

  Result := sText;

  for i := Length(sText) downto 1 do
  begin
    if Copy(sText,i,1) = '|' then
    begin
      Result := Copy(sText,i + 1, Length(sText));
      Exit;
    end;
  end;

end;


function FoundFirstChar(sText: WideString): WideString;
var i: Integer;
begin

  Result := sText;

  for i := 1 to Length(sText) do
  begin
    if Copy(sText,i,1) = '<' then
    begin
      Result := Copy(sText,1, i - 1);
      Exit;
    end;

  end;

end;

function PHPToText(sText: WideString): WideString;
begin
  Result := '';

  Result := StringReplace(Result, '\n', #13+#10, [rfReplaceAll]);
  Result := StringReplace(Result, '\t', #9, [rfReplaceAll]);
end;

function WordExists(str1, str2: WideString): Boolean;
begin
  if StrPos( PChar(str1), PChar(str2) ) = nil then
    Result := False
  else
    Result := True;
end;

(* === StrPosE, function from .NET (InStr) ================================== *)
function StrPosE(str1, str2: WideString;  Start: Int64; CaseSensitive: Boolean): Int64;
var sFound: String;
begin

  if CaseSensitive = True then
  begin
    if Start > 1 then
      sFound := StrPos(pchar(Copy(str1, Start, Length(str1) - Start + 1)),pchar(str2))
    else
      sFound := StrPos(pchar(str1),pchar(str2));
  end
  else
  begin
    if Start > 1 then
      sFound := StrPos(pchar(AnsiUpperCase(Copy(str1, Start, Length(str1) - Start + 1))),pchar(AnsiUpperCase(str2)))
    else
      sFound := StrPos(pchar(AnsiUpperCase(str1)),pchar(AnsiUpperCase(str2)));
  end;

  if sFound = '' then
    StrPosE := 0
  else
    StrPosE := Length(str1) - Length(sFound) + 1

end;

function ReplCondBlocks(sText : WideString) : WideString;
var
  iFS, iFS1, iFS2, i : Integer;
  sCond : WideString;

Label  0;
begin

0:
  sCond := FoundStr(sText, '{{', '}}', 1, iFS, iFS1, iFS2);
  if sCond<>'' then
  begin
    if Copy(sCond,1,1) = '=' then
    begin
      sText := Copy(sText, 1, iFS1-1) + Copy(sText,iFS2 )
    end
    else
    begin
      i := StrPosE(sCond,'=',1,False);
      sText := Copy(sText,1,iFS1-1 )
             + Copy(sText,iFS1 + i + 2, Length(sCond) - i)
             + Copy(sText,iFS2 )
    end;

    GoTo 0;
  end;

  Result := sText;

end;

end.
