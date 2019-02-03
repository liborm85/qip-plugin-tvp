unit Updater;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, ShellApi,
  Hash, KAZip, ImgList;

type
  TfrmUpdater = class(TForm)
    btnLater: TBitBtn;
    btnDownload: TBitBtn;
    pgcUpdater: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    lblAvailable: TLabel;
    lblDownloadQuestion: TLabel;
    lvUpdater: TListView;
    tmrDownloading: TTimer;
    pnlDownload: TPanel;
    lblInfo: TLabel;
    prgDownload: TProgressBar;
    lblPosition: TLabel;
    lblElapse: TLabel;
    lblTotalElapse: TLabel;
    lblTotalPosition: TLabel;
    lblTotalEstimate: TLabel;
    lblEstimate: TLabel;
    prgTotalDownload: TProgressBar;
    ilUpdater: TImageList;
    richWhatsNew: TRichEdit;
    procedure FormShow(Sender: TObject);
    procedure btnLaterClick(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure tmrDownloadingTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmUpdater: TfrmUpdater;

  infFileSize: Int64;
  infFileName: WideString;
  iTotalSize : Int64;
  iTotalDownloaded: Int64;

  bCancel : Boolean;
  StartTimer, StartTimerFile: TDateTime;




implementation

uses General, u_lang_ids, UpdaterUnit, Convs, TextSearch, DownloadFile,
     uFileFolder, uLNG, u_qip_plugin, uSuperReplace, u_plugin_info, fQIPPlugin;

var UpdaterDownloadInfo: TPositionInfo;     

{$R *.dfm}

function ReplNumber(sText: WideString; sNumber: WideString): WideString;
begin

  sText := StringReplace(sText, '%NUMBER%', sNumber, [rfReplaceAll, rfIgnoreCase]);
  Result := sText;

end;

function ReplFile(sText: WideString; sFile: WideString): WideString;
begin

  sText := StringReplace(sText, '%FILE%', sFile, [rfReplaceAll, rfIgnoreCase]);
  Result := sText;

end;

procedure TfrmUpdater.btnDownloadClick(Sender: TObject);
var KAZipPack : TKAZip;
    FilesList: TStringList;
    HTMLData: TResultData;
    sUpdaterList, sUpdaterTxt, sPackS: WideString;
    i, ii, iFS, iFS1, iFS2, iUpdLstPos, hIndex: Integer;
    ItmUpd: Boolean;
    sMD5: AnsiString;
    F: TextFile;
    sSpaces: WideString;
    dtF : TDateTime;
    sLng : WideString;

Label 1,2, UpdatingFail;
begin
  sSpaces := '     ';

  if btnDownload.Tag = 1 then
  begin
    btnLater.Caption := QIPPlugin.GetLang(LI_CANCEL);
    btnDownload.Enabled := False;

    pnlDownload.Visible := False;

    pgcUpdater.ActivePageIndex := 1;

    KAZipPack := TKAZip.Create(Self);

    KAZipPack.Close;

    FilesList := TStringList.Create;
    FilesList.Clear;

    StartTimer := Now;

    tmrDownloading.Enabled := True;
    Application.ProcessMessages;

    lvUpdater.Items.Add;
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := ReplNumber( LNG('UPDATER','DownloadingUpdateList','Downloading update list of files from server #%NUMBER%...'), IntToStr(UpdaterWebIndex));
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 0;

    if Copy(PluginLanguage,1,1)='<' then
      sLng := QIPInfiumLanguage
    else
      sLng := PluginLanguage;

    try
      HTMLData := GetHTML(UpdaterWeb.Strings[UpdaterWebIndex]+'updater_lst.php?file=' + frmUpdater_UpdaterList +
              '&name='+PLUGIN_NAME+
              '&ver_major='+IntToStr(PLUGIN_VER_MAJOR)+'&ver_minor='+IntToStr(PLUGIN_VER_MINOR)+'&ver_release='+IntToStr(PLUGIN_VER_RELEASE)+'&ver_build='+IntToStr(PLUGIN_VER_BUILD)+
              '&ver_test='+PLUGIN_VER_BETA+'&language='+sLng, '', '', 5000, NO_CACHE, UpdaterDownloadInfo);
    except

    end;


    if HTMLData.OK = True then
    begin
      sUpdaterList := HTMLData.parString;

      lvUpdater.Items.Add;
      lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := LNG('UPDATER','ProcessingUpdateList','Processing update list of files...');
      lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := -1;
      lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

      sUpdaterList := FoundStr(sUpdaterList,'<UpdaterList>','</UpdaterList>',1,iFS, iFS1, iFS2);
      iUpdLstPos := 1;

      1:

      sUpdaterTxt := FoundStr(sUpdaterList,'<File>','</File>',iUpdLstPos,iUpdLstPos, iFS1, iFS2);
      if sUpdaterTxt = '' then Goto 2;


      FilesList.Add('ITEM');
      hIndex:= FilesList.Count - 1;
      FilesList.Objects[hIndex] := TUpdaterFileInfo.Create;

      TUpdaterFileInfo(FilesList.Objects[hIndex]).Path := FoundStr(sUpdaterTxt,'<Path>','</Path>',1,iFS, iFS1, iFS2);
      TUpdaterFileInfo(FilesList.Objects[hIndex]).URL  := FoundStr(sUpdaterTxt,'<URL>','</URL>',1,iFS, iFS1, iFS2);
      TUpdaterFileInfo(FilesList.Objects[hIndex]).MD5  := FoundStr(sUpdaterTxt,'<MD5>','</MD5>',1,iFS, iFS1, iFS2);
      TUpdaterFileInfo(FilesList.Objects[hIndex]).Size := StrToInt( FoundStr(sUpdaterTxt,'<Size>','</Size>',1,iFS, iFS1, iFS2) );
      TUpdaterFileInfo(FilesList.Objects[hIndex]).DateTime := FoundStr(sUpdaterTxt,'<DateTime>','</DateTime>',1,iFS, iFS1, iFS2);

      if StrPosE(sUpdaterTxt,'<Pack />',1,false) = 0 then
        TUpdaterFileInfo(FilesList.Objects[hIndex]).Pack := False
      else
      begin
        TUpdaterFileInfo(FilesList.Objects[hIndex]).Pack := True;

        sPackS := FoundStr(sUpdaterTxt,'<Pack>','</Pack>',1,iFS, iFS1, iFS2);

        TUpdaterFileInfo(FilesList.Objects[hIndex]).Pack_MD5  := FoundStr(sPackS,'<MD5>','</MD5>',1,iFS, iFS1, iFS2);
        TUpdaterFileInfo(FilesList.Objects[hIndex]).Pack_Size := StrToInt(FoundStr(sPackS,'<Size>','</Size>',1,iFS, iFS1, iFS2));
      end;

      Goto 1;
      2:
    end;

    // odstranìní složky i s podložkami
    RemoveDirectory(PChar(ExtractFilePath(PluginDllPath) + '[updater]\'));

    //vytvoøení složky
    CheckFolder(ExtractFilePath(PluginDllPath) + '[updater]\', False);

    iTotalSize := 0;
    iTotalDownloaded := 0;

    for i := FilesList.Count - 1 downto 0 do
    begin
      ItmUpd := True;
      if FileExists(ExtractFilePath(PluginDllPath) + TUpdaterFileInfo(FilesList.Objects[i]).Path) = True then
      begin
        MD5HashFile(ExtractFilePath(PluginDllPath) + TUpdaterFileInfo(FilesList.Objects[i]).Path, sMD5);

        if sMD5=TUpdaterFileInfo(FilesList.Objects[i]).MD5 then
          ItmUpd := False;
      end;

      if ItmUpd = False then
        FilesList.Delete(i);

      Application.ProcessMessages;

    end;

    for i := 0 to FilesList.Count - 1 do
    begin
      iTotalSize := iTotalSize + TUpdaterFileInfo(FilesList.Objects[i]).Size;
    end;

    pnlDownload.Visible := True;
    Application.ProcessMessages;

    for i := 0 to FilesList.Count - 1 do
    begin
      if bCancel = True then Exit;

      StartTimerFile := Now;

      UpdaterDownloadInfo.Int64_1 := 0;

      infFileName := TUpdaterFileInfo(FilesList.Objects[i]).Path;

      if TUpdaterFileInfo(FilesList.Objects[i]).Pack = True then
        infFileSize := TUpdaterFileInfo(FilesList.Objects[i]).Pack_Size
      else
        infFileSize := TUpdaterFileInfo(FilesList.Objects[i]).Size;

      lblInfo.Caption := IntToStr(i + 1) + ' / '+ IntToStr(FilesList.Count) + '  ' + infFileName;

      lvUpdater.Items.Add;
      lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := ReplFile(LNG('UPDATER','DownloadingFile','Downloading file %FILE%...'), TUpdaterFileInfo(FilesList.Objects[i]).Path );
      lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 0;
      lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

      HTMLData.OK := False;
      try
        HTMLData := GetHTML(UpdaterWeb.Strings[UpdaterWebIndex] + TUpdaterFileInfo(FilesList.Objects[i]).URL, '','', 5000, NO_CACHE, UpdaterDownloadInfo);
      except

      end;

      if HTMLData.OK = True then
      begin
        CheckFolder( ExtractFilePath(ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path), False );

        if TUpdaterFileInfo(FilesList.Objects[i]).Pack = True then
        begin
          AssignFile(F, ExtractFilePath(PluginDllPath) + 'updater.tmp');
          Rewrite(F);
          Write(F,HTMLData.parString);
          CloseFile(F);

          MD5HashFile(ExtractFilePath(PluginDllPath) + 'updater.tmp', sMD5);
          if sMD5<>TUpdaterFileInfo(FilesList.Objects[i]).Pack_MD5 then
          begin
            lvUpdater.Items.Add;
            lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := sSpaces + LNG('UPDATER','IncorrectCompressedFile','Downloaded compressed file is incorrect.');
            lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 2;
            lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

            try
              DeleteFile(ExtractFilePath(PluginDllPath) + 'updater.tmp')
            finally

            end;

            Goto UpdatingFail;
          end;

          KAZipPack.Close;

          KAZipPack.Open( ExtractFilePath(PluginDllPath) + 'updater.tmp' );
          KAZipPack.OverwriteAction := oaOverwriteAll;

          if KAZipPack.Active then
          begin
            KAZipPack.ExtractAll(  ExtractFilePath( ExtractFilePath(ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path ) ) );
          end;

          KAZipPack.Close;

          try
            DeleteFile(ExtractFilePath(PluginDllPath) + 'updater.tmp')
          finally

          end;

        end
        else
        begin
          AssignFile(F, ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path);
          Rewrite(F);
          Write(F,HTMLData.parString);
          CloseFile(F);
        end;

        lvUpdater.Items.Add;
        lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := sSpaces + LNG('UPDATER','FileDownloaded','File downloaded.');
        lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 1;
        lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);


        dtF := SQLDLToDT(TUpdaterFileInfo(FilesList.Objects[i]).DateTime);
        if dtF<>0 then
          SetDateToFile( ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path, dtF);

        MD5HashFile(ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path, sMD5);

        if sMD5<>TUpdaterFileInfo(FilesList.Objects[i]).MD5 then
        begin
          lvUpdater.Items.Add;
          lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := sSpaces + LNG('UPDATER','IncorrectFile','Downloaded file is incorrect.');
          lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 2;
          lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

          try
            DeleteFile(ExtractFilePath(PluginDllPath) + '[updater]\' + TUpdaterFileInfo(FilesList.Objects[i]).Path)
          finally

          end;

          Goto UpdatingFail;
        end;

      end
      else
      begin
        lvUpdater.Items.Add;
        lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := sSpaces + LNG('UPDATER','ErrorDownloadingFile','Error during downloading file.');
        lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 2;
        lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

        Goto UpdatingFail;
      end;

      Application.ProcessMessages;

      iTotalDownloaded := iTotalDownloaded + infFileSize;

    end;

    tmrDownloading.Enabled := False;

    pnlDownload.Visible := False;


    lvUpdater.Items.Add;
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := LNG('UPDATER','UpdatingUpdaterSystem','Updating Updater system...');
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := -1;
    //lvUpdater.Items.item[lvUpdater.Items.Count - 1].SubItems.Add( '' );

    lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

    if FileExists(ExtractFilePath(PluginDllPath) + '[updater]\' + 'updPlugin.exe') then
    begin
      MoveDir( ExtractFilePath(PluginDllPath) + '[updater]\' + 'updPlugin.exe', ExtractFilePath(PluginDllPath) + 'updPlugin.exe' );
    end;

    lvUpdater.Items.Add;
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := sSpaces + QIPPlugin.GetLang(LI_UPDATE_LOG_UPDATE_SUCCESFUL); //LNG('UPDATER','Complete','Complete');
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 4;
    //lvUpdater.Items.item[lvUpdater.Items.Count - 1].SubItems.Add( '' );
    lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

    lblInfo.Caption := '';
    {
    btnContinue.Enabled := True;
    }
    lvUpdater.Items.Add;
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption :=  QIPPlugin.GetLang(LI_UPDATE_LOG_NEXT_TEXT);//LNG('UPDATER','ClickContinue','Click "Continue" button for updating...');
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 4;
    //lvUpdater.Items.item[lvUpdater.Items.Count - 1].SubItems.Add( '' );
    lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

    btnDownload.Tag := 2;

    btnDownload.Caption := QIPPlugin.GetLang(LI_NEXT); //LI_UPDATE

    btnDownload.Enabled := True;

    Exit;
  end
  else if btnDownload.Tag = 2 then
  begin
    btnDownload.Enabled := False;

    lvUpdater.Items.Add;
    lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := QIPPlugin.GetLang(LI_UPDATE_LOG_INSTALLING);
    lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

    if FileExists(ExtractFilePath(PluginDllPath) + 'updPlugin.exe')=False then
    begin
      ShowMessage( TagsReplace( StringReplace(LNG('Texts', 'FileNotFound', 'File %file% wasn''t found.[br]Plugin can be unstable.'), '%file%', 'updPlugin.exe', [rfReplaceAll, rfIgnoreCase]) ) );
      Goto UpdatingFail;
    end;

    if Copy(PluginLanguage,1,1)='<' then
      sLng := QIPInfiumLanguage
    else
      sLng := PluginLanguage;

    AssignFile(F, ExtractFilePath(PluginDllPath) + 'updPlugin.ini');
    Rewrite(F);
    WriteLn(F,'; Code page: UTF-8');
    WriteLn(F);
    WriteLn(F,'[Conf]');
    WriteLn(F,'Language=' + sLng);
    WriteLn(F,'AutomaticClose=1');
    CloseFile(F);

    Shellexecute(0, 'open', PChar(ExtractFilePath(PluginDllPath) + 'updPlugin.exe'), nil, nil, SW_SHOWNORMAL);

    QIPPlugin.InfiumClose(0);

    Close;

    Exit;
  end
  else if btnDownload.Tag = 255 then  //exit
  begin
    Close;

    Exit;
  end;

UpdatingFail:
  btnDownload.Tag := 255;
  btnDownload.Caption := QIPPlugin.GetLang(LI_NEXT);
  btnDownload.Enabled := True;

  lvUpdater.Items.Add;
  lvUpdater.Items.item[lvUpdater.Items.Count - 1].Caption := QIPPlugin.GetLang(LI_UPDATE_LOG_UPDATE_FAILED);
  lvUpdater.Items.item[lvUpdater.Items.Count - 1].ImageIndex := 3;
  lvUpdater.Scroll(0,lvUpdater.Items.Count * 10);

end;

procedure TfrmUpdater.btnLaterClick(Sender: TObject);
begin
  bCancel := True; 
  Close;
end;

procedure TfrmUpdater.FormShow(Sender: TObject);
var i: Integer;
begin

  i:=0;
  while ( i<= pgcUpdater.PageCount - 1 ) do
  begin
    pgcUpdater.Pages[i].TabVisible := false;

    Inc(i);
  end;

  pgcUpdater.ActivePageIndex := 0;

  btnDownload.Tag := 1;

  Caption := LNG('UPDATER','Updater','Updater') + ': ' + PLUGIN_NAME;

  Icon := PluginSkin.PluginIcon.Icon;

  (*pgcUpdater.Left := 0;
  pgcUpdater.Top := 0;
  pgcUpdater.Width := frmUpdater.Width;
  pgcUpdater.Height := frmUpdater.Height;   *)

  lblDownloadQuestion.Caption := QIPPlugin.GetLang(LI_UPDATE_UI_WOULD_DOWNLOAD);


  btnLater.Caption := QIPPlugin.GetLang(LI_UPDATE_UI_LATER);
  btnDownload.Caption := QIPPlugin.GetLang(LI_UPDATE_UI_DOWNLOAD);

  lblAvailable.Caption :=  ReplNewVesion( LNG('UPDATER','NewVersion','New version %VERSION% is available.'), frmUpdater_Version);

  richWhatsNew.Text := frmUpdater_Changelog;

end;

procedure TfrmUpdater.tmrDownloadingTimer(Sender: TObject);
begin
  if prgDownload.Max <> infFileSize then
    prgDownload.Max := infFileSize;

  prgDownload.Position:= UpdaterDownloadInfo.Int64_1;

  lblPosition.Caption := ConvB(UpdaterDownloadInfo.Int64_1) + ' / ' + ConvB(infFileSize);

{
  lblElapse.Caption := FormatDateTime( 'MM:SS', Now - StartTimerFile - ( 12 * (1/(24*60) ) ) );
}
  if prgTotalDownload.Max <> iTotalSize then
    prgTotalDownload.Max := iTotalSize;

  prgTotalDownload.Position:= iTotalDownloaded + UpdaterDownloadInfo.Int64_1;

  lblTotalPosition.Caption := ConvB(iTotalDownloaded + UpdaterDownloadInfo.Int64_1) + ' / ' + ConvB(iTotalSize);
{
  lblTotalElapse.Caption := FormatDateTime( 'MM:SS', Now - StartTimer - ( 12 * (1/(24*60) ) ) );
}
end;

end.
