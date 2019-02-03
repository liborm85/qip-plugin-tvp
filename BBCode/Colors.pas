unit Colors;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  { ClrColors }
  TClrColors = class
  public
    Name    : WideString;
    Command : WideString;


  end;

  TfrmColors = class(TForm)
    lstColors: TListBox;
    ColorDialog1: TColorDialog;
    pnlButtons: TPanel;
    btnApply: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lstColorsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstColorsDblClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmColors: TfrmColors;
  ClrColors : TStringList;
  CustomColor: TColor;

implementation

uses uColors, BBCode, u_common, General, u_lang_ids;

{$R *.dfm}

procedure TfrmColors.btnApplyClick(Sender: TObject);
var Color: Longint;
    R,G,B : Byte;
begin
  if lstColors.ItemIndex = 0 then
  begin
    Color := CustomColor;

    r     := Color;
    g     := Color shr 8;
    b     := Color shr 16;

    Colors_Color := '#' + IntToHex(R,2)+IntToHex(G,2)+IntToHex(B,2);
  end
  else
    Colors_Color := TClrColors(ClrColors.Objects[lstColors.ItemIndex]).Command;

  Close;
end;

procedure TfrmColors.FormClose(Sender: TObject; var Action: TCloseAction);
begin


  ColorsIsShow := False;
end;

procedure AddColor(Name : WideString; Command: WideString; var stringlist: TStringList);
var hIndex: Integer;
begin
  stringlist.Add('COLOR');
  hIndex:= stringlist.Count - 1;
  stringlist.Objects[hIndex] := TClrColors.Create;
  if Name='' then
    TClrColors(stringlist.Objects[hIndex]).Name    := Command
  else
    TClrColors(stringlist.Objects[hIndex]).Name    := Name;
    
  TClrColors(stringlist.Objects[hIndex]).Command := Command;
//  TClrColors(stringlist.Objects[hIndex]).Value   := Value;
end;

procedure TfrmColors.FormShow(Sender: TObject);
var i: Integer;
begin
  ColorsIsShow := True;

//  Icon := PluginSkin.Color.Icon;

  Caption := QIPPlugin.GetLang(LI_COLORS);
  btnApply.Caption := QIPPlugin.GetLang(LI_APPLY);

  ClrColors := TStringList.Create;
  ClrColors.Clear;

  AddColor('','!RGB!',ClrColors);

  AddColor(QIPPlugin.GetLang(144),'AccBtnText', ClrColors);
  AddColor(QIPPlugin.GetLang(145),'AccBtn', ClrColors);
  AddColor(QIPPlugin.GetLang(146),'AccBtnGrad', ClrColors);
  AddColor(QIPPlugin.GetLang(147),'AccBtnFrameL', ClrColors);
  AddColor(QIPPlugin.GetLang(148),'AccBtnFrameD', ClrColors);
  AddColor(QIPPlugin.GetLang(149),'Divider', ClrColors);
  AddColor(QIPPlugin.GetLang(150),'Group', ClrColors);
  AddColor(QIPPlugin.GetLang(151),'Counter', ClrColors);
  AddColor(QIPPlugin.GetLang(152),'Online', ClrColors);
  AddColor(QIPPlugin.GetLang(153),'Offline', ClrColors);
  AddColor(QIPPlugin.GetLang(154),'NotInList', ClrColors);
  AddColor(QIPPlugin.GetLang(155),'OffMsg', ClrColors);
  AddColor(QIPPlugin.GetLang(156),'Focus', ClrColors);
  AddColor(QIPPlugin.GetLang(157),'FocusGrad', ClrColors);
  AddColor(QIPPlugin.GetLang(158),'FocusFrame', ClrColors);
  AddColor(QIPPlugin.GetLang(269),'Hint', ClrColors);
  AddColor(QIPPlugin.GetLang(270),'HintGrad', ClrColors);
  AddColor(QIPPlugin.GetLang(271),'HintFrame', ClrColors);
  AddColor(QIPPlugin.GetLang(159),'IncEvents', ClrColors);
  AddColor(QIPPlugin.GetLang(160),'OutEvents', ClrColors);
  AddColor(QIPPlugin.GetLang(161),'FadeTitle', ClrColors);
  AddColor(QIPPlugin.GetLang(162),'FadeText', ClrColors);
  AddColor(QIPPlugin.GetLang(229),'TabBorder', ClrColors);
  AddColor(QIPPlugin.GetLang(230),'TabBorderDrk', ClrColors);
  AddColor(QIPPlugin.GetLang(231),'TabInactive', ClrColors);
  AddColor(QIPPlugin.GetLang(232),'TabInactGrad', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabActive', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabActGrad', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabActLiTop', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabActLight', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabFontInact', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'TabFontAct', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatTopic', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatTime', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatOwnNick', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatContNick', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatOwnText', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatContText', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatJoined', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatLeft', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatDiscon', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatNotice', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatHighLi', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatInfoText', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatActText', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatKickText', ClrColors);
  AddColor(QIPPlugin.GetLang(0),'ChatModeText', ClrColors);
{    BgPicClOff     : Boolean;
    BgPicMsgOff    : Boolean;
    BgPicChatOff   : Boolean;
    BgClColor      : integer;
    BgMsgColor     : integer;
    BgChatColor    : integer;
}

  i:=0;
  while ( i<= ClrColors.Count - 1 ) do
  begin
    Application.ProcessMessages;

    lstColors.Items.Add(TClrColors(ClrColors.Objects[i]).Name);

    if AnsiUpperCase(TClrColors(ClrColors.Objects[i]).Command) = AnsiUpperCase(Colors_Color) then
      lstColors.ItemIndex := i;

//  ColorListBox1.Items.Add(TClrColors(ClrColors.Objects[i]).Name);

    Inc(i);
  end;

  if Copy(Colors_Color,1,1)='#' then
  begin
    lstColors.ItemIndex := 0;
    CustomColor := TextToColor(Colors_Color,QIP_Colors);
  end;

  if lstColors.ItemIndex = -1 then
    lstColors.ItemIndex := 0;




end;

procedure TfrmColors.lstColorsDblClick(Sender: TObject);
begin
  if lstColors.ItemIndex = 0 then
  begin
    ColorDialog1.Color := CustomColor;

    if ColorDialog1.Execute() then
    begin
      CustomColor := ColorDialog1.Color;
    end;

  end;
end;

procedure TfrmColors.lstColorsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var R1: TRect;
    wStr : WideString;

begin
 { with lstColors.Canvas do
  begin     }
{    Font.Color := clBlack;
    TextOut(Rect.Left + 1, Rect.Top + 1, lstColors.Items[Index]);}

  lstColors.Canvas.Brush.Color := clWhite;

  lstColors.Canvas.FillRect(Rect);
  if TClrColors(ClrColors.Objects[Index]).Command = '!RGB!' then
  begin
    lstColors.Canvas.Brush.Color := CustomColor;
    wStr := '[b][i]Custom...[/i][/b]';
  end
  else
  begin
    lstColors.Canvas.Brush.Color := TextToColor(TClrColors(ClrColors.Objects[Index]).Command, QIP_Colors);//clRed;
    wStr := '[b]'+TClrColors(ClrColors.Objects[Index]).Name+'[/b][br]'+TClrColors(ClrColors.Objects[Index]).Command;
  end;


  R1.Left := Rect.Left + 5;
  R1.Right := Rect.Left + 5 + 20;
  R1.Top := Rect.Top + 5;
  R1.Bottom := Rect.Top + 5 + 15;

  lstColors.Canvas.FillRect(R1);

  lstColors.Canvas.Brush.Color := clWhite;

  lstColors.Canvas.Font.Color := clBlack;





  R1.Left := Rect.Left + 30;
  R1.Right := Rect.Right;
  R1.Top := Rect.Top + 5;
  R1.Bottom := Rect.Bottom;

//  R1 := Rect(R1.Left + 24, R1.Top + 1 , R1.Right, R1.Bottom);

  BBCodeDrawText(lstColors.Canvas, wStr, R1, False, QIP_Colors);
{  end;   }



//    Control.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold];

end;

end.
