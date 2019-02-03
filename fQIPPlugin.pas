unit fQIPPlugin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles,
  u_plugin_info, u_plugin_msg, u_common, ExtCtrls, Menus, ImgList;

type

  { TSpecCntUniq }
  TSpecCntUniq = record
    UniqID            : DWord;
    ItemType          : DWord;
    Index             : DWord;
  end;
  pSpecCntUniq = ^TSpecCntUniq;

  { FadeMsg }
  TFadeMsg = class
  public
    FadeType     : Byte;        //0 - message style, 1 - information style, 2 - warning style
    FadeIcon     : HICON;       //icon in the top left corner of the window
    FadeTitle    : WideString;
    FadeText     : WideString;
    TextCentered : Boolean;     //if true then text will be centered inside window
    NoAutoClose  : Boolean;     //if NoAutoClose is True then wnd will be always shown until user close it. Not recommended to set this param to True.
    CloseTime    : Integer;
    pData        : Integer;
  end;

  { FadeMsgClosing }
  TFadeMsgClosing = class
  public
    FadeID       : DWord;        //0 - message style, 1 - information style, 2 - warning style
    Time         : Integer;     // 1 jednotka 500 ms.
  end;


  TfrmQIPPlugin = class(TForm)
    tmrStep: TTimer;
    tmrStart: TTimer;
    pmContactMenu: TPopupMenu;
    miContactMenu_Open: TMenuItem;
    miContactMenu_RefreshAll: TMenuItem;
    N1: TMenuItem;
    miContactMenu_Search: TMenuItem;
    miContactMenu_Edit: TMenuItem;
    miContactMenu_EditStations: TMenuItem;
    miContactMenu_Options: TMenuItem;
    ImageList1: TImageList;
    tmrUpdateData: TTimer;
    tmrNP: TTimer;
    N2: TMenuItem;
    miContactMenu_Remove: TMenuItem;
    miContactMenu_PlannedPrograms: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure tmrStepTimer(Sender: TObject);
    procedure tmrStartTimer(Sender: TObject);
    procedure miContactMenu_OptionsClick(Sender: TObject);
    procedure CMAdvDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      State: TOwnerDrawState);
    procedure ddrrr(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);

    procedure DrawMenu(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure MeasureMenu(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);
    procedure miContactMenu_OpenClick(Sender: TObject);
    procedure miContactMenu_SearchClick(Sender: TObject);
    procedure tmrNPTimer(Sender: TObject);
    procedure tmrUpdateDataTimer(Sender: TObject);
    procedure miContactMenu_RefreshAllClick(Sender: TObject);
    procedure miContactMenu_EditClick(Sender: TObject);
    procedure miContactMenu_EditStationsClick(Sender: TObject);
    procedure miContactMenu_RemoveClick(Sender: TObject);
    procedure miContactMenu_PlannedProgramsClick(Sender: TObject);
  private
    FPluginSvc : pIQIPPluginService;
    FDllHandle : Cardinal;
    FDllPath   : WideString;

    procedure WMHotKey(var msg:TWMHotKey);message WM_HOTKEY;
  public
    property PluginSvc : pIQIPPluginService read FPluginSvc write FPluginSvc;
    property DllHandle : Cardinal           read FDllHandle write FDllHandle;
    property DllPath   : WideString         read FDllPath   write FDllPath;


    procedure CreateControls;
    procedure FreeControls;

    procedure LoadPluginOptions;
    procedure SavePluginOptions;

    procedure ShowPluginOptions;

//    procedure SpellCheck(var PlugMsg: TPluginMessage);
//    procedure SpellPopup(var PlugMsg: TPluginMessage);
    procedure QipSoundChanged(PlugMsg: TPluginMessage);
    procedure AntiBoss(HideForms: Boolean);
    procedure CurrentLanguage(LangName: WideString);
    procedure DrawSpecContact(PlugMsg: TPluginMessage);
    procedure SpecContactDblClick(PlugMsg: TPluginMessage);
    procedure SpecContactRightClick(PlugMsg: TPluginMessage);
    procedure LeftClickOnFadeMsg(PlugMsg: TPluginMessage);
    procedure GetSpecContactHintSize(var PlugMsg: TPluginMessage);
    procedure DrawSpecContactHint(PlugMsg: TPluginMessage);
    procedure XstatusChangedByUser(PlugMsg: TPluginMessage);
    procedure InstantMsgRcvd(var PlugMsg: TPluginMessage);
    procedure InstantMsgSend(var PlugMsg: TPluginMessage);
    procedure NewMessageFlashing(PlugMsg: TPluginMessage);
    procedure NewMessageStopFlashing(PlugMsg: TPluginMessage);
    procedure AddNeededBtns(PlugMsg: TPluginMessage);
    procedure MsgBtnClicked(PlugMsg: TPluginMessage);
    procedure SpecMsgRcvd(PlugMsg: TPluginMessage);
    procedure StatusChanged(PlugMsg: TPluginMessage);
    procedure ImRcvdSuccess(PlugMsg: TPluginMessage);
    procedure ContactStatusRcvd(PlugMsg: TPluginMessage);
    procedure ChatTabAction(PlugMsg: TPluginMessage);
    procedure AddNeededChatBtns(PlugMsg: TPluginMessage);
    procedure ChatBtnClicked(PlugMsg: TPluginMessage);
    procedure ChatMsgRcvd(PlugMsg: TPluginMessage);
    procedure ChatMsgSending(var PlugMsg: TPluginMessage);
    procedure EnumInfo(PlugMsg: TPluginMessage);

    function  FadeMsg(FType: Byte; FIcon: HICON; FTitle: WideString; FText: WideString; FTextCenter: Boolean; FNoAutoClose: Boolean; pData: Integer) : DWORD;
    procedure AddFadeMsg(
                                    FadeType     : Byte;        //0 - message style, 1 - information style, 2 - warning style
                                    FadeIcon     : HICON;       //icon in the top left corner of the window
                                    FadeTitle    : WideString;
                                    FadeText     : WideString;
                                    TextCentered : Boolean;     //if true then text will be centered inside window
                                    NoAutoClose  : Boolean;     //if NoAutoClose is True then wnd will be always shown until user close it. Not recommended to set this param to True.
                                    CloseTime    : Integer;
                                    pData        : Integer
                                  );


    procedure AddSpecContact(CntType: DWord; CntIndex: DWord; var UniqID: TSpecCntUniq; HeightCnt: Integer = 19);
    procedure RedrawSpecContact(UniqID: DWord);
    procedure RemoveSpecContact(var UniqID: DWord);


    function GetLang(ID: Word) : WideString;

    procedure InfiumClose(itype: Word);

//    procedure DrawStation(Cnv: TCanvas; clCL : TCL; var Width: Integer; var Height: Integer);
    procedure DrawHint(Cnv: TCanvas; R : TRect; CalcRect: Boolean; spec: pSpecCntUniq; var Width: Integer; var Height: Integer);


    procedure ShowContactMenu(pX, pY : Integer; index : Integer );





  protected
    procedure CreateParams (var Params: TCreateParams); override;
  end;

var
  frmQIPPlugin: TfrmQIPPlugin;
  FadeMsgs        : TStringList;
  FadeMsgsClosing : TStringList;

implementation

uses General, uImage, Convs, UpdaterUnit, uLNG, HotKeyManager,
     DateUtils, u_lang_ids, u_qip_plugin, uIcon, Drawing, uOptions,
     uSuperReplace,  uColors,  uFileFolder, uINI, TVpDLL,
     XMLFiles,
     SQLiteFuncs, SQLiteTable3,
     BBCode;

{$R *.dfm}

procedure TfrmQIPPlugin.CreateParams (var Params: TCreateParams);
begin
  inherited;
    with Params do begin
      ExStyle := (ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE);
    end;
end;

procedure TfrmQIPPlugin.WMHotKey(var msg:TWMHotKey);
{var
  INI : TIniFile;}
begin

  if msg.HotKey = 8901 then
  begin

    if WindowIsShow = False then
      OpenBookmark(-1, False)
    else
      CloseWindow;

  end;

(*  if msg.HotKey = 8801 then
{    FBassPlayer.PlayStopRadi}
  else if msg.HotKey = 8802 then
  begin
{    Player_Volume := Player_Volume + 5;

    if Player_Volume > 100 then
      Player_Volume := 100;

    SetChangeVolume;       }
  end
  else if msg.HotKey = 8803 then
  begin
{    Player_Volume := Player_Volume - 5;

    if Player_Volume < 0 then
      Player_Volume := 0;

    SetChangeVolume;    }
  end
  else if msg.HotKey = 8804 then
  begin
 {   if Player_Mute = False then
      Player_Mute := True
    else
      Player_Mute := False;

    SetChangeVolume;      }
  end
  else if msg.HotKey = 8805 then
  begin
{    StationNext();       }
  end
  else if msg.HotKey = 8806 then
  begin
  {  StationPrev();        }
  end
  else if msg.HotKey = 8807 then  // Enable/Disable XStatus
  begin
 {   XStatus_Boolean := not (XStatus_Boolean);

    if XStatus_Boolean = True then
      ChangeXstatus := True
    else
      RemoveXstatus := True;

    INIGetProfileConfig(INI);
    INIWriteBool(INI, 'XStatus', 'Enabled', XStatus_Boolean);
    INIFree(INI);      }
  end;       *)

end;

procedure TfrmQIPPlugin.FormCreate(Sender: TObject);
begin

  FadeMsgs := TStringList.Create;
  FadeMsgs.Clear;

  FadeMsgsClosing := TStringList.Create;
  FadeMsgsClosing.Clear;

  TVpPlugins := TStringList.Create;
  TVpPlugins.Clear;

  CL := TStringList.Create;
  CL.Clear;

  Stations := TStringList.Create;
  Stations.Clear;

  PluginSkin.MenuIcons := TStringList.Create;
  PluginSkin.MenuIcons.Clear;

  PluginSkin.OptionsIcons := TStringList.Create;
  PluginSkin.OptionsIcons.Clear;

  BookmarkWindow := TStringList.Create;
  BookmarkWindow.Clear;

  TVpPlan := TStringList.Create;
  TVpPlan.Clear;


  DTFormatDATETIME.DateSeparator   := '-';
  DTFormatDATETIME.TimeSeparator   := ':';
  DTFormatDATETIME.ShortDateFormat := 'YYYY-MM-DD';
  DTFormatDATETIME.ShortTimeFormat := 'HH:MM:SS';
  DTFormatDATETIME.LongDateFormat := 'YYYY-MM-DD''  ''HH:MM:SS';

  DTFormat.DateSeparator   := '-';
  DTFormat.TimeSeparator   := ':';
  DTFormat.ShortDateFormat := 'yyyy-mm-dd';
  DTFormat.ShortTimeFormat := 'hh:nn';
  DTFormat.LongDateFormat := 'yyyy-mm-dd''  ''hh:nn';



end;


procedure TfrmQIPPlugin.CreateControls;
begin
  //
end;

procedure TfrmQIPPlugin.FreeControls;
var
  INI : TIniFile;

begin


  if WindowIsShow = True then
  begin
    INIGetProfileConfig(INI);

    INIWriteInteger(INI, 'Window', 'X', FWindow.Left );
    INIWriteInteger(INI, 'Window', 'Y', FWindow.Top );

    INIWriteInteger(INI, 'Window', 'Width', FWindow.Width );
    INIWriteInteger(INI, 'Window', 'Height', FWindow.Height );

    INIFree(INI);
  end;



  try
    if Assigned(SQLdb) then
      SQLdb.Free;
  except

  end;

  try
    HotKeysDeactivate;
  except

  end;

  try
    RemoveSpecContacts;
  except

  end;



  try
    if Assigned(FColors) then FreeAndNil(FColors);
  finally

  end;


  try
    if Assigned(FAbout) then FreeAndNil(FAbout);
  except

  end;

  try
    if Assigned(FCLItems) then FreeAndNil(FCLItems);
  except

  end;

{  try
    if Assigned(FEditItem) then FreeAndNil(FEditItem);
  except

  end;     }


  try
    if Assigned(FItemOptions) then FreeAndNil(FItemOptions);
  except

  end;

  try
    if Assigned(FOptions) then FreeAndNil(FOptions);
  except

  end;

  try
    if Assigned(FPlanEdit) then FreeAndNil(FPlanEdit);
  except

  end;

  try
    if Assigned(FPlanList) then FreeAndNil(FPlanList);
  except

  end;

  try
    if Assigned(FProgramInfo) then FreeAndNil(FProgramInfo);
  except

  end;

  try
    if Assigned(FSearch) then FreeAndNil(FSearch);
  except

  end;

  try
    if Assigned(FWindow) then FreeAndNil(FWindow);
  except

  end;



end;

procedure TfrmQIPPlugin.LoadPluginOptions;
var
    PlugMsg1: TPluginMessage;
    QipColors : pQipColors;

begin
  PlugMsg1.Msg       := PM_PLUGIN_GET_NAMES;
  PlugMsg1.DllHandle := DllHandle;

  FPluginSvc.OnPluginMessage(PlugMsg1);

  if Boolean(PlugMsg1.Result) then
  begin
    Account_DisplayName := PWideChar(PlugMsg1.WParam);
    Account_ProfileName := PWideChar(PlugMsg1.LParam);
  end;

  Account_FileName   := Account_ProfileName;


  // Profile path
  PlugMsg1.Msg       := PM_PLUGIN_GET_PROFILE_DIR;
  PlugMsg1.DllHandle := DllHandle;

  FPluginSvc.OnPluginMessage(PlugMsg1);

  if Boolean(PlugMsg1.Result) then
  begin
    ProfilePath := PWideChar(PlugMsg1.WParam) + PLUGIN_NAME + '\';
  end;



  PlugMsg1.Msg       := PM_PLUGIN_GET_COLORS_FONT;
  PlugMsg1.DllHandle := DllHandle;

  FPluginSvc.OnPluginMessage(PlugMsg1);

  //get results
{  wFontName := PWideChar(PlugMsg1.WParam);
  iFontSize := PlugMsg1.LParam;}
  QipColors := pQipColors(PlugMsg1.NParam);

  QIP_Colors := QipColors^;


  CheckFolder( ProfilePath, False );
  CheckFolder( ProfilePath + 'Logos\', False );
  CheckFolder( ProfilePath + 'Temp\', False );

  tmrStart.Enabled := True;

end;

procedure TfrmQIPPlugin.MeasureMenu(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
begin
  Menu_MeasureMenu(Sender, ACanvas, Width, Height);
end;

procedure TfrmQIPPlugin.DrawMenu(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  Menu_DrawMenu(Sender, ACanvas, ARect, Selected);
end;

procedure TfrmQIPPlugin.miContactMenu_EditClick(Sender: TObject);
begin
  OpenItemOptions(pmContactMenu.Tag);
end;

procedure TfrmQIPPlugin.miContactMenu_EditStationsClick(Sender: TObject);
begin
  OpenCLItems;
end;

procedure TfrmQIPPlugin.miContactMenu_OpenClick(Sender: TObject);
begin
  OpenBookmark(pmContactMenu.Tag, False);
end;

procedure TfrmQIPPlugin.miContactMenu_OptionsClick(Sender: TObject);
begin
  OpenOptions;
end;

procedure TfrmQIPPlugin.miContactMenu_PlannedProgramsClick(Sender: TObject);
begin
  OpenPlanList;
end;

procedure TfrmQIPPlugin.miContactMenu_RefreshAllClick(Sender: TObject);
begin
  NextUpdate := Now;
end;

procedure TfrmQIPPlugin.miContactMenu_RemoveClick(Sender: TObject);
begin
  OpenRemoveContact(pmContactMenu.Tag);
end;

procedure TfrmQIPPlugin.miContactMenu_SearchClick(Sender: TObject);
begin
  OpenSearch;
end;

procedure TfrmQIPPlugin.SavePluginOptions;
begin
  //
end;

procedure TfrmQIPPlugin.ShowPluginOptions;
begin
  OpenOptions;
end;

procedure OldSetToNewPLugin(INI: TINIFile);

begin

end;

procedure TfrmQIPPlugin.tmrNPTimer(Sender: TObject);
var
  idx1, idx2 : Integer;
  sSQL : WideString;
  iNewNP : Integer;
begin

  tmrNP.Enabled := False;

//  showmessage('');

//showmessage(inttostr(Stations.count));

  idx1 := 0;
  while ( idx1 <= Stations.Count - 1 ) do
  begin
    Application.ProcessMessages;

    iNewNP := -1;

    idx2 := 0;
    while ( idx2 <= TTVpStations(Stations.Objects[idx1]).NPData.Count - 1 ) do
    begin
      Application.ProcessMessages;

      if TTVpStations(Stations.Objects[idx1]).NPData.Strings[idx2] <= FormatDateTime('yyyy-mm-dd hh:nn',Now) then
      begin
        iNewNP := idx2;
      end;

      Inc(idx2);
    end; {while idx2}


    if TTVpStations(Stations.Objects[idx1]).NPIndex <> iNewNP then
    begin
      TTVpStations(Stations.Objects[idx1]).NPIndex := iNewNP;


      idx2:=0;
      while ( idx2 <= CL.Count - 1 ) do
      begin
        Application.ProcessMessages;

        if CL.Strings[idx2]='CL' then
        begin
          if TCL(CL.Objects[idx2]).ID = TTVpStations(Stations.Objects[idx1]).StationID then
            QIPPlugin.RedrawSpecContact(TCL(CL.Objects[idx2]).UniqID.UniqID);
        end;

        Inc(idx2);
      end;


      //QIPPlugin.RedrawSpecContact(TCL(CL.Objects[idx1]).UniqID.UniqID);
    end;

    Inc(idx1);
  end;  {while idx1}



  //  Naplanovane porady - kontrola
  idx1:=0;
  while ( idx1 <= TVpPlan.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if TTVpPlan(TVpPlan.Objects[idx1]).Notified = 0 then
    begin
      if TTVpPlan(TVpPlan.Objects[idx1]).DateTime <= Now then
      begin
        QIPPlugin.AddFadeMsg(1, PluginSkin.PluginIcon.Icon.Handle, PLUGIN_NAME,
                             '' + TTVpPlan(TVpPlan.Objects[idx1]).StationID + ' - ' + TTVpPlan(TVpPlan.Objects[idx1]).Name + '  (' + TTVpPlan(TVpPlan.Objects[idx1]).Time + ')'
                              , True, True, 0, 0);

        TTVpPlan(TVpPlan.Objects[idx1]).Notified := 1;

        sSQL := 'UPDATE Plan SET Notified='+IntToStr(TTVpPlan(TVpPlan.Objects[idx1]).Notified)+' WHERE DataID='+IntToStr(TTVpPlan(TVpPlan.Objects[idx1]).DataID);
        ExecSQLUTF8(sSQL);
      end;

    end;

    Inc(idx1);
  end;



  tmrNP.Enabled := True;


end;

procedure TfrmQIPPlugin.tmrStartTimer(Sender: TObject);
var
  hLibraryPics    : THandle;
//  F : TextFile;
//  FName : WideString;
  INI : TINIFile;
//  sXStatusTitle,sXStatusText, sPopupText, sL1Text, sL2Text: WideString;
//  PlugMsg1: TPluginMessage;
//  idx : Integer;
//  iMod, iKey: Word;
//  hIndex: Integer;
  sColor: WideString;


//  sLine, sFileData: RawByteString;


  TableColumns    : TStringList;
//  SQLtb     : TSQLiteTable;
begin
  tmrStart.Enabled := False;



  INI := TiniFile.Create(PluginDllPath + PLUGIN_NAME + '.ini');

  // Pøevod starého nastavení uživatelù pro novou verzi
  OldSetToNewPlugin(INI);

  INIWriteStringUTF8(INI, 'Plugin', 'Version', PluginVersion);
  INIWriteStringUTF8(INI, 'SDK', 'Version', IntToStr(QIP_SDK_VER_MAJOR) + '.' + IntToStr(QIP_SDK_VER_MINOR));

  //// Naètení barev
  sColor     := INIReadStringUTF8(INI, 'Colors', '1', 'F0F0F0');  //frmBgColor = $00F0F0F0;//$00FFEEDD;
{  frmBgColor := RGB( StrToInt('$' + Copy(sColor,1,2)),
                     StrToInt('$' + Copy(sColor,3,2)),
                     StrToInt('$' + Copy(sColor,5,2))); }
  INIWriteStringUTF8(INI, 'Colors', '1', sColor);
  INIFree(INI);


  INIGetProfileConfig(INI);

  PluginLanguage := INIReadStringUTF8(INI, 'Conf', 'Language', '<default>');

  CheckUpdates := INIReadBool(INI, 'Conf', 'CheckUpdates', True );
  CheckUpdatesInterval := INIReadInteger(INI, 'Conf', 'CheckUpdatesInterval', 6);
  CheckBetaUpdates := INIReadBool(INI, 'Conf', 'CheckBetaUpdates', False );

  // pokud je plugin v testovací fázi, jsou zapnuty beta aktualizace
  if Trim(PLUGIN_VER_BETA) <> '' then
  begin
    CheckBetaUpdates := True;
  end;


{  clLine1     :=  $EFEFEF;
  clLine2     :=  $EAEAEA;
  clPlanned   :=  clHighlight;
  clTimerInfo :=  clYellow;
  clStation   :=  clMedGray;}


  clLine1     := INIReadStringUTF8(INI, 'Colors', 'Line1', '#EFEFEF');
  clLine2     := INIReadStringUTF8(INI, 'Colors', 'Line2', '#FFFFFF');
  clPlanned   := INIReadStringUTF8(INI, 'Colors', 'Planned', '#3399FF');
  clTimerInfo := INIReadStringUTF8(INI, 'Colors', 'TimeInfo', '#FFFF00');
  clStation   := INIReadStringUTF8(INI, 'Colors', 'Station', '#A0A0A4');

  clProgress1 := INIReadStringUTF8(INI, 'Colors', 'Progress1', '#008000');
  clProgress2 := INIReadStringUTF8(INI, 'Colors', 'Progress2', '#FFFFFF');


  ShowComments := INIReadBool(INI, 'Conf', 'ShowComments', true);

  CloseBookmarks := INIReadBool(INI, 'Conf', 'CloseBookmarks', false);
  AlwaysShowAllStations := INIReadBool(INI, 'Conf', 'AlwaysShowAllStations', false);
  ShowAsOneContact := INIReadBool(INI, 'Conf', 'ShowAsOneContact', false);

  SpecCntText := INIReadStringUTF8(INI, 'Conf', 'SpecCntText', 'TVp');
  if SpecCntText = '' then
    SpecCntText := 'TVp';

  LoadFont(INIReadStringUTF8(INI, 'Conf', 'SpecCntFont', 'Name="Tahoma";Size="8";Color="NotInList";Style="";'), SpecCntFont);

  LastUpdate := SQLDLToDT(INIReadStringUTF8(INI, 'Conf', 'LastUpdate', ''));
  NextUpdate := SQLDLToDT(INIReadStringUTF8(INI, 'Conf', 'NextUpdate', ''));

  UpdateProgrammeInterval := INIReadInteger(INI, 'Conf', 'UpdateProgrammeInterval', 360);

  HotKeyEnabled     := INIReadBool(INI, 'Conf', 'HotKey', false);
  HotKeyOpenTVp     := INIReadInteger(INI, 'Conf', 'HotKeyOpenTVp', 49236) ;


//  Proxy_Enabled := INIReadBool(INI, 'Proxy', 'Enabled', false);
//  Proxy_Server := INIReadStringUTF8(INI, 'Proxy', 'Server', '');

  INIFree(INI);




  SQLdbPath := ProfilePath + '\program.db';
  try
    SQLdb := TSQLiteDatabase.Create(SQLdbPath, PluginDllPath );
  except
    ShowMessage('Chyba v otevøení databáze!');
  end;


  TableColumns := TStringList.Create;


  TableColumns.Clear;
  AddColumnSL('ID',                 'INTEGER PRIMARY KEY AUTOINCREMENT',TableColumns);
  AddColumnSL('StationID',          'TEXT',TableColumns);
  AddColumnSL('Name',               'TIME',TableColumns);
  AddColumnSL('Logo',               'TEXT',TableColumns);
  CheckTable('Stations',TableColumns);


  TableColumns.Clear;
  AddColumnSL('ID',                 'INTEGER PRIMARY KEY AUTOINCREMENT',TableColumns);
  AddColumnSL('StationID',          'TEXT',TableColumns);
  AddColumnSL('Date',               'DATE',TableColumns);
  AddColumnSL('IncDate',            'INTEGER',TableColumns);
  AddColumnSL('Time',               'TIME',TableColumns);
  AddColumnSL('Name',               'TEXT',TableColumns);
  AddColumnSL('OrigName',           'TEXT',TableColumns);
  AddColumnSL('Info',               'TEXT',TableColumns);
  AddColumnSL('InfoImage',          'TEXT',TableColumns);
  AddColumnSL('URL',                'TEXT',TableColumns);
  AddColumnSL('Specifications',     'TEXT',TableColumns);
  CheckTable('Data',TableColumns);


  TableColumns.Clear;
  AddColumnSL('ID',                 'INTEGER PRIMARY KEY AUTOINCREMENT',TableColumns);
  AddColumnSL('DataID',             'INTEGER',TableColumns);
  AddColumnSL('NotifyBeforeBegin',  'INTEGER',TableColumns);
  AddColumnSL('Notified',           'INTEGER',TableColumns);
  CheckTable('Plan',TableColumns);

  TableColumns.Free;



  LoadTVpPlugins;




  hLibraryPics := LoadLibrary(PChar(PluginDllPath + 'pics.dll'));

  if hLibraryPics=0 then
  begin
    ShowMessage( TagsReplace( StringReplace(LNG('Texts', 'LibraryNotLoad', 'Can''t load library %file%.[br]Plugin can be unstable.'), '%file%', 'pics.dll', [rfReplaceAll, rfIgnoreCase]) ) );
    Exit;
  end;

  PluginSkin.PluginIconBig        := LoadImageFromResource(10, hLibraryPics);

  PluginSkin.PluginIcon.Image     := LoadImageFromResource(11, hLibraryPics);
  PluginSkin.PluginIcon.Icon      := LoadImageAsIconFromResource(11, hLibraryPics);

  PluginSkin.IconProgram.Image    := LoadImageFromResource(12, hLibraryPics);
  PluginSkin.IconProgram.Icon     := LoadImageAsIconFromResource(12, hLibraryPics);

  PluginSkin.IconNoProgram.Image  := LoadImageFromResource(13, hLibraryPics);
  PluginSkin.IconNoProgram.Icon   := LoadImageAsIconFromResource(13, hLibraryPics);

  PluginSkin.IconGuide.Image      := LoadImageFromResource(14, hLibraryPics);
  PluginSkin.IconGuide.Icon       := LoadImageAsIconFromResource(14, hLibraryPics);

  PluginSkin.Check.Image          := LoadImageFromResource(15, hLibraryPics);
  PluginSkin.Check.Icon           := LoadImageAsIconFromResource(15, hLibraryPics);


  PluginSkin.Options.Image        := LoadImageFromResource(20, hLibraryPics);
  PluginSkin.Options.Icon         := LoadImageAsIconFromResource(20, hLibraryPics);

  PluginSkin.Open.Image           := LoadImageFromResource(21, hLibraryPics);
  PluginSkin.Open.Icon            := LoadImageAsIconFromResource(21, hLibraryPics);

  PluginSkin.Edit.Image           := LoadImageFromResource(22, hLibraryPics);
  PluginSkin.Edit.Icon            := LoadImageAsIconFromResource(22, hLibraryPics);

  PluginSkin.Refresh.Image        := LoadImageFromResource(23, hLibraryPics);
  PluginSkin.Refresh.Icon         := LoadImageAsIconFromResource(23, hLibraryPics);

  PluginSkin.EditItems.Image      := LoadImageFromResource(24, hLibraryPics);
  PluginSkin.EditItems.Icon       := LoadImageAsIconFromResource(24, hLibraryPics);

  PluginSkin.Search.Image         := LoadImageFromResource(25, hLibraryPics);
  PluginSkin.Search.Icon          := LoadImageAsIconFromResource(25, hLibraryPics);


  PluginSkin.Close.Image          := LoadImageFromResource(26, hLibraryPics);
  PluginSkin.Close.Icon           := LoadImageAsIconFromResource(26, hLibraryPics);


  PluginSkin.Info.Image           := LoadImageFromResource(27, hLibraryPics);
  PluginSkin.Info.Icon            := LoadImageAsIconFromResource(27, hLibraryPics);

  PluginSkin.Remove.Image         := LoadImageFromResource(28, hLibraryPics);
  PluginSkin.Remove.Icon          := LoadImageAsIconFromResource(28, hLibraryPics);



  PluginSkin.General.Icon         := LoadImageAsIconFromResource(30, hLibraryPics);
  PluginSkin.Advanced.Icon        := LoadImageAsIconFromResource(31, hLibraryPics);
  PluginSkin.Layout.Icon          := LoadImageAsIconFromResource(32, hLibraryPics);
  PluginSkin.HotKeys.Icon         := LoadImageAsIconFromResource(33, hLibraryPics);
  PluginSkin.Plugins.Icon         := LoadImageAsIconFromResource(34, hLibraryPics);
  PluginSkin.Connect.Icon         := LoadImageAsIconFromResource(35, hLibraryPics);


  PluginSkin.Plan.Image           := LoadImageFromResource(40, hLibraryPics);
  PluginSkin.Plan.Icon            := LoadImageAsIconFromResource(40, hLibraryPics);
  PluginSkin.Plan_Add.Image       := LoadImageFromResource(41, hLibraryPics);
  PluginSkin.Plan_Add.Icon        := LoadImageAsIconFromResource(41, hLibraryPics);
  PluginSkin.Plan_Delete.Image    := LoadImageFromResource(42, hLibraryPics);
  PluginSkin.Plan_Delete.Icon     := LoadImageAsIconFromResource(42, hLibraryPics);
  PluginSkin.Plan_Edit.Image      := LoadImageFromResource(43, hLibraryPics);
  PluginSkin.Plan_Edit.Icon       := LoadImageAsIconFromResource(43, hLibraryPics);

  PluginSkin.ItemAdd.Image        := LoadImageFromResource(44, hLibraryPics);
  PluginSkin.ItemAdd.Icon         := LoadImageAsIconFromResource(44, hLibraryPics);
  PluginSkin.ItemRemove.Image     := LoadImageFromResource(45, hLibraryPics);
  PluginSkin.ItemRemove.Icon      := LoadImageAsIconFromResource(45, hLibraryPics);
  PluginSkin.ItemUp.Image         := LoadImageFromResource(46, hLibraryPics);
  PluginSkin.ItemUp.Icon          := LoadImageAsIconFromResource(46, hLibraryPics);
  PluginSkin.ItemDown.Image       := LoadImageFromResource(47, hLibraryPics);
  PluginSkin.ItemDown.Icon        := LoadImageAsIconFromResource(47, hLibraryPics);

  PluginSkin.Font.Image           := LoadImageFromResource(48, hLibraryPics);
  PluginSkin.Font.Icon            := LoadImageAsIconFromResource(48, hLibraryPics);

  PluginSkin.Color.Image          := LoadImageFromResource(49, hLibraryPics);
  PluginSkin.Color.Icon           := LoadImageAsIconFromResource(49, hLibraryPics);


  PluginSkin.CheckMenuItem        := LoadImageAsIconFromResource(60, hLibraryPics);
  PluginSkin.Update.Icon          := LoadImageAsIconFromResource(61, hLibraryPics);

  PluginSkin.Comment.Image        := LoadImageFromResource(62, hLibraryPics);
  PluginSkin.Comment.Icon         := LoadImageAsIconFromResource(62, hLibraryPics);

  FreeLibrary(hLibraryPics);


  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Open.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Edit.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Refresh.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Search.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.EditItems.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Options.Icon);

  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Info.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Close.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Plan_Add.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Plan_Edit.Icon);

  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Remove.Icon);
  AddIconToStringList(PluginSkin.MenuIcons, PluginSkin.Plan.Icon);


  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.General.Icon);
  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.Advanced.Icon);
  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.Layout.Icon);
  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.HotKeys.Icon);
  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.Plugins.Icon);
  AddIconToStringList(PluginSkin.OptionsIcons, PluginSkin.Connect.Icon);




  if HotKeyEnabled = True then
  begin
    HotKeysActivate;
  end;


  LoadCL;

  LoadStationsData;

  LoadPlan;




//  QIPPlugin.AddSpecContact( UniqContactId, SpecCntHeight );

(*
  {=== Sound switch on/off test ===================================}
  {getting sound option enabled/disbaled}
  PlugMsg1.Msg := PM_PLUGIN_SOUND_GET;
  {when plugin sending msg to qip core it have to add self dllhandle, else your msg will be ignored}
  PlugMsg1.DllHandle := DllHandle;

  FPluginSvc.OnPluginMessage(PlugMsg1);

  {if sound enabled then disabling it}
  if Boolean(PlugMsg1.WParam) then
    QIPSound := True
  else
    QIPSound := False;

  if UseQIPMute = True then
  begin
    //Player_Mute := not QIPSound;
    //SetChangeVolume;
  end;
  {================================================================}
*)


  AddSpecContacts;
(*
  // --- Add spec contacts ---
  if (CL.Count = 0) or (ShowAsOneContact = True) then
  begin
    AddSpecContact(0,0, SpecCntUniq);
  end
  else
  begin
    idx:=0;
    while ( idx<= CL.Count - 1 ) do
    begin
      Application.ProcessMessages;

      if CL.Strings[idx]='CL' then
        QIPPlugin.AddSpecContact( 1, idx, TCL(CL.Objects[idx]).UniqID)
      else if CL.Strings[idx]='CLGuide' then
        QIPPlugin.AddSpecContact( 1, idx, TCLGuide(CL.Objects[idx]).UniqID);

      Inc(idx);
    end;
  end;   *)


  if NextUpdate < Now then
    NextUpdate :=  Now + ( 5 * (1/(24*60*60) ) );


  UpdaterWebIndex := -1;

  UpdaterWeb  := TStringList.Create;
  UpdaterWeb.Clear;

  UpdaterWeb.Add('http://lmscze7.ic.cz/');
  UpdaterWeb.Add('http://lmscze7.wz.cz/');

  NextCheckVersion := Now + ( 5 * (1/(24*60*60) ) );

  tmrStep.Enabled := True;
  tmrUpdateData.Enabled := True;
  tmrNP.Enabled := True;



end;

procedure CheckLoadProgram;
var {i :  Integer; }
    INI: TINIFile;
begin
(*  AllCheckingUpdates := True;
  RedrawSpecContacts := True;

  try  *)
    NextUpdate := -1;
(*
  if WindowIsShow = True then
  begin
    FfrmWindow.Timer2.Enabled := True;
  end;
*)
  CheckProgram(DownInfo);

  LastUpdate := Now;

  NextUpdate := Now + (UpdateProgrammeInterval * (1/(24*60) ) );

  INIGetProfileConfig(INI);
  INIWriteStringUTF8(INI,'Conf','LastUpdate', FormatDateTime('YYYY-MM-DD HH:MM:SS',LastUpdate) );
  INIWriteStringUTF8(INI,'Conf','NextUpdate', FormatDateTime('YYYY-MM-DD HH:MM:SS',NextUpdate) );
  INIFree(INI);

(*


  if WindowIsShow = True then
  begin
    FfrmWindow.Timer2.Enabled := False;

  end;

  for i := 0 to CLStations.Count - 1 do
  begin
    if WindowIsShow = True then
      FfrmWindow.StatusBar1.Panels[0].Text := LNG('FORM TVp', 'Info.Loading', 'Loading data...') + ' ' + IntToStr(i + 1) + ' / ' + IntToStr( CLStations.Count );




    OpenTVpProgram(TSLTVpCLData(CLStations.Objects[i]).StationID, TSLTVpCLData(CLStations.Objects[i]).Data, True);



    if WindowIsShow = True then
      if FfrmWindow.TabControl1.TabIndex = i then  FfrmWindow.ShowProgram;



  end;

  LastUpdate := Now;

  NextUpdate := Now + (UpdateInterval * (1/(24*60) ) );

  INI := TiniFile.Create(ExtractFilePath(PluginDllPath) + Account_FileName + '.ini');

  INI.WriteString('Conf','LastUpdate', FormatDateTime('YYYY-MM-DD HH:MM:SS',LastUpdate) );
  INI.WriteString('Conf','NextUpdate', FormatDateTime('YYYY-MM-DD HH:MM:SS',NextUpdate) );

  INI.Free;

  if WindowIsShow = True then
  begin
    FfrmWindow.StatusBar1.Panels[0].Text := '';
  end;



  StationNoData := False;
  RedrawSpecContacts := True;
  finally

  end;

  AllCheckingUpdates := False;
  RedrawSpecContacts := True;

*)
(*  if NextUpdate=-1 then
    NextUpdate := Now + (UpdateInterval * (1/(24*60) ) );    *)


  cthread := 0;

//CLStations[0].DataNP[0].ItemDate := '0001-01-01';

end;

procedure TfrmQIPPlugin.tmrStepTimer(Sender: TObject);
var
  fmFadeMsg  : TFadeMsg;
  fmcFadeMsgClosing: TFadeMsgClosing;
  i : Integer;
  fid: DWord;
  PlugMsg1{, RepMsg}  : TPluginMessage;

//  sText : WideString;
begin



  if FadeMsgsClosing.Count > 0 then
  begin
    i:=0;
    while ( i<= FadeMsgsClosing.Count - 1 ) do
    begin
      Application.ProcessMessages;

      Dec(TFadeMsgClosing(FadeMsgsClosing.Objects[i]).Time);

      if TFadeMsgClosing(FadeMsgsClosing.Objects[i]).Time <= 0  then
      begin
        PlugMsg1.Msg    := PM_PLUGIN_FADE_CLOSE;
        PlugMsg1.WParam := TFadeMsgClosing(FadeMsgsClosing.Objects[i]).FadeID;

        PlugMsg1.DllHandle := DllHandle;
        FPluginSvc.OnPluginMessage(PlugMsg1);

        FadeMsgsClosing.Delete(i);
        Dec(i);
      end;

      Inc(i);
    end;

  end;

  if FadeMsgs.Count > 0 then
  begin
    fmFadeMsg := TFadeMsg(FadeMsgs.Objects[0]);
    FadeMsgs.Delete(0);

    if fmFadeMsg.CloseTime <> 0 then
      fmFadeMsg.NoAutoClose := True;

    fid := FadeMsg(fmFadeMsg.FadeType,
            fmFadeMsg.FadeIcon,
            fmFadeMsg.FadeTitle,
            fmFadeMsg.FadeText,
            fmFadeMsg.TextCentered,
            fmFadeMsg.NoAutoClose,
            fmFadeMsg.pData
            );

    if fmFadeMsg.CloseTime <> 0 then
    begin

      fmcFadeMsgClosing := TFadeMsgClosing.Create;
      fmcFadeMsgClosing.FadeID      := fid;
      fmcFadeMsgClosing.Time        := fmFadeMsg.CloseTime * 2;

      FadeMsgsClosing.Add('FADEMSG');
      FadeMsgsClosing.Objects[FadeMsgsClosing.Count - 1] := fmcFadeMsgClosing.Create;

    end;

    if fmFadeMsg.pData=255 then
      Updater_NewVersionFadeID := fid;

  end;




  // ---- Check new version ----
  CheckNewVersion(False);




end;

procedure TfrmQIPPlugin.tmrUpdateDataTimer(Sender: TObject);
var ThreadId: Cardinal;
begin

  if tmrUpdateData.Interval <> 1000 * 5 then
    tmrUpdateData.Interval := 1000 * 5;

  if NextUpdate = -1 then
      //WORKING
  else if (NextUpdate <= Now)
          or
          (NextUpdate = 0) then
  begin
{
    NextUpdate:=-1;

    CheckLoadProgram;

    if NextUpdate=-1 then
      NextUpdate := Now + (UpdateInterval * (1/(24*60) ) );
}
    if cthread = 0 then
      cthread := BeginThread(nil, 0, @CheckLoadProgram, NIL, 0, ThreadId)
{    else
      ShowMessage('Nelze provést aktualizaci, jedna již bìží.')}

  end;

end;

////////////////////////////////////////////////////////////////////////////////
{procedure TfrmQIPPlugin.SpellCheck(var PlugMsg: TPluginMessage);
begin
  //
end;}

{******************************************************************************}
{procedure TfrmQIPPlugin.SpellPopup(var PlugMsg: TPluginMessage);
begin
  //
end;}

{******************************************************************************}
procedure TfrmQIPPlugin.QipSoundChanged(PlugMsg: TPluginMessage);
begin
  if Boolean(PlugMsg.WParam) then
    QIPSound := True
  else
    QIPSound := False;


end;

{******************************************************************************}
procedure TfrmQIPPlugin.AntiBoss(HideForms: Boolean);
begin
  if HideForms then
    /// AntiBoss: activated
  else
    /// AntiBoss: deactivated
end;

{******************************************************************************}
procedure TfrmQIPPlugin.CurrentLanguage(LangName: WideString);
var
  INI : TINIFile;
begin
  //  ShowMessage(LangName);
  QIPInfiumLanguage := LangName;

  INI := TiniFile.Create(PluginDllPath + PLUGIN_NAME + '.ini');
  INIWriteStringUTF8(INI, 'Language', 'QIP', QIPInfiumLanguage );
  INIFree(INI);
end;

procedure TfrmQIPPlugin.ddrrr(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
  Selected: Boolean);
begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.DrawSpecContact(PlugMsg: TPluginMessage);
var ContactId : DWord;
    //Data      : Pointer;
    Cnv       : TCanvas;
    R         : PRect;
    wFontName, wStr : WideString;
    R1{, R2, RCalc} : TRect;
//    RRight, RBottom, RRight2, RBottom2, iAlign, iLeft : Integer;
//    RLeft, RTop : Integer;

//    Params: TDrawTextParams;

//    IdxOf: Integer;
//    sValue: WideString;
    bProgram : Boolean;
    NPInfo : TNPInfo;

    PlugMsg1 : TPluginMessage;
    QipColors : pQipColors;
    iFontSize : Integer;
    spec : pSpecCntUniq;

begin

  //get unique contact id from msg
  ContactId := PlugMsg.WParam;

  spec := pSpecCntUniq(PlugMsg.LParam);

  //actually all incoming ContactIDs will be only of your plugin, but here i made condition just for example
//  if (ContactId <> FfrmTest.UniqContactId) then Exit;

  //get your Data pointer which you added when sent PM_PLUGIN_SPEC_ADD_CNT.
  //IMPORTANT!!! Do NOT make here any heavy loading actions, like cycles FOR, WHILE etc.
  //That's why you have to add Data pointer to PM_PLUGIN_SPEC_ADD_CNT, to get quick access to your data.
  //Data not used here in this example because plugin added only one contact
  //Data      := Pointer(PlugMsg.LParam);

  //create temporary canvas to draw the contact
  Cnv       := TCanvas.Create;
  try
    //get canvas handle from msg
    Cnv.Handle := PlugMsg.NParam;

    //get drawing rectangle pointer from msg
    R := PRect(PlugMsg.Result);

    //this needed to draw text over contact list backgroud
    SetBkMode(Cnv.Handle, TRANSPARENT);


    PlugMsg1.Msg       := PM_PLUGIN_GET_COLORS_FONT;
    PlugMsg1.DllHandle := DllHandle;

    FPluginSvc.OnPluginMessage(PlugMsg1);

    //get results
    wFontName := PWideChar(PlugMsg1.WParam);
    iFontSize := PlugMsg1.LParam;
    QipColors := pQipColors(PlugMsg1.NParam);

    QIP_Colors := QipColors^;

    Cnv.Font.Name  := SpecCntFont.Font.Name; //wFontName;
    Cnv.Font.Color := TextToColor( SpecCntFont.FontColor, QIP_Colors ); //QipColors^.NotInList;
    Cnv.Font.Size  := SpecCntFont.Font.Size; //;
    Cnv.Font.Style := SpecCntFont.Font.Style; //[];
{
    Cnv.Font.Name  := fontDefaultCLFont.Font.Name;
    Cnv.Font.Color := TextToColor( fontDefaultCLFont.FontColor, QIP_Colors );
    Cnv.Font.Size  := fontDefaultCLFont.Font.Size;
    Cnv.Font.Style := fontDefaultCLFont.Font.Style;
}

    if spec^.ItemType=0 then   // TVp
    begin
      Cnv.Draw(6, 1, PluginSkin.IconProgram.Image.Picture.Graphic);

      wStr := SpecCntText;
      R1 := Rect(R^.Left + 24, R^.Top + 1 , R^.Right, R^.Bottom);
      DrawTextW(Cnv.Handle, PWideChar(wStr), Length(wStr), R1, DT_LEFT);
//      BBCodeDrawText(Cnv, wStr, R1, False, QipColors^)
    end
    else if spec^.ItemType=1 then   // CL
    begin
      if CL.Strings[spec^.Index]='CL' then
        wStr := TCL(CL.Objects[spec^.Index]).Name
      else if CL.Strings[spec^.Index]='CLGuide' then
      begin
        wStr := TCLGuide(CL.Objects[spec^.Index]).Name;
      end;

      bProgram := False;
      if CL.Strings[spec^.Index]='CL' then
      begin
        GetNPInfo(TCL(CL.Objects[spec^.Index]).ID, -2, NPInfo);

        if NPInfo.TimeLength = -1 then
        begin
          wStr := wStr + '';
        end
        else
        begin
          wStr := wStr + ': ' + NPInfo.Name;
          bProgram := True;
        end;

(*        IdxOf := Stations.IndexOf( TCL(CL.Objects[spec^.Index]).ID );

        if IdxOf <> -1 then
        begin

//          wStr := wStr + ': ' + inttostr(TTVpStations(Stations.Objects[IdxOf]).NPIndex)+'/'+IntToStr(TTVpStations(Stations.Objects[IdxOf]).NPData.Count) + '    ' + FormatDateTime('yyyy-mm-dd hh:nn:ss',Now);
          if TTVpStations(Stations.Objects[IdxOf]).NPIndex = -1 then
          begin
            wStr := wStr + '';
          end
          else
          begin
            wStr := wStr + ': ' +TTVpProgram(TTVpStations(Stations.Objects[IdxOf]).NPData.Objects[TTVpStations(Stations.Objects[IdxOf]).NPIndex]).Name;
            bProgram := True;
          end;

        end;
*)
      end;

      if CL.Strings[spec^.Index]='CL' then
      begin
        if bProgram = True then
          Cnv.Draw(6, 1, PluginSkin.IconProgram.Image.Picture.Graphic)
        else
          Cnv.Draw(6, 1, PluginSkin.IconNoProgram.Image.Picture.Graphic);
      end
      else if CL.Strings[spec^.Index]='CLGuide' then
      begin
        Cnv.Draw(6, 1, PluginSkin.IconGuide.Image.Picture.Graphic);
      end;

//     DrawIconEx (cnv.Handle, 20, 1, PluginSkin.IconProgram.Icon.Handle, 16, 16, 0, NULL, {DI_NORMAL or} DI_COMPAT {or DI_DEFAULTSIZE});
//        DrawIcon(cnv.Handle, 20, 1, PluginSkin.IconProgram.Icon.Handle);


      R1 := Rect(R^.Left + 24, R^.Top + 1 , R^.Right, R^.Bottom);
      DrawTextW(Cnv.Handle, PWideChar(wStr), Length(wStr), R1, DT_LEFT + DT_NOPREFIX );
//      BBCodeDrawText(Cnv, wStr, R1, False, QipColors^);

      if TCL(CL.Objects[spec^.Index]).CheckingUpdate = True then
        Cnv.Draw(R^.Right - R^.Left - 16, 1, PluginSkin.Check.Image.Picture.Graphic);
{
      if TCL(CL.Objects[spec^.Index]).Error = True then
        if TCL(CL.Objects[spec^.Index]).CheckingUpdate = True then
          Cnv.Draw(R^.Right - R^.Left - 16 - 16, 1, PluginSkin.Error.Image.Picture.Graphic)
        else
          Cnv.Draw(R^.Right - R^.Left - 16, 1, PluginSkin.Error.Image.Picture.Graphic);

      if TCL(CL.Objects[spec^.Index]).NewItems = True then
        if (NewItemsAnimate=0) or
           (NewItemsAnimate=1) then
          Cnv.Draw(6, 1, PluginSkin.Msg.Image.Picture.Graphic);    }

    end;

  finally
    //free canvas
    Cnv.Free;
  end;
end;

{******************************************************************************}
procedure TfrmQIPPlugin.SpecContactDblClick(PlugMsg: TPluginMessage);
var
  ContactId : DWord;
  spec      : pSpecCntUniq;
begin
  ContactId := PlugMsg.WParam;

  spec := pSpecCntUniq(PlugMsg.LParam);

  if CL.Count = 0 then
    OpenSearch
  else
    OpenBookmark(spec^.Index, False);

end;

{******************************************************************************}
procedure TfrmQIPPlugin.SpecContactRightClick(PlugMsg: TPluginMessage);
var ContactId : DWord;
    //Data      : Pointer;
    Pt        : PPoint;
    spec      : pSpecCntUniq;
begin
  //get right clicked contact id from msg
  ContactId := PlugMsg.WParam;

  //get data pointer if added
  //Data      := Pointer(PlugMsg.LParam);
  spec := pSpecCntUniq(PlugMsg.LParam);

  //get popup screen coordinates
  Pt        := PPoint(PlugMsg.NParam);
  if spec^.ItemType=0 then
    QIPPlugin.ShowContactMenu(Pt.X, Pt.Y, -1)
  else if spec^.ItemType=1 then
    QIPPlugin.ShowContactMenu(Pt.X, Pt.Y, spec^.Index);


end;

{******************************************************************************}
procedure TfrmQIPPlugin.LeftClickOnFadeMsg(PlugMsg: TPluginMessage);
var PlugMsg1 : TPluginMessage;
    FadeMsgID: integer;
    //spec : Integer;
begin

  FadeMsgID := PlugMsg.WParam;

  if Updater_NewVersionFadeID = FadeMsgID then
  begin
    PlugMsg1.Msg    := PM_PLUGIN_FADE_CLOSE;

    PlugMsg1.WParam := FadeMsgID;

    PlugMsg1.DllHandle := DllHandle;
    FPluginSvc.OnPluginMessage(PlugMsg1);

    OpenUpdater;
  end;
end;

procedure DrawNextProgram(Cnv: TCanvas; clCL : TCL; CalcRect : Boolean; R1 : TRect; idxPrg : Int64; var RItem : TRect; var Width: Integer; var Height: Integer);
var
  NPInfo : TNPInfo;
  IdxOf : Integer;
  RCalc, RDraw : TRect;
  sText : WideString;
begin

  GetNPInfo(clCL.ID, idxPrg, NPInfo);

  if ( (NPInfo.TimeLength = -1) or (NPInfo.TimeLength = 0) ) then

  else
  begin
    RCalc.Left    := 0;
    RCalc.Right   := RItem.Right - RItem.Left;
    RCalc.Top     := 0;
    RCalc.Bottom  := 0;

    Cnv.Font.Style := [];
    sText := FormatDateTime('hh:mm',NPInfo.TimeBegin) + ' ' + NPInfo.Name;
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

    RDraw.Left    := RItem.Left;
    RDraw.Right   := RItem.Left+RCalc.Right;
    RDraw.Top     := RItem.Top;
    RDraw.Bottom  := RItem.Top+RCalc.Bottom;
    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT + DT_WORDBREAK);
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RDraw.Bottom;
    RItem.Bottom  := R1.Bottom;
  end;

end;

procedure DrawStation(Cnv: TCanvas; clCL : TCL; CalcRect : Boolean; R1 : TRect; var RItem : TRect; var Width: Integer; var Height: Integer);
var
  NPInfo : TNPInfo;
  imgLogo : TImage;
  RItemTop, RCalc, Rprg, RDraw : TRect;
  sText : WideString;
  proc : Real;
  IdxOf, idxPrg, idx, IdxOf2, CntNxtPrograms : Integer;
  slConf : TStringList;

begin

  SetBkMode(Cnv.Handle, TRANSPARENT);

  RItemTop.Left    := RItem.Left;
  RItemTop.Right   := RItem.Right;
  RItemTop.Top     := RItem.Top;
  RItemTop.Bottom  := RItem.Bottom;


  GetNPInfo(clCL.ID, -2, NPInfo);


  //--- LOAD STATION ICON ---
  imgLogo := TImage.Create(nil);
  imgLogo.AutoSize := True;
  GetStationLogo(clCL.ID, imgLogo);
  //---

  // --- Nazev stanice ---
  RCalc.Left    := 0;
  RCalc.Right   := RItem.Right - RItem.Left - imgLogo.Width;
  RCalc.Top     := 0;
  RCalc.Bottom  := 0;

  Cnv.Font.Style := [fsBold];
  sText := clCL.Name;
  DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

  RDraw.Left    := RItem.Left;
  RDraw.Right   := RItem.Left+RCalc.Right;
  RDraw.Top     := RItem.Top;
  RDraw.Bottom  := RItem.Top+RCalc.Bottom;

  if CalcRect=False then
  begin
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT + DT_WORDBREAK);
  end;

  RItem.Left    := R1.Left;
  RItem.Right   := R1.Right;
  RItem.Top     := RDraw.Bottom;
  RItem.Bottom  := R1.Bottom;
  //---

  // --- ID stanice ---
  RCalc.Left    := 0;
  RCalc.Right   := RItem.Right - RItem.Left - imgLogo.Width;
  RCalc.Top     := 0;
  RCalc.Bottom  := 0;

  Cnv.Font.Style := [fsItalic];
  sText := clCL.ID;
  DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

  RDraw.Left    := RItem.Left;
  RDraw.Right   := RItem.Left+RCalc.Right;
  RDraw.Top     := RItem.Top;
  RDraw.Bottom  := RItem.Top+RCalc.Bottom;

  if CalcRect=False then
  begin
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT + DT_WORDBREAK);
  end;

  RItem.Left    := R1.Left;
  RItem.Right   := R1.Right;
  RItem.Top     := RDraw.Bottom;
  RItem.Bottom  := R1.Bottom;
  //---

  //==== STANICE NEVYSILA /VYSILA =====
  if NPInfo.TimeLength = -1 then
  begin
    //--- Stanice nevysila ---
    RCalc.Left    := 0;
    RCalc.Right   := RItem.Right - RItem.Left;
    RCalc.Top     := 0;
    RCalc.Bottom  := 0;

    Cnv.Font.Style := [fsItalic, fsBold];
    sText := #13+#10+LNG('TEXTS', 'StationIsNotBroadcastJustNow', 'Station isn''t broadcast just now');//+#13+#10;
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

    RDraw.Left    := RItem.Left;
    RDraw.Right   := RItem.Left+RCalc.Right;
    RDraw.Top     := RItem.Top;
    RDraw.Bottom  := RItem.Top+RCalc.Bottom;

    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_CENTER + DT_WORDBREAK);
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RDraw.Bottom;
    RItem.Bottom  := R1.Bottom;
    //---

    //---- dalsi porady ---
    IdxOf := Stations.IndexOf( clCL.ID );
    if IdxOf <> -1 then
    begin
      idxPrg := TTVpStations(Stations.Objects[IdxOf]).NPIndex;

      slConf := TStringList.Create;
      slConf.Clear;
      LoadOptions(clCL.Conf,slConf);

      IdxOf2 := slConf.IndexOf('HintCountNextPrograms');
      if IdxOf2 <> -1 then
        CntNxtPrograms := ConvStrToInt( TItemOptions(slConf.Objects[IdxOf2]).dataWideString )
      else
        CntNxtPrograms := 3;


      idx := 0;
      while ( idx <= CntNxtPrograms - 1 ) do
      begin

        DrawNextProgram(Cnv, clCL, CalcRect, R1, idxPrg + idx + 1, RItem, Width, Height);

        Inc(idx);
      end; {while idx}

    end;
    //----------------


    if CalcRect=True then
    begin
      Height := RItem.Top - R1.Top;
    end;
  end
  else
  begin   // VYSILA
    // --- Casy a uplynuti ---
    RDraw.Left    := RItemTop.Left;
    RDraw.Right   := RItemTop.Right;
    RDraw.Top     := RItem.Top;
    RDraw.Bottom  := RItemTop.Bottom;


    Cnv.Font.Style := [fsBold];


    sText := FormatDateTime('hh:mm',NPInfo.TimeBegin);

    RCalc.Left    := 0;
    RCalc.Right   := RItem.Right - RItem.Left;
    RCalc.Top     := 0;
    RCalc.Bottom  := 0;

    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_CALCRECT );

    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT );
    end;


    sText := FormatDateTime('hh:mm',NPInfo.TimeEnd);

    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_RIGHT );
    end;

    Cnv.Font.Style := [fsItalic];

    //sText := IntToStr(NPInfo.TimePosition) + ' ' + QIPPlugin.GetLang(LI_MINUTES) + ' / ' + IntToStr(NPInfo.TimeLength - NPInfo.TimePosition) + ' ' + QIPPlugin.GetLang(LI_MINUTES);
    sText := IntToStr(NPInfo.TimePosition) + ' ' + ' / ' + IntToStr(NPInfo.TimeLength - NPInfo.TimePosition) + ' ('+IntToStr(NPInfo.TimeLength)+') ' + QIPPlugin.GetLang(LI_MINUTES);

    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_CENTER );
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RItem.Top+RCalc.Bottom;
    RItem.Bottom  := R1.Bottom;
    //---

    //--- draw progress ---
    Cnv.Font.Style := [];

    Rprg.Left    := RItem.Left;
    Rprg.Right   := RItem.Right;
    Rprg.Top     := RItem.Top;
    Rprg.Bottom  := Rprg.Top + 5;
    if CalcRect=False then
    begin
      Cnv.Brush.Color := TextToColor(clProgress2, QIP_Colors);
      Cnv.FillRect(Rprg);

      if ((NPInfo.TimeLength=-1) or (NPInfo.TimeLength=0)) then

      else
      begin
        proc := (NPInfo.TimePosition/NPInfo.TimeLength)*100;

        Rprg.Right   := round(
                            Rprg.Left+
                            (((Rprg.Right - Rprg.Left) / 100) * proc)
                           );

        Cnv.Brush.Color := TextToColor(clProgress1, QIP_Colors);
        Cnv.FillRect(Rprg);
      end;

      SetBkMode(Cnv.Handle, TRANSPARENT);
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RItem.Top+(Rprg.Bottom-Rprg.Top);
    RItem.Bottom  := R1.Bottom;
    //---


    //--- Nazev poradu ---
    RCalc.Left    := 0;
    RCalc.Right   := RItem.Right - RItem.Left;
    RCalc.Top     := 0;
    RCalc.Bottom  := 0;

    Cnv.Font.Style := [fsBold];
    sText := NPInfo.Name;
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

    RDraw.Left    := RItem.Left;
    RDraw.Right   := RItem.Left+RCalc.Right;
    RDraw.Top     := RItem.Top;
    RDraw.Bottom  := RItem.Top+RCalc.Bottom;
    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT + DT_WORDBREAK);
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RDraw.Bottom;
    RItem.Bottom  := R1.Bottom;
    //---

    //---- dalsi porady ---
    IdxOf := Stations.IndexOf( clCL.ID );
    if IdxOf <> -1 then
    begin
      idxPrg := TTVpStations(Stations.Objects[IdxOf]).NPIndex;

      slConf := TStringList.Create;
      slConf.Clear;
      LoadOptions(clCL.Conf,slConf);

      IdxOf2 := slConf.IndexOf('HintCountNextPrograms');
      if IdxOf2 <> -1 then
        CntNxtPrograms := ConvStrToInt( TItemOptions(slConf.Objects[IdxOf2]).dataWideString )
      else
        CntNxtPrograms := 3;

      idx := 0;
      while ( idx <= CntNxtPrograms - 1 ) do
      begin

        DrawNextProgram(Cnv, clCL, CalcRect, R1, idxPrg + idx + 1, RItem, Width, Height);

        Inc(idx);
      end; {while idx}

    end;


  {    Info.Name   := TTVpProgram(TTVpStations(Stations.Objects[IdxOf]).NPData.Objects[ProgramIndex]).Name;

      Info.TimeBegin  := SQLDLToDT( TTVpStations(Stations.Objects[IdxOf]).NPData.Strings[ProgramIndex]  );

      if TTVpStations(Stations.Objects[IdxOf]).NPData.Count - 1 >= ProgramIndex+1 then
      begin
        Info.TimeEnd    := SQLDLToDT( TTVpStations(Stations.Objects[IdxOf]).NPData.Strings[ProgramIndex+1]);
        Info.TimeLength := DiffMinutes(Info.TimeBegin, Info.TimeEnd);
      end;      }
    //----
    if CalcRect=True then
    begin
      Height := RItem.Top - R1.Top;
    end;

  end;

  if CalcRect=False then
  begin
    //DRAW STATION ICON
    Cnv.Draw(RItemTop.Right - RItemTop.Left - imgLogo.Width, RItemTop.Top, imgLogo.Picture.Graphic);
  end;

end;

procedure TfrmQIPPlugin.DrawHint(Cnv: TCanvas; R : TRect; CalcRect: Boolean; spec: pSpecCntUniq; var Width: Integer; var Height: Integer);
var
  PlugMsg1  : TPluginMessage;
  wFontName : WideString;
  iFontSize : Integer;
  QipColors : pQipColors;

  R1, RItem, RCalc, RDraw : TRect;
  sText : WideString;
  idx : Integer;

begin

  if CL.Count = 0 then
    Exit;


  SetBkMode(Cnv.Handle, TRANSPARENT);

  PlugMsg1.Msg       := PM_PLUGIN_GET_COLORS_FONT;
  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);
  wFontName := PWideChar(PlugMsg1.WParam);
  iFontSize := PlugMsg1.LParam;
  QipColors := pQipColors(PlugMsg1.NParam);


  R1 := Rect(R.Left+5, R.Top+5, R.Right-5, R.Bottom-5);


  if CalcRect=True then
  begin
    Width := 200;
    Height := 0;

    R1.Left  := 0;
    R1.Right := 200;
//    R1.Top := 0;
//    R1.Bottom := 200;
  end;

  if CL.Strings[spec.Index]='CL' then
  begin
    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := R1.Top;
    RItem.Bottom  := R1.Bottom;


    DrawStation(Cnv, TCL(CL.Objects[spec^.Index]), CalcRect, R1, RItem, Width, Height);

  end
  else if CL.Strings[spec.Index]='CLGuide' then
  begin
    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := R1.Top;
    RItem.Bottom  := R1.Bottom;

    // --- Nazev prehledu ---
    RCalc.Left    := 0;
    RCalc.Right   := RItem.Right - RItem.Left;
    RCalc.Top     := 0;
    RCalc.Bottom  := 0;

    Cnv.Font.Style := [fsBold];
    sText := TCLGuide(CL.Objects[spec^.Index]).Name;
    DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RCalc, DT_LEFT + DT_WORDBREAK + DT_CALCRECT );

    RDraw.Left    := RItem.Left;
    RDraw.Right   := RItem.Left+RCalc.Right;
    RDraw.Top     := RItem.Top;
    RDraw.Bottom  := RItem.Top+RCalc.Bottom;

    if CalcRect=False then
    begin
      DrawTextW(Cnv.Handle, PWideChar(sText), Length(sText), RDraw, DT_LEFT + DT_WORDBREAK);
    end;

    RItem.Left    := R1.Left;
    RItem.Right   := R1.Right;
    RItem.Top     := RDraw.Bottom;
    RItem.Bottom  := R1.Bottom;
    //---

    //--- oddelit
    RItem.Top     := RItem.Top+13;
    //---

    idx:=0;
    while ( idx<= TCLGuide(CL.Objects[spec^.Index]).Items.Count - 1 ) do
    begin
      Application.ProcessMessages;


      DrawStation(Cnv, TCL(TCLGuide(CL.Objects[spec^.Index]).Items.Objects[idx]), CalcRect, R1, RItem, Width, Height);

      //--- oddelit
      RItem.Top     := RItem.Top+13;
      //---

      Inc(idx);
    end;
       {
    //odecist posledni oddeleni
    RItem.Top     := RItem.Top-13;
         }
    if CalcRect=True then
    begin
      Height := RItem.Top - R1.Top;
    end;

  end;

end;

{******************************************************************************}
procedure TfrmQIPPlugin.GetSpecContactHintSize(var PlugMsg: TPluginMessage);
var ContactId : DWord;
    //Data      : Pointer;

//    CntIndex  : DWord;

    spec : pSpecCntUniq;

    Img : TImage;

    Rx : TRect;
begin
(*  //get spec contact id from msg
  ContactId := PlugMsg.WParam;

  spec := pSpecCntUniq(PlugMsg.Result);


  //set contact hint Width
  PlugMsg.LParam := 200;


  //set contact hint Height
  PlugMsg.NParam := 13 * 8;
*)
         {
  Rx.Left    := 0;
  Rx.Top     := 0;
  Rx.Right   := 0;
  Rx.Bottom  := 0;  }

  ContactId := PlugMsg.WParam;

  spec := pSpecCntUniq(PlugMsg.Result);

  Img := TImage.Create(Self);
  try
    DrawHint( Img.Canvas, Rx, True, spec, PlugMsg.LParam, PlugMsg.NParam);
  finally
    Img.Free;
  end;

end;

{******************************************************************************}
procedure TfrmQIPPlugin.DrawSpecContactHint(PlugMsg: TPluginMessage);
var ContactId : DWord;
    //Data      : Pointer;
    Cnv       : TCanvas;
    R         : PRect;
    spec : pSpecCntUniq;
    tmpI : Integer;

begin

  ContactId := PlugMsg.WParam;

  spec := pSpecCntUniq(PlugMsg.Result);

  Cnv       := TCanvas.Create;
  try
    Cnv.Handle := PlugMsg.LParam;
    R := PRect(PlugMsg.NParam);

    DrawHint( Cnv, R^, False, spec, tmpI, tmpI);
  finally
    Cnv.Free;
  end;

end;

{******************************************************************************}
procedure TfrmQIPPlugin.XstatusChangedByUser(PlugMsg: TPluginMessage);
begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.InstantMsgRcvd(var PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.InstantMsgSend(var PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.NewMessageFlashing(PlugMsg: TPluginMessage);
//var wAccName, wNickName : WideString;
begin
//  {getting aaccount name and nick name of contact whose msg was received but not read yet}
//  wAccName  := PWideChar(PlugMsg.WParam);
//  wNickName := PWideChar(PlugMsg.LParam);
end;

{******************************************************************************}
procedure TfrmQIPPlugin.NewMessageStopFlashing(PlugMsg: TPluginMessage);
begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.AddNeededBtns(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.MsgBtnClicked(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.SpecMsgRcvd(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.StatusChanged(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.ImRcvdSuccess(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.ContactStatusRcvd(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.ChatTabAction(PlugMsg: TPluginMessage);

begin

end;

procedure TfrmQIPPlugin.CMAdvDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; State: TOwnerDrawState);
begin


end;

{******************************************************************************}
procedure TfrmQIPPlugin.AddNeededChatBtns(PlugMsg: TPluginMessage);

begin

end;


{******************************************************************************}
procedure TfrmQIPPlugin.ChatBtnClicked(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.ChatMsgRcvd(PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.ChatMsgSending(var PlugMsg: TPluginMessage);

begin

end;

{******************************************************************************}
procedure TfrmQIPPlugin.EnumInfo(PlugMsg: TPluginMessage);
begin

end;

////////////////////////////////////////////////////////////////////////////////

function TfrmQIPPlugin.FadeMsg(FType: Byte; FIcon: HICON; FTitle: WideString; FText: WideString; FTextCenter: Boolean; FNoAutoClose: Boolean; pData: Integer) : DWORD;
var PlugMsg1 : TPluginMessage;
    aFadeWnd: TFadeWndInfo;
begin

  //0 - message style, 1 - information style, 2 - warning style
  aFadeWnd.FadeType  := FType;//1;
  //its better to use ImageList of icons if you gonna show more than one icon everytime,
  //else you have to care about destroying your HICON after showing fade window, cauz core makes self copy of HICON
//  aFadeWnd.FadeIcon  := LoadImage(0, IDI_INFORMATION, IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR or LR_SHARED);


  aFadeWnd.FadeIcon  := FIcon;

  aFadeWnd.FadeTitle := FTitle;
  aFadeWnd.FadeText  := FText;

  //if your text is too long, then you have to set this param to False
  aFadeWnd.TextCentered := FTextCenter;

  //it's recommended to set this parameter = False if your fade window is not very important
  aFadeWnd.NoAutoClose := FNoAutoClose;

  //send msg to qip core
  PlugMsg1.Msg       := PM_PLUGIN_FADE_MSG;
  PlugMsg1.WParam    := LongInt(@aFadeWnd);


  PlugMsg1.LParam    := 0; //vlastni Pointer

  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);


  //if your window was successfuly shown then core returns Result = True (Result is unique id of fade msg),
  //else you should try later to show it again
  if Boolean(PlugMsg1.Result) then
    //LogAdd('Fading popup window successefuly shown: FadeMsg ID is '+ IntToStr(PlugMsg1.Result))
    Result := PlugMsg1.Result
  else
    //LogAdd('Fading popup window was NOT shown');
    Result := 0;


end;

procedure TfrmQIPPlugin.AddFadeMsg(
                                    FadeType     : Byte;        //0 - message style, 1 - information style, 2 - warning style
                                    FadeIcon     : HICON;       //icon in the top left corner of the window
                                    FadeTitle    : WideString;
                                    FadeText     : WideString;
                                    TextCentered : Boolean;     //if true then text will be centered inside window
                                    NoAutoClose  : Boolean;     //if NoAutoClose is True then wnd will be always shown until user close it. Not recommended to set this param to True.
                                    CloseTime    : Integer;
                                    pData        : Integer
                                  );
var fmFadeMsg  : TFadeMsg;
begin
  fmFadeMsg := TFadeMsg.Create;
  fmFadeMsg.FadeType      := FadeType ;
  fmFadeMsg.FadeIcon      := FadeIcon;
  fmFadeMsg.FadeTitle     := FadeTitle;
  fmFadeMsg.FadeText      := FadeText;
  fmFadeMsg.TextCentered  := TextCentered;
  fmFadeMsg.NoAutoClose   := NoAutoClose;
  fmFadeMsg.CloseTime     := CloseTime;
  fmFadeMsg.pData         := pData;

  FadeMsgs.Add('FADEMSG');
  FadeMsgs.Objects[FadeMsgs.Count - 1] := fmFadeMsg.Create;

end;

////////////////////////////////////////////////////////////////////////////////
procedure TfrmQIPPlugin.AddSpecContact(CntType: DWord; CntIndex: DWord; var UniqID: TSpecCntUniq; HeightCnt: Integer = 19);
var PlugMsg1 : TPluginMessage;
{    spec : TSpecCntUniq;
    specp: pSpecCntUniq;}
begin
  PlugMsg1.Msg    := PM_PLUGIN_SPEC_ADD_CNT;

  //set height of your contact here, min 8, max 100.
  PlugMsg1.WParam := HeightCnt;

  UniqID.ItemType := CntType;
  UniqID.Index    := CntIndex;

  //Pointer
  PlugMsg1.LParam := LongInt(@UniqID);

//  specp := pSpecCntInfo(PlugMsg1.LParam);
//  showmessage('');
//showmessage(  IntToStr(specp.ItemType) + ' / ' + IntToStr(specp.Index));

  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);

  UniqID.UniqID := PlugMsg1.Result;

end;


procedure TfrmQIPPlugin.RedrawSpecContact(UniqID: DWord);
var
  PlugMsg1 : TPluginMessage;
begin
  if UniqID = 0 then Exit;

  PlugMsg1.Msg    := PM_PLUGIN_SPEC_REDRAW;
  PlugMsg1.WParam := UniqID;
  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);
end;

procedure TfrmQIPPlugin.RemoveSpecContact(var UniqID: DWord);
var
  PlugMsg1 : TPluginMessage;
begin
  if UniqID = 0 then Exit;

  PlugMsg1.Msg    := PM_PLUGIN_SPEC_DEL_CNT;
  PlugMsg1.WParam := UniqID;

  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);

  if Boolean(PlugMsg1.Result) then
    UniqID := 0;
end;

function TfrmQIPPlugin.GetLang(ID: Word) : WideString;
var
  PlugMsg1 : TPluginMessage;
begin
  PlugMsg1.Msg       := PM_PLUGIN_GET_LANG_STR;
  PlugMsg1.WParam    := ID;
  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);
  Result := PWideChar(PlugMsg1.Result);
end;


procedure TfrmQIPPlugin.InfiumClose(itype: Word);
var PlugMsg1 : TPluginMessage;
begin
  // 0 - close; 1 - restart

  PlugMsg1.Msg    := PM_PLUGIN_INFIUM_CLOSE;
  PlugMsg1.WParam := itype;
  PlugMsg1.DllHandle := DllHandle;
  FPluginSvc.OnPluginMessage(PlugMsg1);
end;



procedure TfrmQIPPlugin.ShowContactMenu(pX, pY : Integer; Index : Integer );
//var
//  NewItem, NewItemTop10Folder, NewItemTop10: TMenuItem;

//  i: Integer;
//  StationsPlayCount, MenuGroups : TStringlist;
//  idxGroup: Integer;
//  bTop10Items : Boolean;
begin
(*  MenuGroups := TStringList.Create;
  MenuGroups.Clear;

  StationsPlayCount := TStringList.Create;
  StationsPlayCount.Clear;

  for i:=1 to miContactMenu_Stations.Count do miContactMenu_Stations.Delete(0);

  bTop10Items := False;

  //Sekce - Nejpøehrávanìjších rádíí
  NewItemTop10Folder := TMenuItem.Create(Self);
  NewItemTop10Folder.Caption := LNG('MENU ContactMenu', 'Favourites', 'Favourites');
  NewItemTop10Folder.Tag     := -1;
  //NewItemTop10Folder.OnClick := miContactMenu_StationsClick;
  NewItemTop10Folder.OnDrawItem := DrawMenu;
  NewItemTop10Folder.OnMeasureItem := MeasureMenu;
  NewItemTop10Folder.ImageIndex := 11;
  miContactMenu_Stations.Add(NewItemTop10Folder);

  NewItem := TMenuItem.Create(Self);
  NewItem.Caption := '-';
  NewItem.Tag     := -1;
  //NewItem.OnClick := miContactMenu_StationsClick;
  NewItem.OnDrawItem := DrawMenu;
  NewItem.OnMeasureItem := MeasureMenu;
  miContactMenu_Stations.Add(NewItem);

  StationsPlayCount.Assign(Stations);


  //StationsPlayCount := SortStationsPlayCount(StationsPlayCount);
  StationsPlayCount := SortStationsPlayTime(StationsPlayCount);


  for i := 0 to StationsPlayCount.Count - 1 do
  begin
    if (TStation(StationsPlayCount.Objects[i]).PlayCount = 0) or (i > 9)  then
      break;

    NewItemTop10 := TMenuItem.Create(Self);
    NewItemTop10.Caption := TStation(StationsPlayCount.Objects[i]).Name;
    NewItemTop10.Tag     := Stations.IndexOfObject(StationsPlayCount.Objects[i]);
    NewItemTop10.OnClick := miContactMenu_StationsClick;
    NewItemTop10.OnDrawItem := DrawMenu;
    NewItemTop10.OnMeasureItem := MeasureMenu;

    if Radio_StationID = NewItemTop10.Tag then NewItemTop10.Checked := True;

    NewItemTop10Folder.Add(NewItemTop10);

    bTop10Items := True;

  end;

  if bTop10Items = False then
  begin
    NewItemTop10 := TMenuItem.Create(Self);
    NewItemTop10.Caption := QIPPlugin.GetLang(LI_NO_ACCOUNT);
    NewItemTop10.Enabled := False;
    NewItemTop10.Tag     := 0;
    NewItemTop10.OnClick := miContactMenu_StationsClick;
    NewItemTop10.OnDrawItem := DrawMenu;
    NewItemTop10.OnMeasureItem := MeasureMenu;
    NewItemTop10Folder.Add(NewItemTop10);
  end;


  for i := 0 to Stations.Count - 1 do
  begin
    if TStation(Stations.Objects[i]).Group='' then
    begin
      NewItem := TMenuItem.Create(Self);
      NewItem.Caption := TStation(Stations.Objects[i]).Name;
      NewItem.Tag     := i;
      NewItem.OnClick := miContactMenu_StationsClick;
      NewItem.OnDrawItem := DrawMenu;
      NewItem.OnMeasureItem := MeasureMenu;

      if Radio_StationID = i then NewItem.Checked := True;

      miContactMenu_Stations.Add(NewItem);
    end
    else
    begin
      idxGroup := MenuGroups.IndexOf(TStation(Stations.Objects[i]).Group);

      if idxGroup = -1 then
      begin
        MenuGroups.Add(TStation(Stations.Objects[i]).Group);
        idxGroup := MenuGroups.Count - 1;
        MenuGroups.Objects[idxGroup] := TMenuItem.Create(Self);

        TMenuItem(MenuGroups.Objects[idxGroup]).Caption := TStation(Stations.Objects[i]).Group;
        TMenuItem(MenuGroups.Objects[idxGroup]).Tag     := -1;
        //TMenuItem(MenuGroups.Objects[idxGroup]).OnClick := miContactMenu_StationsClick;
        TMenuItem(MenuGroups.Objects[idxGroup]).OnDrawItem := DrawMenu;
        TMenuItem(MenuGroups.Objects[idxGroup]).OnMeasureItem := MeasureMenu;
        TMenuItem(MenuGroups.Objects[idxGroup]).ImageIndex := 10;
        miContactMenu_Stations.Add(TMenuItem(MenuGroups.Objects[idxGroup]));
      end;

      NewItem := TMenuItem.Create(Self);
      NewItem.Caption := TStation(Stations.Objects[i]).Name;
      NewItem.Tag     := i;
      NewItem.OnClick := miContactMenu_StationsClick;
      NewItem.OnDrawItem := DrawMenu;
      NewItem.OnMeasureItem := MeasureMenu;

      if Radio_StationID = i then NewItem.Checked := True;

      TMenuItem(MenuGroups.Objects[idxGroup]).Add(NewItem);

//        TMenuItem(MenuGroups.Objects[idxGroup]).
    end;
  end;





  for i:=1 to miContactMenu_Formats.Count do miContactMenu_Formats.Delete(0);
  if Radio_StationID > Stations.Count - 1 then
    //dodelat
  else
  begin
    for i := 0 to TStation(Stations.Objects[Radio_StationID]).Streams.Count - 1 do
    begin
      NewItem := TMenuItem.Create(Self);
      NewItem.Caption := TStream(TStation(Stations.Objects[Radio_StationID]).Streams.Objects[i]).Format;
      NewItem.Tag     := i;
      NewItem.OnClick := miContactMenu_FormatsClick;
      NewItem.OnDrawItem := DrawMenu;
      NewItem.OnMeasureItem := MeasureMenu;

      if Radio_StreamID = i then NewItem.Checked := True;

      miContactMenu_Formats.Add(NewItem);
    end;

  end;

  miContactMenu_Stations.Caption := LNG('MENU ContactMenu', 'Stations', 'Stations');
  miContactMenu_Formats.Caption := LNG('MENU ContactMenu', 'Format', 'Format');

  miContactMenu_Informations.Caption := QIPPlugin.GetLang(LI_INFORMATION);
  miContactMenu_Equalizer.Caption := LNG('MENU ContactMenu', 'Equalizer', 'Equalizer');
  miContactMenu_Recording.Caption := LNG('MENU ContactMenu', 'Recording', 'Recording');
  miContactMenu_Volume.Caption := LNG('MENU ContactMenu', 'Volume', 'Volume');
  miContactMenu_EditStations.Caption := LNG('MENU ContactMenu', 'EditStations', 'Edit stations');
  miContactMenu_FastAddStation.Caption := LNG('MENU ContactMenu', 'FastAddStation', 'Fast add station');
  miContactMenu_Options.Caption := QIPPlugin.GetLang(LI_OPTIONS);

  if Radio_Playing = False then
  begin
    miContactMenu_OnOff.Caption := LNG('MENU ContactMenu', 'RadioOn', 'Radio on');
    TIcon(PluginSkin.MenuIcons.Objects[0]).Assign(PluginTheme.State.PicturePlay);
  end
  else
  begin
    miContactMenu_OnOff.Caption := LNG('MENU ContactMenu', 'RadioOff', 'Radio off');
    TIcon(PluginSkin.MenuIcons.Objects[0]).Assign(PluginTheme.State.PictureStop);
  end;      *)

  miContactMenu_Open.Caption            := QIPPlugin.GetLang(LI_OPEN);
  miContactMenu_Edit.Caption            := LNG('MENU ContactMenu', 'Edit', 'Edit');
  miContactMenu_Remove.Caption          := QIPPlugin.GetLang(LI_DELETE);
  miContactMenu_RefreshAll.Caption      := LNG('MENU ContactMenu', 'RefreshAll', 'Refresh all');
  miContactMenu_Search.Caption          := QIPPlugin.GetLang(LI_SEARCH);
  miContactMenu_EditStations.Caption    := LNG('MENU ContactMenu', 'EditStations', 'Edit stations');
  miContactMenu_PlannedPrograms.Caption := LNG('MENU ContactMenu', 'ScheduledProgrammes', 'Scheduled programmes');
  miContactMenu_Options.Caption         := QIPPlugin.GetLang(LI_OPTIONS);

  if CL.Count = 0 then
  begin
    miContactMenu_Open.Visible := False;
    miContactMenu_Edit.Visible := False;
    miContactMenu_Remove.Visible := False;
    miContactMenu_RefreshAll.Visible := False;
  end
  else
  begin
    if ShowAsOneContact = True then
    begin
      miContactMenu_Open.Visible := True;
      miContactMenu_Edit.Visible := False;
      miContactMenu_Remove.Visible := False;
      miContactMenu_RefreshAll.Visible := True;
    end
    else
    begin
      miContactMenu_Open.Visible := True;
      miContactMenu_Edit.Visible := True;
      miContactMenu_Remove.Visible := True;
      miContactMenu_RefreshAll.Visible := True;
    end;
  end;

  pmContactMenu.Tag := Index;
  pmContactMenu.Popup(pX,pY);

end;




end.
