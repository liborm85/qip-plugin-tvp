unit Options;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, Menus, ImgList, ToolWin,
  CommCtrl;

type
  TfrmOptions = class(TForm)
    pnlCont: TPanel;
    pnlText: TPanel;
    lblPluginVersion: TLabel;
    btnAbout: TBitBtn;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    pgcOptions: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet6: TTabSheet;
    gbUpdater: TGroupBox;
    chkUpdaterCheckingUpdates: TCheckBox;
    lblUpdaterInterval: TLabel;
    edtUpdaterInterval: TEdit;
    udUpdaterInterval: TUpDown;
    lblUpdaterIntervalUnit: TLabel;
    btnUpdaterCheckUpdate: TBitBtn;
    gbProxy: TGroupBox;
    lblProxyServerInfo: TLabel;
    edtProxyServer: TEdit;
    chkUseProxyServer: TCheckBox;
    TabSheet7: TTabSheet;
    gbHotKeys: TGroupBox;
    lblHotKeyOpenTVp: TLabel;
    HotKey1: THotKey;
    chkUseHotKeys: TCheckBox;
    gbLanguage: TGroupBox;
    lblInfoTransAuthor: TLabel;
    lblInfoTransEmail: TLabel;
    lblTransAuthor: TLabel;
    lblTransEmail: TLabel;
    lblInfoTransWeb: TLabel;
    lblTransURL: TLabel;
    lblLanguage: TLabel;
    lstMenu: TListBox;
    BottomLine: TShape;
    lblLanguageVersion: TLabel;
    gbAdvancedOptions: TGroupBox;
    cmbLangs: TComboBox;
    chkAnnounceBeta: TCheckBox;
    lblLanguageRem: TLabel;
    ImageList1: TImageList;
    chkShowComments: TCheckBox;
    TabSheet5: TTabSheet;
    lvPlugins: TListView;
    chkCloseBookmarks: TCheckBox;
    gbContacts: TGroupBox;
    chkAlwaysOpenAllStations: TCheckBox;
    chkShowAsOneContact: TCheckBox;
    pnlColorStation: TPanel;
    lblColorStation: TLabel;
    lblColorTimeInfo: TLabel;
    pnlColorTimeInfo: TPanel;
    pnlColorPlanned: TPanel;
    lblColorPlanned: TLabel;
    lblColorLine2: TLabel;
    pnlColorLine2: TPanel;
    pnlColorLine1: TPanel;
    lblColorLine1: TLabel;
    ColorDialog1: TColorDialog;
    gbColors: TGroupBox;
    gbUpdateProgram: TGroupBox;
    lblUpdateProgramInterval: TLabel;
    edtUpdateProgramInterval: TEdit;
    udUpdateProgramInterval: TUpDown;
    lblUpdateProgramIntervalUnit: TLabel;
    edtSpecCntText: TEdit;
    lblSpecCntText: TLabel;
    edtCLFont: TEdit;
    edtCLFontSize: TEdit;
    pnlCLFontColor: TPanel;
    lblSpecCntFont: TLabel;
    FontDialog1: TFontDialog;
    tbButtons: TToolBar;
    tbtnCLFont: TToolButton;
    ilButtons: TImageList;
    tbtnCLColor: TToolButton;
    lblColorProgress1: TLabel;
    pnlColorProgress1: TPanel;
    pnlColorProgress2: TPanel;
    lblColorProgress2: TLabel;
    procedure btnAboutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure udUpdaterIntervalClick(Sender: TObject; Button: TUDBtnType);
    procedure lblTransEmailClick(Sender: TObject);
    procedure lblTransURLClick(Sender: TObject);
    procedure btnUpdaterCheckUpdateClick(Sender: TObject);
    procedure lstMenuClick(Sender: TObject);
    procedure lstMenuDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);

    procedure MeasureMenu(Sender: TObject;
      ACanvas: TCanvas; var Width, Height: Integer);
    procedure DrawMenu(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure cmbLangsChange(Sender: TObject);
    procedure GetOffHotKey(Sender: TObject);
    procedure GetHotKeysActivate(Sender: TObject);
    procedure lstMenuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblSkinEmailMouseEnter(Sender: TObject);
    procedure lblSkinWebMouseEnter(Sender: TObject);
    procedure lblSkinWebMouseLeave(Sender: TObject);
    procedure lblSkinEmailMouseLeave(Sender: TObject);
    procedure lblTransEmailMouseEnter(Sender: TObject);
    procedure lblTransEmailMouseLeave(Sender: TObject);
    procedure lblTransURLMouseLeave(Sender: TObject);
    procedure lblTransURLMouseEnter(Sender: TObject);
    procedure pnlColorLine1Click(Sender: TObject);
    procedure pnlColorLine2Click(Sender: TObject);
    procedure pnlColorPlannedClick(Sender: TObject);
    procedure pnlColorTimeInfoClick(Sender: TObject);
    procedure pnlColorStationClick(Sender: TObject);
    procedure btnCLFontClick(Sender: TObject);
    procedure tbtnCLFontClick(Sender: TObject);
    procedure tbtnCLColorClick(Sender: TObject);
    procedure pnlColorProgress1Click(Sender: TObject);
    procedure pnlColorProgress2Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowLanguageInfo;
  end;

var
  frmOptions: TfrmOptions;

implementation

uses General, u_lang_ids, u_qip_plugin, IniFiles, uLNG, UpdaterUnit, TextSearch,
     Convs, Drawing, uSuperReplace, uToolTip, uComments, uOptions,
     uLinks, uINI, TVpDLL, uColors;

{$R *.dfm}



procedure TfrmOptions.udUpdaterIntervalClick(Sender: TObject;
  Button: TUDBtnType);
begin
  edtUpdaterInterval.Text := IntToStr( udUpdaterInterval.Position );
end;


procedure TfrmOptions.ShowLanguageInfo;
var sAuthor, sEmail, sURL, sTrans, sTransInfo, sVersion, sLang: WideString;
    iFS, iFS1, iFS2: Integer;
    INI : TIniFile;
begin
  if Copy(cmbLangs.Text,1,1)='<' then
    INI := TIniFile.Create(PluginDllPath +
                         'Langs\' + QIPInfiumLanguage + '.lng')
  else
    INI := TIniFile.Create(PluginDllPath +
                         'Langs\' + cmbLangs.Text + '.lng');

  sTrans := INIReadStringUTF8(INI, 'Info', 'Translator', LNG('Texts','unknown', 'unknown'));
  sVersion := INIReadStringUTF8(INI, 'Info', 'Version', '0.0.0');

  INIFree(INI);

  sLang := PluginLanguage;
  PluginLanguage := cmbLangs.Text;
  if sVersion < PluginVersionWithoutBuild then
    lblLanguageVersion.Caption := '(' + LNG('FORM Options', 'Language.VersionError', 'version of translation is not actual') + ')'
  else
    lblLanguageVersion.Caption := '';
  PluginLanguage := sLang;

  lblLanguageVersion.Left := cmbLangs.Left + cmbLangs.Width + 4;

  iFS := StrPosE(sTrans,' [',1,False);
  sAuthor := Copy(sTrans, 1, iFS);

  sTransInfo := FoundStr(sTrans, ' [', ']', 1, iFS, iFS1, iFS2);

  sEmail := FoundStr(sTransInfo, 'EMAIL="', '"', 1, iFS, iFS1, iFS2);
  sURL := FoundStr(sTransInfo, 'URL="', '"', 1, iFS, iFS1, iFS2);

  lblTransAuthor.Caption  :=  sAuthor;


  sEmail := Trim(sEmail);
  sURL := Trim(sURL);

  if sEmail<>'' then
    begin
      lblTransEmail.Enabled   := True;
      lblTransEmail.Caption   := sEmail;
    end
  else
    begin
      lblTransEmail.Enabled   := False;
      lblTransEmail.Caption   := LNG('Texts','unknown', 'unknown');
    end;

  if sURL<>'' then
    begin
      lblTransURL.Enabled   := True;
      lblTransURL.Caption   := sURL;
    end
  else
    begin
      lblTransURL.Enabled   := False;
      lblTransURL.Caption   := LNG('Texts','unknown', 'unknown');
    end;
end;


procedure TfrmOptions.tbtnCLColorClick(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlCLFontColor.Hint;

  OpenColors(sColor);

  pnlCLFontColor.Hint := sColor;

  pnlCLFontColor.Color := TextToColor(pnlCLFontColor.Hint, QIP_Colors);

  edtCLFont.Font.Color := TextToColor(pnlCLFontColor.Hint, QIP_Colors);

end;

procedure TfrmOptions.tbtnCLFontClick(Sender: TObject);
begin
  FontDialog1.Font.Name := edtCLFont.Font.Name;
  FontDialog1.Font.Size := edtCLFont.Font.Size;
  FontDialog1.Font.Style := edtCLFont.Font.Style;

  if FontDialog1.Execute() then
  begin
    edtCLFont.Text := FontDialog1.Font.Name;
    edtCLFontSize.Text := IntToStr(FontDialog1.Font.Size);

    edtCLFont.Font.Name := FontDialog1.Font.Name;
    edtCLFont.Font.Size := FontDialog1.Font.Size;
    edtCLFont.Font.Style:= FontDialog1.Font.Style;
  end;
end;

procedure TfrmOptions.btnAboutClick(Sender: TObject);
begin
  OpenAbout;
end;

procedure TfrmOptions.btnApplyClick(Sender: TObject);
var
  INI : TIniFile;
  ActualMenu: Integer;

begin


  clLine1     := pnlColorLine1.Hint;
  clLine2     := pnlColorLine2.Hint;
  clPlanned   := pnlColorPlanned.Hint;
  clTimerInfo := pnlColorTimeInfo.Hint;
  clStation   := pnlColorStation.Hint;
  clProgress1 := pnlColorProgress1.Hint;
  clProgress2 := pnlColorProgress2.Hint;


  UpdateProgrammeInterval := ConvStrToInt( edtUpdateProgramInterval.text);

  ShowComments := chkShowComments.Checked;

  CloseBookmarks := chkCloseBookmarks.Checked;
  AlwaysShowAllStations := chkAlwaysOpenAllStations.Checked;
  ShowAsOneContact := chkShowAsOneContact.Checked;

  SpecCntText := edtSpecCntText.Text;
  if SpecCntText = '' then
    SpecCntText := 'TVp';

  SpecCntFont.FontColor := pnlCLFontColor.Hint;

  //Proxy_Enabled := chkUseProxyServer.Checked;
  //Proxy_Server  := edtProxyServer.Text;


  CheckUpdates := chkUpdaterCheckingUpdates.Checked;
  CheckBetaUpdates := chkAnnounceBeta.Checked;
  CheckUpdatesInterval := ConvStrToInt( edtUpdaterInterval.Text );
  PluginLanguage := cmbLangs.Text;

  HotKeyEnabled := chkUseHotKeys.Checked;



  HotKeyOpenTVp := HotKey1.HotKey;


  SpecCntFont.Font.Name  := edtCLFont.Font.Name;
  SpecCntFont.Font.Size  := edtCLFont.Font.Size;
  SpecCntFont.Font.Style := edtCLFont.Font.Style;


  INIGetProfileConfig(INI);

  INIWriteBool(INI, 'Conf', 'CheckUpdates', CheckUpdates);
  INIWriteInteger(INI, 'Conf', 'CheckUpdatesInterval', CheckUpdatesInterval);
  INIWriteBool(INI, 'Conf', 'CheckBetaUpdates', CheckBetaUpdates);
  INIWriteStringUTF8(INI, 'Conf', 'Language', PluginLanguage);


  INIWriteBool(INI, 'Conf', 'ShowComments', ShowComments);

  INIWriteBool(INI, 'Conf', 'CloseBookmarks', CloseBookmarks);
  INIWriteBool(INI, 'Conf', 'AlwaysShowAllStations', AlwaysShowAllStations);
  INIWriteBool(INI, 'Conf', 'ShowAsOneContact', ShowAsOneContact);
  INIWriteStringUTF8(INI, 'Conf', 'SpecCntText', SpecCntText);
  INIWriteStringUTF8(INI, 'Conf', 'SpecCntFont', SaveFont(SpecCntFont) );

  INIWriteInteger(INI, 'Conf', 'UpdateProgrammeInterval', UpdateProgrammeInterval);



  INIWriteBool(INI, 'Conf', 'HotKey', HotKeyEnabled);
  INIWriteInteger(INI, 'Conf', 'HotKeyOpenTVp',              HotKeyOpenTVp) ;


//  INIWriteBool(INI, 'Proxy', 'Enabled', Proxy_Enabled);
//  INIWriteStringUTF8(INI, 'Proxy', 'Server', Proxy_Server );

  INIWriteStringUTF8(INI, 'Colors', 'Line1', clLine1);
  INIWriteStringUTF8(INI, 'Colors', 'Line2', clLine2);
  INIWriteStringUTF8(INI, 'Colors', 'Planned', clPlanned);
  INIWriteStringUTF8(INI, 'Colors', 'TimeInfo', clTimerInfo);
  INIWriteStringUTF8(INI, 'Colors', 'Station', clStation);
  INIWriteStringUTF8(INI, 'Colors', 'Progress1', clProgress1);
  INIWriteStringUTF8(INI, 'Colors', 'Progress2', clProgress2);



  INIFree(INI);

  RemoveSpecContacts;
  AddSpecContacts;


  HotKeysDeactivate;


  ActualMenu := lstMenu.ItemIndex;

  FormShow(Sender);

  if HotKeyEnabled then
    HotKeysActivate;

  lstMenu.ItemIndex := ActualMenu;
  pnlText.Caption := lstMenu.Items[ActualMenu];
  pgcOptions.ActivePageIndex := ActualMenu;

  AddComments(FOptions);
end;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmOptions.btnCLFontClick(Sender: TObject);
begin
  FontDialog1.Font.Name := edtCLFont.Font.Name;
  FontDialog1.Font.Size := edtCLFont.Font.Size;
  FontDialog1.Font.Style := edtCLFont.Font.Style;

  if FontDialog1.Execute() then
  begin
    edtCLFont.Text := FontDialog1.Font.Name;
    edtCLFontSize.Text := IntToStr(FontDialog1.Font.Size);

    edtCLFont.Font.Name := FontDialog1.Font.Name;
    edtCLFont.Font.Size := FontDialog1.Font.Size;
    edtCLFont.Font.Style:= FontDialog1.Font.Style;
  end;
end;

procedure TfrmOptions.btnOKClick(Sender: TObject);
begin
  btnApplyClick(Sender);

  Close;
end;

procedure TfrmOptions.btnUpdaterCheckUpdateClick(Sender: TObject);
begin
  CheckNewVersion(True);
end;

procedure TfrmOptions.cmbLangsChange(Sender: TObject);
begin
  ShowLanguageInfo;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OptionsIsShow := False;
  FOptions.Destroy;
end;

procedure TfrmOptions.FormShow(Sender: TObject);
var INI : TIniFile;
    idx : Integer;

    rec: TSearchRec;
    LngPath: WideString;
    NewItem: TMenuItem;
    sText: WideString;

    sAuthor, sEmail, sURL, sTrans, sVersion, sTransInfo: WideString;
    iFS: Integer;

begin
  (*
  Obštrukce, když chcete pøidat TabSheet:
  1) nastavení ikonek v souboru fQIPPlugin, øádek cca 1050
  2) nastavení názvu v tomto souboru, øádek cca 637
  3) to je snad všechno - have fun!
  *)

//  Color := frmBgColor;


  //***          Nastavení jazyka        ***
  //****************************************
  //--- komentáøe
  chkUpdaterCheckingUpdates.Hint := LNG('COMMENTS', 'CheckingUpdates', 'Plugin checks the availability of new version (of program) in the given interval.');
  chkAnnounceBeta.Hint           := LNG('COMMENTS', 'CheckBetaUpdates', 'Checking availability of beta version of plugin. This choice is automatically selected, if you have beta version of plugin.');
  //---

  btnAbout.Caption         := LNG('FORM Options', 'About', 'About plugin...');

  //--- nastavení Options
  pgcOptions.Pages[0].Caption := QIPPlugin.GetLang(LI_GENERAL);
  pgcOptions.Pages[1].Caption := LNG('FORM Options', 'Advanced', 'Advanced');
  pgcOptions.Pages[2].Caption := LNG('FORM Options', 'Layout', 'Layout');
  pgcOptions.Pages[3].Caption := QIPPlugin.GetLang(LI_HOT_KEYS);
  pgcOptions.Pages[4].Caption := QIPPlugin.GetLang(LI_PLUGINS);
  pgcOptions.Pages[5].Caption := QIPPlugin.GetLang(LI_CONNECTION);
  //---

  //--- nastavení Updater
  gbUpdater.Caption                 := LNG('FORM Options', 'General.Updates', 'Updater');
  chkUpdaterCheckingUpdates.Caption := LNG('FORM Options', 'General.CheckingUpdates', 'Checking updates');
  lblUpdaterInterval.Caption        := LNG('FORM Options', 'General.CheckingUpdates.Interval', 'Interval') + ':';
  lblUpdaterIntervalUnit.Caption    := QIPPlugin.GetLang(LI_HOURS);//LNG('FORM Options', 'General.CheckingUpdates.Interval.Unit', 'hours');
  btnUpdaterCheckUpdate.Caption     := QIPPlugin.GetLang(LI_CHECK);
  chkAnnounceBeta.Caption           := LNG('FORM Options', 'General.CheckingUpdates.Beta', 'Announce beta version');
  edtUpdaterInterval.Left     := lblUpdaterInterval.Left + lblUpdaterInterval.Width + 4;
  udUpdaterInterval.Left      := edtUpdaterInterval.Left + edtUpdaterInterval.Width;
  lblUpdaterIntervalUnit.Left := udUpdaterInterval.Left + udUpdaterInterval.Width + 4;
  btnUpdaterCheckUpdate.Left  := lblUpdaterIntervalUnit.Left + lblUpdaterIntervalUnit.Width + 4;

  //--- nastavení Language
  gbLanguage.Caption         := QIPPlugin.GetLang(LI_LANGUAGE);
  lblLanguage.Caption        := QIPPlugin.GetLang(LI_LANGUAGE)+':';
  lblLanguageRem.Caption     := LNG('FORM Options', 'Language.Rem', 'rem: Partial translation is take from QIP.');
  lblInfoTransAuthor.Caption := QIPPlugin.GetLang(LI_AUTHOR) + ':';
  lblInfoTransEmail.Caption  := QIPPlugin.GetLang(LI_EMAIL) + ':';
  lblInfoTransWeb.Caption    := QIPPlugin.GetLang(LI_WEB_SITE) + ':';
  //---

  //--- nastavení Advanced
  gbAdvancedOptions.Caption  := QIPPlugin.GetLang(LI_OPTIONS);

  chkCloseBookmarks.Caption  := LNG('FORM Options', 'Advanced.CloseBookmarks', 'When you close the window, close all tabs');

  chkShowComments.Caption    := LNG('FORM Options', 'Advanced.ShowComments', 'Show comments');

  //gbUpdaterProgram.Caption                 := LNG('FORM Options', 'General.Updates', 'Updater');
  lblUpdateProgramInterval.Caption        := LNG('FORM Options', 'General.CheckingUpdates.Interval', 'Interval') + ':';
  lblUpdateProgramIntervalUnit.Caption    := QIPPlugin.GetLang(LI_HOURS);//LNG('FORM Options', 'General.CheckingUpdates.Interval.Unit', 'hours');

  edtUpdateProgramInterval.Left     := lblUpdateProgramInterval.Left + lblUpdateProgramInterval.Width + 4;
  udUpdateProgramInterval.Left      := edtUpdateProgramInterval.Left + edtUpdateProgramInterval.Width;
  lblUpdateProgramIntervalUnit.Left := udUpdateProgramInterval.Left + udUpdateProgramInterval.Width + 4;

  lblSpecCntText.Caption  := LNG('TEXTS', 'Text', 'Text') + ':';
  lblSpecCntFont.Caption  := QIPPlugin.GetLang(LI_FONT) + ':';

  tbtnCLFont.Hint   := QIPPlugin.GetLang(LI_FONT);
  tbtnCLColor.Hint  := QIPPlugin.GetLang(LI_COLORS);

  gbContacts.Caption  := QIPPlugin.GetLang(LI_CONTACT_LIST);
  gbUpdateProgram.Caption  := LNG('FORM Options', 'Advanced.UpdateProgramme', 'Update programme');

  chkShowAsOneContact.Caption  := LNG('FORM Options', 'Advanced.ShowAllAsOneContact', 'View all as one contact');
  chkAlwaysOpenAllStations.Caption  := LNG('FORM Options', 'Advanced.AlwaysOpenAllStations', 'Always open all stations');

  //---

  //--- nastavení Layout
  gbColors.Caption  := QIPPlugin.GetLang(LI_COLORS);
  lblColorLine1.Caption     := LNG('TEXTS', 'OddLine', 'Odd line') + ':';
  lblColorLine2.Caption     := LNG('TEXTS', 'EvenLine', 'Even line') + ':';
  lblColorPlanned.Caption   := LNG('TEXTS', 'Scheduled', 'Scheduled') + ':';
  lblColorTimeInfo.Caption  := LNG('TEXTS', 'Time', 'Time') + ':';
  lblColorStation.Caption   := LNG('TEXTS', 'Station', 'Station') + ':';
  //---

  //--- nastavení Hot Keys
  gbHotKeys.Caption            := QIPPlugin.GetLang(LI_HOT_KEYS);
  chkUseHotKeys.Caption        := LNG('FORM Options', 'HotKeys.Use', 'Use Hot Keys');
  lblHotKeyOpenTVp.Caption     := LNG('FORM Options', 'HotKeys.OpenTVp', 'Otevøít TVp') + ':';
  //---

  //--- nastavení Plugins
  lvPlugins.Column[0].Caption  := QIPPlugin.GetLang(LI_PLUGIN_FILE);
  lvPlugins.Column[1].Caption  := QIPPlugin.GetLang(LI_PLUGIN_NAME);
  lvPlugins.Column[2].Caption  := QIPPlugin.GetLang(LI_VERSION);
  lvPlugins.Column[3].Caption  := QIPPlugin.GetLang(LI_AUTHOR);
  //---

  //--- nastavení Conncetion
  gbProxy.Caption             := QIPPlugin.GetLang(LI_PROXY);
  chkUseProxyServer.Caption   := LNG('FORM Options', 'Connection.ProxyManual', 'Manual proxy configuration');
  lblProxyServerInfo.Caption  := LNG('FORM Options', 'Connection.Proxy.Syntax', 'Syntax') + ': ' + LNG('FORM Options', 'Connection.Proxy.How', '[user:pass@]server:port');
  //---
  //****************************************

  //***    Nastavení dalších voleb       ***
  //****************************************
  // nastavení ikonky
  Icon := PluginSkin.PluginIcon.Icon;


  // nastavení hlavièky
  Caption := PLUGIN_NAME + ' | ' + QIPPlugin.GetLang(LI_OPTIONS);

  // hlavní tlaèítka Options
  btnOK.Caption := QIPPlugin.GetLang(LI_OK);
  btnCancel.Caption := QIPPlugin.GetLang(LI_CANCEL);
  btnApply.Caption := QIPPlugin.GetLang(LI_APPLY);

  // verze pluginu
  lblPluginVersion.Caption := QIPPlugin.GetLang(LI_VERSION) + ' ' + PluginVersion;

  // èasový interval aktualizací
  edtUpdaterInterval.Text := IntToStr( CheckUpdatesInterval );
  udUpdaterInterval.Position := CheckUpdatesInterval;
  chkAnnounceBeta.Checked := CheckBetaUpdates;

  // pokud je plugin v testovací fázi, jsou zapnuty beta aktualizace
  if Trim(PLUGIN_VER_BETA) <> '' then
  begin
    chkAnnounceBeta.Enabled := False;
  end;



  //****************************************

  LngPath := PluginDLLPath + 'Langs\';

  cmbLangs.Clear;

  cmbLangs.Items.Add('<default>');
  if cmbLangs.Items[cmbLangs.Items.Count - 1] = PluginLanguage then
    cmbLangs.ItemIndex := cmbLangs.Items.Count - 1;

  if FindFirst(LngPath + '*.lng', faAnyFile, rec) = 0 then
    begin
      repeat
          if rec.Name = '' then
          else if rec.Name = '.' then
          else if rec.Name = '..' then
          else
            begin
              cmbLangs.Items.Add( Copy(rec.Name, 1 , Length(rec.Name)-Length(ExtractFileExt(rec.Name))) ) ;
              if cmbLangs.Items[cmbLangs.Items.Count - 1] = PluginLanguage then
                cmbLangs.ItemIndex := cmbLangs.Items.Count - 1;
            end;
      until FindNext(rec) <> 0;
    end;
  FindClose(rec);

  ShowLanguageInfo;


  edtUpdateProgramInterval.Text := IntToStr(UpdateProgrammeInterval);


  pnlColorLine1.Hint      := clLine1;
  pnlColorLine1.Color     := TextToColor(pnlColorLine1.Hint, QIP_Colors);

  pnlColorLine2.Hint      := clLine2;
  pnlColorLine2.Color     := TextToColor(pnlColorLine2.Hint, QIP_Colors);

  pnlColorPlanned.Hint    := clPlanned;
  pnlColorPlanned.Color   := TextToColor(pnlColorPlanned.Hint, QIP_Colors);

  pnlColorTimeInfo.Hint   := clTimerInfo;
  pnlColorTimeInfo.Color  := TextToColor(pnlColorTimeInfo.Hint, QIP_Colors);

  pnlColorStation.Hint    := clStation;
  pnlColorStation.Color   := TextToColor(pnlColorStation.Hint, QIP_Colors);

  pnlColorProgress1.Hint  := clProgress1;
  pnlColorProgress1.Color := TextToColor(pnlColorProgress1.Hint, QIP_Colors);

  pnlColorProgress2.Hint  := clProgress2;
  pnlColorProgress2.Color := TextToColor(pnlColorProgress2.Hint, QIP_Colors);



  chkShowComments.Checked           := ShowComments;
  chkCloseBookmarks.Checked         := CloseBookmarks;
  chkAlwaysOpenAllStations.Checked  := AlwaysShowAllStations;
  chkShowAsOneContact.Checked       := ShowAsOneContact;

  edtSpecCntText.Text := SpecCntText;
  pnlCLFontColor.Hint := SpecCntFont.FontColor;
  pnlCLFontColor.Color := TextToColor(pnlCLFontColor.Hint, QIP_Colors);


  edtCLFont.Text := SpecCntFont.Font.Name;
  edtCLFontSize.Text := IntToStr(SpecCntFont.Font.Size);

  edtCLFont.Font.Name  := SpecCntFont.Font.Name;
  edtCLFont.Font.Size  := SpecCntFont.Font.Size;
  edtCLFont.Font.Style := SpecCntFont.Font.Style ;
  edtCLFont.Font.Color := TextToColor(pnlCLFontColor.Hint, QIP_Colors);

  if HotKeyEnabled then
    chkUseHotKeys.Checked := True
  else
    chkUseHotKeys.Checked := False;

  HotKey1.HotKey := HotKeyOpenTVp;


  //chkUseProxyServer.Checked := Proxy_Enabled;
  //edtProxyServer.Text := Proxy_Server;

  chkUpdaterCheckingUpdates.Checked := CheckUpdates;


  lvPlugins.Items.Clear;
  for idx := 0 to TVpPlugins.Count - 1 do
  begin
    lvPlugins.Items.Add;
    lvPlugins.Items.item[lvPlugins.Items.Count - 1].Caption := ExtractFileName(TTVpPluginData(TVpPlugins.Objects[idx]).DllPath); //ExtractFileName(WPlugins[i].DllPath);
    lvPlugins.Items.item[lvPlugins.Items.Count - 1].SubItems.Add(TTVpPluginData(TVpPlugins.Objects[idx]).Info.PluginName);
    lvPlugins.Items.item[lvPlugins.Items.Count - 1].SubItems.Add(IntToStr(TTVpPluginData(TVpPlugins.Objects[idx]).Info.PluginVerMajor) + '.' + IntToStr(TTVpPluginData(TVpPlugins.Objects[idx]).Info.PluginVerMinor));
    lvPlugins.Items.item[lvPlugins.Items.Count - 1].SubItems.Add(TTVpPluginData(TVpPlugins.Objects[idx]).Info.PluginAuthor);
  end;



  //32 bit support - transparent atd....
  ilButtons.Handle := ImageList_Create(ilButtons.Width, ilButtons.Height, ILC_COLOR32 or ILC_MASK, ilButtons.AllocBy, ilButtons.AllocBy);

  ilButtons.AddIcon(PluginSkin.Font.Icon);
  ilButtons.AddIcon(PluginSkin.Color.Icon);



  lstMenu.Clear;
  idx:=0;
  while ( idx <= pgcOptions.PageCount - 1) do
  begin
    pgcOptions.Pages[idx].TabVisible := false;
    lstMenu.Items.Add ( pgcOptions.Pages[idx].Caption );
    Inc(idx);
  end;

  // NEYOBRAZUJE polozku CONNECTION           - odstraneni
  lstMenu.Items.Delete( pgcOptions.PageCount - 1 );



//  lstMenu.ItemHeight := 26;
  pgcOptions.ActivePageIndex:=0;
  lstMenu.ItemIndex := 0;
  pnlText.Caption := lstMenu.Items[lstMenu.ItemIndex];


  AddComments(FOptions);

  OptionsIsShow := True;
end;

procedure TfrmOptions.GetOffHotKey(Sender: TObject);
begin
//  HotKeysDeactivate;
end;

procedure TfrmOptions.GetHotKeysActivate(Sender: TObject);
begin
//  HotKeysActivate;
end;

procedure TfrmOptions.lblSkinEmailMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmOptions.lblSkinEmailMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmOptions.lblSkinWebMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmOptions.lblSkinWebMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmOptions.lblTransEmailClick(Sender: TObject);
begin
  LinkUrl( 'mailto:'+lblTransEmail.Caption);
end;

procedure TfrmOptions.lblTransEmailMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmOptions.lblTransEmailMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmOptions.lblTransURLClick(Sender: TObject);
begin
  LinkUrl( lblTransURL.Caption);
end;

procedure TfrmOptions.lblTransURLMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmOptions.lblTransURLMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmOptions.lstMenuClick(Sender: TObject);
begin
  pgcOptions.ActivePageIndex := lstMenu.ItemIndex;
  pnlText.Caption := lstMenu.Items[lstMenu.ItemIndex];
  lstMenu.Refresh;
  lstMenu.Update;
end;

procedure TfrmOptions.lstMenuDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var CenterText : integer;
begin

  if lstMenu.ItemIndex = Index then
  begin
    lstMenu.Canvas.Brush.Color := $FFE0C2{QIP_Colors.Focus};
    lstMenu.Canvas.FillRect(Rect);
    lstMenu.Canvas.Brush.Color := $FF9933{QIP_Colors.FocusFrame};
    lstMenu.Canvas.FrameRect(Rect);
  end
  else
  begin
    lstMenu.Canvas.Brush.Color := clWindow;
    lstMenu.Canvas.FillRect (rect);
    lstMenu.Canvas.FrameRect(rect);
  end;

  DrawIconEx(lstMenu.Canvas.Handle, rect.Left + 4, rect.Top + 4, TIcon(PluginSkin.OptionsIcons.Objects[index]).Handle, 16, 16, 0, 0, DI_NORMAL);

  //ilMenu.Draw(lstMenu.Canvas,rect.Left + 4, rect.Top + 4, index );

  SetBkMode(lstMenu.Canvas.Handle, TRANSPARENT);

  CenterText := ( rect.Bottom - rect.Top - lstMenu.Canvas.TextHeight(text)) div 2 ;
  lstMenu.Canvas.Font.Color := clWindowText;
  lstMenu.Canvas.TextOut (rect.left + {ilMenu.Width}16 + 8 , rect.Top + CenterText,
                          lstMenu.Items.Strings[index]);
end;

procedure TfrmOptions.lstMenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pnlText.SetFocus; // odnastavení aktivity na jiný objekt (zabránìní èerchovanému orámování)
end;

procedure TfrmOptions.MeasureMenu(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
begin
  Menu_MeasureMenu(Sender, ACanvas, Width, Height);
end;

procedure TfrmOptions.pnlColorLine1Click(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorLine1.Hint;
  OpenColors(sColor);
  pnlColorLine1.Hint := sColor;
  pnlColorLine1.Color := TextToColor(pnlColorLine1.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorLine2Click(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorLine2.Hint;
  OpenColors(sColor);
  pnlColorLine2.Hint := sColor;
  pnlColorLine2.Color := TextToColor(pnlColorLine2.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorPlannedClick(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorPlanned.Hint;
  OpenColors(sColor);
  pnlColorPlanned.Hint := sColor;
  pnlColorPlanned.Color := TextToColor(pnlColorPlanned.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorProgress1Click(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorProgress1.Hint;
  OpenColors(sColor);
  pnlColorProgress1.Hint := sColor;
  pnlColorProgress1.Color := TextToColor(pnlColorProgress1.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorProgress2Click(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorProgress2.Hint;
  OpenColors(sColor);
  pnlColorProgress2.Hint := sColor;
  pnlColorProgress2.Color := TextToColor(pnlColorProgress2.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorStationClick(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorStation.Hint;
  OpenColors(sColor);
  pnlColorStation.Hint := sColor;
  pnlColorStation.Color := TextToColor(pnlColorStation.Hint, QIP_Colors);
end;

procedure TfrmOptions.pnlColorTimeInfoClick(Sender: TObject);
var sColor : WideString;
begin
  sColor := pnlColorTimeInfo.Hint;
  OpenColors(sColor);
  pnlColorTimeInfo.Hint := sColor;
  pnlColorTimeInfo.Color := TextToColor(pnlColorTimeInfo.Hint, QIP_Colors);
end;

procedure TfrmOptions.DrawMenu(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  Menu_DrawMenu(Sender, ACanvas, ARect, Selected);
end;

end.
