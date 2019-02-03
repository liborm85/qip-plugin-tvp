unit Search;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, CheckLst, EditItem;

type
  TfrmSearch = class(TForm)
    lblSearch: TLabel;
    edtSearch: TEdit;
    chkSelectPlugin: TCheckBox;
    chklbSelectPlugin: TCheckListBox;
    lvData: TListView;
    btnAdd: TButton;
    StatusBar1: TStatusBar;
    btnSearch: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvDataSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnSearchClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure chkSelectPluginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSearch: TfrmSearch;
  FEditItem: TfrmEditItem;

implementation

uses General, uLNG, TVpDLL, TVp_plugin_info, u_lang_ids;

{$R *.dfm}

procedure TfrmSearch.btnAddClick(Sender: TObject);
begin
  if EditItemIsShow = False then
  begin
    FEditItem := TfrmEditItem.Create(nil);
    FEditItem.Caption      := LNG('TEXTS', 'AddStation', 'Add station');
    FEditItem.edtName.Text := lvData.Items[lvData.ItemIndex].Caption;
    FEditItem.edtID.Text   := lvData.Items[lvData.ItemIndex].SubItems[0];
    FEditItem.Show;
  end;
end;

procedure TfrmSearch.btnSearchClick(Sender: TObject);
var i: Integer;
    Search: TFSearch;
    DATA_Search: TStringList;
    PluginIndex: Integer;

begin

  btnAdd.Visible := False;
  lblSearch.Enabled := False;
  edtSearch.Enabled := False;
  btnSearch.Enabled := False;

  StatusBar1.Panels[0].Text := QIPPlugin.GetLang(LI_SEARCHING);
  StatusBar1.Update;

  lvData.Items.Clear;


  for PluginIndex := 0 to TVpPlugins.Count - 1 do
  begin
    if (chkSelectPlugin.Checked=False) or (chklbSelectPlugin.Checked[PluginIndex]=True) then
    begin

      @Search:= nil;
      try
        @Search := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[PluginIndex]).DllHandle, 'Search');
      except
        ShowError(11, PluginIndex, 'Search');
      end;

      if @Search <> nil then
        begin


          try
            Search(edtSearch.Text, '', DATA_Search, INFO_GetProgram);
          except
            ShowError(12, PluginIndex, 'Search');
          end;


          for i:= 0 to DATA_Search.Count - 1 do
            begin

              if DATA_Search.Strings[i] = 'STATION' then
                begin
(*                  if TSLFoundPlaces(DATA_Search.Objects[i]).ID = 'NOT FOUND' then
                    begin
//                      ShowMessage(edtSearch.Text +  ' not found in ' + TSLWPluginData(WPlugins.Objects[PluginIndex]).Info.PluginName + '.');
                    end
                  else
                    begin
*)
                      lvData.Items.Add;
                      lvData.Items.item[lvData.Items.Count - 1].Caption   :=  TDLLStations(DATA_Search.Objects[i]).StationName;
                      lvData.Items.item[lvData.Items.Count - 1].SubItems.Add( TDLLStations(DATA_Search.Objects[i]).StationID  );

  (*
                    end;
*)
                end;

            end;
        end;
    end;

  end;


  StatusBar1.Panels[0].Text := '';
  edtSearch.Text    := '';
  lblSearch.Enabled := True;
  edtSearch.Enabled := True;
  btnSearch.Enabled := True;

  if lvData.Items.Count=0 then
  begin
    StatusBar1.Panels[0].Text := QIPPlugin.GetLang(LI_NOT_FOUND);
  end
  else
  begin
    StatusBar1.Panels[0].Text :=  QIPPlugin.GetLang(LI_RESULTS) + ': ' + IntToStr(lvData.Items.Count);
  end;

end;

procedure TfrmSearch.chkSelectPluginClick(Sender: TObject);
begin
  if chkSelectPlugin.Checked = True then
    chklbSelectPlugin.Enabled := True
  else
    chklbSelectPlugin.Enabled := False;
end;

procedure TfrmSearch.edtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=13 then
  begin
    btnSearchClick(Sender);
    Key := 0;
  end;
end;

procedure TfrmSearch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SearchIsShow := False;
end;

procedure TfrmSearch.FormShow(Sender: TObject);
var
  i : Integer;
begin
  SearchIsShow := True;

  Icon := PluginSkin.Search.Icon;


  chklbSelectPlugin.Enabled := False;

  Caption           := QIPPlugin.GetLang(LI_SEARCH);
  lblSearch.Caption := QIPPlugin.GetLang(LI_NAME) + ':';
  btnSearch.Caption := QIPPlugin.GetLang(LI_SEARCH);
  btnAdd.Caption    := QIPPlugin.GetLang(LI_ADD);

  chkSelectPlugin.Caption    := LNG('FORM Search', 'SearchOnlyIn', 'Search only in:');

  lvData.Column[0].Caption   := QIPPlugin.GetLang(LI_NAME);
  lvData.Column[1].Caption   := LNG('TEXTS', 'ID', 'ID');

  StatusBar1.Panels[0].Text := '';

  for i := 0 to TVpPlugins.Count - 1 do
  begin
    chklbSelectPlugin.Items.Add(TTVpPluginData(TVpPlugins.Objects[i]).Info.PluginName);
  end;

end;

procedure TfrmSearch.lvDataSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin

  if lvData.ItemIndex <> -1 then
    btnAdd.Visible := True;

end;

end.
