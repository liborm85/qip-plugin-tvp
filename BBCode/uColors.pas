unit uColors;

interface
uses
  SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls,
  u_common, Colors;

  function TextToColor(sColor: WideString; qipcolors: TQipColors): TColor;
  procedure ShowColors(var sColor: WideString);

var
  FColors : TfrmColors;
  ColorsIsShow : Boolean;
  Colors_Color : WideString;

implementation

uses General, BBCode;

procedure ShowColors(var sColor: WideString);
begin
  if ColorsIsShow = False then
  begin
    Colors_Color := sColor;
    FColors := TfrmColors.Create(nil);
    FColors.ShowModal;
    sColor := Colors_Color;

    try
      if Assigned(FColors) then FreeAndNil(FColors);
    finally

    end;
  end;
end;

function TextToColor(sColor: WideString; qipcolors: TQipColors): TColor;
begin

  sColor := AnsiUpperCase(sColor);

//  cl
  if Copy(sColor,1,1)='#' then
  begin
    //#000000
    Result := RGB(HexToInt('$'+Copy(sColor,2,2)),HexToInt('$'+Copy(sColor,4,2)),HexToInt('$'+Copy(sColor,6,2)));
  end
  else if sColor = AnsiUpperCase('AccBtnText') then
  begin
    Result := qipcolors.AccBtnText;
  end
  else if sColor = AnsiUpperCase('AccBtn') then
  begin
    Result := qipcolors.AccBtn;
  end
  else if sColor = AnsiUpperCase('AccBtnGrad') then
  begin
    Result := qipcolors.AccBtnGrad;
  end
  else if sColor = AnsiUpperCase('AccBtnFrameL') then
  begin
    Result := qipcolors.AccBtnFrameL;
  end
  else if sColor = AnsiUpperCase('AccBtnFrameD') then
  begin
    Result := qipcolors.AccBtnFrameD;
  end
  else if sColor = AnsiUpperCase('Divider') then
  begin
    Result := qipcolors.Divider;
  end
  else if sColor = AnsiUpperCase('Group') then
  begin
    Result := qipcolors.Group;
  end
  else if sColor = AnsiUpperCase('Counter') then
  begin
    Result := qipcolors.Counter;
  end
  else if sColor = AnsiUpperCase('Online') then
  begin
    Result := qipcolors.Online;
  end
  else if sColor = AnsiUpperCase('Offline') then
  begin
    Result := qipcolors.Offline;
  end
  else if sColor = AnsiUpperCase('NotInList') then
  begin
    Result := qipcolors.NotInList;
  end
  else if sColor = AnsiUpperCase('OffMsg') then
  begin
    Result := qipcolors.OffMsg;
  end
  else if sColor = AnsiUpperCase('Focus') then
  begin
    Result := qipcolors.Focus;
  end
  else if sColor = AnsiUpperCase('FocusGrad') then
  begin
    Result := qipcolors.FocusGrad;
  end
  else if sColor = AnsiUpperCase('FocusFrame') then
  begin
    Result := qipcolors.FocusFrame;
  end
  else if sColor = AnsiUpperCase('Hint') then
  begin
    Result := qipcolors.Hint;
  end
  else if sColor = AnsiUpperCase('HintGrad') then
  begin
    Result := qipcolors.HintGrad;
  end
  else if sColor = AnsiUpperCase('HintFrame') then
  begin
    Result := qipcolors.HintFrame;
  end
  else if sColor = AnsiUpperCase('IncEvents') then
  begin
    Result := qipcolors.IncEvents;
  end
  else if sColor = AnsiUpperCase('OutEvents') then
  begin
    Result := qipcolors.OutEvents;
  end
  else if sColor = AnsiUpperCase('FadeTitle') then
  begin
    Result := qipcolors.FadeTitle;
  end
  else if sColor = AnsiUpperCase('FadeText') then
  begin
    Result := qipcolors.FadeText;
  end
  else if sColor = AnsiUpperCase('TabBorder') then
  begin
    Result := qipcolors.TabBorder;
  end
  else if sColor = AnsiUpperCase('TabBorderDrk') then
  begin
    Result := qipcolors.TabBorderDrk;
  end
  else if sColor = AnsiUpperCase('TabInactive') then
  begin
    Result := qipcolors.TabInactive;
  end
  else if sColor = AnsiUpperCase('TabInactGrad') then
  begin
    Result := qipcolors.TabInactGrad;
  end
  else if sColor = AnsiUpperCase('TabActive') then
  begin
    Result := qipcolors.TabActive;
  end
  else if sColor = AnsiUpperCase('TabActGrad') then
  begin
    Result := qipcolors.TabActGrad;
  end
  else if sColor = AnsiUpperCase('TabActLiTop') then
  begin
    Result := qipcolors.TabActLiTop;
  end
  else if sColor = AnsiUpperCase('TabActLight') then
  begin
    Result := qipcolors.TabActLight;
  end
  else if sColor = AnsiUpperCase('TabFontInact') then
  begin
    Result := qipcolors.TabFontInact;
  end
  else if sColor = AnsiUpperCase('TabFontAct') then
  begin
    Result := qipcolors.TabFontAct;
  end
  else if sColor = AnsiUpperCase('ChatTopic') then
  begin
    Result := qipcolors.ChatTopic;
  end
  else if sColor = AnsiUpperCase('ChatTime') then
  begin
    Result := qipcolors.ChatTime;
  end
  else if sColor = AnsiUpperCase('ChatOwnNick') then
  begin
    Result := qipcolors.ChatOwnNick;
  end
  else if sColor = AnsiUpperCase('ChatContNick') then
  begin
    Result := qipcolors.ChatContNick;
  end
  else if sColor = AnsiUpperCase('ChatOwnText') then
  begin
    Result := qipcolors.ChatOwnText;
  end
  else if sColor = AnsiUpperCase('ChatContText') then
  begin
    Result := qipcolors.ChatContText;
  end
  else if sColor = AnsiUpperCase('ChatJoined') then
  begin
    Result := qipcolors.ChatJoined;
  end
  else if sColor = AnsiUpperCase('ChatLeft') then
  begin
    Result := qipcolors.ChatLeft;
  end
  else if sColor = AnsiUpperCase('ChatDiscon') then
  begin
    Result := qipcolors.ChatDiscon;
  end
  else if sColor = AnsiUpperCase('ChatNotice') then
  begin
    Result := qipcolors.ChatNotice;
  end
  else if sColor = AnsiUpperCase('ChatHighLi') then
  begin
    Result := qipcolors.ChatHighLi;
  end
  else if sColor = AnsiUpperCase('ChatInfoText') then
  begin
    Result := qipcolors.ChatInfoText;
  end
  else if sColor = AnsiUpperCase('ChatActText') then
  begin
    Result := qipcolors.ChatActText;
  end
  else if sColor = AnsiUpperCase('ChatKickText') then
  begin
    Result := qipcolors.ChatKickText;
  end
  else if sColor = AnsiUpperCase('ChatModeText') then
  begin
    Result := qipcolors.ChatModeText;
  end
  else
  begin
    Result := clBlack;
  end;
   ;

{   A take: (pozadi okna, bude barva nebo obrazek)

    BgPicClOff     : Boolean;
    BgPicMsgOff    : Boolean;
    BgPicChatOff   : Boolean;
    BgClColor      : integer;
    BgMsgColor     : integer;
    BgChatColor    : integer;
}
end;

end.
