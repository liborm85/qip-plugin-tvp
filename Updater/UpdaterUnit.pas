unit UpdaterUnit;

interface

uses Windows, SysUtils, ShellApi, Classes, Dialogs,
     Updater;

type
  {Updater File Info}
  TUpdaterFileInfo = class
  public
    Path             : WideString;
    URL              : WideString;
    MD5              : WideString;
    Size             : Int64;
    DateTime         : WideString;
    Pack             : Boolean;
    Pack_MD5         : WideString;
    Pack_Size        : Int64;
  end;

function MoveDir(const fromDir, toDir: string): Boolean;
procedure CheckNewVersion(bManual: Boolean);

var
  CheckUpdates, CheckBetaUpdates: Boolean;
  NextCheckVersion : TDateTime;
  CheckUpdatesInterval: Integer;

function Checking(): Boolean;

procedure OpenUpdater;

var updatethread : DWORD = 0;
    updater_Manual: Boolean;

    UpdaterWeb      : TStringList;
    UpdaterWebIndex : Integer;

    FUpdater: TfrmUpdater;
    frmUpdater_UpdaterList : WideString;
    frmUpdater_Version : WideString;
    frmUpdater_Changelog  : WideString;
    Updater_NewVersionFadeID : DWORD;
    UpdaterIsShow: Boolean;

implementation

uses General, u_qip_plugin,Convs, TextSearch, DownloadFile, uLNG;

function MoveDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_SILENT Or FOF_NOCONFIRMATION Or FOF_NOCONFIRMMKDIR;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function Checking(): Boolean;
var HTMLData: TResultData;
    Info2: TPositionInfo;
    sChVersion, sStable, sBeta, sBetaVer, sText, sVer, sUpdater : WideString;
    iMajor, iMinor, iRelease, iBuild, iFS, iFS1, iFS2: Integer;
    sBetaLst, sBetaChangeLog, sLst, sChangeLog{, sTest}: WideString;
//    NewVer: Boolean;

    sLng : WideString;
Label ExitFunc, NextWeb;
begin

//  UpdaterWeb.Insert(0,'http://panther7.ic.cz/updater/');

  UpdaterWebIndex := -1;

  NextWeb:

  Inc(UpdaterWebIndex);

  if UpdaterWebIndex > UpdaterWeb.Count - 1 then
    Goto ExitFunc;

    if Copy(PluginLanguage,1,1)='<' then
      sLng := QIPInfiumLanguage
    else
      sLng := PluginLanguage;

    try
      HTMLData := GetHTML(UpdaterWeb.Strings[UpdaterWebIndex]+'updaterV2.php?name='+PLUGIN_NAME+'&version='+PluginVersion+'&language='+sLng+'&options='+IntToStr(BoolToInt(updater_Manual)), '','', 5000, NO_CACHE, Info2);
    except

    end;

    if HTMLData.OK = True then
    begin
      if (CheckUpdates = True) or (updater_Manual = True) then
      begin
        sUpdater := FoundStr(HTMLData.parString,'<updater>','</updater>',1,iFS , iFS1, iFS2);

        if sUpdater='' then
          Goto NextWeb;


        // nacteni informaci o stable verzi
        sStable := FoundStr(sUpdater,'<stable>','</stable>',1,iFS, iFS1, iFS2);
        sVer := FoundStr(sStable,'<fullver>','</fullver>',1,iFS, iFS1, iFS2);
        sLst := FoundStr(sStable,'<url_lst>','</url_lst>',1,iFS, iFS1, iFS2);
        sChangeLog := FoundStr(sStable,'<changelog>','</changelog>',1,iFS, iFS1, iFS2);


        //nacteni informaci o beta verzi
        sBeta := FoundStr(sUpdater,'<beta>','</beta>',1,iFS, iFS1, iFS2);
        sBetaVer := FoundStr(sBeta,'<fullver>','</fullver>',1,iFS, iFS1, iFS2);
        sBetaLst := FoundStr(sBeta,'<url_lst>','</url_lst>',1,iFS, iFS1, iFS2);
        sBetaChangeLog := FoundStr(sBeta,'<changelog>','</changelog>',1,iFS, iFS1, iFS2);


        if CheckBetaUpdates then  //Zapnuto oznamovani beta verzi
        begin
          if Trim(sBetaVer) > Trim(sVer)  then
          begin  // Beta verze je novejsi nez stable verze
            sVer := sBetaVer;
            sLst := sBetaLst;
            sChangeLog := sBetaChangeLog;
          end;
        end;

        if Trim(PluginVersion) < Trim(sVer) then
        begin // Kontrola zda je novejsi verze
          sText := ReplNewVesion( LNG('UPDATER', 'NewVersion', 'New version %VERSION% is available.'), sVer);

          frmUpdater_UpdaterList := sLst;
          frmUpdater_Version := sVer;
          frmUpdater_Changelog  := UTF82WideString(sChangeLog);
          QIPPlugin.AddFadeMsg(1, PluginSkin.Update.Icon.Handle, PLUGIN_NAME, sText, True, True, 60, 255);
        end
        else
        begin
          if updater_Manual = True then
          begin
            sText := LNG('UPDATER', 'LastestVersion', 'You already have the lastest version.');

            QIPPlugin.AddFadeMsg(1, PluginSkin.Update.Icon.Handle, PLUGIN_NAME, sText, True, False, 5, 0);
          end;

        end;
      end;

    end;

  ExitFunc:

  updatethread := 0;
  Result := True;
end;

procedure CheckNewVersion(bManual: Boolean);
var ThreadId: Cardinal;
begin
  if (NextCheckVersion <= Now) or (bManual = True) then
  begin
    if CheckUpdatesInterval < 1 then CheckUpdatesInterval := 6;
    NextCheckVersion := Now + ( CheckUpdatesInterval * (1/(24{*60}) ) );
    updater_Manual := bManual;

    if updatethread = 0 then
      updatethread := BeginThread(nil, 0, @Checking, nil, 0, ThreadId);

  end;
end;

procedure OpenUpdater;
begin
  if UpdaterIsShow = False then
  begin
    FUpdater := TfrmUpdater.Create(nil);
    FUpdater.Show;
  end;
end;

end.
