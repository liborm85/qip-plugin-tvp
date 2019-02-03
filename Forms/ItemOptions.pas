unit ItemOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, Buttons, ExtCtrls, ComCtrls;

type
  TfrmItemOptions = class(TForm)
    edtName: TEdit;
    vdtData: TVirtualDrawTree;
    edtItemID: TEdit;
    lblItemID: TLabel;
    edtItemName: TEdit;
    lblItemName: TLabel;
    btnApply: TBitBtn;
    btnSave: TBitBtn;
    chkItemShowInfo: TCheckBox;
    pnlTop: TPanel;
    pnlMiddle: TPanel;
    pnlBottom: TPanel;
    lblName: TLabel;
    lblItemWidth: TLabel;
    edtItemWidth: TEdit;
    udItemWidth: TUpDown;
    lblItemWidthUnit: TLabel;
    pgcItem: TPageControl;
    tsGeneral: TTabSheet;
    tsWindow: TTabSheet;
    Hint: TTabSheet;
    lblCountNextPrograms: TLabel;
    edtCountNextPrograms: TEdit;
    udCountNextPrograms: TUpDown;
    lblCountNextProgramsUnit: TLabel;
    pnlItem: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vdtDataDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure vdtDataChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnApplyClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure udItemWidthClick(Sender: TObject; Button: TUDBtnType);
    procedure udCountNextProgramsClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmItemOptions: TfrmItemOptions;

  Items_Data : TStringList;

  idxNodeRow: Integer;

implementation

uses General, Convs, uColors, TVpDLL, XMLFiles, u_lang_ids, uLNG, uOptions, TextSearch;

{$R *.dfm}

procedure TfrmItemOptions.btnApplyClick(Sender: TObject);

begin

  //TCL(Items_Data.Objects[idxNodeRow]).ID := edtItemID.Text    ID NELZE ZMENIT!!!
  TCL(Items_Data.Objects[idxNodeRow]).Name := edtItemName.Text;

  if chkItemShowInfo.Checked = True then
    TCL(Items_Data.Objects[idxNodeRow]).Conf := '[Info]="True;";'
  else
    TCL(Items_Data.Objects[idxNodeRow]).Conf := '[Info]="False;";';

  TCL(Items_Data.Objects[idxNodeRow]).Width := udItemWidth.Position;

  TCL(Items_Data.Objects[idxNodeRow]).Conf := TCL(Items_Data.Objects[idxNodeRow]).Conf + '[HintCountNextPrograms]="'+IntToStr(udCountNextPrograms.Position)+'";';


  vdtData.Refresh;


end;

procedure TfrmItemOptions.btnSaveClick(Sender: TObject);
var
  idxItem, idx: Integer;
begin

  if CL.Strings[FItemOptions_Index]='CL' then
  begin
    btnApplyClick(Sender);
  end;

  if ((CL.Strings[FItemOptions_Index]='CLGuide') and (edtName.Text = '')) then
  begin
    ShowMessage('Je nutno zadat název pøehledu');
    edtName.SetFocus;
    Exit;
  end;



  {if CL.Strings[FItemOptions_Index]='CL' then
    TCL(CL.Objects[FItemOptions_Index]).Name := edtName.Text
  else} if CL.Strings[FItemOptions_Index]='CLGuide' then
    TCLGuide(CL.Objects[FItemOptions_Index]).Name := edtName.Text;


  if CL.Strings[FItemOptions_Index]='CL' then
  begin
    idxItem := Items_Data.Count - 1;

    TCL(CL.Objects[FItemOptions_Index]).ID    := TCL(Items_Data.Objects[idxItem]).ID;
    TCL(CL.Objects[FItemOptions_Index]).Name  := TCL(Items_Data.Objects[idxItem]).Name;
    TCL(CL.Objects[FItemOptions_Index]).Width := TCL(Items_Data.Objects[idxItem]).Width;
    TCL(CL.Objects[FItemOptions_Index]).Conf  := TCL(Items_Data.Objects[idxItem]).Conf;


  end
  else if CL.Strings[FItemOptions_Index]='CLGuide' then
  begin
    idx:=0;
    while ( idx<= TCLGuide(CL.Objects[FItemOptions_Index]).Items.Count - 1 ) do
    begin
      Application.ProcessMessages;

      idxItem := idx;
      TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).ID     := TCL(Items_Data.Objects[idxItem]).ID;
      TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Name   := TCL(Items_Data.Objects[idxItem]).Name;
      TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Width  := TCL(Items_Data.Objects[idxItem]).Width;
      TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Conf   := TCL(Items_Data.Objects[idxItem]).Conf;

      Inc(idx);
    end;
  end;

  SaveCL;

  if CL.Strings[FItemOptions_Index]='CL' then
    QIPPlugin.RedrawSpecContact( TCL(CL.Objects[FItemOptions_Index]).UniqID.UniqID )
  else if CL.Strings[FItemOptions_Index]='CLGuide' then
    QIPPlugin.RedrawSpecContact( TCLGuide(CL.Objects[FItemOptions_Index]).UniqID.UniqID );

  Close;
end;

procedure TfrmItemOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin


  ItemOptionsIsShow := False;
end;

procedure TfrmItemOptions.FormShow(Sender: TObject);
var
  idx : Integer;
  idxItem: Integer;
begin
  ItemOptionsIsShow := True;

  Icon := PluginSkin.Edit.Icon;


  Caption := LNG('MENU ContactMenu', 'Edit', 'Edit');

  tsGeneral.Caption := QIPPlugin.GetLang(LI_GENERAL);
  tsWindow.Caption  := QIPPlugin.GetLang(LI_CL_WINDOW);
//tsHint.Caption    := QIPPlugin.GetLang(LI_GENERAL);

  btnSave.Caption       := QIPPlugin.GetLang(LI_SAVE);
  lblName.Caption       := QIPPlugin.GetLang(LI_NAME) + ':';
  btnApply.Caption      := QIPPlugin.GetLang(LI_APPLY);
  lblItemName.Caption   := QIPPlugin.GetLang(LI_NAME) + ':';
  lblItemID.Caption     := LNG('TEXTS', 'ID', 'ID') + ':';

  chkItemShowInfo.Caption := LNG('FORM ItemOptions', 'ShowInfoAboutProgramme', 'Show informations about programme');


  if CL.Strings[FItemOptions_Index]='CL' then
    edtName.Text := TCL(CL.Objects[FItemOptions_Index]).Name
  else if CL.Strings[FItemOptions_Index]='CLGuide' then
    edtName.Text := TCLGuide(CL.Objects[FItemOptions_Index]).Name;

  Items_Data := TStringList.Create;

  Items_Data.Clear;
  vdtData.Clear;
  vdtData.RootNodeCount := 0;
  vdtData.Update;

  if CL.Strings[FItemOptions_Index]='CL' then
  begin
    pnlTop.Visible := False;
    pnlBottom.Visible := False;
    Height := Height - pnlTop.Height;
    pnlBottom.Visible := True;

    edtName.Visible := False;
    vdtData.Visible := False;
    pnlItem.Left := vdtData.Left;

    Width := vdtData.Left + vdtData.width + vdtData.Left;

    btnApply.Visible := False;

    btnSave.Left := round((Width / 2) - (btnSave.Width / 2));


    Items_Data.Add('ITEM');
    idxItem := Items_Data.Count - 1;
    Items_Data.Objects[idxItem] := TCL.Create;
    TCL(Items_Data.Objects[idxItem]).ID     := TCL(CL.Objects[FItemOptions_Index]).ID;
    TCL(Items_Data.Objects[idxItem]).Name   := TCL(CL.Objects[FItemOptions_Index]).Name;
    TCL(Items_Data.Objects[idxItem]).Width  := TCL(CL.Objects[FItemOptions_Index]).Width;
    TCL(Items_Data.Objects[idxItem]).Conf   := TCL(CL.Objects[FItemOptions_Index]).Conf;

  end
  else if CL.Strings[FItemOptions_Index]='CLGuide' then
  begin
    pnlTop.Visible := True;
    pnlBottom.Visible := True;

    edtName.Visible := True;
    vdtData.Visible := True;

    btnApply.Visible := True;

    btnSave.Left := round((Width / 2) - (btnSave.Width / 2));

    idx:=0;
    while ( idx<= TCLGuide(CL.Objects[FItemOptions_Index]).Items.Count - 1 ) do
    begin
      Application.ProcessMessages;


      Items_Data.Add('ITEM');
      idxItem := Items_Data.Count - 1;
      Items_Data.Objects[idxItem] := TCL.Create;
      TCL(Items_Data.Objects[idxItem]).ID     := TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).ID;
      TCL(Items_Data.Objects[idxItem]).Name   := TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Name;
      TCL(Items_Data.Objects[idxItem]).Width  := TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Width;
      TCL(Items_Data.Objects[idxItem]).Conf   := TCL(TCLGuide(CL.Objects[FItemOptions_Index]).Items.Objects[idx]).Conf;

      Inc(idx);
    end;

  end;


  vdtData.DefaultNodeHeight := 5*13;
  vdtData.RootNodeCount := Items_Data.Count;
  vdtData.Update;

  if vdtData.RootNodeCount > 0 then
  begin
    vdtData.Selected[vdtData.GetFirst] := True;
    vdtData.FocusedNode := vdtData.GetFirst;
  end;


  pgcItem.ActivePageIndex := 0;


{  if vdtData.RootNodeCount > 0 then
  begin
    vdtData.in
  end;
}

//             showmessage(inttostr(Items_Data.Count));

end;

procedure TfrmItemOptions.udCountNextProgramsClick(Sender: TObject;
  Button: TUDBtnType);
begin
  edtCountNextPrograms.Text := IntToStr( udCountNextPrograms.Position );
end;

procedure TfrmItemOptions.udItemWidthClick(Sender: TObject;
  Button: TUDBtnType);
begin
  edtItemWidth.Text := IntToStr( udItemWidth.Position );
end;

procedure TfrmItemOptions.vdtDataChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  slConf : TStringList;
  sInfo : WideString;
  IdxOf : Integer;
begin

  if Node <> nil then
  begin
    idxNodeRow := Node.Index;

    edtItemID.Text   := TCL(Items_Data.Objects[idxNodeRow]).ID;
    edtItemName.Text := TCL(Items_Data.Objects[idxNodeRow]).Name;


    if TCL(Items_Data.Objects[idxNodeRow]).Width = 0 then
      udItemWidth.Position := 200
    else
      udItemWidth.Position := TCL(Items_Data.Objects[idxNodeRow]).Width;

    edtItemWidth.Text     := IntToStr(udItemWidth.Position);


    slConf := TStringList.Create;
    slConf.Clear;
    LoadOptions(TCL(Items_Data.Objects[idxNodeRow]).Conf,slConf);


    sInfo  := '';

    IdxOf := slConf.IndexOf('Info');
    if IdxOf <> -1 then
      sInfo := TItemOptions(slConf.Objects[IdxOf]).dataWideString;


    if StrPosE(sInfo,'False;',1,False) <> 0 then
      chkItemShowInfo.Checked := False
    else
      chkItemShowInfo.Checked := True;


    IdxOf := slConf.IndexOf('HintCountNextPrograms');
    if IdxOf <> -1 then
      sInfo := TItemOptions(slConf.Objects[IdxOf]).dataWideString
    else
      sInfo := '3';

    udCountNextPrograms.Position := ConvStrToInt(sInfo);
    edtCountNextPrograms.Text     := IntToStr(udCountNextPrograms.Position);

  end;

end;

procedure TfrmItemOptions.vdtDataDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);

var
  R, RectD : TRect;
  idxRow : Integer;
  sText : WideString;

begin



  with Sender as TVirtualDrawTree, PaintInfo do
  begin

    SetBkMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);

    {    Dec(R.Right);
    Dec(R.Bottom);  }

    //Malovat od zacatku (ne jako TreeView (spojovaci cary))
    if (Column=0) OR (Column=-1) then
      R.Left  := 0
    else
      R.Left  := R.Left - 8;
    //   a az do konce
    R.Right := R.Right + 4;

    idxRow := Node.Index;

    Canvas.Font.Color := clWindowText;

    if Odd(idxRow) then
      Canvas.Brush.Color := TextToColor(clLine1, QIP_Colors)
    else
      Canvas.Brush.Color := TextToColor(clLine2, QIP_Colors);

    Canvas.FillRect(R);

    if idxRow > Items_Data.Count - 1 then
      Exit;

    Canvas.Font.style := [fsBold];
    RectD.Left   := R.Left + 5;
    RectD.Right  := R.Right - 5 ;
    RectD.Top    := R.Top + 5;
    RectD.Bottom := R.Bottom;

    sText :=  TCL(Items_Data.Objects[idxRow]).Name + '   ' + TCL(Items_Data.Objects[idxRow]).ID;


    Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectD, DT_SINGLELINE + DT_NOPREFIX{, False});


    // Malovat focus
    if (Column = FocusedColumn) and (Node = FocusedNode) then
    begin
      DrawFocusRect(Canvas.Handle, R);
    end;


  end;
end;

end.
