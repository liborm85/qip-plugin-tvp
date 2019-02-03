unit CLItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, StdCtrls, Buttons, CommCtrl, ComCtrls, ImgList, ToolWin;

type
  TfrmCLItems = class(TForm)
    vdtData: TVirtualDrawTree;
    btnSave: TBitBtn;
    tbButtons: TToolBar;
    ilButtons: TImageList;
    tbtnItemAdd: TToolButton;
    tbtnItemRemove: TToolButton;
    ToolButton3: TToolButton;
    tbtnItemUp: TToolButton;
    tbtnItemDown: TToolButton;
    ToolButton1: TToolButton;
    tbtnItemEdit: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vdtDataDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure tbtnItemRemoveClick(Sender: TObject);
    procedure vdtDataChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnItemUpClick(Sender: TObject);
    procedure tbtnItemDownClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure tbtnItemAddClick(Sender: TObject);
    procedure tbtnItemEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ItemRefresh;
  end;

var
  frmCLItems: TfrmCLItems;

  Items_Data : TStringList;

  idxNodeRow : Int64;
  nodeNodeRow : PVirtualNode;

implementation

uses General, uLNG, XMLFiles, u_lang_ids, BBCode, uColors;

{$R *.dfm}

procedure TfrmCLItems.ItemRefresh;
begin
  vdtData.DefaultNodeHeight := 5*13;
  vdtData.RootNodeCount := CL.Count;
  vdtData.Update;

  tbtnItemEdit.Enabled := False;
  tbtnItemRemove.Enabled := False;
  tbtnItemUp.Enabled := False;
  tbtnItemDown.Enabled := False;

  if vdtData.RootNodeCount > 0 then
  begin
    vdtData.Selected[vdtData.GetFirst] := True;
    vdtData.FocusedNode := vdtData.GetFirst;
  end
end;

procedure TfrmCLItems.btnSaveClick(Sender: TObject);
begin
  SaveCL;

  Close;
end;

procedure TfrmCLItems.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CLItemsIsShow := False;
end;

procedure TfrmCLItems.FormShow(Sender: TObject);

begin
  CLItemsIsShow := True;

  Icon := PluginSkin.EditItems.Icon;


  Caption := LNG('MENU ContactMenu', 'EditStations', 'Edit stations');

  btnSave.Caption     := QIPPlugin.GetLang(LI_SAVE);


  tbtnItemEdit.Hint   := LNG('MENU ContactMenu', 'Edit', 'Edit');

  tbtnItemAdd.Hint    := QIPPlugin.GetLang(LI_ADD);
  tbtnItemRemove.Hint := QIPPlugin.GetLang(LI_DELETE);

  tbtnItemUp.Hint     := QIPPlugin.GetLang(LI_HST_UP);
  tbtnItemDown.Hint   := QIPPlugin.GetLang(LI_HST_DOWN);


  //32 bit support - transparent atd....
  ilButtons.Handle := ImageList_Create(ilButtons.Width, ilButtons.Height, ILC_COLOR32 or ILC_MASK, ilButtons.AllocBy, ilButtons.AllocBy);

  ilButtons.AddIcon(PluginSkin.Edit.Icon);
  ilButtons.AddIcon(PluginSkin.ItemAdd.Icon);
  ilButtons.AddIcon(PluginSkin.ItemRemove.Icon);
  ilButtons.AddIcon(PluginSkin.ItemUp.Icon);
  ilButtons.AddIcon(PluginSkin.ItemDown.Icon);


  ItemRefresh;


end;

procedure TfrmCLItems.tbtnItemAddClick(Sender: TObject);
begin
  OpenSearch;
end;

procedure TfrmCLItems.tbtnItemDownClick(Sender: TObject);
var
  idx : Int64;
  VirtualNode: PVirtualNode;
begin
  idx := idxNodeRow;

  CL.Exchange(idx, idx + 1);

  VirtualNode := vdtData.GetNext(nodeNodeRow);

  vdtData.Selected[VirtualNode] := True;
  vdtData.FocusedNode := VirtualNode;

  vdtData.Refresh;
end;

procedure TfrmCLItems.tbtnItemEditClick(Sender: TObject);
begin
  OpenItemOptions(idxNodeRow);
end;

procedure TfrmCLItems.tbtnItemRemoveClick(Sender: TObject);
begin
  OpenRemoveContact(idxNodeRow);

  FormShow(Sender);
end;

procedure TfrmCLItems.tbtnItemUpClick(Sender: TObject);
var
  idx : Int64;
  VirtualNode: PVirtualNode;
begin
  idx := idxNodeRow;

  CL.Exchange(idx, idx - 1);


  VirtualNode := vdtData.GetPrevious(nodeNodeRow);

  vdtData.Selected[VirtualNode] := True;
  vdtData.FocusedNode := VirtualNode;


  vdtData.Refresh;
end;

procedure TfrmCLItems.vdtDataChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin

  if Node <> nil then
  begin
    idxNodeRow := Node.Index;
    nodeNodeRow := Node;


    tbtnItemEdit.Enabled   := True;
    tbtnItemAdd.Enabled    := True;
    tbtnItemRemove.Enabled := True;



    tbtnItemUp.Enabled     := True;
    tbtnItemDown.Enabled   := True;

    if idxNodeRow = 0 then
      tbtnItemUp.Enabled     := False;

    if idxNodeRow = vdtData.RootNodeCount - 1 then
      tbtnItemDown.Enabled   := False;


  end;



end;

procedure TfrmCLItems.vdtDataDrawNode(Sender: TBaseVirtualTree;
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

    if idxRow > CL.Count - 1 then
      Exit;


    if CL.Strings[idxRow]='CL' then
    begin
      Canvas.Draw(6, 1, PluginSkin.IconProgram.Image.Picture.Graphic)
    end
    else if CL.Strings[idxRow]='CLGuide' then
    begin
      Canvas.Draw(6, 1, PluginSkin.IconGuide.Image.Picture.Graphic);
    end;

    Canvas.Font.style := [fsBold];
    RectD.Left   := R.Left + 25;
    RectD.Right  := R.Right - 5;
    RectD.Top    := R.Top + 5;
    RectD.Bottom := R.Bottom;

    if CL.Strings[idxRow]='CL' then
    begin
      BBCodeDrawText(Canvas, '[b]'+TCL(CL.Objects[idxRow]).Name+'[/b] ([i]'+TCL(CL.Objects[idxRow]).ID+'[/i])' , RectD, True, QIP_Colors);
//      sText :=  TCL(CL.Objects[idxRow]).Name + '   ' + TCL(CL.Objects[idxRow]).ID;
    end
    else if CL.Strings[idxRow]='CLGuide' then
    begin
      BBCodeDrawText(Canvas, '[b]'+TCL(CL.Objects[idxRow]).Name+'[/b][br]'+
                             LNG('TEXTS', 'Items', 'Items')+': '+IntToStr(TCLGuide(CL.Objects[idxRow]).Items.Count)
                     , RectD, True, QIP_Colors);
//      sText :=  TCLGuide(CL.Objects[idxRow]).Name + '   [pøehled stanic]   Položek: ' + IntToStr(TCLGuide(CL.Objects[idxRow]).Items.Count);
    end;


{    if CL.Strings[idxRow]='CL' then
    begin
      sText :=  TCL(CL.Objects[idxRow]).Name + '   ' + TCL(CL.Objects[idxRow]).ID;
    end
    else if CL.Strings[idxRow]='CLGuide' then
    begin
      sText :=  TCLGuide(CL.Objects[idxRow]).Name + '   [pøehled stanic]   Položek: ' + IntToStr(TCLGuide(CL.Objects[idxRow]).Items.Count);
    end;


    Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectD, DT_SINGLELINE + DT_NOPREFIX);
}


    // Malovat focus
    if (Column = FocusedColumn) and (Node = FocusedNode) then
    begin
      DrawFocusRect(Canvas.Handle, R);
    end;


  end;

end;

end.
