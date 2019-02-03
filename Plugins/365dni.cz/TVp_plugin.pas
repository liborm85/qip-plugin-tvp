unit TVp_plugin;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, TVp_plugin_info,
     WinInet;


const
  PLUGIN_VER_MAJOR = 0;
  PLUGIN_VER_MINOR = 7;
  PLUGIN_NAME      : WideString = '365dni.cz (tvp.sms.cz)';
  PLUGIN_AUTHOR    : WideString = 'Lms';
  PLUGIN_TYPE      : Integer = 20;
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
  TDLLServers(DATA.Objects[hIndex]).ServerID   := '365dni.cz';
  TDLLServers(DATA.Objects[hIndex]).ServerName := '365dni.cz (tvp.sms.cz)';
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
    r1, r2{,r3}: Int64;
//    sChecked: String;
//    bChecked: Boolean;
    sStationName, sStationID: WideString;
    hIndex: Integer;

    Info: TPositionInfo;

label SearchNextStation;

begin
  DATA := TStringList.Create;

//  HTMLData := GetHTML('http://tv.sms.cz/index.php?P_id_kategorie=56456&P_soubor=/televize/volba_stanice.php', '', '', 10000, NO_CACHE, Info);
//  HTMLData := GetHTML('http://tv.sms.cz/index.php?P_id_kategorie=56456&P_soubor=televize/volba_stanice.php', '', '', 10000, NO_CACHE, Info);
  HTMLData := GetHTML('http://tv.sms.cz/index.php?P_id_kategorie=56456&P_soubor=televize/volba_stanice.php', '', '', 10000, NO_CACHE, Info);
//showmessage(HTMLData.parString+'---END----');

  if HTMLData.OK = True then
    begin
  //       showmessage('ok');
      r2 := 1;
SearchNextStation:
      sStationName:='';
      r1:=StrPosE(HTMLData.parString, 'class="tv"', r2, False);
//showmessage(inttostr(r1)+#13+#13+HTMLData.parString+#13+'----END----');
      if r1 <> 0 then
        begin
          r2:=StrPosE(HTMLData.parString, 'value="', r1 , False);

          if r2 <> 0 then
            begin
              r1:=StrPosE(HTMLData.parString, '"', r2 + 7, False);

              if r1 <> 0 then
                begin

    //            showmessage(Copy(HTMLData.parString, r2 + 7, r1 - r2 - 7) );

                  sStationName:=FoundLastChar2(Copy(HTMLData.parString, r2 + 7, r1 - r2 - 7));

                  sStationID:= {ConvFileName(}sStationName{)};


(*                  DATA.StationName.Add( sStationName );
                  DATA.StationID.Add( sStationID );*)
(*
                  bChecked:=False;

                  sChecked :='';
                  r3:=StrPosE(HTMLData.parString, '>', r1, False);

                  if r3 <> 0 then
                    begin
                    sChecked :=Copy(HTMLData.parString, r1, r3 - r1 );

                    r3:=StrPosE(sChecked, 'checked="checked"', 1, False);

                    if r3 <> 0 then
                      begin
//                        DATA.StationChecked.Add('True');
                        //frmMain.lstStations.Checked[frmMain.lstStations.Items.Count - 1] := True;
//                        Result.Stations[High(Result.Stations)].Checked := True;

                        bChecked:=True;
                      end
                    end;   *)

                  Application.ProcessMessages;


                  DATA.Add('STATION');
                  hIndex:= DATA.Count - 1;
                  DATA.Objects[hIndex] := TDLLStations.Create;
                  TDLLStations(DATA.Objects[hIndex]).StationID:=sStationID + '@365dni.cz';
                  TDLLStations(DATA.Objects[hIndex]).StationName:=sStationName;
                  TDLLStations(DATA.Objects[hIndex]).StationLogo:='';
//                  TSLStations(DATA.Objects[hIndex]).StationChecked:=bChecked;
(*                  if bChecked=true then
                      DATA.StationChecked.Add('1')
                  else
                      DATA.StationChecked.Add('0');
*)
                  Application.ProcessMessages;
                  GoTo SearchNextStation
                end;
            end;
        end;

    end;


end;


(* === Search - PLUGIN PROCEDURE ============================================ *)
procedure Search(SearchName: WideString; Server: WideString; var DATA: TStringList; var Info: TPositionInfo ); stdcall;

var hIndex{, iFS}: Integer;
   // HTMLData: TResultData;
   // sName,sID: WideString;

    DATA_Stations: TStringList;
    i,r1,r2, r3 : Integer;



//Label EndProc;
//Label NextPlace;
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
    r1, r2: Int64;
    sSelectDate: WideString;
    hIndex: Integer;

    Info: TPositionInfo;

Label NextAvailableDay;

begin
  DATA := TStringList.Create;


  try
    HTMLData := GetHTML('http://tv.sms.cz', '', '', 10000, NO_CACHE, Info);
  except
    showmessage('error in downloading')
  end;




  if HTMLData.OK = True then
    begin
      r1:=StrPosE(HTMLData.parString, 'select name="datum"',  1, False);
      if r1 <> 0 then
        begin
          r2:=StrPosE(HTMLData.parString, '</select>',  r1, False);
          if r2 <> 0 then
            begin

              sSelectDate :=  Copy(HTMLData.parString, r1, r2 - r1);

            end;
        end;

      r2:=1;

NextAvailableDay:
      r1:=StrPosE(sSelectDate, 'option value="',  r2, False);
      if r1 <> 0 then
        begin
          r2:=StrPosE(sSelectDate, '"',  r1 + 14, False);
          if r2 <> 0 then
            begin


              DATA.Add('DATE');
              hIndex:= DATA.Count - 1;
              DATA.Objects[hIndex] := TDLLAvailableDays.Create;
              TDLLAvailableDays(DATA.Objects[hIndex]).DateID:=Copy(sSelectDate,r1 + 14,  r2 - r1 - 14);

              if TDLLAvailableDays(DATA.Objects[hIndex]).DateID='' then
                TDLLAvailableDays(DATA.Objects[hIndex]).DateID := FormatDateTime('yyyy-mm-dd',Now);

              //showmessage(Copy(sSelectDate,r1 + 14,  r2 - r1 - 14));

(*            DATA.DayID.Add(Copy(sSelectDate,r1 + 14,  r2 - r1 - 14));*)

              Application.ProcessMessages;
              goto NextAvailableDay
            end;
        end;
    end;

end;

(* === Get Extra Info ======================================================= *)
procedure GetExtraInfo(InfoURL: WideString; Server: WideString; Station: WideString; var DATA: TStringList; var Info: TPositionInfo); stdcall;

var HTMLData: TResultData;
    F: TextFile;
    r1, r2, hIndex: Integer;
    sExtraInfo: WideString;

    sInfoLong, sInfoLongImage, sSpecification: WideString;
    iShowView: Int64;
    iSpec: Integer;

begin

  DATA := TStringList.Create;
  DATA.Clear;

  iSpec := 0;
(*

  Info.Info := 'Downloading';

  HTMLData := GetHTML(InfoURL, '', '', 10000, NO_CACHE, Info);

  Info.Info := 'Downloaded';

  if HTMLData.OK = True then
    begin
      AssignFile(F, TVpConf.TempPath + 'html-extrainfo-365dnicz.txt');
      Rewrite(F);
      writeln(f,HTMLData.parString);
      CloseFile(F);

      r1:=StrPosE(HTMLData.parString, 'class="P_nadpis"', 1, False);

      if r1<>0 then
        begin
          sExtraInfo := copy(HTMLData.parString, r1, Length(HTMLData.parString) - r1);

          r1:=StrPosE(sExtraInfo, '</div> <!-- obsah -->', 1, False);
          if r1<>0 then
            begin
              sExtraInfo := Copy(sExtraInfo, 1, r1);
            end;

          r1:=StrPosE(sExtraInfo, '<strong>Dlouhý popis</strong>', 1, False);

          if r1 <> 0 then
            begin
              r2:=StrPosE(sExtraInfo, '</div>', r1, False);

              if r2 <> 0 then
                begin
                 sInfoLong := Copy(sExtraInfo,r1 + 29, r2 - r1 - 29);

                sInfoLong := StringReplace(sInfoLong, '<br />', '', [rfReplaceAll]);
{
                 if AnsiUpperCase(Copy(sInfoLong,length(sInfoLong) - 3, 4)) = AnsiUpperCase('</p>') then
                   sInfoLong := Copy(sInfoLong,1, length(sInfoLong) - 4);

                 if AnsiUpperCase(Copy(sInfoLong,1, 6)) = AnsiUpperCase('<br />') then
                   sInfoLong := Copy(sInfoLong,7, length(sInfoLong) - 6);

                 if AnsiUpperCase(Copy(sInfoLong,1, 1)) = AnsiUpperCase(' ') then
                   sInfoLong := Copy(sInfoLong,2, length(sInfoLong) - 1);}
                end;
            end;

{  IMAGE - jeden
<img class="P_obr" src="http://gonet.cz/~tri65dnigalerie/tv_porad/250/4/49bab9c200272e512883b77d029f9860.jpg" BORDER="0">
}
          r1:=StrPosE(sExtraInfo, 'SRC="', 1, False);

          if r1 <> 0 then
            begin
              r2:=StrPosE(sExtraInfo, '"',  r1 + 5, False);
              if r2 <> 0 then
                begin
                  sInfoLongImage := Copy(sExtraInfo, r1 + 5, r2 - (r1 + 5));
                end;

            end;


          r1:=StrPosE(sExtraInfo, '<strong>Showview</strong><br />', 1, False);

          if r1 <> 0 then
            begin
              r2:=StrPosE(sExtraInfo, '<',  r1 + 31, False);
              if r2 <> 0 then
                begin
                  iShowView := ConvStrToInt(Copy(sExtraInfo, r1 + 31, r2 - (r1 + 31)));
                end;

            end;

          r1:=StrPosE(sExtraInfo, '<strong>Specifikace</strong><br />', 1, False);

          if r1 <> 0 then
            begin
              r2:=StrPosE(sExtraInfo, '<',  r1 + 34, False);
              if r2 <> 0 then
                begin
                  sSpecification := Copy(sExtraInfo, r1 + 34, r2 - (r1 + 34));

                  if StrPosE(sSpecification, 'skryté titulky', 1, False) <> 0 then
                    iSpec := iSpec + 10;

                  if StrPosE(sSpecification, 'znakový jazyk', 1, False) <> 0 then
                    iSpec := iSpec + 20;


                  if StrPosE(sSpecification, 'stereo', 1, False) <> 0 then
                    iSpec := iSpec + 1;

                  //if StrPosE(sSpecification, 'duo', 1, False) <> 0 then
                  //  iSpec := iSpec + 2;

                end;


            end;



          DATA.Add('PROGRAM');
          hIndex:= DATA.Count - 1;
          DATA.Objects[hIndex] := TDLLProgramInfo.Create;
          TDLLProgramInfo(DATA.Objects[hIndex]).LongInfo      := Trim(sInfoLong);
          TDLLProgramInfo(DATA.Objects[hIndex]).LongInfoImage := Trim(sInfoLongImage);
          TDLLProgramInfo(DATA.Objects[hIndex]).ShowView      := iShowView;

          //////////////////////////////////////////////////////////////////////
          TDLLProgramInfo(DATA.Objects[hIndex]).PrgSpec       := inttostr(iSpec); //sSpecification;

//        showmessage('LONGINFO:' +#13+ sInfoLong +#13+#13+ 'LONGINFOIMAGE:' +#13+ sInfoLongImage  +#13+#13+'SHOWVIEW:' +#13+ sShowView + #13 + #13 + 'SPECIFICATION:' +#13+  sSpecification);

        end;






    end;

*)
end;


(* === Set _ Stations ======================================================= *)
(*function Set_Stations( Station: TStringList): WideString;
var HTMLData: TResultData;
//  r1,r2: int64;
  i,ii: Integer;
//  F: TextFile;
//  sStationID, sStationName: WideString;
  sHTML: WideString;
//  bStationChecked : boolean;

  Info: TPositionInfo;
//  ListStat: WideString;

  slStat: TStringList;
//  tcomponentSender: TComponent;
//  Sender: TComponent;
//    ret: Integer;
//    handle: Integer;
//    LinkUrl: String;

    sStations, sHEXStations: AnsiString;

    URL,Cookie,CookieData : String;

    bReturn : Boolean;

//Label SearchNextStation;
//Label RU;
//Label ES;
begin


  HTMLData := GetHTML('http://tv.sms.cz/index.php?P_id_kategorie=56456&P_soubor=/televize/volba_stanice.php', '', '', 10000, Info);

  sHTML:=HTMLData.parString;

  GetStations('365dni.cz', slStat);

  for i := 0 to Station.Count - 1 do
  begin
    for ii := 0 to slStat.Count - 1 do
    begin

      if slStat.Strings[i]='STATION' then
      begin

        if TDLLStations(Station.Objects[i]).StationID + '@365dni.cz' = TDLLStations(slStat.Objects[ii]).StationID then
        begin
          TDLLStations(Station.Objects[i]).StationName :=  TDLLStations(slStat.Objects[ii]).StationName;
          break;
        end;

      end;

    end;
  end;

  sStations := '';
  for i := 0 to Station.Count - 1 do
  begin
    if sStations='' then
      sStations := TDLLStations(Station.Objects[i]).StationName
    else
      sStations := sStations + ',' + TDLLStations(Station.Objects[i]).StationName
  end;
  sHEXStations := '';
  for i := 1 to Length(sStations) do
  begin
    sHEXStations := sHEXStations + '%'+IntToHex(Ord(sStations[i]),2);
  end;
    
  {
  sHEXStations := '';
  while ( i<= Length(sStations) ) do
  begin
    sHEXStations := sHEXStations + '%'+IntToHex(Ord(sStations[i]),2);

    Inc(i);
  end;}
{showmessage(    sStations + #13+#13+
   sHEXStations);}

  URL        := 'http://sms.cz/';
  Cookie     := 'P_cookies_televize_stanice';
  //CookieData := '%C8T1%2C%C8T2%2CNova%2CPrima%2CJim+Jam%2C%D3%E8ko'+'; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  CookieData := sHEXStations + '; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  bReturn := InternetSetCookie(PChar(URL), PChar(Cookie), PChar(CookieData));
  if(not bReturn) then ShowMessage('FALSE SetCookie');

  URL        := 'http://sms.cz/';
  Cookie     := 'P_cookies_siroke_zobrazeni';
  CookieData := 'false'+'; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  bReturn := InternetSetCookie(PChar(URL), PChar(Cookie), PChar(CookieData));
  if(not bReturn) then ShowMessage('FALSE SetCookie');
//showmessage('set');
end;      *)

(* === Check Date =========================================================== *)
(*procedure CheckDate( sHTML: WideString; var sCheckedDate: WideString );
var r1,r2,r3,r4,r5: Integer;
    sSelectDate, sOption: WideString;

Label NextAvailableDay,ExitProc;
begin

      r1:=StrPosE(sHTML, 'select name="datum"',  1, False);
      if r1 <> 0 then
        begin
          r2:=StrPosE(sHTML, '</select>',  r1, False);
          if r2 <> 0 then
            begin

              sSelectDate :=  Copy(sHTML, r1, r2 - r1);

            end;
        end;

      r2:=1;

NextAvailableDay:
      sOption:='';
      r1:=StrPosE(sSelectDate, '<option',  r2, False);
      if r1 <> 0 then
        begin

          r2:=StrPosE(sSelectDate, '</option>',  r1, False);
          if r2 <> 0 then
            begin
              sOption:=Copy(sSelectDate, r1, r2 - r1);

              r3:=StrPosE(sOption, 'selected',  1, False);
              if r3 <> 0 then
                begin

                  r4:=StrPosE(sOption, 'option value="',  1, False);
                  if r4 <> 0 then
                    begin
                      r5:=StrPosE(sOption, '"',  r4 + 14, False);
                      if r5 <> 0 then
                        begin

                          sCheckedDate:=Copy(sOption, r4 + 14,  r5 - r4 - 14);
                          GoTo ExitProc;

                        end;
                    end;

                end;
              Application.ProcessMessages;
              GoTo NextAvailableDay;
            end;

        end;

ExitProc:

end;      *)


(* === Process _ Program ==================================================== *)
procedure Process_Program(sHTML: WideString; var DATA: TPrograms);
var sProgram, sImage: WideString;
    r1,r2: Integer;
//    F: TextFile;
//    iPrgSpec: Integer;
    sPrgGenre, sPrgType, sPrgScreen, sPrgSound : WideString;
Label NextImage;
begin
  sProgram := sHTML;

  DATA.Time:='';
  DATA.Name:='';
  DATA.OrigName:='';
  DATA.Info:='';
  DATA.InfoImage:='';
  DATA.Specifications:='';
//  DATA.PrgType:='';
//  DATA.PrgSpec:='';
  DATA.URL:='';

  //iPrgSpec:=0;
  sPrgGenre := '';
  sPrgType := '';
  sPrgScreen := '';
  sPrgSound := '';



  {--- Program URL ---}
  r1:=StrPosE(sProgram, 'onclick="location=' + '''', 1, False);

  if r1 <> 0 then
    begin
      r2:=StrPosE(sProgram, '''' + '"', r1 , False);

      if r2 <> 0 then
        begin

          DATA.URL := Copy(sProgram, r1 + 1 + 18, r2 - (r1 + 1) - 18);

          DATA.URL := HTMLToText(DATA.URL)

        end;
    end;


  {--- Program Time ---}
  r1:=StrPosE(sProgram, 'class="cas"', 1, False);

  if r1 <> 0 then
  begin
//showmessage(  Copy(sProgram, r1,100) );
    DATA.Time := FoundStr(sProgram,'d">','<',r1);

    DATA.Time := StringReplace(DATA.Time, '.', ':', [rfReplaceAll]);

    if DATA.Time='' then
      DATA.Time := '00:00';
//showmessage(DATA.Time);
    {
      r2:=StrPosE(sProgram, '>', r1 , False);

      if r2 <> 0 then
        begin
          r1:=StrPosE(sProgram, '<', r2 , False);

          if r1 <> 0 then
            begin
              DATA.Time := HTMLToText( Copy(sProgram, r2 + 1, r1 - (r2 + 1)) );
//showmessage(DATA.Time);
              DATA.Time := StringReplace(DATA.Time, '.', ':', [rfReplaceAll]);

              if DATA.Time='' then
                DATA.Time := '00:00';
            end;
        end;  }
  end;


  {--- Program Type ---}
  r1:=0;
NextImage:
  r1:=StrPosE(sProgram, '<img src="', r1 , False);

  if r1 <> 0 then
    begin
      r2:=StrPosE(sProgram, '"', r1 + 10 , False);

      if r2 <> 0 then
        begin
//          DATA.PrgType:=Copy(sProgram, r1 + 10, r2 - (r1 + 1) - 9);
          sImage:=Copy(sProgram, r1 + 10, r2 - (r1 + 1) - 9);

//                   showmessage(simage);
{          AssignFile(F, xConf.TempPath + 'images.txt' );
          Append(F);
          WriteLn(f, sImage );
          CloseFile(F);}

          if StrPosE(sImage,'bmp/typprg',1,false) <> 0 then
          begin
            if StrPosE(sImage,'bmp/typprg/d.gif',1,false) <> 0 then
              sPrgGenre := 'Documentary;'
            else if StrPosE(sImage,'bmp/typprg/f.gif',1,false) <> 0 then
              sPrgGenre := 'Film;'
            else if StrPosE(sImage,'bmp/typprg/l.gif',1,false) <> 0 then
              sPrgGenre := 'Entertainment;'
            else if StrPosE(sImage,'bmp/typprg/m.gif',1,false) <> 0 then
              sPrgGenre := 'Music;'
            else if StrPosE(sImage,'bmp/typprg/o.gif',1,false) <> 0 then
              sPrgGenre := 'Sport;'
            else if StrPosE(sImage,'bmp/typprg/q.gif',1,false) <> 0 then
              sPrgGenre := 'Children;'
            else if StrPosE(sImage,'bmp/typprg/s.gif',1,false) <> 0 then
              sPrgGenre := 'Serial;'
            else if StrPosE(sImage,'bmp/typprg/z.gif',1,false) <> 0 then
              sPrgGenre := 'The News;'
            else
              showmessage('unknown:' + sImage);
          end

        {  if AnsiLowerCase(Copy(sImage,1,4))='bmp/' then
            begin
              if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/d.gif') then
                sPrgGenre := 'Documentary;'  //'1'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/f.gif') then
                sPrgGenre := 'Film;'  //'2'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/l.gif') then
                sPrgGenre := 'Entertainment;'  //'3'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/m.gif') then
                sPrgGenre := 'Music;'  //'4'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/o.gif') then
                sPrgGenre := 'Sport;'  //'5'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/q.gif') then
                sPrgGenre := 'Children;'  //'6'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/s.gif') then
                sPrgGenre := 'Serial;'  //'7'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/typprg/z.gif') then
                sPrgGenre := 'The News;'  //'8'
              else if AnsiUpperCase(sImage)=AnsiUpperCase('bmp/video.gif') then
                //Vyhodnocuje az druhou informaci
              else
                showmessage('unknown:' + sImage);

            end   }
          else if AnsiLowerCase(Copy(sImage,1,22))='http://www.sms.cz/img/' then
            begin
              if AnsiUpperCase(sImage)=AnsiUpperCase('http://www.sms.cz/img/porad_info.gif') then

              else if AnsiUpperCase(sImage)=AnsiUpperCase('http://www.sms.cz/img/porad_fotky.gif') then

              else if AnsiUpperCase(sImage)=AnsiUpperCase('http://www.sms.cz/img/porad_video.gif') then

              else
                showmessage('unknown:' + sImage);

            end
          else
          begin
            if Copy(sImage,1, length('/bannery'))='/bannery' then
              //
            else
              DATA.InfoImage:=sImage;
          end;

(*

http://www.sms.cz/img/porad_video.gif
*)

          Application.ProcessMessages;

          r1 := r2;
          Application.ProcessMessages;
          goto NextImage;

                      {
                      !!! NEFUNGUJE !!!
                      }



{                            if AnsiUpperCase(Copy(sProgramInfoImage,1,4))=AnsiUpperCase('bmp/') then
                              sProgramInfoImage:='';}

{                            if AnsiUpperCase(Copy(sProgramInfoImage,1,9))=AnsiUpperCase('bmp/loga/') then
                              sProgramInfoImage:='';
                            if AnsiUpperCase(Copy(sProgramInfoImage,1,11))=AnsiUpperCase('bmp/typprg/') then
                              sProgramInfoImage:='';    }

        end;
    end;


  {--- Program Name ---}
  r1:=StrPosE(sProgram, 'class="nazev"', 1, False);

  if r1 <> 0 then
    begin
      r2:=StrPosE(sProgram, '>', r1 + 16 , False);

      if r2 <> 0 then
        begin
          r1:=StrPosE(sProgram, '<', r2 , False);

          if r1 <> 0 then
            begin
              DATA.Name := HTMLToText( Copy(sProgram, r2 + 1, r1 - (r2 + 1)) );

              DATA.Name := Trim(DATA.Name);

              if Copy(DATA.Name, length(DATA.Name) - 3, 4) = ' /P/' then   //Premiera
                begin
                  sPrgType := 'Premiere;';
                  DATA.Name := Copy(DATA.Name, 1, length(DATA.Name) - 4);
                end;

              if Copy(DATA.Name, length(DATA.Name) - 3, 4) = ' /R/' then    //Repriza
                begin
                  sPrgType := 'Repeat;';
                  DATA.Name := Copy(DATA.Name, 1, length(DATA.Name) - 4);
                end;

              if Copy(DATA.Name, length(DATA.Name) - 3, 4) = ' /L/' then    //Zive
                begin
                  sPrgType := 'Live;';
                  DATA.Name := Copy(DATA.Name, 1, length(DATA.Name) - 4);
                end;


              if Copy(DATA.Name, length(DATA.Name) - 1, 2) = ' W' then    //W - wide screen
                begin
                  sPrgScreen := 'Wide;';
                  DATA.Name := Copy(DATA.Name, 1, length(DATA.Name) - 2);
                end;


            end;
        end;
    end;


  {--- Program Info ---}
  r1:=StrPosE(sProgram, 'class="info1"', 1, False);

  if r1 <> 0 then
    begin
      r2:=StrPosE(sProgram, '>', r1 , False);

      if r2 <> 0 then
        begin
          r1:=StrPosE(sProgram, '<', r2 , False);

          if r1 <> 0 then
            begin
              DATA.Info := Copy(sProgram, r2 + 1, r1 - (r2 + 1));

              if Copy(DATA.Info,1,1)='(' then
                begin

                  r1:=StrPosE(DATA.Info, ') ', 1, False);
                  if r1 <> 0 then
                    begin
                      DATA.OrigName:=Copy(DATA.Info, 2, r1 - 2);
                      DATA.Info :=Copy(DATA.Info, r1 + 2 );
                    end;

                end;

            end;
        end;
    end;

(*
  {--- Program Info - Image ---}
  r2:=0;
  r1:=StrPosE(sProgram, '<img src="', r2 + 1, False);

  if r1 <> 0 then
    begin
      r2:=StrPosE(sProgram, '"', r1 + 10 , False);

      if r2 <> 0 then
        begin
          DATA.InfoImage:=Copy(sProgram, r1 + 10, r2 - (r1 + 1) - 9);

{          if AnsiUpperCase(Copy(DATA.InfoImage,1,4))=AnsiUpperCase('bmp/') then
            DATA.InfoImage:='';}

{                            if AnsiUpperCase(Copy(sProgramInfoImage,1,9))=AnsiUpperCase('bmp/loga/') then
                              sProgramInfoImage:='';
                            if AnsiUpperCase(Copy(sProgramInfoImage,1,11))=AnsiUpperCase('bmp/typprg/') then
                              sProgramInfoImage:='';    }
        end;
    end;*)

  DATA.Name := HTMLToText( DATA.Name );
  DATA.Info := HTMLToText( DATA.Info );

  if sPrgGenre <> '' then
    DATA.Specifications := DATA.Specifications + '[Genre]="'+sPrgGenre+'";';

  if sPrgType <> '' then
    DATA.Specifications := DATA.Specifications + '[Type]="'+sPrgType+'";';

  if sPrgScreen <> '' then
    DATA.Specifications := DATA.Specifications + '[Screen]="'+sPrgScreen+'";';


//  if iPrgSpec <> 0 then
//    DATA.PrgSpec := IntToStr( iPrgSpec );

end;

(* === Get Program ========================================================== *)
procedure GetProgram(Server: WideString; Station: TStringList; Dates : TStringList; var DATA: TStringList; var Info: TPositionInfo); stdcall;

var HTMLData: TResultData;
    sDate: WideString;
//    F: TextFile;
    s1, s2: Int64;
    p1, p2: Int64;
    r1, r2, r3: Int64;
    hIndex: Integer;
    sStation, sProgram: String;

    sStationName, sStationID, sStationLogo: WideString;

    StationsList : TStringList;

    StationIndex: Integer;
    i, ii: Integer;

    sCheckedDate: WideString;

    DATAProgram: TPrograms;

    slServers: TStringList;

    SetStations: Boolean;




    sPart: WideString;
    prt1, prt2, w1: Int64;
    bWasProgram: Boolean;

    NumSetS: Integer;
    pdw : PDWORD;
    pathsetstat: WideString;


    sStations, sHEXStations: AnsiString;

    URL,Cookie,CookieData : String;

    bReturn : Boolean;

Label NextStationx;


Label NextStation;
Label NextProgram;
Label ProcessProgram;
Label NextItems;
Label StationFound;
Label LoadStation;
Label SetStation_Found;
Label SetStation_End;
Label SetStation_Found2;
Label NoPrg;

Label NextStationItems;
Label NextStationProgram;
Label ProcessStationProgram;
Label NoProg;


Label NextStationItemsTITLE;
Label LoadStationTITLE;
Label NoProgTITLE;


Label NextPart;

Label NextStationA;

Label RetryGetStation;

Label 444;

begin

  DATA := TStringList.Create;
  StationsList := TStringList.Create;

  sDate := Dates.Strings[0];
            {
      for i := 0 to Station.Count - 1 do
        begin
//               showmessage(TSLStations(Station.Objects[i]).StationID+#13+TSLStations(Station.Objects[i]).StationName);
               showmessage(Station.Strings[i]);
        end;

              }


  // SET STATIONS
  sStations := '';
  for i := 0 to Station.Count - 1 do
  begin
    if UpperCase(Copy(Station.Strings[i],Length(Station.Strings[i]) - Length('@365DNI.CZ') + 1,Length('@365DNI.CZ'))) = '@365DNI.CZ'  then
    begin
      if sStations='' then
        sStations := Copy(Station.Strings[i],1, Length(Station.Strings[i]) - Length('@365DNI.CZ') )
      else
        sStations := sStations + ',' + Copy(Station.Strings[i],1, Length(Station.Strings[i]) - Length('@365DNI.CZ') );
    end;
  end;
  sHEXStations := '';
  for i := 1 to Length(sStations) do
  begin
    sHEXStations := sHEXStations + '%'+IntToHex(Ord(sStations[i]),2);
  end;

  URL        := 'http://sms.cz/';
  Cookie     := 'P_cookies_televize_stanice';
  //CookieData := '%C8T1%2C%C8T2%2CNova%2CPrima%2CJim+Jam%2C%D3%E8ko'+'; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  CookieData := sHEXStations + '; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  bReturn := InternetSetCookie(PChar(URL), PChar(Cookie), PChar(CookieData));
  if(not bReturn) then ShowMessage('FALSE SetCookie');

  URL        := 'http://sms.cz/';
  Cookie     := 'P_cookies_siroke_zobrazeni';
  CookieData := 'false'+'; expires = Sat, 01-Jan-'+FormatDateTime('yyyy', Now+365+365)+' 00:00:00 GMT';
  bReturn := InternetSetCookie(PChar(URL), PChar(Cookie), PChar(CookieData));
  if(not bReturn) then ShowMessage('FALSE SetCookie');
  //---


(*
  NumSetS := 0;

 RetryGetStation:           *)

  DATA.Clear;
  StationsList.Clear;

  Info.Info := 'Downloading';

  try
    HTMLData := GetHTML('http://tv.sms.cz/index.php?P_id_kategorie=56456&P_soubor=/televize/index.php?datum=' + sDate + '&casod=-1', '', '', 10000, NO_CACHE, Info);
  except

    DATA.Add('DOWNLOADERROR');
{    hIndex:= DATA.Count - 1;
    DATA.Objects[hIndex] := TSLFoundPlaces.Create;
    TSLFoundPlaces(DATA.Objects[hIndex]).Name       := 'ERROR';
    TSLFoundPlaces(DATA.Objects[hIndex]).ID         := 'ERROR';}

    HTMLData.OK := False;

  end;




  Info.Info := 'Downloaded';

  if HTMLData.OK = True then
    begin
//      showmessage(TVpConf.TempPath + #13+#10+ TVpConf.TempPath + 'html-data.txt');

{
      AssignFile(F, TVpConf.TempPath + 'html-data.txt');
      Rewrite(F);
      writeln(f,HTMLData.parString);
      CloseFile(F);
}
{ ------------------------ kontrola datumu ---------------
      sCheckedDate:='';

      CheckDate(HTMLData.parString, sCheckedDate);

      if sCheckedDate <> sDate then
        begin
          SHOWMESSAGE('PLUGIN INFO: datum nenalezen!' +#13+sDate);
        end;}
      {{ ******************************************************************** }

(*      Info.Info := 'Kontroluje stanice';

      StationsList.Clear;

      s1:=StrPosE(HTMLData.parString, 'class="stanice_nazev"', 1, False);

      {--- Next Station A ---}
     NextStationA:
      sStationID  :='';
      sStationName:='';
      sStationLogo:='';
      if s1<>0 then
        begin
          s2:=StrPosE(HTMLData.parString, 'class="stanice_nazev"', s1 + 1, False);
          if s2<>0 then
            begin
              sStation:=Copy(HTMLData.parString, s1, s2 - s1);

              r1:=StrPosE(sStation, '<', Length('class="stanice_nazev"') + 2, False);
              if r1<>0 then
                begin

                  sStationName := Copy(sStation, Length('class="stanice_nazev"') + 2, r1 - (Length('class="stanice_nazev"') + 2));
                  sStationID   := {ConvFileName(} sStationName {)};
                  sStationLogo := 'unknown';

                  for i := 0 to StationsList.Count - 1 do
                    begin
                      if sStationName = TDLLStations(StationsList.Objects[i]).StationName then
                      begin
                        Application.ProcessMessages;
                        GoTo StationFound;
                      end;
                    end;



                  StationsList.Add('STATION');
                  hIndex:= StationsList.Count - 1;
                  StationsList.Objects[hIndex] := TDLLStations.Create;
                  TDLLStations(StationsList.Objects[hIndex]).StationID:=sStationID;
                  TDLLStations(StationsList.Objects[hIndex]).StationName:=sStationName;
                  TDLLStations(StationsList.Objects[hIndex]).StationLogo:=sStationLogo;

StationFound:
                end;

            end; {s2}

          s1 := s2;

          Application.ProcessMessages;

          GoTo NextStationA;

        end;{s1}



      SetStations:=False;
      for i := 0 to Station.Count - 1 do
        begin
//               showmessage(TSLStations(Station.Objects[i]).StationID);
          for ii := 0 to StationsList.Count - 1 do
            begin

              if TDLLStations(Station.Objects[i]).StationID =
                 {ConvFileName(} TDLLStations(StationsList.Objects[ii]).StationID {)} then
                begin
                  Application.ProcessMessages;
                  GoTo SetStation_Found;
                end;

              Application.ProcessMessages;
            end;


            SetStations:=True;

            Goto SetStation_End;
    SetStation_Found:

            Application.ProcessMessages;

        end;

    SetStation_End:

      if SetStations=True then
        begin

          NumSetS := NumSetS + 1;

          GetStations(Server,slServers);

          for i := 0 to Station.Count - 1 do
            begin
              for ii := 0 to slServers.Count - 1 do
                begin

                  if TDLLStations( Station.Objects[i]).StationID =
                      {ConvFileName(} TDLLStations(slServers.Objects[ii]).StationID {)} then
                    begin

                      TDLLStations(Station.Objects[i]).StationName :=
                      TDLLStations(slServers.Objects[ii]).StationName;
                      Application.ProcessMessages;
                      GoTo SetStation_Found2;
                    end;
                end;
  SetStation_Found2:
              Application.ProcessMessages;
            end;

  Info.Info := 'Setting stations';


          pathsetstat := Set_Stations(Station);
{
          DATA.Add('SETSTATION');
          hIndex:= DATA.Count - 1;
          DATA.Objects[hIndex] := TSLStations.Create;
          TSLStations(DATA.Objects[hIndex]).StationID      := pathsetstat;
          TSLStations(DATA.Objects[hIndex]).StationName    := '';
          TSLStations(DATA.Objects[hIndex]).StationLogo    := '';
  Info.Info := 'Setting stations - exit';      }

          Exit;
          if NumSetS = 3 then
            begin
              ShowMessage('PLUGIN INFO: Stanice nelze nastavit!');
            end
          else
          begin
            Application.ProcessMessages;
            Goto RetryGetStation;
          end;

        end;

{{
                  hIndex:= StationsList.Count - 2;
{                  StationsList.Objects[hIndex] := TSLStations.Create;
                  TSLStations(StationsList.Objects[hIndex]).StationID:=sStationID;}

                  showmessage( TSLStations(StationsList.Objects[hIndex]).StationID  );
}}

*)

  Info.Info := 'Processing program...';

//  RaiseException(155,1,2,pdw);
//RaiseLastWin32Error

      (* ******************************************************************** *)

      StationsList.Clear;

      prt1:=StrPosE(HTMLData.parString, 'style="border-collapse:collapse"', 1, False);

      bWasProgram:=False;

      {--- Next Part ---}
     NextPart:
Info.Info := 'Processing program... Parts';
               bWasProgram := True;
      if prt1<>0 then
        begin
          prt2:=StrPosE(HTMLData.parString, 'style="border-collapse:collapse"', prt1 + 1, False);
          if prt2<>0 then
            begin
              sPart := Copy(HTMLData.parString, prt1, prt2 - prt1);

//              w1:=StrPosE(sPart, 'class="porad"', 1, False);
              w1:=StrPosE(sPart, 'class="pruh_nazev"', 1, False);


              {NADPIS - }
//              if w1 = 0 then
              if w1 <> 0 then
                begin

                  if bWasProgram=True then
                    begin
                      StationsList.Clear;
                      bWasProgram := False;

                      StationIndex:=-1;

{                     showmessage('//');}
                    end;



                  s1:=StrPosE(sPart, 'class="program"', 1, False);
                 NextStationItemsTITLE:
                  if s1<>0 then
                    begin

                      s2:=StrPosE(sPart, 'class="program"', s1 + 1, False);
                      if s2<>0 then
                        begin
                         LoadStationTITLE:

                          sStation:=Copy(sPart, s1, s2 - s1);

                          sStationID  :='';
                          sStationName:='';
                          sStationLogo:='';

                          {--- Station Name ---}
                          r1:=StrPosE(sStation, 'class="stanice_nazev"', 1, False);
                          444:
                          if r1<>0 then
                            begin
                              r2:=StrPosE(sStation, '>', r1, False);
                              if r2<>0 then
                                begin
                                  r3:=StrPosE(sStation, '<', r2, False);
                                  if r3<>0 then
                                    begin
//                                    showmessage( Copy(sStation, r2 + 1) );
                                      sStationName := Copy(sStation, r2 + 1, r3 - (r2 + 1) );
                                      sStationID   := {ConvFileName(} sStationName {)};
                                      if sStationID = '' then
                                      begin
                                        r1 := r1 + 30;
                                        Goto 444;
                                      end;
                                    end;
                                end;
                            end;

                          {--- Station Logo ---}
                          r1:=StrPosE(sStation, '<img src="', 1, False);
                          if r1<>0 then
                            begin
                              r2:=StrPosE(sStation, '"', r1 + 10, False);
                              if r2<>0 then
                                begin
                                  sStationLogo := 'http://tv.sms.cz/kategorie/televize/' + Copy(sStation, r1 + 10, r2 - (r1 + 1) - 9);
                                end;
                            end;
//                                         showmessage(sStationID);

Info.Info := 'Processing program...' + ' Station: ' + sStationID + '; Stations: ' + IntToStr(StationsList.Count);
                          { ADD TO StationsList }
                          StationsList.Add('STATION');
                          hIndex:= StationsList.Count - 1;
                          StationsList.Objects[hIndex] := TDLLStations.Create;
                          TDLLStations(StationsList.Objects[hIndex]).StationID      := sStationID + '@365dni.cz';
                          TDLLStations(StationsList.Objects[hIndex]).StationName    := sStationName;
                          TDLLStations(StationsList.Objects[hIndex]).StationLogo    := sStationLogo;

Info.Info := 'Processing program...' + ' Station: ' + sStationID + '; Stations: ' + IntToStr(StationsList.Count) + ' COMPLETE';

{                        showmessage(sStationID+#13+IntToStr(StationsList.Count));}


                        end{s2}
                      else {else s2}
                        begin
                          If s1 < Length(sPart) Then
                            begin
                              s2 := Length(sPart);
                              Application.ProcessMessages;
                              GoTo LoadStationTITLE;
                            end
                        end;{else s2}

                        s1 := s2;
                        Application.ProcessMessages;
                        GoTo NextStationItemsTITLE;

                    end;{s1}

                end{if nadpis}
              {PORADY}
              else
                begin
                {  showmessage('start');     }

                  if bWasProgram=False then
                    begin
                      bWasProgram:=True;

                      StationIndex:=-1;
                    end;
{                   showmessage('porad');}
                  s1:=StrPosE(sPart, 'class="program"', 1, False);
                 NextStationItems:
                  if s1<>0 then
                    begin

                      s2:=StrPosE(sPart, 'class="program"', s1 + 1, False);
                      if s2<>0 then
                        begin
                         LoadStation:
                          sStation:=Copy(sPart, s1, s2 - s1);

                          StationIndex := StationIndex + 1;
                          if StationIndex > StationsList.Count - 1  then StationIndex:=0;
{try}
                          if StationIndex <= StationsList.Count then
                            begin
Info.Info := 'Processing program...' + ' 2; Station: ' + sStationID + '; Stations: ' + IntToStr(StationsList.Count);
                              DATA.Add('STATION');
                              hIndex:= DATA.Count - 1;
                              DATA.Objects[hIndex] := TDLLStations.Create;
                              TDLLStations(DATA.Objects[hIndex]).StationID   := TDLLStations(StationsList.Objects[StationIndex]).StationID;
                              TDLLStations(DATA.Objects[hIndex]).StationName := TDLLStations(StationsList.Objects[StationIndex]).StationName;
                              TDLLStations(DATA.Objects[hIndex]).StationLogo := TDLLStations(StationsList.Objects[StationIndex]).StationLogo;
Info.Info := 'Processing program...' + ' 2; Station: ' + sStationID + '; Stations: ' + IntToStr(StationsList.Count) + ' COMPLETE';
                            end;
{      except
        Showmessage('nelze vlozit zaloyzk stanice. ' + inttostr(  StationIndex  ) + '/' + INTTOSTR( StationsList.Count ));
      end;}
                          p1:=StrPosE(sStation, 'class="porad"', 1, False);
                          {--- Next Program ---}
                         NextStationProgram:
Info.Info := 'Processing program...' + ' Station: ' + sStationID + '; Program: '+ DATAProgram.Name + '; Programs: ' + IntToStr(DATA.Count) + 'NEXT STATION PROGRAM';
                          if p1<>0 then
                            begin

                              p2:=StrPosE(sStation, 'class="porad"', p1 + 1, False);

                              if p2<>0 then
                                begin
                                 ProcessStationProgram:
                                  sProgram := Copy(sStation, p1, p2 - p1);

                                  Process_Program(sProgram, DATAProgram);

                                  if DATAProgram.Time = '' then
                                    begin
                                      if DATAProgram.Name = '' then
                                        goto NoProg
                                    end;

Info.Info := 'Processing program...' + ' Station: ' + sStationID + '; Program: '+ DATAProgram.Name + '; Programs: ' + IntToStr(DATA.Count);
                                    DATA.Add('PROGRAM');
                                    hIndex:= DATA.Count - 1;
                                    DATA.Objects[hIndex] := TDLLProgramInfo.Create;
                                    TDLLProgramInfo(DATA.Objects[hIndex]).Time      :=Trim(DATAProgram.Time);
                                    TDLLProgramInfo(DATA.Objects[hIndex]).Name      :=Trim(DATAProgram.Name);
                                    TDLLProgramInfo(DATA.Objects[hIndex]).OrigName  :=Trim(DATAProgram.OrigName);
                                    TDLLProgramInfo(DATA.Objects[hIndex]).Info      :=Trim(DATAProgram.Info);
                                    TDLLProgramInfo(DATA.Objects[hIndex]).InfoImage :=Trim(DATAProgram.InfoImage);
                                    TDLLProgramInfo(DATA.Objects[hIndex]).Specifications := DATAProgram.Specifications;
                                    TDLLProgramInfo(DATA.Objects[hIndex]).URL       :=Trim(DATAProgram.URL);
Info.Info := 'Processing program...' + ' Station: ' + sStationID + '; Program: '+ DATAProgram.Name + '; Programs: ' + IntToStr(DATA.Count)+' COMPLETE';
{                                    ShowMessage('ADDED');}

                                   NoProg:

                                    p1 := p2;
                                    Application.ProcessMessages;
                                    GoTo NextStationProgram;

                                end {p2}
                              else {p2}
                                begin

                                  If p1 < Length(sStation) Then
                                    begin
                                      p2 := Length(sStation);
                                      Application.ProcessMessages;
                                     GoTo ProcessStationProgram;
                                   end;

                                end;{else p2}


                            end;{p1}




                        end{s2}
                      else {else s2}
                        begin
                          If s1 < Length(sPart) Then
                            begin
                              s2 := Length(sPart);
                              Application.ProcessMessages;
                              GoTo LoadStation;
                            end
                        end;{else s2}

                        s1 := s2;
                        Application.ProcessMessages;
                        GoTo NextStationItems;

                    end;{s1}
                 { showmessage('End');   }
                end{if porady}


            end;{prt2}


          prt1 := prt2;
          Application.ProcessMessages;
          GoTo NextPart;
          {Posledni polozku style="...." nezpracovava, protoze jsou to pouze konecne obrazky}

        end;{prt1}





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
