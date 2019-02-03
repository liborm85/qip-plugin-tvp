unit TVpDLL;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls,
     TVp_plugin_info,
     {Podpora jpg, png, gif:  (nemazat!)}
     Jpeg, PNGImage,  GIFImg
     {----------------------------------}
     ;

type

  { TVp Plan }
  TTVpPlan      = class
  public
    DateTime          : TDateTime;
    DataID            : Int64;
    StationID         : WideString;
    Date              : WideString;
    IncDate           : Integer;
    Time              : WideString;
    Name              : WideString;
    NotifyBeforeBegin : Integer; //minutes
    Notified          : Integer;
  end;

  TTVpColumn = class
  public
    ColumnType         : Integer;
    StationID          : WideString;
    StationName        : WideString;
    StationLogo        : WideString;

    Conf               : WideString;

    DATA               : TStringList;
  end;

  { NPInfo  - record}
  TNPInfo = record
    Name              : WideString;
    TimeBegin         : TDateTime;
    TimeEnd           : TDateTime;
    TimeLength        : Integer;
    TimePosition      : Integer;
  end;

  { Program }
  TTVpProgram      = class
  public
    DataID            : Int64;
    Time              : WideString;
    Name              : WideString;
    OrigName          : WideString;
    Info              : WideString;
    InfoImage         : WideString;
    Specifications    : WideString;
    URL               : WideString;
    IncDate           : Integer;
    Planned           : Boolean;
  end;

  TTVpDays = class
  public
    Date               : WideString;

    DATAProgram        : TStringList;
  end;

  TTVpStations = class
  public
    StationID          : WideString;
    StationName        : WideString;
    StationLogo        : WideString;

    DATADays           : TStringList;
    NPData             : TStringList;
    NPIndex            : Integer;
  end;


  TTVpServers = class
  public
    ServerID           : WideString;
    ServerName         : WideString;
    ServerIcon         : TImage;

    DATAStations       : TStringList;
  end;

  TTVpPluginData = class
  public
    DllHandle         : DWord;
    DllPath           : WideString;
    Info              : TTVpPluginInfo;
    Servers           : TStringList;
  end;

  {Procedury v pluginu}
  TFGetPluginInfo = function(): TTVpPluginInfo; stdcall;
  TFGetServers = procedure( var DATA: TStringList ); stdcall;
  TFSetConf = procedure( Conf: TSetConf ); stdcall;
  TFSearch = procedure(SearchName: WideString; Server: WideString; var DATA: TStringList; var Info: TPositionInfo ); stdcall;
  TFGetStations = procedure(Server: WideString; var DATA: TStringList); stdcall;
  TFGetAvailableDays = procedure(Server: WideString; var DATA: TStringList); stdcall;
  TFGetProgram = procedure(Server: WideString; Station: TStringList; Dates: TStringList; var DATA: TStringList; var Info: TPositionInfo); stdcall;
  TFGetExtraInfo = procedure(InfoURL: WideString; Server: WideString; Station: WideString; var DATA: TStringList; var Info: TPositionInfo); stdcall;


  procedure ShowError(ErrNumber: Integer; PluginIndex: Integer; PluginProcedure : WideString);
  procedure LoadTVpPlugins;

  procedure TVpGetAvailableDays(ServerIndex: Integer; ServerName: WideString; var DATA: TStringList);
  procedure TVpGetStations(ServerIndex: Integer; ServerName: WideString; var DATA: TStringList);

  procedure CheckProgram(var Info : WideString);

  procedure SQLSaveTVpProgram(DATA : TStringList);

  procedure LoadStationsData;

  procedure LoadNPData;
  procedure GetNPInfo(StationID: WideString; ProgramIndex: Integer; var Info : TNPInfo);

  procedure LoadPlan;
  function GetStationPlanned(DataID : Int64) : Boolean;

  procedure SetCheckingUpdatesToStations(DATA : TStringList; bCheckingUpdates : Boolean);


  procedure GetStationLogo(StationID : WideString; var img: TImage);


var
  TVpPlugins : TStringList;

  INFO_GetProgram: TPositionInfo;

implementation

uses General, uLNG, TextSearch, SQLiteFuncs, SQLiteTable3, Convs, uBase64,
     DownloadFile, u_qip_plugin, u_lang_ids;


function ReplErrMsg(sText: WideString; sMsg: WideString): WideString;
begin
  Result := StringReplace(sText, '%MESSAGE%', sMsg, [rfReplaceAll]);
end;


function ReplErr(sText: WideString; sName: WideString; sProcedure: WideString): WideString;
begin
  sText  := StringReplace(sText, '%FILENAME%', sName, [rfReplaceAll]);
  Result := StringReplace(sText, '%PROCEDURE%', sProcedure, [rfReplaceAll]);
end;

{=== Show Error ===}
procedure ShowError(ErrNumber: Integer; PluginIndex: Integer; PluginProcedure : WideString);
var MessageText: WideString;
begin
{
  ErrNumber:
   10 - Nelze naèíst plugin %ExtractFileName(WPlugins[i].DllPath)%.
   11 - V pluginu %ExtractFileName(WPlugins[i].DllPath)% nelze naèíst proceduru %---%.
   12 - V pluginu %ExtractFileName(WPlugins[i].DllPath)% je chyba v proceduøe %---%.');
}

  if ErrNumber = 10 then
    MessageText := LNG('TEXTS', 'Err10', 'Can''t load plugin %FILENAME%.')
  else if ErrNumber = 11 then
    MessageText := LNG('TEXTS', 'Err11', 'Can''t load procedure %PROCEDURE% from plugin %FILENAME%.')
  else if ErrNumber = 12 then
    MessageText := LNG('TEXTS', 'Err12', 'Error occured in procedure %PROCEDURE% of plugin %FILENAME%.');



  MessageText :=
    ReplErr(MessageText, ExtractFileName(TTVpPluginData(TVpPlugins.Objects[PluginIndex]).DllPath), PluginProcedure) +
    #13 + QIPPlugin.GetLang(LI_INFORMATION) +#13 +
    INFO_GetProgram.Info;

  QIPPlugin.AddFadeMsg(2, PluginSkin.PluginIcon.Icon.Handle, PLUGIN_NAME,
                             MessageText
                              , True, True, 0, 0);

//  MessageBoxW(0, PWideChar( ReplErrMsg(LNG('TEXTS', 'Message', 'ERROR: %MESSAGE%'),MessageText) ), PWideChar( PLUGIN_NAME ), MB_OK + MB_ICONEXCLAMATION + MB_SystemModal)

end;

{=== Load TVp plugins ===}
procedure LoadTVpPlugins;
var PluginsPath: WideString;
    rec: TSearchRec;
    ii: Integer;

    GetPluginInfo: TFGetPluginInfo;
    SetConf   : TFSetConf;
    GetServers: TFGetServers;

    DATA_Servers: TStringList; {TServers;}
    DATA_Conf: TSetConf;
    hIndex: Integer;
    idx, idx2: Integer;
begin


  TVpPlugins.Clear;

  PluginsPath := PluginDllPath + 'Plugins\';

  DATA_Conf.TempPath := ProfilePath + 'Temp\';

  if FindFirst(PluginsPath + '*.dll', faAnyFile, rec) = 0 then
  begin
    repeat
      if (rec.Name = '') or (rec.Name = '.') or (rec.Name = '..') then
      else
      begin
        TVpPlugins.Add('P');
        hIndex:= TVpPlugins.Count - 1;
        TVpPlugins.Objects[hIndex] := TTVpPluginData.Create;
        TTVpPluginData(TVpPlugins.Objects[hIndex]).DllPath  := PluginsPath + rec.name;
        TTVpPluginData(TVpPlugins.Objects[hIndex]).Servers := TStringList.Create;
        TTVpPluginData(TVpPlugins.Objects[hIndex]).Servers.Clear;
      end;
    until FindNext(rec) <> 0;
  end;
  //FindClose(rec);


  idx:=0;
  while ( idx<= TVpPlugins.Count - 1 ) do
  begin
    Application.ProcessMessages;

    {--- Load Library - plugin ---}
    TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle:=0;
    try
      TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle := LoadLibraryW( PWideChar(TTVpPluginData(TVpPlugins.Objects[idx]).DllPath) );
    except
      ShowError( 10, idx, '' );
    end;

    if TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle <> 0 then
    begin
      {--- Get Plugin Info ---}
      @GetPluginInfo:= nil;
      try
        @GetPluginInfo := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle, 'GetPluginInfo');
       except
         ShowError( 11, idx, 'GetPluginInfo');
       end;

       if @GetPluginInfo <> nil then
       begin
         try
           TTVpPluginData(TVpPlugins.Objects[idx]).Info := GetPluginInfo();
         except
           ShowError(12, idx, 'GetPluginInfo');
         end;
       end; {if GetPluginInfo}

       {--- Set Conf        ---}
       @SetConf:= nil;
       try
         @SetConf := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle, 'SetConf');
       except
         ShowError(11, idx, 'SetConf');
       end;

       if @SetConf <> nil then
       begin
         try
           SetConf( DATA_Conf );
         except
           ShowError(12, idx, 'SetConf');
         end;
       end; {if Set Conf     }

       {--- Get Servers ---}
       DATA_Servers := TStringlist.Create;
       DATA_Servers.Clear;
       @GetServers:= nil;
       try
         @GetServers := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[idx]).DllHandle, 'GetServers');
       except
         ShowError(11, idx, 'GetServers');
       end;

       if @GetServers <> nil then
       begin
         try
           GetServers( DATA_Servers );
         except
           ShowError(12, idx, 'GetServers');
         end;

         for ii := 0 to DATA_Servers.Count - 1 do
         begin
            TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Add('S');
            idx2:= TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Count - 1;
            TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2] := TTVpServers.Create;
            TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2]).ServerID   := TDLLServers(DATA_Servers.Objects[ii]).ServerID;
            TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2]).ServerName := TDLLServers(DATA_Servers.Objects[ii]).ServerName;
            TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2]).ServerIcon := TDLLServers(DATA_Servers.Objects[ii]).ServerIcon;
            TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2]).DATAStations := TStringList.Create;
            TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx]).Servers.Objects[idx2]).DATAStations.Clear;
         end;
       end;

    end;  {if DllHandle}

    Inc(idx);
  end; {while idx}


end;

{=== Get Available Days ===}
procedure TVpGetAvailableDays(ServerIndex: Integer; ServerName: WideString; var DATA: TStringList);
var i: Integer;
    GetAvailableDays: TFGetAvailableDays;
     DATA_AvailableDays: TStringList;
begin
  DATA := TStringList.Create;
  DATA.Clear;

  @GetAvailableDays:= nil;
  try
    @GetAvailableDays := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[ServerIndex]).DllHandle, 'GetAvailableDays');
  except
    ShowError(11, ServerIndex, 'GetAvailableDays');
  end;

  if @GetAvailableDays <> nil then
  begin
    try
      GetAvailableDays(ServerName, DATA_AvailableDays);
    except
      ShowError(12, ServerIndex, 'GetAvailableDays');
    end;


    for i := 0 to DATA_AvailableDays.Count - 1 do
    begin
      if DATA_AvailableDays.Strings[i]='DATE' then
      begin
        DATA.Add(TDLLAvailableDays(DATA_AvailableDays.Objects[i]).DateID);
      end else
      if DATA_AvailableDays.Strings[i]='DATE N/A' then
      begin
        DATA.Add('N/A');
      end;

    end;

  end;
end;

{=== Get Stations ===}
procedure TVpGetStations(ServerIndex: Integer; ServerName: WideString; var DATA: TStringList);
var GetStations: TFGetStations;
    DATA_Stations: TStringList;
begin
  @GetStations:= nil;

  try
    @GetStations := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[ServerIndex]).DllHandle, 'GetStations');
  except
    ShowError(11, ServerIndex, 'GetStations')
  end;

  if @GetStations <> nil then
  begin
    try
      GetStations(ServerName,  DATA_Stations);
    except
      ShowError(12, ServerIndex, 'GetStations')
    end;
  end;
end;



{=== TVp Get Program ===}
function TVpGetProgram(PluginIndex : Integer;
                       ServerName  : WideString;
                       Stations    : TStringList;
                       Dates       : TStringList;
                       var DATA    : TStringList): Integer;

var {i, ii: Integer;}
{    StationFound,StationIndex: Integer;}
    GetProgram: TFGetProgram;
    DATA_ProgramsData: TStringList;

    idx1, idxStation, idxDate, idxProgram : Integer;
    sDate : WideString;

//    F, F1 : TEXTFILE;

Label RU, CompleteFce;

begin
{  AssignFile(F, ProfilePath + 'get.txt');
  Rewrite(F);

  AssignFile(F1, ProfilePath + 'get_X.txt');
  Rewrite(F1);}

  DATA := TStringList.Create;
  DATA.Clear;

  if Dates.Count=0 then
    Goto CompleteFce;

  sDate := Dates.Strings[0];

  idxStation := -1;
  idxDate    := -1;
  idxProgram := -1;

  @GetProgram:= nil;
  try
    @GetProgram := GetProcAddress(TTVpPluginData(TVpPlugins.Objects[PluginIndex]).DllHandle, 'GetProgram');
  except
    ShowError(11, PluginIndex, 'GetProgram');
  end;

  if @GetProgram <> nil then
  begin
    //  frmMain.lblInfo.Caption:='Knihovna zpracovává požadavek...';

    try
      GetProgram(ServerName, Stations, Dates, DATA_ProgramsData, INFO_GetProgram);
    except
    showmessage(INFO_GetProgram.Info);
      ShowError(12, PluginIndex, 'GetProgram');
    end;

    DATA.Clear;

//showmessage(inttostr(DATA_ProgramsData.Count ));
    idx1 := 0;
    while ( idx1 <= DATA_ProgramsData.Count - 1 ) do
    begin
      Application.ProcessMessages;
//showmessage(inttostr(idx1)+'/'+inttostr(DATA_ProgramsData.Count ));
//      showmessage(inttostr(idx1) +'/'+ inttostr(DATA_ProgramsData.Count - 1) +#13+DATA_ProgramsData.Strings[idx1]);

      if DATA_ProgramsData.Strings[idx1] = 'DOWNLOADERROR' then
      begin
        //ShowMessage('Error in downloading tv programs. ' + ServerName);
        break;
      end;

      if DATA_ProgramsData.Strings[idx1] = 'STATION' then      { Station }
      begin
//writeln(F,'STATION' + ' >>> ' + TTVpStations(DATA_ProgramsData.Objects[idx1]).StationID);
//showmessage (  TTVpStations(DATA_ProgramsData.Objects[idx1]).StationID  );
        idxStation := DATA.IndexOf( TTVpStations(DATA_ProgramsData.Objects[idx1]).StationID );
        if idxStation = -1 then
        begin
//writeln(F1,'ADD STATION' + ' >>> ' + WideString2UTF8(TTVpStations(DATA_ProgramsData.Objects[idx1]).StationID));
          DATA.Add(  TTVpStations(DATA_ProgramsData.Objects[idx1]).StationID  );
          idxStation := DATA.Count - 1;
          DATA.Objects[idxStation] := TTVpStations.Create;
          TTVpStations( DATA.Objects[idxStation]).StationID   := TDLLStations(DATA_ProgramsData.Objects[idx1]).StationID;
          TTVpStations( DATA.Objects[idxStation]).StationName := TDLLStations(DATA_ProgramsData.Objects[idx1]).StationName;
          TTVpStations( DATA.Objects[idxStation]).StationLogo := TDLLStations(DATA_ProgramsData.Objects[idx1]).StationLogo;
          TTVpStations( DATA.Objects[idxStation]).DATADays := TStringList.Create;
          TTVpStations( DATA.Objects[idxStation]).DATADays.Clear;

//writeln(F1,'ADD DATE' + ' >>> ' + WideString2UTF8(sDate));
          TTVpStations( DATA.Objects[idxStation]).DATADays.Add(  sDate  );
          idxDate := TTVpStations( DATA.Objects[idxStation]).DATADays.Count - 1;
          TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate] := TTVpDays.Create;

          TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date := sDate;
          TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram := TStringList.Create;
          TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Clear;
        end
        else
        begin
          idxDate := TTVpStations( DATA.Objects[idxStation]).DATADays.IndexOf( sDate );
          if idxDate = -1 then
          begin
//writeln(F1,'NEW DATE' + ' >>> ' + WideString2UTF8(sDate));
//          showmessage( 'new date ' +  ProgramDate );
            TTVpStations( DATA.Objects[idxStation]).DATADays.Add(  sDate  );
            idxDate := TTVpStations( DATA.Objects[idxStation]).DATADays.Count - 1;
            TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate] := TTVpDays.Create;

            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date := sDate;
            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram := TStringList.Create;
            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Clear;
          end;
        end;
      end  {if station}
      else if DATA_ProgramsData.Strings[idx1] = 'PROGRAM' then { Program }
      begin
//writeln(F,'PROGRAM' + ' >>> ' + WideString2UTF8( TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Name)+ ' , ' + TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Time);
//writeln(F1,'ADDPROGRAM' + ' >>> ' + TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date + ' >>> ' + WideString2UTF8( TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Name)+ ' , ' + TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Time);
        TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Add( 'PROGRAM' );
        idxProgram := TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Count - 1;
        TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] := TTVpProgram.Create;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Time      := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Time;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Name      := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Name;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).OrigName  := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).OrigName;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).URL       := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).URL;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Specifications   := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Specifications;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Info      := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).Info;
        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).InfoImage := TDLLProgramInfo(DATA_ProgramsData.Objects[idx1]).InfoImage;

//showmessage(                TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Time    + '     ' +
//        TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Name             );
      end  {if progam}
      else if DATA_ProgramsData.Strings[idx1] = 'DATE' then { Date }
      begin
//writeln(F,'DATE' + ' >>> ' + TDLLAvailableDays(DATA_ProgramsData.Objects[idx1]).DateID);

          sDate := TDLLAvailableDays(DATA_ProgramsData.Objects[idx1]).DateID;

          idxDate := TTVpStations( DATA.Objects[idxStation]).DATADays.IndexOf( sDate );
          if idxDate = -1 then
          begin
//writeln(F1,'NEW DATE2' + ' >>> ' + WideString2UTF8(sDate));
//          showmessage( 'new date ' +  ProgramDate );
            TTVpStations( DATA.Objects[idxStation]).DATADays.Add(  sDate  );
            idxDate := TTVpStations( DATA.Objects[idxStation]).DATADays.Count - 1;
            TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate] := TTVpDays.Create;

            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date := sDate;
            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram := TStringList.Create;
            TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Clear;
          end;
//writeln(F1,'CHANGE DATE' + ' >>> ' + WideString2UTF8(sDate));
      end; {if progam}

      Inc(idx1);
    end; {while idx1}

{
  CloseFile(F);

  CloseFile(F1);}

(*
    StationFound:=-1;
    for i:= 0 to DATA_ProgramsData.Count - 1 do
    begin
      if DATA_ProgramsData.Strings[i] = 'DOWNLOADERROR' then
      begin
        //        ShowMessage('Error in downloading tv programs. ' + ServerName);
        break;
      end;

//      showmessage(DATA_ProgramsData.Strings[i] + #13 + TSLStations(DATA_ProgramsData.Objects[i]).StationID);

      if DATA_ProgramsData.Strings[i]='STATION' then      { Station }
      begin
        DATA.Add()

        StationFound := -1;

        for ii := 0 to High(TVpStations) do
        begin
          if TSLStations(DATA_ProgramsData.Objects[i]).StationID  + '@' + ServerName = TVpStations[ii].StationID then
          begin
            StationFound:=ii;
            break;
          end;
        end; {for ii}

        if StationFound > -1 then
        begin

        end else
        begin
          SetLength(TVpStations, 1 + High(TVpStations) + 1);
          StationFound:=High(TVpStations);

          TVpStations[StationFound].StationID   := TSLStations(DATA_ProgramsData.Objects[i]).StationID + '@' + ServerName;
          TVpStations[StationFound].StationName := TSLStations(DATA_ProgramsData.Objects[i]).StationName;
          TVpStations[StationFound].StationLogo := TSLStations(DATA_ProgramsData.Objects[i]).StationLogo;
          SetLength(TVpStations[StationFound].Programs, 0);
        end;
      end {if station} else
      if DATA_ProgramsData.Strings[i]='PROGRAM' then { Program }
      begin
        SetLength(TVpStations[StationFound].Programs, 1 + High(TVpStations[StationFound].Programs) + 1);
        StationIndex := High(TVpStations[StationFound].Programs);

        TVpStations[StationFound].Programs[StationIndex].Time      := TSLProgramInfo(DATA_ProgramsData.Objects[i]).Time;
        TVpStations[StationFound].Programs[StationIndex].Name      := TSLProgramInfo(DATA_ProgramsData.Objects[i]).Name;
        TVpStations[StationFound].Programs[StationIndex].OrigName  := TSLProgramInfo(DATA_ProgramsData.Objects[i]).OrigName;
        TVpStations[StationFound].Programs[StationIndex].URL       := TSLProgramInfo(DATA_ProgramsData.Objects[i]).URL;
        TVpStations[StationFound].Programs[StationIndex].PrgType   := TSLProgramInfo(DATA_ProgramsData.Objects[i]).PrgType;
        TVpStations[StationFound].Programs[StationIndex].PrgSpec   := TSLProgramInfo(DATA_ProgramsData.Objects[i]).PrgSpec;
        TVpStations[StationFound].Programs[StationIndex].Info      := TSLProgramInfo(DATA_ProgramsData.Objects[i]).Info;
        TVpStations[StationFound].Programs[StationIndex].InfoImage := TSLProgramInfo(DATA_ProgramsData.Objects[i]).InfoImage;
      end {if program}

    end; {for i}     *)
  end;


CompleteFce:

  Result := 1;
end;

procedure CheckProgram(var Info : WideString);
var
  idx1, idx2, idx3, idx4, hIndex: Integer;
  StationsInCL, DATA_AvailableDays, DATA_StationsPrograms , slStation, slDate : TStringList;
  ID1, ID2:  WideString;

Label 1;
begin

  StationsInCL := TStringList.Create;
  StationsInCL.Clear;

  DATA_AvailableDays := TStringList.Create;
  DATA_AvailableDays.Clear;

  DATA_StationsPrograms := TStringList.Create;
  DATA_StationsPrograms.Clear;

  slStation := TStringList.Create;
  slStation.Clear;

  slDate := TStringList.Create;
  slDate.Clear;

  // Nalezení všech stanic (každá pouze jednou!)
  idx1 := 0;
  while ( idx1 <= CL.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if CL.Strings[idx1]='CL' then
    begin
      if StationsInCL.IndexOf( TCL(CL.Objects[idx1]).ID ) = -1 then
        StationsInCL.Add( TCL(CL.Objects[idx1]).ID );
    end
    else if CL.Strings[idx1]='CLGuide' then
    begin

      idx2 := 0;
      while ( idx2 <= TCLGuide(CL.Objects[idx1]).Items.Count - 1 ) do
      begin
        Application.ProcessMessages;

        if StationsInCL.IndexOf( TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID ) = -1 then
          StationsInCL.Add( TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID );

        Inc(idx2);
      end; {while idx2}

    end;

    Inc(idx1);
  end; {while idx1}


  // Rozdìlení stanic k jednotlivím pluginùm a jejich serverùm
  idx1 := 0;
  while ( idx1 <= TVpPlugins.Count - 1 ) do
  begin
    Application.ProcessMessages;

    idx2 := 0;
    while ( idx2 <= TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Count - 1 ) do
    begin
      Application.ProcessMessages;

      idx3 := StationsInCL.Count - 1;
      while ( idx3 >= 0 ) do
      begin
        Application.ProcessMessages;

        DecodeID( StationsInCL.Strings[idx3], '@', ID1, ID2 );
        if ID2 = TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID then
        begin
          TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Add(  StationsInCL.Strings[idx3]  );
          hIndex := TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Count - 1;
          TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Objects[hIndex] := TTVpStations.Create;
          TTVpStations( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Objects[hIndex] ).StationID := StationsInCL.Strings[idx3];
          TTVpStations( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Objects[hIndex] ).DATADays := TStringList.Create;
          TTVpStations( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Objects[hIndex] ).DATADays.Clear;

          StationsInCL.Delete(idx3);
        end;



        Dec(idx3);
      end; {while idx3}

      Inc(idx2);
    end; {while idx2}

    Inc(idx1);
  end; {while idx1}

 // AddLog('Naètení programu');
  // Naètení programu
  idx1 := 0;
  while ( idx1 <= TVpPlugins.Count - 1 ) do
  begin
    Application.ProcessMessages;

  //  AddLog('for TVpPlugins ' + inttostr(idx1));

    idx2 := 0;
    while ( idx2 <= TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Count - 1 ) do
    begin
      Application.ProcessMessages;

      Info := IntToStr(idx1+1)+'/'+IntToStr(idx2+1);

      SetCheckingUpdatesToStations( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations, True);


 //   AddLog('for TVpPlugins - Server ' + inttostr(idx2));

      DATA_AvailableDays.Clear;

      if TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Count > 0 then
      begin
//    AddLog('GetAvailableDays ' + TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID );
        TVpGetAvailableDays(idx1, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID, DATA_AvailableDays);
  //  AddLog('GetAvailableDays ' + TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID  + ' COMPLETE');

        idx3 := DATA_AvailableDays.Count - 1;
        while ( idx3 >= 0 ) do
        begin
          Application.ProcessMessages;

          idx4 := 0;
          while ( idx4 <= Stations.Count - 1 ) do
          begin
            Application.ProcessMessages;
            if UpperCase(Copy(Stations.Strings[idx4],Length(Stations.Strings[idx4]) - Length( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID ) + 1,Length( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID ))) = UpperCase(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID)  then
            begin
              if TTVpStations( Stations.Objects[idx4]).DATADays.IndexOf( DATA_AvailableDays.Strings[idx3] ) = -1 then
                Goto 1;
            end;

            Inc(idx4);
          end; {while idx4}


          DATA_AvailableDays.Delete(idx3);

          1:

          Dec(idx3);
        end; {while idx3}
//        1:


        DATA_StationsPrograms.Clear;
 //   AddLog('Load program');
        //datumy zvlast
        if (TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 10) or     //jedna stanice, datumy zvlast
           (TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 20) then   //vice stanic, datumy zvlast
        begin
          idx3 := 0;
          while ( idx3 <= DATA_AvailableDays.Count - 1 ) do
          begin
            Application.ProcessMessages;

 //   AddLog('DATA_AvailableDays ' + inttostr(idx3));

            if TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 10 then
            begin
              idx4 := 0;
              while ( idx4 <= TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Count - 1 ) do
              begin

 //   AddLog('10 idx4 ' + inttostr(idx4));

                Application.ProcessMessages;

                slStation.Clear;
                slStation.Add(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Strings[idx4]);

                DATA_StationsPrograms.Clear;

                //SetCheckingUpdatesToStations(slStation,True);

                slDate.Clear;
                slDate.Add(DATA_AvailableDays.Strings[idx3]);

                TVpGetProgram(idx1, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID, slStation, slDate, DATA_StationsPrograms);

                //SetCheckingUpdatesToStations(slStation,False);
                SQLSaveTVpProgram(DATA_StationsPrograms);

                Inc(idx4);
              end; {while idx4}
            end
            else if TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 20 then
            begin
              DATA_StationsPrograms.Clear;
  //  AddLog('20 ' + inttostr(idx4));

              //SetCheckingUpdatesToStations(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations,True);

              slDate.Clear;
              slDate.Add(DATA_AvailableDays.Strings[idx3]);

              TVpGetProgram(idx1, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations, slDate, DATA_StationsPrograms);

              //SetCheckingUpdatesToStations(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations,False);
              SQLSaveTVpProgram(DATA_StationsPrograms);
            end;


            Inc(idx3);
          end; {while idx3}

//    AddLog('idx3 complete ' );
        end
        //datumy dohromady
        else if (TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 15) or    //jedna stanice, datumy dohromady
                (TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 25) then  //vice stanic, datumy dohromady
        begin
//              showmessage('datumy');
  //  AddLog('datumy ');

          if TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 15 then
          begin
            idx4 := 0;
            while ( idx4 <= TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Count - 1 ) do
            begin
              Application.ProcessMessages;

              slStation.Clear;
              slStation.Add(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Strings[idx4]);

              DATA_StationsPrograms.Clear;

              //SetCheckingUpdatesToStations(slStation,True);

              TVpGetProgram(idx1, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID, slStation, DATA_AvailableDays, DATA_StationsPrograms);

              //SetCheckingUpdatesToStations(slStation,False);
              SQLSaveTVpProgram(DATA_StationsPrograms);

              Inc(idx4);
            end; {while idx4}
          end
          else if TTVpPluginData(TVpPlugins.Objects[idx1]).Info.PluginType = 25 then
          begin
            DATA_StationsPrograms.Clear;

            //SetCheckingUpdatesToStations(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations,True);
{ showmessage(
inttostr(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Count)
+#13+
inttostr(DATA_AvailableDays.Count)
);  }
//showmessage(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Strings[0]);
            TVpGetProgram(idx1, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).ServerID, TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations, DATA_AvailableDays, DATA_StationsPrograms);

            //SetCheckingUpdatesToStations(TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations,False);
            SQLSaveTVpProgram(DATA_StationsPrograms);

          end;

        end;


      end;

//      TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).StationsData.Clear;

      SetCheckingUpdatesToStations( TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations, False);

      Inc(idx2);
    end; {while idx2}

    Inc(idx1);
  end; {while idx1}


//  AddLog('Naètení programu - COMPLETE');


  // odstranìní stanic a programu
  idx1 := 0;
  while ( idx1 <= TVpPlugins.Count - 1 ) do
  begin
    Application.ProcessMessages;

    idx2 := 0;
    while ( idx2 <= TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Count - 1 ) do
    begin
      Application.ProcessMessages;

      TTVpServers(TTVpPluginData(TVpPlugins.Objects[idx1]).Servers.Objects[idx2]).DATAStations.Clear;

      Inc(idx2);
    end; {while idx2}

    Inc(idx1);
  end; {while idx1}

  LoadStationsData;

//  showmessage('complete');
end;

procedure SQLSaveTVpProgram(DATA : TStringList);
var idxStation, idxDate, idxProgram,
    idxSStation: Integer;
    iIncDate : Integer;
    dtLast: TDateTime;
    bND : Boolean;
    sSQL: WideString;
    SQLtb     : TSQLiteTable;

Label 1;
begin


  idxStation := 0;
  while ( idxStation <= DATA.Count - 1 ) do
  begin
    Application.ProcessMessages;

    idxSStation := Stations.IndexOf(TTVpStations(DATA.Objects[idxStation]).StationID);

//   showmessage(TTVpStations(DATA.Objects[idxStation]).StationID);
    SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Stations WHERE StationID='+''''+TextToSQLText(TTVpStations(DATA.Objects[idxStation]).StationID)+''''));

    if SQLtb.Count > 0 then
    begin
      sSQL := 'UPDATE Stations SET StationID='+''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationID )+''''+', '+
                     'Name='+''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationName )+''''+', '+
                     'Logo='+''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationLogo )+''''+
              ' WHERE ID='+IntToStr(SQLtb.FieldAsInteger(SQLtb.FieldIndex['ID']))+'';
      ExecSQLUTF8(sSQL);
    end
    else
    begin
      sSQL := 'INSERT INTO Stations(StationID, Name, Logo) VALUES ' +
                '(' +''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationID )+''''+', '+
                     ''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationName )+''''+', '+
                     ''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationLogo )+''''+');';
      ExecSQLUTF8(sSQL);
    end;

    SQLtb.Free;

    idxDate := 0;
    while ( idxDate <= TTVpStations(DATA.Objects[idxStation]).DATADays.Count - 1 ) do
    begin
      Application.ProcessMessages;

      if idxSStation <> -1 then
      begin
        if TTVpStations( Stations.Objects[idxSStation]).DATADays.IndexOf( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date ) <> -1 then
        begin
          Goto 1;
        end;
      end;

//      TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).Date

      dtLast := 0;
      bND    := False;

      idxProgram := 0;
      while ( idxProgram <= TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Count - 1 ) do
      begin
        Application.ProcessMessages;



        if dtLast > StrToTime( TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Time ) then
          bND := True;

        dtLast := StrToTime( TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Time );

        if bND = True then        
          iIncDate := 1
        else
          iIncDate := 0;
                             //kjjj

        sSQL := 'INSERT INTO Data(StationID, Date, IncDate, Time, Name, OrigName, Info, InfoImage, URL, Specifications) VALUES ' +
                '(' +''''+TextToSQLText( TTVpStations(DATA.Objects[idxStation]).StationID )+''''+', '+
                     ''''+TextToSQLText( TTVpStations( DATA.Objects[idxStation]).DATADays.Strings[idxDate] )+''''+', '+
                     ''''+IntToStr(iIncDate)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Time)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Name)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).OrigName)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Info)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).InfoImage)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).URL)+''''+', '+
                     ''''+TextToSQLText(TTVpProgram( TTVpDays( TTVpStations( DATA.Objects[idxStation]).DATADays.Objects[idxDate]).DATAProgram.Objects[idxProgram] ).Specifications)+''''+');';
        ExecSQLUTF8(sSQL);


        Inc(idxProgram);
      end; {while idxProgram}

      1:

      Inc(idxDate);
    end; {while idxDate}


    Inc(idxStation);
  end; {while idxStation}


end;


procedure SQLLoadAvailableDays;
begin

end;


procedure LoadStationsData;
var
  idx1, idx2, hIndex : Integer;
  SQLtb     : TSQLiteTable;
  sDate     : WideString;
begin
  Stations.Clear;


  // Nalezení všech stanic (každá pouze jednou!)
  idx1 := 0;
  while ( idx1 <= CL.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if CL.Strings[idx1]='CL' then
    begin
      if Stations.IndexOf( TCL(CL.Objects[idx1]).ID ) = -1 then
      begin
        Stations.Add( TCL(CL.Objects[idx1]).ID );
        hIndex := Stations.Count - 1;
        Stations.Objects[hIndex] := TTVpStations.Create;
        TTVpStations( Stations.Objects[hIndex] ).StationID   := TCL(CL.Objects[idx1]).ID;
        TTVpStations( Stations.Objects[hIndex] ).StationName := '';
        TTVpStations( Stations.Objects[hIndex] ).StationLogo := '';
        TTVpStations( Stations.Objects[hIndex] ).DATADays    := TStringList.Create;
        TTVpStations( Stations.Objects[hIndex] ).DATADays.Clear;
        TTVpStations( Stations.Objects[hIndex] ).NPData      := TStringList.Create;
        TTVpStations( Stations.Objects[hIndex] ).NPData.Clear;
        TTVpStations( Stations.Objects[hIndex] ).NPIndex     := -1;
      end;
    end
    else if CL.Strings[idx1]='CLGuide' then
    begin

      idx2 := 0;
      while ( idx2 <= TCLGuide(CL.Objects[idx1]).Items.Count - 1 ) do
      begin
        Application.ProcessMessages;

        if Stations.IndexOf( TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID ) = -1 then
        begin
          Stations.Add( TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID );
          hIndex := Stations.Count - 1;
          Stations.Objects[hIndex] := TTVpStations.Create;
          TTVpStations( Stations.Objects[hIndex] ).StationID   := TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID;
          TTVpStations( Stations.Objects[hIndex] ).StationName := '';
          TTVpStations( Stations.Objects[hIndex] ).StationLogo := '';
          TTVpStations( Stations.Objects[hIndex] ).DATADays    := TStringList.Create;
          TTVpStations( Stations.Objects[hIndex] ).DATADays.Clear;
          TTVpStations( Stations.Objects[hIndex] ).NPData      := TStringList.Create;
          TTVpStations( Stations.Objects[hIndex] ).NPData.Clear;
          TTVpStations( Stations.Objects[hIndex] ).NPIndex     := -1;
        end;

        Inc(idx2);
      end; {while idx2}

    end;

    Inc(idx1);
  end; {while idx1}


  //
  idx1 := 0;
  while ( idx1 <= Stations.Count - 1 ) do
  begin
    Application.ProcessMessages;

    SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Stations WHERE StationID='+''''+ TextToSQLText( Stations.Strings[idx1] )+''''));

    if SQLtb.Count > 0 then
    begin
      TTVpStations( Stations.Objects[idx1] ).StationName := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
      TTVpStations( Stations.Objects[idx1] ).StationLogo := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Logo']) );
    end;

    SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT DISTINCT Date FROM Data WHERE StationID='+''''+TextToSQLText( Stations.Strings[idx1] )+''''));
    if SQLtb.Count > 0 then
    begin
      while not SQLtb.EOF do
      begin
        sDate := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Date']) );

        TTVpStations( Stations.Objects[idx1]).DATADays.Add(  sDate  );
        hIndex := TTVpStations( Stations.Objects[idx1]).DATADays.Count - 1;
        TTVpStations( Stations.Objects[idx1]).DATADays.Objects[hIndex] := TTVpDays.Create;

        TTVpDays( TTVpStations( Stations.Objects[idx1]).DATADays.Objects[hIndex] ).Date := sDate;
        TTVpDays( TTVpStations( Stations.Objects[idx1]).DATADays.Objects[hIndex] ).DATAProgram := TStringList.Create;
        TTVpDays( TTVpStations( Stations.Objects[idx1]).DATADays.Objects[hIndex] ).DATAProgram.Clear;

        SQLtb.Next;
      end;

    end;
    SQLtb.Free;


    Inc(idx1);
  end; {while idx1}


  LoadNPData;

end;

procedure LoadNPData;
var
  idx1, hIndex : Integer;
  SQLtb     : TSQLiteTable;
  dtDate : TDateTime;
begin

  idx1 := 0;
  while ( idx1 <= Stations.Count - 1 ) do
  begin
    Application.ProcessMessages;

    TTVpStations( Stations.Objects[idx1] ).NPData.Clear;

    SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Data WHERE StationID='+''''+TextToSQLText( TTVpStations( Stations.Objects[idx1] ).StationID ) +''''+' AND ('+''''+'Date='+FormatDateTime('yyyy-mm-dd',Now-1)+''''+' OR Date='+''''+FormatDateTime('yyyy-mm-dd',Now)+''''+' OR Date='+FormatDateTime('yyyy-mm-dd',Now+1)+')' {' ORDER BY Time'}));

//    showmessage( 'SELECT * FROM Data WHERE StationID='+''''+TextToSQLText( TTVpStations( Stations.Objects[idx1] ).StationID ) +''''+' AND Date= ('+''''+FormatDateTime('yyyy-mm-dd',Now-1)+''''+' OR '+''''+FormatDateTime('yyyy-mm-dd',Now)+''''+' OR '+FormatDateTime('yyyy-mm-dd',Now+1)+')' {' ORDER BY Time'} + #13+ #13+
//    TTVpStations( Stations.Objects[idx1] ).StationID+#13+IntToStr(SQLtb.Count));

    if SQLtb.Count > 0 then
    begin
      while not SQLtb.EOF do
      begin

        dtDate := StrToDateTime( SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Date']) ) , DTFormat );
        dtDate := dtDate + SQLtb.FieldAsInteger(SQLtb.FieldIndex['IncDate']);

        TTVpStations( Stations.Objects[idx1] ).NPData.Add
          (
            FormatDateTime('yyyy-mm-dd',dtDate)
            + ' ' +
            SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) )
          );
{
  if 'Nova@365dni.cz'=TTVpStations( Stations.Objects[idx1] ).StationID then
    showmessage( TTVpStations( Stations.Objects[idx1] ).StationID+#13+
    SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Date']) )+#13+
                            FormatDateTime('yyyy-mm-dd',dtDate)
            + ' ' +
            SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) )

            );   }


        hIndex := TTVpStations( Stations.Objects[idx1] ).NPData.Count - 1;
        TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex] := TTVpProgram.Create;

        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).Time       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).Name       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).OrigName   := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['OrigName']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).Info       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Info']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).InfoImage  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['InfoImage']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).URL        := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['URL']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).Specifications:= SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Specifications']) );
        TTVpProgram(TTVpStations( Stations.Objects[idx1] ).NPData.Objects[hIndex]).IncDate    := SQLtb.FieldAsInteger(SQLtb.FieldIndex['IncDate']);
        {      TTVpProgram(Program_Data.Objects[hIndex]).ExtraSpec  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(Program_Data.Objects[hIndex]).ShowView   := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(Program_Data.Objects[hIndex]).IncDate    := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(Program_Data.Objects[hIndex]).Planned    := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );}



        SQLtb.Next;
      end;

    end;

    SQLtb.Free;



    Inc(idx1);
  end;  {while idx1}

end;

procedure SetCheckingUpdatesToStations(DATA : TStringList; bCheckingUpdates : Boolean);
var
  idx1, idx2: Integer;
begin

  idx1 := 0;
  while ( idx1 <= CL.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if CL.Strings[idx1]='CL' then
    begin

      idx2 := 0;
      while ( idx2 <= DATA.Count - 1 ) do
      begin
        Application.ProcessMessages;

        if DATA.Strings[idx2]=TCL(CL.Objects[idx1]).ID then
        begin
          TCL(CL.Objects[idx1]).CheckingUpdate := bCheckingUpdates;
          QIPPlugin.RedrawSpecContact(TCL(CL.Objects[idx1]).UniqID.UniqID);
        end;

        Inc(idx2);
      end; {while idx2}

    end;

    Inc(idx1);
  end;  {while idx1}

end;

procedure LoadPlan;
var
  SQLtb : TSQLiteTable;
  idx : Integer;
begin

  TVpPlan.Clear;


  SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT Plan.DataID, Plan.NotifyBeforeBegin, Plan.Notified, Data.StationID, Data.Date, Data.IncDate, Data.Time, Data.Name FROM Plan, Data WHERE (Data.ID = Plan.DataID) AND (Plan.Notified=0)'));
  if SQLtb.Count > 0 then
  begin
    while not SQLtb.EOF do
    begin

      TVpPlan.Add('ITEM');
      idx := TVpPlan.Count - 1;
      TVpPlan.Objects[idx] := TTVpPlan.Create;
      TTVpPlan(TVpPlan.Objects[idx]).DataID     := SQLtb.FieldAsInteger(SQLtb.FieldIndex['DataID']);
      TTVpPlan(TVpPlan.Objects[idx]).StationID  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['StationID']) );
      TTVpPlan(TVpPlan.Objects[idx]).Date       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Date']) );
      TTVpPlan(TVpPlan.Objects[idx]).IncDate    := SQLtb.FieldAsInteger(SQLtb.FieldIndex['IncDate']);
      TTVpPlan(TVpPlan.Objects[idx]).Time       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
      TTVpPlan(TVpPlan.Objects[idx]).Name       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
      TTVpPlan(TVpPlan.Objects[idx]).NotifyBeforeBegin := SQLtb.FieldAsInteger(SQLtb.FieldIndex['NotifyBeforeBegin']);
      TTVpPlan(TVpPlan.Objects[idx]).Notified   := SQLtb.FieldAsInteger(SQLtb.FieldIndex['Notified']);

      TTVpPlan(TVpPlan.Objects[idx]).DateTime := StrToDateTime( TTVpPlan(TVpPlan.Objects[idx]).Date + ' ' + TTVpPlan(TVpPlan.Objects[idx]).Time, DTFormat );
      TTVpPlan(TVpPlan.Objects[idx]).DateTime := TTVpPlan(TVpPlan.Objects[idx]).DateTime + TTVpPlan(TVpPlan.Objects[idx]).IncDate;

      TTVpPlan(TVpPlan.Objects[idx]).DateTime := TTVpPlan(TVpPlan.Objects[idx]).DateTime - (TTVpPlan(TVpPlan.Objects[idx]).NotifyBeforeBegin * (1/(24*60) ) );

//      showmessage(formatdatetime('yyyy-mm-dd hh:nn', TTVpPlan(TVpPlan.Objects[idx]).DateTime ));

      SQLtb.Next;
    end;

  end;

  SQLtb.Free;

end;

function GetStationPlanned(DataID : Int64) : Boolean;
var
  SQLtb : TSQLiteTable;
  idx : Integer;
begin

  Result := False;

  SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Plan WHERE DataID='+IntToStr(DataID)));
  if SQLtb.Count > 0 then
  begin
    Result := True;
//    SQLtb.FieldAsInteger(SQLtb.FieldIndex['Notified']);
  end;

  SQLtb.Free;

end;


procedure GetNPInfo(StationID: WideString; ProgramIndex: Integer; var Info : TNPInfo);
var
  IdxOf : Integer;
begin
  Info.Name := '';
  Info.TimeBegin := 0;
  Info.TimeEnd   := 0;
  Info.TimeLength := -1;
  Info.TimePosition := -1;

  IdxOf := Stations.IndexOf( StationID );
  if IdxOf <> -1 then
  begin

    if ProgramIndex = -2 then
      ProgramIndex := TTVpStations(Stations.Objects[IdxOf]).NPIndex;

    if ProgramIndex <> -1 then
    begin
      if ProgramIndex > TTVpStations(Stations.Objects[IdxOf]).NPData.Count - 1 then
      begin

      end
      else
      begin
        Info.Name   := TTVpProgram(TTVpStations(Stations.Objects[IdxOf]).NPData.Objects[ProgramIndex]).Name;

        Info.TimeBegin  := SQLDLToDT( TTVpStations(Stations.Objects[IdxOf]).NPData.Strings[ProgramIndex]  );

        if TTVpStations(Stations.Objects[IdxOf]).NPData.Count - 1 >= ProgramIndex+1 then
        begin
          Info.TimeEnd    := SQLDLToDT( TTVpStations(Stations.Objects[IdxOf]).NPData.Strings[ProgramIndex+1]);
          Info.TimeLength := DiffMinutes(Info.TimeBegin, Info.TimeEnd);
        end;

        Info.TimePosition := DiffMinutes(Info.TimeBegin, Now);
      end;
    end;
  end;

end;


procedure GetStationLogo(StationID : WideString; var img: TImage);
var
  idxStation: Integer;
  StationIDBase64, sFileName, sExt : WideString;
  rec: TSearchRec;
  HTMLData: TResultData;
  Info : TPositionInfo;
  F: TextFile;

begin
  StationIDBase64 := MIMEBase64Encode(WideString2UTF8(StationID));
  idxStation := Stations.IndexOf(StationID);

  if FindFirst(ProfilePath + 'Logos\' + StationIDBase64 + '.*', faAnyFile, rec) = 0 then
  begin
    sFileName := rec.name;
  end
  else
  begin
    if TTVpStations(Stations.Objects[idxStation]).StationLogo <> '' then
    begin
      HTMLData := GetHTML(TTVpStations(Stations.Objects[idxStation]).StationLogo, '', '', 5000, NO_CACHE, Info);

      sExt := ExtractFileExt( TTVpStations(Stations.Objects[idxStation]).StationLogo );

      if HTMLData.OK = True then
      begin
        if StrPosE(HTMLData.parString, 'NOT FOUND',1,False) <> 0  then
        begin
          sFileName := '';
        end
        else
        begin
          AssignFile(F, ProfilePath + 'Logos\' + StationIDBase64 + sExt);
          Rewrite(F);
          write(F,HTMLData.parString);
          CloseFile(F);

          sFileName := StationIDBase64 + sExt;
        end;
      end;
    end;
  end;

  if sFileName<>'' then
  begin
    try
      img.Picture.LoadFromFile(ProfilePath + 'Logos\' + sFileName);
    except

    end;
  end;

end;

end.
