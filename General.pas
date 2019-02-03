unit General;

interface

uses
  SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls, Controls,
  fQIPPlugin, u_common, IniFiles,
  About, Options, Search, Window, PlanEdit, PlanList, ItemOptions, ProgramInfo,
  CLItems, Colors,
  DownloadFile, uOptions;

type
{
  if ExecRegExpr ('\bg', 'abcdefg') then
  begin
    showmessage('valid');
  end;

  memReplaceRes.Text := ReplaceRegExpr(edSearchFor.Text, memSearchIn.Text, edReplaceWith.Text, false);
}

  { Bookmark Window }
  TBookmarkWindow = class
  public
    CLPos          : Integer;
    Date           : WideString;
    Data           : TStringList;
  end;

  {CL}
  TCL = class
  public
    UniqID              : TSpecCntUniq;
    Name                : WideString;
    ID                  : WideString;
    Width               : Int64;
    Conf                : WideString;

    CheckingUpdate      : Boolean;
  end;

  {CLGuide}
  TCLGuide = class
  public
    UniqID              : TSpecCntUniq;
    Name                : WideString;
    Items               : TStringList;

    CheckingUpdate      : Boolean;
  end;

  { Langs }
  TLangs = class
  public
    QIPID : DWORD;
    Name  : WideString;
    Trans : WideString;
  end;


  TImageIcon = record
    Image             : TImage;
    Icon              : TIcon;
  end;

  { PluginSkin }
  TPluginSkin = record
    PluginIconBig      : TImage;
    PluginIcon         : TImageIcon;

    IconProgram        : TImageIcon;
    IconNoProgram      : TImageIcon;
    IconGuide          : TImageIcon;
    Check              : TImageIcon;


    Options            : TImageIcon;
    Open               : TImageIcon;
    Edit               : TImageIcon;
    Refresh            : TImageIcon;
    EditItems          : TImageIcon;
    Search             : TImageIcon;

    Close              : TImageIcon;

    Info               : TImageIcon;

{
    Volume             : TImageIcon;
    Equalizer          : TImageIcon;

    Recording          : TImageIcon;
    Stations           : TImageIcon;
    Formats            : TImageIcon;
    EditStations       : TImageIcon;
    FastAddStation     : TImageIcon;}


{    ST_online          : TImageIcon;
    ST_ffc             : TImageIcon;
    ST_away            : TImageIcon;
    ST_na              : TImageIcon;
    ST_occ             : TImageIcon;
    ST_dnd             : TImageIcon;
    ST_invisible       : TImageIcon;
    ST_lunch           : TImageIcon;
    ST_depression      : TImageIcon;
    ST_evil            : TImageIcon;
    ST_at_home         : TImageIcon;
    ST_at_work         : TImageIcon;
    ST_offline         : TImageIcon;

    Mute               : TImageIcon;
    Unmute             : TImageIcon;
    Export             : TImageIcon;
    Import             : TImageIcon;      }

    General            : TImageIcon;
    Advanced           : TImageIcon;
    Layout             : TImageIcon;
    HotKeys            : TImageIcon;
    Plugins            : TImageIcon;
    Connect            : TImageIcon;


    Plan               : TImageIcon;
    Plan_Add           : TImageIcon;
    Plan_Delete        : TImageIcon;
    Plan_Edit          : TImageIcon;


    MenuIcons          : TStringList;
    OptionsIcons       : TStringList;

    CheckMenuItem      : TIcon;
    Update             : TImageIcon;
    Comment            : TImageIcon;

    Folder             : TImageIcon;
    Favourite          : TImageIcon;

    Remove             : TImageIcon;

    ItemAdd            : TImageIcon;
    ItemRemove         : TImageIcon;
    ItemUp             : TImageIcon;
    ItemDown           : TImageIcon;


    Font               : TImageIcon;
    Color              : TImageIcon;


  end;



  procedure OpenColors(var sColor : WideString);

  procedure OpenAbout;
  procedure OpenOptions;

  procedure OpenSearch;

  procedure OpenWindow;
  procedure CloseWindow;
  procedure OpenBookmark(CLPos: Integer; NoShowWindow: Boolean);


  procedure OpenPlanList;
  procedure OpenPlanEdit(DataID : Int64);

  procedure OpenItemOptions(idx : Int64);

  procedure OpenProgramInfo(ProgramID: Int64);

  procedure OpenRemoveContact(idx : Int64);

  procedure OpenCLItems;


  procedure GetLangs;

  procedure HotKeysActivate;
  procedure HotKeysDeactivate;


  procedure AddLog(sText : WideString);

  procedure AddSpecContacts;
  procedure RemoveSpecContacts;

const
  FrequencyCount = 10;

var
  QIPPlugin       : TfrmQIPPlugin;
  PluginDllPath,
  QIPInfiumPath,
  ProfilePath,
  PluginVersion,
  PluginVersionWithoutBuild,
  PluginLanguage,
  QIPInfiumLanguage : WideString;
  PluginSkin      : TPluginSkin;
  Account_DisplayName, Account_ProfileName, Account_FileName : WideString;

  INT_PLUGIN_HINT, INT_PLUGIN_DESC : WideString;

//  frmBgColor : TColor;


  CL, Stations, TVpPlan, BookmarkWindow : TStringList;

  Langs : TStringList;


  clLine1,clLine2,clPlanned,clTimerInfo,clStation,clProgress1,clProgress2
   : WideString;

  FAbout        : TfrmAbout;
  FOptions      : TfrmOptions;
  FSearch       : TfrmSearch;
  FWindow       : TfrmWindow;
  FPlanEdit     : TfrmPlanEdit;
  FPlanList     : TfrmPlanList;
  FItemOptions  : TfrmItemOptions;
  FProgramInfo  : TfrmProgramInfo;
  FCLItems      : TfrmCLItems;
  FColors       : TfrmColors;


  AboutIsShow, OptionsIsShow, EditItemIsShow, SearchIsShow, WindowIsShow,
  PlanEditIsShow, PlanListIsShow, ItemOptionsIsShow, ProgramInfoIsShow,
  CLItemsIsShow, ColorsIsShow : Boolean;

  FPlanList_DataID : Int64;
  FItemOptions_Index : Int64;

  FProgramInfo_ProgramID : Int64;

  FColors_Color : WideString;


  UniqContactId      : DWord;

  DTFormat : TFormatSettings;

  UseQIPMute, QIPSound, ShowComments: Boolean;

  HotKeyEnabled : Boolean;
  HotKeyOpenTVp : Integer;

  DownloadingInfo : TPositionInfo;

  SpecCntUniq   : TSpecCntUniq;

  QIP_Colors : TQipColors;

  osVerInfo: TOSVersionInfo;

  cthread: DWORD = 0;
  DownInfo : WideString;

  CloseBookmarks,
  AlwaysShowAllStations,
  ShowAsOneContact  : Boolean;

  SpecCntText : WideString;
  SpecCntFont : TOwnFont;

  UpdateProgrammeInterval : Integer;
  LastUpdate          : TDateTime;
  NextUpdate          : TDateTime;


implementation

uses u_lang_ids, Convs, uLNG, uImage, uSuperReplace, HotKeyManager,
     TextSearch, uFileFolder, uINI, u_qip_plugin, XMLFiles, TVpDLL;


procedure OpenColors(var sColor : WideString);
begin
  if ColorsIsShow = False then
  begin
    FColors_Color := sColor;
    FColors := TfrmColors.Create(nil);
    FColors.ShowModal;
    sColor := FColors_Color;

    try
      if Assigned(FColors) then FreeAndNil(FColors);
    finally

    end;
  end;
end;

procedure OpenAbout;
begin
  if AboutIsShow = False then
  begin
    FAbout := TfrmAbout.Create(nil);
    FAbout.Show;
  end;
end;

procedure OpenOptions;
begin
  if OptionsIsShow = False then
  begin
    FOptions := TfrmOptions.Create(nil);
    FOptions.Show;
  end;
end;


procedure OpenSearch;
begin
  if SearchIsShow = False then
  begin
    FSearch := TfrmSearch.Create(nil);
    FSearch.Show;
  end;

end;


procedure OpenWindow;
begin
  if WindowIsShow = False then
  begin
    FWindow := TfrmWindow.Create(nil);
    FWindow.Show;
  end;
end;

procedure CloseWindow;
begin
  try
    FWindow.Close;
  except

  end;
end;


procedure OpenBookmark(CLPos: Integer; NoShowWindow: Boolean);
var
  idx, hIndex: Int64;

Label NoAddBookmark;
begin
  if (AlwaysShowAllStations=True) or (ShowAsOneContact = True) or (CLPos = -1) then
  begin

    if WindowIsShow=True then
    begin
      if (FWindow.tabWindow.Tabs.Count > CLPos) and (CLPos > -1 ) then
      begin
        FWindow.tabWindow.TabIndex := CLPos;
        FWindow.ShowBookmark(CLPos);
      end;

      SetForegroundWindow(FWindow.Handle);
    end
    else
    begin
      BookmarkWindow.Clear;

      idx:=0;
      while ( idx <= CL.Count - 1 ) do
      begin

        BookmarkWindow.Add('ITEM');
        hIndex:= BookmarkWindow.Count - 1;
        BookmarkWindow.Objects[hIndex] := TBookmarkWindow.Create;
        TBookmarkWindow(BookmarkWindow.Objects[hIndex]).CLPos := idx;
        TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data  := TStringList.Create;
        TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data.Clear;

        Inc(idx);
      end;

      OpenWindow;

      if (FWindow.tabWindow.Tabs.Count > CLPos) and (CLPos > -1 ) then
      begin
        FWindow.tabWindow.TabIndex := CLPos;
        FWindow.ShowBookmark(CLPos);
      end;

    end;

  end
  else
  begin

    idx:=0;
    while ( idx <= BookmarkWindow.Count - 1 ) do
    begin
        Application.ProcessMessages;
        if TBookmarkWindow(BookmarkWindow.Objects[idx]).CLPos = CLPos then
        begin
          hIndex := idx;
          Goto NoAddBookmark;
        end;

      Inc(idx);
    end;

    BookmarkWindow.Add('ITEM');
    hIndex:= BookmarkWindow.Count - 1;
    BookmarkWindow.Objects[hIndex] := TBookmarkWindow.Create;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).CLPos := CLPos;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data  := TStringList.Create;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data.Clear;


    if WindowIsShow=True then
    begin
      FWindow.AddNewTab(hIndex);

      SetForegroundWindow(FWindow.Handle);
    end
    else
    begin
      OpenWindow;
    end;


    EXIT;


    NoAddBookmark:
    if WindowIsShow=True then
    begin
      FWindow.tabWindow.TabIndex := hIndex;
      FWindow.ShowBookmark(hIndex);

      SetForegroundWindow(FWindow.Handle);
    end
    else
    begin
      FWindow.tabWindow.TabIndex := hIndex;
      FWindow.ShowBookmark(hIndex);

      OpenWindow;
    end;
  end;
(*
  if WindowIsShow=True then
  begin
    FWindow.AddNewTab(hIndex);

    if i=0 then
    begin
      FWindow.tabWindow.TabIndex := hIndex;
      FWindow.ShowBookmark(hIndex);
    end;

    SetForegroundWindow(FWindow.Handle);
  end;



  if RSSPos = -1 then
  begin




      Application.ProcessMessages;
      BookmarkWindow.Add('FEED');
      hIndex:= BookmarkWindow.Count - 1;
      BookmarkWindow.Objects[hIndex] := TBookmarkWindow.Create;
      TBookmarkWindow(BookmarkWindow.Objects[hIndex]).CLPos  := CLPos;
      TBookmarkWindow(BookmarkWindow.Objects[hIndex]).RSSPos := i;

      TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data := TStringList.Create;
      TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data.Clear;




      NextRSS:

      Inc(i);
    end;

  end
  else
  begin

    ii:=0;
    while ( ii<= BookmarkWindow.Count - 1 ) do
    begin
      Application.ProcessMessages;
      if (TBookmarkWindow(BookmarkWindow.Objects[ii]).CLPos = CLPos) and (TBookmarkWindow(BookmarkWindow.Objects[ii]).RSSPos = RSSPos) then
      begin
        hIndex := ii;
        Goto NoAddRSS;
      end;

      Inc(ii);
    end;

    Application.ProcessMessages;
    BookmarkWindow.Add('ITEM');
    hIndex:= BookmarkWindow.Count - 1;
    BookmarkWindow.Objects[hIndex] := TBookmarkWindow.Create;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).CLPos  := CLPos;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).RSSPos := RSSPos;

    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data := TStringList.Create;
    TBookmarkWindow(BookmarkWindow.Objects[hIndex]).Data.Clear;


    if WindowIsShow=True then
    begin
      FWindow.AddNewTab(hIndex);
      SetForegroundWindow(FWindow.Handle);
    end;

    NoAddRSS:

    if WindowIsShow=True then
    begin
      FWindow.tabWindow.TabIndex := hIndex;
      FWindow.ShowBookmark(hIndex);
      SetForegroundWindow(FWindow.Handle);
    end;

  end;


  if BookmarkWindow.Count > 0 then
    OpenWindow;
*)
//  OpenWindow;
end;


procedure OpenPlanList;
begin
  if PlanListIsShow = False then
  begin
    FPlanList := TfrmPlanList.Create(nil);
    FPlanList.Show;
  end;
end;

procedure OpenPlanEdit(DataID : Int64);
begin
  if PlanEditIsShow = False then
  begin
    FPlanList_DataID := DataID;
    FPlanEdit := TfrmPlanEdit.Create(nil);
    FPlanEdit.Show;
  end;
end;

procedure OpenItemOptions(idx : Int64);
begin
  if ItemOptionsIsShow = False then
  begin
    FItemOptions_Index := idx;
    FItemOptions := TfrmItemOptions.Create(nil);
    FItemOptions.Show;
  end;
end;

procedure OpenProgramInfo(ProgramID: Int64);
begin
  if ProgramInfoIsShow = False then
  begin
    FProgramInfo_ProgramID := ProgramID;
    FProgramInfo := TfrmProgramInfo.Create(nil);
    FProgramInfo.Show;
  end;
end;

function Repl1(sText: WideString; sStation: WideString): WideString;
begin
  Result := StringReplace(sText, '%STATION%', sStation, [rfReplaceAll]);
end;

procedure OpenRemoveContact(idx : Int64);
var
  sText : WideString;
begin

  RemoveSpecContacts;


  if CL.Strings[idx]='CL' then
    sText := Repl1 ( LNG('TEXTS','MsgStationRemove', 'Do you really want to remove station "%STATION%" from list?' ) , TCL(CL.Objects[idx]).Name )
//    sText := 'Opravdu chcete odstranit stanici "' + TCL(CL.Objects[idx]).Name + '"?'
  else if CL.Strings[idx]='CLGuide' then
    sText := Repl1 ( LNG('TEXTS','MsgStationRemove', 'Do you really want to remove station "%STATION%" from list?' ) , TCLGuide(CL.Objects[idx]).Name );
//    sText := 'Opravdu chcete odstranit pøehled stanic "' + TCLGuide(CL.Objects[idx]).Name + '"?';


  if MessageBoxW(0, PWideChar( sText ), 'TVp', MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    {
    if CL.Strings[idx]='CL' then
      edtName.Text := TCL(CL.Objects[idx]).Name
    else if CL.Strings[idx]='CLGuide' then
      edtName.Text := TCLGuide(CL.Objects[idx]).Name;
     }

   { if CL.Strings[idx]='CL' then
      QIPPlugin.RemoveSpecContact( TCL(CL.Objects[idx]).UniqID.UniqID )
    else if CL.Strings[idx]='CLGuide' then
      QIPPlugin.RemoveSpecContact( TCLGuide(CL.Objects[idx]).UniqID.UniqID );
     }

    CL.Delete(idx);

    SaveCL;

    LoadStationsData;
  end;

  AddSpecContacts;

end;

procedure OpenCLItems;
begin
  if CLItemsIsShow = False then
  begin
    FCLItems := TfrmCLItems.Create(nil);
    FCLItems.Show;
  end;
end;




procedure AddLang(QIPID: DWord; Name: WideString);
var hIndex: Integer;
begin
  Langs.Add(Name);
  hIndex:= Langs.Count - 1;
  Langs.Objects[hIndex] := TLangs.Create;
  TLangs(Langs.Objects[hIndex]).QIPID  := QIPID;
  TLangs(Langs.Objects[hIndex]).Name   := Name;
  if QIPID<>0 then
    TLangs(Langs.Objects[hIndex]).Trans  := QIPPlugin.GetLang(QIPID);
end;

procedure GetLangs;
begin
  Langs := TStringList.Create;
  Langs.Clear;

  AddLang(0                   , '');
  AddLang(LI_LANG_ARABIC      , 'ARABIC');
  AddLang(LI_LANG_BHOJPURI    , 'BHOJPURI');
  AddLang(LI_LANG_BULGARIAN   , 'BULGARIAN');
  AddLang(LI_LANG_BURMESE     , 'BURMESE');
  AddLang(LI_LANG_CANTONESE   , 'CANTONESE');
  AddLang(LI_LANG_CATALAN     , 'CATALAN');
  AddLang(LI_LANG_CHINESE     , 'CHINESE');
  AddLang(LI_LANG_CROATIAN    , 'CROATIAN');
  AddLang(LI_LANG_CZECH       , 'CZECH');
  AddLang(LI_LANG_DANISH      , 'DANISH');
  AddLang(LI_LANG_DUTCH       , 'DUTCH');
  AddLang(LI_LANG_ENGLISH     , 'ENGLISH');
  AddLang(LI_LANG_ESPERANTO   , 'ESPERANTO');
  AddLang(LI_LANG_ESTONIAN    , 'ESTONIAN');
  AddLang(LI_LANG_FARSI       , 'FARSI');
  AddLang(LI_LANG_FINNISH     , 'FINNISH');
  AddLang(LI_LANG_FRENCH      , 'FRENCH');
  AddLang(LI_LANG_GAELIC      , 'GAELIC');
  AddLang(LI_LANG_GERMAN      , 'GERMAN');
  AddLang(LI_LANG_GREEK       , 'GREEK');
  AddLang(LI_LANG_HEBREW      , 'HEBREW');
  AddLang(LI_LANG_HINDI       , 'HINDI');
  AddLang(LI_LANG_HUNGARIAN   , 'HUNGARIAN');
  AddLang(LI_LANG_ICELANDIC   , 'ICELANDIC');
  AddLang(LI_LANG_INDONESIAN  , 'INDONESIAN');
  AddLang(LI_LANG_ITALIAN     , 'ITALIAN');
  AddLang(LI_LANG_JAPANESE    , 'JAPANESE');
  AddLang(LI_LANG_KHMER       , 'KHMER');
  AddLang(LI_LANG_KOREAN      , 'KOREAN');
  AddLang(LI_LANG_LAO         , 'LAO');
  AddLang(LI_LANG_LATVIAN     , 'LATVIAN');
  AddLang(LI_LANG_LITHUANIAN  , 'LITHUANIAN');
  AddLang(LI_LANG_MALAY       , 'MALAY');
  AddLang(LI_LANG_NORWEGIAN   , 'NORWEGIAN');
  AddLang(LI_LANG_POLISH      , 'POLISH');
  AddLang(LI_LANG_PORTUGUESE  , 'PORTUGUESE');
  AddLang(LI_LANG_ROMANIAN    , 'ROMANIAN');
  AddLang(LI_LANG_RUSSIAN     , 'RUSSIAN');
  AddLang(LI_LANG_SERBIAN     , 'SERBIAN');
  AddLang(LI_LANG_SLOVAK      , 'SLOVAK');
  AddLang(LI_LANG_SLOVENIAN   , 'SLOVENIAN');
  AddLang(LI_LANG_SOMALI      , 'SOMALI');
  AddLang(LI_LANG_SPANISH     , 'SPANISH');
  AddLang(LI_LANG_SWAHILI     , 'SWAHILI');
  AddLang(LI_LANG_SWEDISH     , 'SWEDISH');
  AddLang(LI_LANG_TAGALOG     , 'TAGALOG');
  AddLang(LI_LANG_TATAR       , 'TATAR');
  AddLang(LI_LANG_THAI        , 'THAI');
  AddLang(LI_LANG_TURKISH     , 'TURKISH');
  AddLang(LI_LANG_UKRAINIAN   , 'UKRAINIAN');
  AddLang(LI_LANG_URDU        , 'URDU');
  AddLang(LI_LANG_VIETNAMESE  , 'VIETNAMESE');
  AddLang(LI_LANG_YIDDISH     , 'YIDDISH');
  AddLang(LI_LANG_YORUBA      , 'YORUBA');
  AddLang(LI_LANG_AFRIKAANS   , 'AFRIKAANS');
  AddLang(LI_LANG_BOSNIAN     , 'BOSNIAN');
  AddLang(LI_LANG_PERSIAN     , 'PERSIAN');
  AddLang(LI_LANG_ALBANIAN    , 'ALBANIAN');
  AddLang(LI_LANG_ARMENIAN    , 'ARMENIAN');
  AddLang(LI_LANG_PUNJABI     , 'PUNJABI');
  AddLang(LI_LANG_CHAMORRO    , 'CHAMORRO');
  AddLang(LI_LANG_MONGOLIAN   , 'MONGOLIAN');
  AddLang(LI_LANG_MANDARIN    , 'MANDARIN');
  AddLang(LI_LANG_TAIWANESE   , 'TAIWANESE');
  AddLang(LI_LANG_MACEDONIAN  , 'MACEDONIAN');
  AddLang(LI_LANG_SINDHI      , 'SINDHI');
  AddLang(LI_LANG_WELSH       , 'WELSH');
  AddLang(LI_LANG_AZERBAIJANI , 'AZERBAIJANI');
  AddLang(LI_LANG_KURDISH     , 'KURDISH');
  AddLang(LI_LANG_GUJARATI    , 'GUJARATI');
  AddLang(LI_LANG_TAMIL       , 'TAMIL');
  AddLang(LI_LANG_BELORUSSIAN , 'BELORUSSIAN');
  AddLang(LI_LANG_UNKNOWN     , 'UNKNOWN');
end;

procedure HotKeysActivate;
var
  iMod, iKey: Word;
begin
  SeparateHotKey( HotKeyOpenTVp, iMod, iKey );
  RegisterHotKey( QIPPlugin.Handle, 8901, iMod, iKey );
end;

procedure HotKeysDeactivate;
var
  iMod, iKey: Word;
begin
  UnregisterHotKey( QIPPlugin.Handle, 8901);
end;


procedure AddLog(sText : WideString);
var
  F : TextFile;
begin

  if not FileExists(PluginDllPath+PLUGIN_NAME+'.log') then
  begin
    AssignFile(F, PluginDllPath+PLUGIN_NAME+'.log');
    ReWrite(F);
    WriteLn(F,'; Code page: UTF-8');
    WriteLn(F);
    CloseFile(F);
  end;


  AssignFile(F, PluginDllPath+PLUGIN_NAME+'.log');
  Append(F);

  WriteLn(F,   WideString2UTF8(FormatDateTime('yyyy-mm-dd hh:nn:ss',Now) + ' - ' + sText) );
  CloseFile(F);
end;


procedure AddSpecContacts;
var
  idx : Integer;
begin

  if (CL.Count = 0) or (ShowAsOneContact = True) then
  begin
    QIPPlugin.AddSpecContact(0,0, SpecCntUniq);
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
  end;

end;


procedure RemoveSpecContacts;
var
  idx : Integer;
begin

  if SpecCntUniq.UniqID<>0 then
    QIPPlugin.RemoveSpecContact(SpecCntUniq.UniqID);


  idx:=0;
  while ( idx<= CL.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if CL.Strings[idx]='CL' then
    begin
      if TCL(CL.Objects[idx]).UniqID.UniqID <> 0 then
        QIPPlugin.RemoveSpecContact(TCL(CL.Objects[idx]).UniqID.UniqID);
    end
    else if CL.Strings[idx]='CLGuide' then
    begin
      if TCLGuide(CL.Objects[idx]).UniqID.UniqID <> 0 then
        QIPPlugin.RemoveSpecContact(TCLGuide(CL.Objects[idx]).UniqID.UniqID);
    end;

    Inc(idx);
  end;


end;

end.
