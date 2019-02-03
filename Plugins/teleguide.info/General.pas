unit General;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, TVp_plugin_info,
     WinInet, DateUtils,

Controls,Contnrs, IdGlobal{, IdHTTP,
   IBDatabase, IBScript,  IBCustomDataSet, IBTable, IBQuery,
 DB, IBIntf, SyncObjs};

type
  TGMTDateTime = record
   DateTime: TDateTime;
   GMT: Integer;
  end;

  procedure GetXMLFile(sURL : String; sFileName: WideString);
  function UTCtoDT(sUTC : String) : TDateTime;

  function GetFileDateTime(FileName: WideString): TDateTime;

implementation

uses Convs, DownloadFile, TextSearch,
     FileTools;

const
  BufSize = 1024*1024;

var
//    IniName     : string;
    CopyThread  : TCopyThread;
//    Zip         : TZip;
    nr,na       : int64;


function ReadNxtStr (var s   : String;
                     Del     : char) : string;
var
  i : integer;
begin

  if length(s)>0 then
  begin
    i:=pos (Del,s);
    if i=0 then i:=succ(length(s));
    Result:=copy(s,1,pred(i));
    delete(s,1,i);
    end
  else
    Result:='';

end;

procedure ShowStatus (Start : boolean);
begin
  if Start then
  begin
    //ProgressBar.Position:=0;
    //btnPause.Show;
    //Screen.Cursor:=crHourglass;
    //Application.ProcessMessages;
  end
  else
  begin
    //btnPause.Hide;
    //Screen.Cursor:=crDefault;
    CopyThread:=nil;
  end;
end;

procedure GZUnpack(sGZ: WideString; sExtractPath: WideString);
var
  s        : string;
  FileInfo : TGzFileInfo;
begin
  s:=sGZ;

  na:=0; nr:=0;
  repeat
    if GzFileInfo(ReadNxtStr(s,','),FileInfo) then na:=na+FileInfo.USize;
    until length(s)=0;
  ShowStatus(true);

  s:=sGZ;
  repeat
    CopyThread:=TGUnZipThread.Create(ReadNxtStr(s,','),sExtractPath,
       false,BufSize,TThreadPriority({trbPrior.Position}3));
    with CopyThread do begin
      //OnProgress:=ShowProgress;
      repeat Application.ProcessMessages until Done;
      Free;
      end;
    until length(s)=0;
  ShowStatus(false);
end;

procedure GetXMLFile(sURL : String; sFileName: WideString);
var
  HTMLData: TResultData;
  Info: TPositionInfo;
  F : TextFile;
  NewFile :Boolean;
begin

  NewFile := False;
  if FileExists(TVpConf.TempPath +sFileName)=True then
  begin
    if GetFileDateTime(TVpConf.TempPath + sFileName) + (1 * (1/(24*60) )) < Now then
    begin
      NewFile := True;
    end;
  end
  else
  begin
    NewFile := True;
  end;

  if NewFile = True then
  begin
    HTMLData := GetHTML(sURL, '', '', 10000, NO_CACHE, Info);
    if HTMLData.OK = True then
    begin
      if Copy(HTMLData.parString,1,3) = '﻿' then
        HTMLData.parString := Copy(HTMLData.parString,4);

      if Copy(HTMLData.parString,1,5) = '<?xml' then
      begin
        AssignFile(F, TVpConf.TempPath + sFileName );
        Rewrite(F);
        write(F, HTMLData.parString );
        CloseFile(F);
      end
      else
      begin
        AssignFile(F, TVpConf.TempPath + sFileName + '.gz' );
        Rewrite(F);
        write(F, HTMLData.parString );
        CloseFile(F);

        GZUnpack(TVpConf.TempPath + sFileName + '.gz', TVpConf.TempPath);
      end;
    end;
  end;


end;


function UTCtoGMTDateTime(UTC: string): TGMTDateTime;
Var S: string;
    Y, M, D, HH, MM, SS, GMTH, GMTM: Integer;
begin
 S := Fetch(UTC, ' ');
 Y := StrToInt(Copy(S, 1, 4));
 M := StrToInt(Copy(S, 5, 2));
 D := StrToInt(Copy(S, 7, 2));
 GMTH := StrToInt(Copy(UTC, 1, 3));
 GMTM := StrToInt(Copy(UTC, 4, 2));
 HH := StrToInt(Copy(S, 9, 2));
 MM := StrToInt(Copy(S, 11, 2));
 SS := StrToInt(Copy(S, 13, 2));
 Result.DateTime := EncodeDateTime(Y, M, D, HH, MM, SS, 0);
 Result.GMT := GMTH*60+GMTM;
end;

function GMTDateTimeToDateTime(ADateTime: TGMTDateTime): TDateTime;
begin
   ADateTime.GMT := -ADateTime.GMT;
   Result := IncMinute(ADateTime.DateTime, ADateTime.GMT);
end;


function UTCtoDT(sUTC : String) : TDateTime;
var
    TimeZone: TTimeZoneInformation;
    TimeZoneCorrection: Integer;
    StartDT, StopDT: TDateTime;
begin
  GetTimeZoneInformation(TimeZone);
  TimeZoneCorrection := -(TimeZone.Bias + TimeZone.DaylightBias);


  Result := IncMinute(GMTDateTimeToDateTime(UTCtoGMTDateTime(sUTC)), TimeZoneCorrection);

end;



function GetFileDateTime(FileName: WideString): TDateTime;
var intFileAge: LongInt;
begin
  intFileAge := FileAge(FileName);
  if intFileAge = -1 then
    Result := 0
  else
    Result := FileDateToDateTime(intFileAge)
end;



end.
