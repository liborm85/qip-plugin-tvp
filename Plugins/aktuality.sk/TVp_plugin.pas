unit TVp_plugin;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, TVp_plugin_info,
     WinInet;


const
  PLUGIN_VER_MAJOR = 0;
  PLUGIN_VER_MINOR = 2;
  PLUGIN_NAME      : WideString = 'aktuality.sk';
  PLUGIN_AUTHOR    : WideString = 'Lms';
  PLUGIN_TYPE      : Integer = {20;}10;
        {
          10 - Nacitat stanice zvlast
          20 - Nacitat stanice dohromady
        }


implementation

uses Convs, DownloadFile, TextSearch;


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
  TDLLServers(DATA.Objects[hIndex]).ServerID   := 'aktuality.sk';
  TDLLServers(DATA.Objects[hIndex]).ServerName := 'aktuality.sk';
{  TSLServers(DATA.Objects[hIndex]).ServerIcon.Picture.Bitmap.LoadFromResourceID(0, 1); // := nil;}
{try
  TSLServers(DATA.Objects[hIndex]).ServerIcon.Picture.Bitmap.LoadFromResourceName(0, 'MyBitmap');
              except
  showmessage('not');
end;}

{
  DATA.Add('SERVER');
  hIndex:= DATA.Count - 1;
  DATA.Objects[hIndex] := TSLServers.Create;
  TSLServers(DATA.Objects[hIndex]).ServerID   := 'server2.cz';
  TSLServers(DATA.Objects[hIndex]).ServerName := 'Server èíslo 2';
  TSLServers(DATA.Objects[hIndex]).ServerIcon := nil;

  DATA.Add('SERVER');
  hIndex:= DATA.Count - 1;
  DATA.Objects[hIndex] := TSLServers.Create;
  TSLServers(DATA.Objects[hIndex]).ServerID   := 'server3.cz';
  TSLServers(DATA.Objects[hIndex]).ServerName := 'Server èíslo 3';
  TSLServers(DATA.Objects[hIndex]).ServerIcon := nil;   }

end;

(* === Get Stations - PLUGIN PROCEDURE ====================================== *)
procedure GetStations(Server: WideString; var DATA: TStringList); stdcall;

var HTMLData: TResultData;
    sStationName, sStationID, sStation, sStations: WideString;
    hIndex: Integer;

    Info: TPositionInfo;
    iFS, iNxt, iFS1, iFS2: Integer;

label SearchNextStation;

begin
  DATA := TStringList.Create;

  HTMLData := GetHTML('http://www.aktuality.sk/tv-program/', '', '', 10000, NO_CACHE, Info);

  if HTMLData.OK = True then
  begin

    sStations := Trim(FoundStr(HTMLData.parString,'id="stationsList"','</fieldset>',1));

    iNxt := 1;
SearchNextStation:
    sStationName:='';

    sStation := Trim(FoundStr(sStations,'<label','</label>',iNxt, iNxt, iFS1, iFS2));
    Inc(iNxt);

    if sStation<>'' then
    begin
      sStationName := FoundLastChar(sStation);

      sStationID := sStationName;   // Trim(FoundStr(sStation,'for="','"',1, iFS, iFS1, iFS2));

      if (sStationID<>'') and (sStationName<>'') then
      begin
        DATA.Add('STATION');
        hIndex:= DATA.Count - 1;
        DATA.Objects[hIndex] := TDLLStations.Create;
        TDLLStations(DATA.Objects[hIndex]).StationID:=sStationID + '@aktuality.sk';
        TDLLStations(DATA.Objects[hIndex]).StationName:=sStationName;
        TDLLStations(DATA.Objects[hIndex]).StationLogo:='';
      end;
      Application.ProcessMessages;
      GoTo SearchNextStation
    end;

       (*
      iNxt := 1;
SearchNextStation:
      sStationName:='';

      sStation := Trim(FoundStr(HTMLData.parString,'<div class="select-cat-stanice-box">','</div>',iNxt, iNxt, iFS1, iFS2));
      iNxt := iNxt + 1;
      if sStation<>'' then
      begin
        sStation := Trim(FoundStr(sStation,'<label','</label>',1, iFS, iFS1, iFS2));
        if sStation<>'' then
        begin
          sStationName := FoundLastChar(sStation)
        end;

        sStationID := {AnsiLowerCase( ConvFileName(} Trim(FoundStr(sStation,'for="','"',1, iFS, iFS1, iFS2)) {) )};

        if (sStationID<>'') and (sStationName<>'') then
        begin
          DATA.Add('STATION');
          hIndex:= DATA.Count - 1;
          DATA.Objects[hIndex] := TDLLStations.Create;
          TDLLStations(DATA.Objects[hIndex]).StationID:=sStationID + '@aktuality.sk';
          TDLLStations(DATA.Objects[hIndex]).StationName:=sStationName;
          TDLLStations(DATA.Objects[hIndex]).StationLogo:='';
        end;
        Application.ProcessMessages;
        GoTo SearchNextStation

      end;  *)

  end;

end;


(* === Search - PLUGIN PROCEDURE ============================================ *)
procedure Search(SearchName: WideString; Server: WideString; var DATA: TStringList; var Info: TPositionInfo ); stdcall;

var hIndex{, iFS}: Integer;
   // HTMLData: TResultData;
   // sName,sID: WideString;

    DATA_Stations: TStringList;
    i,r1,r2,r3 : Integer;



//Label EndProc;
//Label NextPlace;
begin
  DATA := TStringList.Create;
  DATA.Clear;

  GetStations(Server, DATA_Stations);

//  showmessage(inttostr(DATA_Stations.Count));

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
              if r2 = 0 then
              begin
                r3:=StrPosE(ConvOdstranitDiakritiku(TDLLStations(DATA_Stations.Objects[i]).StationName), ConvOdstranitDiakritiku(SearchName),  1, False);
                if r3 <> 0 then
                begin
                  DATA.Add('STATION');
                  hIndex:= DATA.Count - 1;
                  DATA.Objects[hIndex] := TDLLStations.Create;
                  TDLLStations(DATA.Objects[hIndex]).StationID   := TDLLStations(DATA_Stations.Objects[i]).StationID;
                  TDLLStations(DATA.Objects[hIndex]).StationName := TDLLStations(DATA_Stations.Objects[i]).StationName;
                  TDLLStations(DATA.Objects[hIndex]).StationLogo := TDLLStations(DATA_Stations.Objects[i]).StationLogo;
                end;
              end
              else if r2 <> 0 then
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

var HTMLData: TResultData;
//    r1, r2: Int64;
 {   sSelectDate, }sDay: WideString;
    hIndex: Integer;

    Info: TPositionInfo;
    iFS, iFS1, iFS2: Integer;

Label NextAvailableDay;

begin
  DATA := TStringList.Create;
//     showmessage('available days');

  try
    HTMLData := GetHTML('http://www.aktuality.sk/tv-program/', '', '', 10000, NO_CACHE, Info);
  except
    showmessage('error in downloading')
  end;

  if HTMLData.OK = True then
    begin
      iFS := 1;

NextAvailableDay:

      sDay := Trim(FoundStr(HTMLData.parString,'<option value="','"',iFS, iFS, iFS1, iFS2));
      iFS := iFS + 1;


      if sDay<>'' then
      begin
        DATA.Add('DATE');
        hIndex:= DATA.Count - 1;
        DATA.Objects[hIndex] := TDLLAvailableDays.Create;
        TDLLAvailableDays(DATA.Objects[hIndex]).DateID:=sDay;


        Application.ProcessMessages;
        goto NextAvailableDay
      end;

    end;

end;

(* === Get Extra Info ======================================================= *)
procedure GetExtraInfo(InfoURL: WideString; Server: WideString; Station: WideString; var DATA: TStringList; var Info: TPositionInfo); stdcall;
{
var HTMLData: TResultData;
    F: TextFile;
    r1, r2, hIndex: Integer;
    sExtraInfo: WideString;

    sInfoLong, sInfoLongImage, sSpecification: WideString;
    iShowView: Int64;
    iSpec: Integer;
}

begin

  DATA := TStringList.Create;
  DATA.Clear;


end;



(* === Get Program ========================================================== *)
procedure GetProgram(Server: WideString; Station: TStringList; Dates : TStringList; var DATA: TStringList; var Info: TPositionInfo); stdcall;

var HTMLData: TResultData;
    sDate: WideString;
//    F: TextFile;
  //  s1, s2: Int64;
//    p1, p2: Int64;
//    r1, r2, r3: Int64;
    hIndex: Integer;
//    sStation{, sProgram}: String;

//    sStationName, sStationID{, sStationLogo}: WideString;

    StationsList : TStringList;

//    StationIndex: Integer;
    i{, ii}: Integer;

//    sCheckedDate: WideString;

//    DATAProgram: TPrograms;

//    slServers: TStringList;

//    SetStations: Boolean;


    sStations: WideString;
    iFS, iTab, iProgPos, iPoradPos, iPrdPos, iFS1, iFS2 : Integer;
    iStatPos{, iNxt}: Integer;
    sProg, sProgTab, sPorad, sPrd : WideString;

    sPTime,sPName,sPInfo: WideString;

//    TabStations: TStringList;
    StationsInfo: TStringList;
    StatID,StatName,StatLogo , sStatLogo, sStatName : WideString;

//  F: TextFile;

    sHEXStations: AnsiString;
    URL,Cookie,CookieData : String;
    bReturn : Boolean;


Label NxtTabStation, NxtTabProgram, NxtPorad, NxtTable, SearchNextStation;
Label 1, 2;
begin
    // showmessage('get program');
  DATA := TStringList.Create;
  StationsList := TStringList.Create;

  sDate := Dates.Strings[0];

     {
      for i := 0 to Station.Count - 1 do
        begin
               showmessage(TSLStations(Station.Objects[i]).StationID);
        end;
       }


// RetryGetStation:

  StatName := '';
  StatLogo := '';

  DATA.Clear;
  StationsList.Clear;

  StationsInfo := TStringList.Create;
  StationsInfo.Clear;
(*  Info.Info := 'Downloading stations name';
  HTMLData := GetHTML('http://www.aktuality.sk/tv-program?view_station[]=', '', '', 10000, Info);

  if HTMLData.OK = True then
    begin
  Info.Info := 'Downloaded stations name';
      iNxt := 1;
SearchNextStation:
      sStationName:='';

      sStation := Trim(FoundStr(HTMLData.parString,'<div class="select-cat-stanice-box">','</div>',iNxt, iNxt));
      iNxt := iNxt + 1;
      if sStation<>'' then
      begin

        sStation := Trim(FoundStr(sStation,'<label','</label>',1, iFS));
//      showmessage(sStation);
        if sStation<>'' then
        begin
          sStationName := FoundLastChar(sStation)
        end;

        sStationID := {AnsiLowerCase( ConvFileName(} Trim(FoundStr(sStation,'for="','"',1, iFS)) {) )};
//        showmessage(sStationID);
        if (sStationID<>'') and (sStationName<>'') then
        begin

          StationsInfo.Add('STATION');
          hIndex:= StationsInfo.Count - 1;
          StationsInfo.Objects[hIndex] := TDLLStations.Create;
          TDLLStations(StationsInfo.Objects[hIndex]).StationID:=sStationID;
          TDLLStations(StationsInfo.Objects[hIndex]).StationName:=sStationName;
          TDLLStations(StationsInfo.Objects[hIndex]).StationLogo:='';
        end;
        Application.ProcessMessages;
        GoTo SearchNextStation

      end;

    end;
{

  for i := 0 to StationsInfo.Count - 1 do
  begin
    TSLStations(StationsInfo.Objects[i]).StationID := Copy(TSLStations(StationsInfo.Objects[i]).StationID, 1, Length(TSLStations(StationsInfo.Objects[i]).StationID) - Length('@aktuality.sk'));
  end;
           }
  for i := 0 to Station.Count - 1 do
  begin
    for ii := 0 to StationsInfo.Count - 1 do
    begin


      if {AnsiUpperCase(ConvFileName(}TDLLStations(Station.Objects[i]).StationID{))} = {AnsiUpperCase(ConvFileName(}TDLLStations(StationsInfo.Objects[ii]).StationID{))} then
      begin
        TDLLStations(Station.Objects[i]).StationID := TDLLStations(StationsInfo.Objects[ii]).StationID;
//        showmessage(TSLStations(Station.Objects[i]).StationID);
        Goto 2;
      end;
    end;
    
//      showmessage('nenalzene ' + TSLStations(Station.Objects[i]).StationID);
      2:

  end;            *)





  // SET STATIONS
  sStations := '';
  for i := 0 to Station.Count - 1 do
  begin
    if UpperCase(Copy(Station.Strings[i],Length(Station.Strings[i]) - Length('@AKTUALITY.SK') + 1,Length('@AKTUALITY.SK'))) = '@AKTUALITY.SK'  then
    begin
      if sStations='' then
        sStations := 'i:'+inttostr(i)+';s:0:'+Copy(Station.Strings[i],1, Length(Station.Strings[i]) - Length('@AKTUALITY.SK') )+';'
      else
        sStations := sStations + ',' + 'i:'+inttostr(i)+';s:0:'+Copy(Station.Strings[i],1, Length(Station.Strings[i]) - Length('@AKTUALITY.SK') )+';';
    end;
  end;

  sStations := 'a:'+inttostr(Station.Count)+':{'+sStations+'}';

  sHEXStations := '';
  for i := 1 to Length(sStations) do
  begin
    sHEXStations := sHEXStations + '%'+IntToHex(Ord(sStations[i]),2);
  end;

//  URL        := 'http://www.aktuality.sk/tv-program/';
  URL        := 'http://www.aktuality.sk/tv-program/';
  Cookie     := 'cookie_view_station_filter';
  //CookieData := '%C8T1%2C%C8T2%2CNova%2CPrima%2CJim+Jam%2C%D3%E8ko'+'; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  CookieData := sHEXStations + '; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  bReturn := InternetSetCookie(PChar(URL), PChar(Cookie), PChar(CookieData));
  if(not bReturn) then ShowMessage('FALSE SetCookie');
  //---

  exit;


//i:0;s:7:"Markiza";
//a:4:{i:0;s:7:"Markiza";i:1;s:7:"JOJPlus";i:2;s:3:"CT1";i:3;s:3:"TA3";}



  Info.Info := 'Downloading';

//  showmessage(sStations);

 //    http://www.aktuality.sk/tv-program?date=2008-04-10&view_station[]=Markiza&view_station[]=JOJ

  try                //    sDate
    HTMLData := GetHTML('http://www.aktuality.sk/tv-program/?date='+sDate, '', '', 10000, NO_CACHE, Info);
  except

    DATA.Add('DOWNLOADERROR');

    HTMLData.OK := False;

  end;

{
      AssignFile(F, TVpConf.TempPath + 'aktualitysk-url.txt');
      Rewrite(F);
      writeln(f,'http://www.aktuality.sk/tv-program?tzUpper0=block&date=' + sDate + sStations);
      CloseFile(F);
}


  Info.Info := 'Downloaded';

  if HTMLData.OK = True then
    begin
{      StationsInfo := TStringList.Create;
      StationsInfo.Clear;}

(***      AssignFile(F, TVpConf.TempPath + 'aktualitysk.txt');
      Rewrite(F);    ***)



//      writeln(f,'http://www.aktuality.sk/tv-program?tzUpper0=block&date=' + sDate + sStations);



//      showmessage(TVpConf.TempPath + #13+#10+ TVpConf.TempPath + 'html-data.txt');

{
      AssignFile(F, TVpConf.TempPath + 'html-data.txt');
      Rewrite(F);
      writeln(f,HTMLData.parString);
      CloseFile(F);
}
{
      sCheckedDate:='';

      CheckDate(HTMLData.parString, sCheckedDate);

      if sCheckedDate <> sDate then
        begin
          SHOWMESSAGE('PLUGIN INFO: datum nenalezen!' +#13+sDate);
        end;
}



      Info.Info := 'Working';

      //TabStations := TStringList.Create;


      NxtTable:
      //////// TABLE
      //TabStations.Clear;
      sProg := FoundStr(HTMLData.parString,'<table>','</table>',iTab,iTab, iFS1, iFS2);
      iTab := iTab + 1;

      if sProg <> '' then
      begin
        iProgPos := 1;

        NxtTabStation:

        /////// PORAD / NAZEV STANICE
        sProgTab := FoundStr(sProg,'<td class="default-station-head-grey">','</td>',iProgPos,iProgPos, iFS1, iFS2);
        iProgPos := iProgPos + 1;

        if sProgTab <> '' then
        begin
//          TabStations.Add ( FoundStr(sProgTab,'alt="','"',1,iFS, iFS1, iFS2) );

          sStatName := FoundStr(sProgTab,'alt="','"',1,iFS, iFS1, iFS2);
          if sStatName <> '' then
          begin
            StatName := sStatName;
          end;

          sStatLogo := FoundStr(sProgTab,'<img src="','"',1,iFS1, iFS1, iFS2);
//          showmessage(StatLogo+#13+#13+sProgTab);
          if sStatLogo <> '' then
          begin
            StatLogo := 'http://www.aktuality.sk/' + sStatLogo;
          end;

//          showmessage(FoundStr(sProgTab,'alt="','"',1,iFS));
          Application.ProcessMessages;
          Goto NxtTabStation;
        end;


        iPoradPos := 1;


        NxtTabProgram:
        iStatPos := -1;

//        sPorad := FoundStr(sProg,'<td class="default-station-box" style="">','</td>',iPoradPos,iPoradPos);
        sPorad := FoundStr(sProg,'<td class="default-station-box','</td>',iPoradPos,iPoradPos, iFS1, iFS2);
        iPoradPos := iPoradPos + 1;



        if sPorad <> '' then
        begin
          Inc(iStatPos);
//             showmessage(TabStations.Strings[iStatPos]);
(*** ***         if TabStations.Strings[iStatPos]='' then
          begin
            StatID    := '';
            StatName  := '';
            StatLogo  := '';
          end
          else
          begin
            for i := 0 to StationsInfo.Count - 1 do
            begin

//showmessage(TSLStations(StationsInfo.Objects[i]).StationName +#13+ TabStations.Strings[iStatPos]);
              if TDLLStations(StationsInfo.Objects[i]).StationName = TabStations.Strings[iStatPos] then
              begin
                StatID    := {AnsiLowerCase(ConvFileName(}TDLLStations(StationsInfo.Objects[i]).StationID{))} + '@aktuality.sk';
                StatName  := TDLLStations(StationsInfo.Objects[i]).StationName;
                StatLogo  := TDLLStations(StationsInfo.Objects[i]).StationLogo;
                Goto 1;
              end;
            end;

//            showmessage('stanice nenalezena' +#13+ TabStations.Strings[iStatPos]);

            1:
          end;     *** ***)
//                    showmessage(TabStations.Strings[iStatPos] + #13 + StatID);

                             {
          StatLogo := FoundStr(sProgTab,'<img src="','"',1,iFS1, iFS1, iFS2);
          showmessage(StatLogo+#13+#13+sProgTab);
          if StatLogo <> '' then
          begin
            StatLogo := 'http://www.aktuality.sk/' + StatLogo;
          end;
                            }
          DATA.Add('STATION');
          hIndex:= DATA.Count - 1;
          DATA.Objects[hIndex] := TDLLStations.Create;
          TDLLStations(DATA.Objects[hIndex]).StationID   := Station.Strings[0];  //TabStations.Strings[iStatPos]+'@aktuality.sk';//StatID;
          TDLLStations(DATA.Objects[hIndex]).StationName := StatName;
          TDLLStations(DATA.Objects[hIndex]).StationLogo := StatLogo;

/////http://www.aktuality.sk/components/com_tv/img_tv/logos-noborder/ct1.gif

(***          writeln(f,'STATION '+ TDLLStations(DATA.Objects[hIndex]).StationID + ' / ' + TDLLStations(DATA.Objects[hIndex]).StationName );
***)
          iPrdPos := 1;

          NxtPorad:

          sPrd := FoundStr(sPorad,'_width: 180px;">','<div class="clear"></div></div>',iPrdPos,iPrdPos, iFS1, iFS2);

//            showmessage(sPrd);
          iPrdPos := iPrdPos + 1;
          if sPrd<>'' then
          begin
//              showmessage(sPName);
            sPTime := FoundStr(sPrd,'<div class="prog-cas">','<',1,iFS, iFS1, iFS2);
            sPName := FoundStr(sPrd,'<div class="prog-box-nazov">','<',1,iFS, iFS1, iFS2);
            if sPName='' then
              sPName := FoundStr(sPrd,'<div class="prog-box-nazov-running">','<',1,iFS, iFS1, iFS2);

            sPInfo := FoundLastChar(FoundStr(sPrd,'<div class="prog-box-popis">','</span>',1,iFS, iFS1, iFS2));

//           _width: 180px;">
//          <div class="clear"></div></div>

            DATA.Add('PROGRAM');
            hIndex:= DATA.Count - 1;
            DATA.Objects[hIndex] := TDLLProgramInfo.Create;
            TDLLProgramInfo(DATA.Objects[hIndex]).Time      :=Trim(HTMLToText(sPTime));
            TDLLProgramInfo(DATA.Objects[hIndex]).Name      :=Trim(HTMLToText(sPName));
            TDLLProgramInfo(DATA.Objects[hIndex]).OrigName  :='';
            TDLLProgramInfo(DATA.Objects[hIndex]).Info      :=Trim(HTMLToText(sPInfo));
            TDLLProgramInfo(DATA.Objects[hIndex]).InfoImage :='';//Trim(DATAProgram.InfoImage);
            TDLLProgramInfo(DATA.Objects[hIndex]).Specifications := '';
//            TDLLProgramInfo(DATA.Objects[hIndex]).PrgType   :='';//Trim(DATAProgram.PrgType);
//            TDLLProgramInfo(DATA.Objects[hIndex]).PrgSpec   :='';//Trim(DATAProgram.PrgSpec);
            TDLLProgramInfo(DATA.Objects[hIndex]).URL       :='';//Trim(DATAProgram.URL);

//            showmessage(TDLLProgramInfo(DATA.Objects[hIndex]).Time + '     ' + TDLLProgramInfo(DATA.Objects[hIndex]).Name);

(***            writeln(f, TDLLProgramInfo(DATA.Objects[hIndex]).Time + ' - ' + TDLLProgramInfo(DATA.Objects[hIndex]).Name );
***)
            Application.ProcessMessages;
            Goto NxtPorad;
          end;

          Application.ProcessMessages;
          GoTo NxtTabProgram;
        end;

        Application.ProcessMessages;
        Goto NxtTable;
      end;





(***      CloseFile(F);
***)
//            showmessage('ed');
  Info.Info := '';

    end;

{  else
    showmessage('Nelze stahnout');}


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
(*

a:2:{
 i:0;s:7:"Markiza";
 i:1;s:3:"TA3";
}

a:3:{
  i:0;s:7:"Markiza";
  i:1;s:7:"JOJPlus";
  i:2;s:3:"TA3";
}

a:4:{
  i:0;s:7:"Markiza";
  i:1;s:7:"JOJPlus";
  i:2;s:3:"CT1";
  i:3;s:3:"TA3";}

a:4:{i:0;s:7:"Markiza";i:1;s:7:"JOJPlus";i:2;s:3:"CT1";i:3;s:3:"TA3";}

*)
