unit BBCode;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  General, TextSearch, Convs,
  u_common;

type

  {sl BBCode Word}
  TSLBBCodeWord = class
  public
    Text       : WideString;
    Font       : TFont;
    TextWidth  : Integer;
    TextHeight : Integer;
  end;

  procedure BBCodeDrawText(Cnv: TCanvas; Text: WideString; Rect: TRect; WordBreak: Boolean {uFormat: Cardinal}; qipcolors: TQipColors);
  
  function HexToInt(strHexValue : string) : Integer;


implementation

uses uColors;


function HexToInt(strHexValue : string) : Integer;
var
 c,l : integer;
begin
  Val(strHexValue, l, c);
  Result := l;
end;

procedure BBCodeDrawText(Cnv: TCanvas; Text: WideString; Rect: TRect; WordBreak: Boolean {uFormat: Cardinal}; qipcolors: TQipColors);
var
    wStr      : WideString;
    R,{Rcalc,} RD         : TRect;
    iPos, iPosN : Integer;
    sCommand, sText       : WideString;
    DefFontColor, DefFontSize{, LastW}: Integer;
    hIndex: Integer;

    slText: TStringList;
    i, iFS1, iFS2: Integer;
{    WText : Integer;  }
    MaxHeight: Integer;
    iCN : Integer;

Label Ex1, Retr1;

    procedure DrawWordText(dwtText: WideString; dtwRect: TRect);
    var //slWords: TStringList;
        //hIndex2: Integer;
//        dwtI : Integer;
        dwtPos : Integer;
        dwtRcalc : TRect;
        RemText: WideString;
    Label 1;
    begin
{      slWords := TStringList.Create;
      slWords.Clear;}

      if dwtText='[BR]' then
      begin
        slText.Add('[BR]');
        hIndex:= slText.Count - 1;
        slText.Objects[hIndex] := TSLBBCodeWord.Create;
        TSLBBCodeWord(slText.Objects[hIndex]).Text := '';
        TSLBBCodeWord(slText.Objects[hIndex]).Font := TFont.Create;
        TSLBBCodeWord(slText.Objects[hIndex]).Font.Style := Cnv.Font.Style;
        TSLBBCodeWord(slText.Objects[hIndex]).Font.Color := Cnv.Font.Color;
        TSLBBCodeWord(slText.Objects[hIndex]).Font.Size  := Cnv.Font.Size;
      end
      else
      begin

        RemText := dwtText;

        1:
        dwtPos := StrPosE(RemText,' ',1, False);

        if dwtPos=0 then
        begin
          dwtRcalc.Top    := 0;
          dwtRcalc.Bottom := 0;
          dwtRcalc.Left   := 0;
          dwtRcalc.Right  := 0;

          slText.Add('');
          hIndex:= slText.Count - 1;
          slText.Objects[hIndex] := TSLBBCodeWord.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Text := RemText;
          TSLBBCodeWord(slText.Objects[hIndex]).Font := TFont.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Style := Cnv.Font.Style;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Color := Cnv.Font.Color;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Size  := Cnv.Font.Size;

          sText := TSLBBCodeWord(slText.Objects[hIndex]).Text;
          DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), dwtRcalc, DT_CALCRECT + DT_NOPREFIX);
          TSLBBCodeWord(slText.Objects[hIndex]).TextWidth := dwtRcalc.Right;
          TSLBBCodeWord(slText.Objects[hIndex]).TextHeight := dwtRcalc.Bottom;
        end
        else
        begin

          dwtRcalc.Top    := 0;
          dwtRcalc.Bottom := 0;
          dwtRcalc.Left   := 0;
          dwtRcalc.Right  := 0;

          slText.Add('');
          hIndex:= slText.Count - 1;
          slText.Objects[hIndex] := TSLBBCodeWord.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Text := Copy(RemText,1,dwtPos);
          TSLBBCodeWord(slText.Objects[hIndex]).Font := TFont.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Style := Cnv.Font.Style;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Color := Cnv.Font.Color;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Size  := Cnv.Font.Size;

          sText := TSLBBCodeWord(slText.Objects[hIndex]).Text;
          DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), dwtRcalc, DT_CALCRECT + DT_NOPREFIX);
          TSLBBCodeWord(slText.Objects[hIndex]).TextWidth := dwtRcalc.Right;
          TSLBBCodeWord(slText.Objects[hIndex]).TextHeight := dwtRcalc.Bottom;

          RemText := Copy(RemText,dwtPos + 1);
          Goto 1;
        end;


(*
        dwtI:=1;
        while ( dwtI<= Length(dwtText) ) do
        begin
                dwtText

          Inc(dwtI);
        end;


        slWords.Delimiter := ' ';
        slWords.DelimitedText := UTF8Encode(dwtText);

        for dwtI := 0 to slWords.Count - 1 do
        begin
          dwtRcalc.Top    := 0;
          dwtRcalc.Bottom := 0;
          dwtRcalc.Left   := 0;
          dwtRcalc.Right  := 0;

          slText.Add('');
          hIndex:= slText.Count - 1;
          slText.Objects[hIndex] := TSLBBCodeWord.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Text := UTF8Decode(slWords.Strings[dwtI]) + ' ';
          TSLBBCodeWord(slText.Objects[hIndex]).Font := TFont.Create;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Style := Cnv.Font.Style;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Color := Cnv.Font.Color;
          TSLBBCodeWord(slText.Objects[hIndex]).Font.Size  := Cnv.Font.Size;

          sText := TSLBBCodeWord(slText.Objects[hIndex]).Text;
          DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), dwtRcalc, DT_CALCRECT + DT_NOPREFIX);
          TSLBBCodeWord(slText.Objects[hIndex]).TextWidth := dwtRcalc.Right;
          TSLBBCodeWord(slText.Objects[hIndex]).TextHeight := dwtRcalc.Bottom;
        end;         *)
      end;

  {    slWords.Free;       }
    end;


begin
  DefFontColor := Cnv.Font.Color;
  DefFontSize  := Cnv.Font.Size;

  wStr := Text;
  R := Rect;

  slText := TStringList.Create;
  slText.Clear;

  iPos := 1;

  wStr := StringReplace(wStr, #13+#10, '', [rfReplaceAll]);
  wStr := StringReplace(wStr, #13, '', [rfReplaceAll]);
  wStr := StringReplace(wStr, #10, '', [rfReplaceAll]);

  Retr1:

  sCommand := FoundStr(wStr, '[', ']', iPos, iPosN, iFS1, iFS2);
  sCommand := AnsiUpperCase(sCommand);
  if sCommand='BR' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    DrawWordText('[BR]', R);

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='B' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style + [fsBold];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/B' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style - [fsBold];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='I' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style + [fsItalic];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/I' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style - [fsItalic];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='U' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style + [fsUnderline];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/U' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style - [fsUnderline];    

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='S' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style + [fsStrikeOut];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/S' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Style := Cnv.Font.Style - [fsStrikeOut];

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end

  else if Copy(sCommand,1,6)='COLOR=' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

//    Cnv.Font.Color := RGB(HexToInt('$'+Copy(sCommand,8,2)),HexToInt('$'+Copy(sCommand,11,2)),HexToInt('$'+Copy(sCommand,13,2))); //HexToInt('$'+Copy(sCommand,8,6));
    Cnv.Font.Color := TextToColor(Copy(sCommand,7), qipcolors);

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/COLOR' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Color := DefFontColor;

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end

  else if Copy(sCommand,1,5)='SIZE=' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    iCN := ConvStrToInt(Copy(sCommand,6));

//    if iCN=0 then iCN := 8;

    Cnv.Font.Size := iCN;

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end
  else if sCommand='/SIZE' then
  begin
    sText := Copy(wStr,iPos,iPosN-iPos-2);
    DrawWordText(sText, R);

    Cnv.Font.Size := DefFontSize;

    iPosN := iPosN + Length(sCommand);
    iPos := iPosN;
  end

  else
  begin
    if sCommand='' then //bez prikazu
    begin
      sText := Copy(wStr,iPos);
      DrawWordText(sText, R);

      Goto Ex1;
    end
    else     // chybny prikaz
    begin
      iPosN := iPosN + length(sCommand);

      sText := Copy(wStr,iPos,iPosN-iPos);
      DrawWordText(sText, R);

      iPos := iPosN;
    end;
  end;

  Goto Retr1;

  Ex1:

  RD := Rect;
  MaxHeight := 0;
  for i := 0 to slText.Count - 1 do
  begin
    Cnv.Font.Style := TSLBBCodeWord(slText.Objects[i]).Font.Style;
    Cnv.Font.Color := TSLBBCodeWord(slText.Objects[i]).Font.Color;
    Cnv.Font.Size  := TSLBBCodeWord(slText.Objects[i]).Font.Size;

    if MaxHeight < TSLBBCodeWord(slText.Objects[i]).TextHeight then
      MaxHeight := TSLBBCodeWord(slText.Objects[i]).TextHeight;

    if slText.Strings[i] = '[BR]' then
    begin
      RD.Left := Rect.Left;
      if MaxHeight=0 then
        RD.Top := RD.Top + 13
      else
        RD.Top := RD.Top + MaxHeight;
      MaxHeight := 0;
    end;
    
    if WordBreak = True then
    begin
      if RD.Left + TSLBBCodeWord(slText.Objects[i]).TextWidth > Rect.Right - Rect.Left then
      begin
        RD.Left := Rect.Left;
        if MaxHeight=0 then
          RD.Top := RD.Top + 13
        else
          RD.Top := RD.Top + MaxHeight;
        MaxHeight := 0;
      end;
    end;

    sText := TSLBBCodeWord(slText.Objects[i]).Text;
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RD,  DT_NOPREFIX);

    RD.Left := RD.Left + TSLBBCodeWord(slText.Objects[i]).TextWidth;

  end;

  slText.Free;

end;

end.
