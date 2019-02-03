unit EditItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, CommCtrl;

type
  TfrmEditItem = class(TForm)
    edtName: TEdit;
    edtID: TEdit;
    lblName: TLabel;
    lblID: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    chkAddTo: TCheckBox;
    cmbAddTo: TComboBoxEx;
    ilIcons: TImageList;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure chkAddToClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditItem: TfrmEditItem;

implementation

uses General, TVp_plugin_info, TVpDLL, uLNG, XMLFiles, u_lang_ids;

{$R *.dfm}

procedure TfrmEditItem.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmEditItem.btnOKClick(Sender: TObject);
var
//    F: TextFile;
//    utf8Line: UTF8String;
    idx: Integer;
    idxAddTo : Integer;

    tmpItemCL : TObject;
    sGuideName : WideString;
    idxOpen : Int64;
begin
  idxOpen := -1;

  if chkAddTo.Checked = False then
  begin
    CL.Add('CL');
    idx := CL.Count - 1;
    CL.Objects[idx] := TCL.Create;
    TCL(CL.Objects[idx]).ID     := edtID.Text;
    TCL(CL.Objects[idx]).Name   := edtName.Text;
    //  TSLTVpCLData(CLStations.Objects[hIndex]).Downloading   := False;
    //  TSLTVpCLData(CLStations.Objects[hIndex]).DataAvailable := False;
    //  SetLength(TSLTVpCLData(CLStations.Objects[hIndex]).Data.Date, 0);

    if ShowAsOneContact = False then
    begin
      if CL.Strings[idx]='CL' then
        QIPPlugin.AddSpecContact( 1, idx, TCL(CL.Objects[idx]).UniqID)
      else if CL.Strings[idx]='CLGuide' then
        QIPPlugin.AddSpecContact( 1, idx, TCLGuide(CL.Objects[idx]).UniqID);
    end;

    idxOpen := idx;
  end
  else
  begin
    idxAddTo := cmbAddTo.ItemIndex;

    if CL.Strings[idxAddTo] = 'CL' then
    begin
      sGuideName := '';//InputBox('TVp', LNG('TEXTS', 'NameStationsGuide', 'Name stations guide') + ':','Guide ' + FormatDateTime('YYYY-MM-DD HH:NN:SS', Now));

      TCL(tmpItemCL) := TCL.Create;
      TCL(tmpItemCL).UniqID.UniqID := TCL(CL.Objects[idxAddTo]).UniqID.UniqID;
      TCL(tmpItemCL).UniqID.ItemType := TCL(CL.Objects[idxAddTo]).UniqID.ItemType;
      TCL(tmpItemCL).UniqID.Index := TCL(CL.Objects[idxAddTo]).UniqID.Index;
      TCL(tmpItemCL).Name := TCL(CL.Objects[idxAddTo]).Name;
      TCL(tmpItemCL).ID := TCL(CL.Objects[idxAddTo]).ID;
      TCL(tmpItemCL).Width := TCL(CL.Objects[idxAddTo]).Width;
      TCL(tmpItemCL).Conf := TCL(CL.Objects[idxAddTo]).Conf;
      //TCL(tmpItemCL).CheckingUpdate := TCL(CL.Objects[idxAddTo]).CheckingUpdate;

      CL.Strings[idxAddTo] := '';
      CL.Objects[idxAddTo].Free;


      CL.Objects[idxAddTo] := TCLGuide.Create;
      CL.Strings[idxAddTo] := 'CLGuide';
      TCLGuide(CL.Objects[idxAddTo]).Name     := sGuideName;
      TCLGuide(CL.Objects[idxAddTo]).UniqID.UniqID   := TCL(tmpItemCL).UniqID.UniqID;
      TCLGuide(CL.Objects[idxAddTo]).UniqID.ItemType := TCL(tmpItemCL).UniqID.ItemType;
      TCLGuide(CL.Objects[idxAddTo]).UniqID.Index    := TCL(tmpItemCL).UniqID.Index;
      TCLGuide(CL.Objects[idxAddTo]).Items := TStringList.Create;
      TCLGuide(CL.Objects[idxAddTo]).Items.Clear;

      TCLGuide(CL.Objects[idxAddTo]).Items.Add( 'CL' );
      idx := TCLGuide(CL.Objects[idxAddTo]).Items.Count - 1;
      TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx] := TCL.Create;
      TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Name    := TCL(tmpItemCL).Name;
      TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).ID      := TCL(tmpItemCL).ID;
      TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Width   := TCL(tmpItemCL).Width;
      TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Conf    := TCL(tmpItemCL).Conf;

      // Špatnì pøevání UniqID spec. kontaktù, takže odstraní všechny kontakty a pøidá je :D
      RemoveSpecContacts;
      AddSpecContacts;

    end;


    TCLGuide(CL.Objects[idxAddTo]).Items.Add( 'CL' );
    idx := TCLGuide(CL.Objects[idxAddTo]).Items.Count - 1;
    TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx] := TCL.Create;
    TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Name    := edtName.Text;
    TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).ID      := edtID.Text;
    TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Width   := 0;
    TCL(TCLGuide(CL.Objects[idxAddTo]).Items.Objects[idx]).Conf    := '';

    if ShowAsOneContact = False then
    begin
{
    if CL.Strings[idx]='CL' then
      QIPPlugin.RedrawSpecContact(TCL(CL.Objects[idxAddTo]).UniqID.UniqID)
    else if CL.Strings[idx]='CLGuide' then  }
      QIPPlugin.RedrawSpecContact(TCLGuide(CL.Objects[idxAddTo]).UniqID.UniqID);
    end;

    idxOpen := idxAddTo;

  end;

  if ShowAsOneContact = False then
  begin
    if SpecCntUniq.UniqID <> 0 then
      QIPPlugin.RemoveSpecContact(SpecCntUniq.UniqID);
  end;


  SaveCL;

  LoadStationsData;



(*  if WindowIsShow=True then
  begin
{

}
  end;*)

  // nyní zaktualizovat
  NextUpdate := Now;

  if CLItemsIsShow = True then
    FCLItems.ItemRefresh;

  if idxOpen<>-1 then
    OpenItemOptions( idxOpen );

  Close;

end;

procedure TfrmEditItem.chkAddToClick(Sender: TObject);
begin

  if chkAddTo.Checked = True then
    cmbAddTo.Enabled := True
  else
    cmbAddTo.Enabled := False;

end;

procedure TfrmEditItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EditItemIsShow := False;
end;

procedure TfrmEditItem.FormShow(Sender: TObject);
var
  idx: Integer;
begin
  EditItemIsShow := True;


  lblName.Caption   := QIPPlugin.GetLang(LI_NAME) + ':';
  lblID.Caption     := LNG('TEXTS', 'ID', 'ID') + ':';
  btnOK.Caption     := QIPPlugin.GetLang(LI_OK);
  btnCancel.Caption := QIPPlugin.GetLang(LI_CANCEL);
  chkAddTo.Caption  := LNG('TEXTS', 'AddTo', 'Add to') + ':';

  //32 bit support - transparent atd....
  ilIcons.Handle := ImageList_Create(ilIcons.Width, ilIcons.Height, ILC_COLOR32 or ILC_MASK, ilIcons.AllocBy, ilIcons.AllocBy);

  ilIcons.AddIcon(PluginSkin.IconProgram.Icon);
  ilIcons.AddIcon(PluginSkin.IconGuide.Icon);


  if CL.Count=0 then
  begin
    chkAddTo.Visible := False;
    cmbAddTo.Visible := False;
  end
  else
  begin
    chkAddTo.Visible := True;
    cmbAddTo.Visible := True;
    cmbAddTo.Clear;

    idx:=0;
    while ( idx<= CL.Count - 1 ) do
    begin
      Application.ProcessMessages;

      if CL.Strings[idx]='CL' then
        cmbAddTo.ItemsEx.AddItem(TCL(CL.Objects[idx]).name, 0, 0, 0, -1,{ItemList.Objects[ItemList.Add(fname)]} nil )
      //  cmbAddTo.Items.Add( TCL(CL.Objects[idx]).name )
      else if CL.Strings[idx]='CLGuide' then
        cmbAddTo.ItemsEx.AddItem(TCLGuide(CL.Objects[idx]).name, 1, 1, 1, -1,{ItemList.Objects[ItemList.Add(fname)]} nil );
//        cmbAddTo.Items.Add( '[guide] ' + TCLGuide(CL.Objects[idx]).name  );

      Inc(idx);
    end;

  end;

  if cmbAddTo.Items.Count <> 0 then
    cmbAddTo.ItemIndex := 0;

  chkAddToClick(sender);


end;

end.
