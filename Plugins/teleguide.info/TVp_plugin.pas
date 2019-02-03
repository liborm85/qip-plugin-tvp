unit TVp_plugin;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, TVp_plugin_info,
     WinInet;


const
  PLUGIN_VER_MAJOR = 0;
  PLUGIN_VER_MINOR = 1;
  PLUGIN_NAME      : WideString = 'teleguide.info';
  PLUGIN_AUTHOR    : WideString = 'Lms';
  PLUGIN_TYPE      : Integer = 25;
        {
          10 - Nacitat stanice zvlast
          20 - Nacitat stanice dohromady
          25 - Nacitat stanice dohromady, nacitat vsechny datumy dohromady
        }


implementation

uses Convs, DownloadFile, TextSearch, General, XMLProcess;


(* === Plugin Info - PLUGIN PROCEDURE ======================================= *)
function GetPluginInfo(): TTVpPluginInfo; stdcall;
begin

  Result.SDKVerMajor    := TVp_SDK_VER_MAJOR;
  Result.SDKVerMinor    := TVp_SDK_VER_MINOR;
  Result.PluginVerMajor := PLUGIN_VER_MAJOR;
  Result.PluginVerMinor := PLUGIN_VER_MINOR;
  Result.PluginName     := PWideChar(PLUGIN_NAME);
  Result.PluginAuthor   := PWideChar(PLUGIN_AUTHOR);
  Result.PluginType     := PLUGIN_TYPE;

end;


(* === Set Conf ============================================================= *)
procedure SetConf( Conf: TSetConf ); stdcall;

begin

  TVpConf.TempPath := Conf.TempPath;
  TVpConf.Proxy_Use  := Conf.Proxy_Use;
  TVpConf.Proxy_Host := Conf.Proxy_Host;
  TVpConf.Proxy_Port := Conf.Proxy_Port;
  TVpConf.Proxy_User := Conf.Proxy_User;
  TVpConf.Proxy_Pass := Conf.Proxy_Pass;


end;

(* === Servers - PLUGIN PROCEDURE =========================================== *)
procedure GetServers( var DATA: TStringList ); stdcall;

var hIndex: Integer;

begin

  DATA := TStringList.Create;

  DATA.Add('SERVER');
  hIndex:= DATA.Count - 1;
  DATA.Objects[hIndex] := TDLLServers.Create;
  TDLLServers(DATA.Objects[hIndex]).ServerID   := 'teleguide.info';
  TDLLServers(DATA.Objects[hIndex]).ServerName := 'teleguide.info';

end;



(* === Get Stations - PLUGIN PROCEDURE ====================================== *)
procedure GetStations(Server: WideString; var DATA: TStringList); stdcall;

var
  XMLInfo: TXMLInfo;
  
begin

  DATA := TStringList.Create;

  GetXMLFile('http://www.teleguide.info/download/new3/xmltv.xml.gz', 'teleguideinfo_new.xml');
  //GetXMLFile('http://www.teleguide.info/download/old/xmltv.xml.gz', 'teleguideinfo_old.xml');

  ReadTVXMLStations(TVpConf.TempPath + 'teleguideinfo_new.xml', Data, XMLInfo);

end;


(* === Search - PLUGIN PROCEDURE ============================================ *)
procedure Search(SearchName: WideString; Server: WideString; var DATA: TStringList; var Info: TPositionInfo ); stdcall;

var hIndex: Integer;

    DATA_Stations: TStringList;
    i,r1,r2 : Integer;

begin
  DATA := TStringList.Create;
  DATA.Clear;

  GetStations(Server, DATA_Stations);

  for i:= 0 to DATA_Stations.Count - 1 do
  begin

    if DATA_Stations.Strings[i] = 'STATION' then
    begin
      if SearchName = '' then
      begin
        DATA.Add('STATION');
        hIndex:= DATA.Count - 1;
        DATA.Objects[hIndex] := TDLLStations.Create;
        TDLLStations(DATA.Objects[hIndex]).StationID   := TDLLStations(DATA_Stations.Objects[i]).StationID;
        TDLLStations(DATA.Objects[hIndex]).StationName := TDLLStations(DATA_Stations.Objects[i]).StationName;
        TDLLStations(DATA.Objects[hIndex]).StationLogo := TDLLStations(DATA_Stations.Objects[i]).StationLogo;
      end
      else
      begin
        r1:=StrPosE(TDLLStations(DATA_Stations.Objects[i]).StationName, SearchName,  1, False);

        if r1 = 0 then
        begin
          r2:=StrPosE(TDLLStations(DATA_Stations.Objects[i]).StationID, SearchName,  1, False);
          if r2 <> 0 then
          begin
            DATA.Add('STATION');
            hIndex:= DATA.Count - 1;
            DATA.Objects[hIndex] := TDLLStations.Create;
            TDLLStations(DATA.Objects[hIndex]).StationID   := TDLLStations(DATA_Stations.Objects[i]).StationID;
            TDLLStations(DATA.Objects[hIndex]).StationName := TDLLStations(DATA_Stations.Objects[i]).StationName;
            TDLLStations(DATA.Objects[hIndex]).StationLogo := TDLLStations(DATA_Stations.Objects[i]).StationLogo;
          end;
        end
        else if r1 <> 0 then
        begin
          DATA.Add('STATION');
          hIndex:= DATA.Count - 1;
          DATA.Objects[hIndex] := TDLLStations.Create;
          TDLLStations(DATA.Objects[hIndex]).StationID   := TDLLStations(DATA_Stations.Objects[i]).StationID;
          TDLLStations(DATA.Objects[hIndex]).StationName := TDLLStations(DATA_Stations.Objects[i]).StationName;
          TDLLStations(DATA.Objects[hIndex]).StationLogo := TDLLStations(DATA_Stations.Objects[i]).StationLogo;
        end;

      end;
    end;

  end;

end;


(* === Get Available Days - PLUGIN PROCEDURE ================================ *)
procedure GetAvailableDays(Server: WideString; var DATA: TStringList); stdcall;

var 
  XMLInfo: TXMLInfo;

begin
  DATA := TStringList.Create;
//showmessage('getavailabledays - start');

  GetXMLFile('http://www.teleguide.info/download/new3/xmltv.xml.gz', 'teleguideinfo_new.xml');
  //GetXMLFile('http://www.teleguide.info/download/old/xmltv.xml.gz', 'teleguideinfo_old.xml');


  ReadTVXMLAvailableDays(TVpConf.TempPath + 'teleguideinfo_new.xml', DATA, XMLInfo);
      {
  if DATA.Count >= 2 then
  begin
    DATA.Delete(0);
    DATA.Delete(DATA.Count-1);
  end;  }

//showmessage('getavailabledays - end; count: '+inttostr(DATA.count));
end;


(* === Get Extra Info ======================================================= *)
procedure GetExtraInfo(InfoURL: WideString; Server: WideString; Station: WideString; var DATA: TStringList; var Info: TPositionInfo); stdcall;

begin

  DATA := TStringList.Create;
  DATA.Clear;

end;


(* === Get Program ========================================================== *)
procedure GetProgram(Server: WideString; Station: TStringList; Dates : TStringList; var DATA: TStringList; var Info: TPositionInfo); stdcall;

var HTMLData: TResultData;
    XMLInfo: TXMLInfo;

begin
//showmessage('getprogram - start');
  DATA := TStringList.Create;


  GetXMLFile('http://www.teleguide.info/download/new3/xmltv.xml.gz', 'teleguideinfo_new.xml');
  //GetXMLFile('http://www.teleguide.info/download/old/xmltv.xml.gz', 'teleguideinfo_old.xml');


  ReadTVXMLProgram(TVpConf.TempPath + 'teleguideinfo_new.xml', Station, Dates, DATA, XMLInfo);


//showmessage('getprogram - end; count: '+inttostr(DATA.count));
end;

exports GetPluginInfo;
exports GetServers;
exports GetStations;
exports Search;
exports GetAvailableDays;
exports GetProgram;
exports GetExtraInfo;
exports SetConf;

end.
