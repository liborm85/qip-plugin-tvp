unit Convs;

interface

uses SysUtils, Classes, Dialogs;

const
  OneDay         = 1.0;
  OneWeek        = OneDay * 7;
  OneHour        = OneDay / 24.0;
  OneMinute      = OneHour / 60.0;
  OneSecond      = OneMinute / 60.0;
  OneMillisecond = OneSecond / 1000.0;
  

  function SQLTextToText(sSQLText: AnsiString): WideString;
  function TextToSQLText(sText: WideString): WideString;
  function XMLTextToText(sXMLText: WideString): WideString;
  function HTMLToText(sHTML: WideString): WideString;
  function ConvOdstranitDiakritiku(sName: WideString): WideString;
  function ConvFileName(sName: WideString): WideString;

  {function RFCDTToDT(DT: WideString): WideString;
  function ISO8601DTToDT(DT: WideString): WideString;}
  function SQLDLToDT(DT: WideString): TDateTime;

  function ConvStrToInt(numberString: WideString): Int64;
  function AddLeadingZeroes(const aNumber, Length : Integer) : WideString;
  function ReplNewVesion(sText: WideString; sVersion: WideString): WideString;

  function IntToBool(iInt: Integer): Boolean;
  function BoolToInt(bBool: Boolean): Integer;

  function ConvB(Value : Int64) : WideString;


  function TextToHTMLText(sText: WideString): WideString;


  function UTF82WideString(S : RawByteString) : WideString;
  function WideString2UTF8(S : WideString) : AnsiString;
  
  function HexToInt(HexNum: string): LongInt;
  
  function  DiffMilliseconds(const D1, D2: TDateTime): Int64;
  function  DiffSeconds(const D1, D2: TDateTime): Integer;
  function  DiffMinutes(const D1, D2: TDateTime): Integer;
  function  DiffHours(const D1, D2: TDateTime): Integer;
  function  DiffDays(const D1, D2: TDateTime): Integer;
  function  DiffWeeks(const D1, D2: TDateTime): Integer;
  function  DiffMonths(const D1, D2: TDateTime): Integer;
  function  DiffYears(const D1, D2: TDateTime): Integer;

{
  function TextToHEX(sText: WideString): WideString;
  function HEXToText(sText: WideString): WideString;
}

var DTFormatDATETIME:  TFormatSettings;

implementation

{                                                                              }
{ Difference                                                                   }
{                                                                              }

function DiffMilliseconds(const D1, D2: TDateTime): Int64;
begin
  Result := Integer(Trunc((D2 - D1) / OneMillisecond));
end;

function DiffSeconds(const D1, D2: TDateTime): Integer;
begin
  Result := Integer(Trunc((D2 - D1) / OneSecond));
end;

function DiffMinutes(const D1, D2: TDateTime): Integer;
begin
  Result := Integer(Trunc((D2 - D1) / OneMinute));
end;

function DiffHours(const D1, D2: TDateTime): Integer;
begin
  Result := Integer(Trunc((D2 - D1) / OneHour));
end;

function DiffDays(const D1, D2: TDateTime): Integer;
begin
  Result := Integer(Trunc(D2 - D1));
end;

function DiffWeeks(const D1, D2: TDateTime): Integer;
begin
  Result := Trunc(D2 - D1) div 7;
end;

function DiffMonths(const D1, D2: TDateTime): Integer;
var Ye1, Mo1, Da1 : Word;
    Ye2, Mo2, Da2 : Word;
    ModMonth1,
    ModMonth2     : TDateTime;
begin
  DecodeDate(D1, Ye1, Mo1, Da1);
  DecodeDate(D2, Ye2, Mo2, Da2);
  Result := (Ye2 - Ye1) * 12 + (Mo2 - Mo1);
  ModMonth1 := Da1 + Frac(D1);
  ModMonth2 := Da2 + Frac(D2);
  if (D2 > D1) and (ModMonth2 < ModMonth1) then
    Dec(Result);
  if (D2 < D1) and (ModMonth2 > ModMonth1) then
    Inc(Result);
end;

function DiffYears(const D1, D2: TDateTime): Integer;
var Ye1, Mo1, Da1 : Word;
    Ye2, Mo2, Da2 : Word;
    ModYear1,
    ModYear2      : TDateTime;
begin
  DecodeDate(D1, Ye1, Mo1, Da1);
  DecodeDate(D2, Ye2, Mo2, Da2);
  Result := Ye2 - Ye1;
  ModYear1 := Mo1 * 31 + Da1 + Frac(Da1);
  ModYear2 := Mo2 * 31 + Da2 + Frac(Da2);
  if (D2 > D1) and (ModYear2 < ModYear1) then
    Dec(Result);
  if (D2 < D1) and (ModYear2 > ModYear1) then
    Inc(Result);
end;
{ -------------------------------------                                        }

function UTF82WideString(S : RawByteString) : WideString;
begin

  Result := UTF8ToWideString(S);

end;

function WideString2UTF8(S : WideString) : AnsiString;
begin

  Result := UTF8Encode(S)

end;


function SQLTextToText(sSQLText: AnsiString): WideString;
begin
  Result := UTF82WideString( StringReplace(sSQLText, '````', '''', [rfReplaceAll] ) );
end;

function TextToSQLText(sText: WideString): WideString;
begin
  Result :={ WideString2UTF8(} StringReplace(  StringReplace(sText, '''', '````', [rfReplaceAll] )  , '\"', '"', [rfReplaceAll] ) {)};

end;


function XMLTextToText(sXMLText: WideString): WideString;
begin
//`
 Result := TextToSQLText( Trim( HTMLToText( sXMLText ) ) );
end;


(* === HTML To Text - prevede html kody na text ============================= *)
function HTMLToText(sHTML: WideString): WideString;
begin

  sHTML := StringReplace(sHTML, '&amp;', '&', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '&nbsp;', ' ', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '%2F', '/', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '%3F', '?', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '%3D', '=', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '%26', '&', [rfReplaceAll]);

  sHTML := StringReplace(sHTML, '&quot;', '"',  [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '&apos;', '''', [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '&gt;',   '>',  [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '&lt;',   '<',  [rfReplaceAll]);
  sHTML := StringReplace(sHTML, '&ndash;',   '–',  [rfReplaceAll]);

  Trim(sHTML);

  HTMLToText := sHTML;
end;


(* === Conv Odstranit Diakritiku - odstraòuje háèky a èárky               === *)
function ConvOdstranitDiakritiku(sName: WideString): WideString;
var sSrc,sNew: WideString;
    i: integer;
begin
  sSrc := 'áÁéìÌíÍóÓúÚùÙýÝèÈïÏl¾¼nòÒrøØsšŠtzžŽäëöüÄËÖÜß';
  sNew := 'aAeeEiIoOuUuUyYcCdDllLnnNrrRssSttTzzZaeouAEOUs';

  for i := 0 to Length(sSrc) do
  begin
    sName := StringReplace(sName, Copy(sSrc,i,1), Copy(sNew,i,1), [rfReplaceAll]);
  end;

  Result := sName;

end;

(* === Conv File Name - konvertuje text na nazev souboru ( bez mezer,atd.)=== *)
function ConvFileName(sName: WideString): WideString;
var sSrc,sNew: WideString;
    i: integer;
begin
  sName := StringReplace( AnsiLowerCase( sName ), ' ', '-', [rfReplaceAll]);

  sSrc := 'áÁéìÌíÍóÓúÚùÙýÝèÈïÏl¾¼nòÒrøØsšŠtzžŽäëöüÄËÖÜß';
  sNew := 'aAeeEiIoOuUuUyYcCdDllLnnNrrRssSttTzzZaeouAEOUs';

  for i := 0 to Length(sSrc) do
  begin
    sName := StringReplace(sName, Copy(sSrc,i,1), Copy(sNew,i,1), [rfReplaceAll]);
  end;

  Result := sName;

(*
  sSrc := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789áÁéìÌíÍóÓúÚùÙýÝèÈïÏl¾¼nòÒrøØsšŠtzžŽäëöüÄËÖÜß';
  sNew := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789aAeeEiIoOuUuUyYcCdDllLnnNrrRssSttTzzZaeouAEOUs';

//  sText := '';

  for i := 1 to Length(sName) do
    begin
      if sName[i]=' ' then

      else
        begin
          r1 := StrPosE(sSrc, sName[i], 1, true);
          if r1<>0 then
            begin
              sText := sText + sNew[r1]
            end
          else
            begin

            end;
      end;
    end;

  ConvFileName := AnsiLowerCase(sText);      *)
end;

function SQLDLToDT(DT: WideString): TDateTime;
begin

  if DT='' then
    Result := 0
  else
    Result := StrToDateTime( DT , DTFormatDATETIME );

end;

{
function RFCDTToDT(DT: WideString): WideString;
begin

  if DT='' then
    Result := '0000-00-00 00:00:00'
  else
    Result := FormatDateTime('YYYY-MM-DD HH:MM:SS', RFCDateTimeToGMTDateTime( DT ) );

end;

function ISO8601DTToDT(DT: WideString): WideString;
begin
  if DT='' then
    Result := '0000-00-00 00:00:00'
  else
    Result := FormatDateTime('YYYY-MM-DD HH:MM:SS', ISO8601StringAsDateTime( DT ) );

end;
}

function ConvStrToInt(numberString: WideString): Int64;
var float: Int64;
    errorPos: Integer;
begin

  Val(numberString, float, errorPos);

  if errorPos = 0 then
    result := float
  else
    result := 0;
    
end;

function AddLeadingZeroes(const aNumber, Length : Integer) : WideString;
begin
   result := SysUtils.Format('%.*d', [Length, aNumber]) ;
end;

function ReplNewVesion(sText: WideString; sVersion: WideString): WideString;
begin

  sText := StringReplace(sText, '%VERSION%', sVersion, [rfReplaceAll, rfIgnoreCase]);
  Result := sText;

end;


function BoolToInt(bBool: Boolean): Integer;
begin
  if bBool = True then
    Result := 1
  else
    Result := 0;
end;

function IntToBool(iInt: Integer): Boolean;
begin
  if iInt = 1 then
    Result := True
  else
    Result := False;
end;


function ConvB(Value : Int64) : WideString;
const
  OneKB = 1024;
  OneMB = OneKB * 1024;
  OneGB = OneMB * 1024;
begin
  if Value < OneKB then
    Result := FormatFloat('#,##0 B',Value)
  else
    if Value < OneMB then
      Result := FormatFloat('#,##0.00 kB', Value / OneKB)
    else
      if Value < OneGB then
        Result := FormatFloat('#,##0.00 MB', Value / OneMB)
      else
        Result := FormatFloat('#,##0.00 GB', Value / OneGB)

end;


function TextToHTMLText(sText: WideString): WideString;
var i : Integer;
    S : WideString;
begin
  S := WideString2UTF8(sText);
  Result := '';
  i:=1;
  while ( i<= Length(S) ) do
  begin
    Result := Result + '%' +IntToHex(Ord(S[i]),2);

    Inc(i);
  end;

end;



function HexToInt(HexNum: string): LongInt;
begin
   Result:=StrToInt('$' + HexNum) ;
end;

(*
function TextToHEX(sText: WideString): WideString;
var i : Integer;
    S : WideString;
begin
  S := {WideString2UTF8(}sText{)};

  Result := '';
  i:=1;
  showmessage(inttostr(Length(S)));
  while ( i<= Length(S) ) do
  begin
    Result := Result + IntToHex(Ord(sText[i]),2);

    Inc(i);
  end;

end;

function HEXToText(sText: WideString): WideString;
var i : Integer;
begin

  Result := '';

  i:=1;
  while ( i <= Length(sText) ) do
  begin
    Result := Result + Chr(HexToInt(Copy(sText,i,2)));

    Inc(i);
    Inc(i);
  end;
          ShowMessage({UTF82WideString(Result)+#13+}Result);
  Result := {UTF82WideString(}Result{)};

end;
*)

end.
