unit DownloadFile;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls,
     WinInet, mshtml, inifiles, ShellApi;

const
  NO_CACHE = INTERNET_FLAG_DONT_CACHE;
  CACHE    = 0;

  type
  {Result Data}
  TResultData = record
    OK                : Boolean;
    parString         : String;
  end;



  { Position Info }
  TPositionInfo = record
    Info              : WideString;
    Int64_1           : Int64;
    Int64_2           : Int64;
    Int64_3           : Int64;
    Int64_4           : Int64;
    Int64_5           : Int64;
  end;

  function GetHTML(const fileURL: String;LoginName: String; LoginPassword: String; const timeout: DWORD; const cache: DWORD; var Info: TPositionInfo): TResultData;

implementation

(* === Download file from internet (HTML) =================================== *)
function GetHTML(const fileURL: String;LoginName: String; LoginPassword: String; const timeout: DWORD; const cache: DWORD; var Info: TPositionInfo): TResultData;
const BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  sAppName: string;
  i: integer;
  sBuffer: AnsiString;
  iDownloaded: integer;
  sFileURL : String;
begin

  sFileURL:= fileURL;

  if (LoginName<>'') or (LoginPassword<>'') then
  begin
    LoginName := StringReplace(LoginName, ':', '%39', [rfReplaceAll]);
    LoginName := StringReplace(LoginName, '@', '%40', [rfReplaceAll]);

    LoginPassword := StringReplace(LoginPassword, ':', '%39', [rfReplaceAll]);
    LoginPassword := StringReplace(LoginPassword, '@', '%40', [rfReplaceAll]);

    if AnsiUpperCase(Copy(sFileURL,1,7))=AnsiUpperCase('http://') then
      sFileURL := Copy(sFileURL,1,7) + LoginName +':'+LoginPassword+'@' + Copy(sFileURL,8)
    else if AnsiUpperCase(Copy(sFileURL,1,8))=AnsiUpperCase('https://') then
      sFileURL := Copy(sFileURL,1,8) + LoginName +':'+LoginPassword+'@' + Copy(sFileURL,9)
    else if AnsiUpperCase(Copy(sFileURL,1,6))=AnsiUpperCase('ftp://') then
      sFileURL := Copy(sFileURL,1,6) + LoginName +':'+LoginPassword+'@' + Copy(sFileURL,7);

  end;

  Info.Info := 'DOWNLOADING';

  Result.parString := '';

  iDownloaded:=0;

  if InternetGetConnectedState(nil, 0) then
  begin
    sAppName := ExtractFileName('');
    //sAppName := ExtractFileName('explorer.exe');
    //sAppName := ExtractFileName(Application.ExeName);
    hSession := InternetOpenW(PChar(sAppName),
                  INTERNET_OPEN_TYPE_PRECONFIG,
                  nil, nil, 0);



    InternetSetOptionW ( hSession, INTERNET_OPTION_CONNECT_TIMEOUT, @timeout, sizeof(timeout) );


    try
      hURL := InternetOpenUrlW(hSession,
                PChar(sFileURL),
                nil,0,cache,0);

      try

        repeat
          InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);

          sBuffer :='';
          for i := 1 to BufferLen do
          begin
            sBuffer  := sBuffer + Ansichar(Buffer[i]);
            Application.ProcessMessages;
          end;

          Result.parString := Result.parString +  sBuffer;

          iDownloaded := iDownloaded + SizeOf(Buffer);
          Info.Int64_1 := iDownloaded;

           Application.ProcessMessages;

        until BufferLen = 0;

        Result.OK := True;
      finally
        InternetCloseHandle(hURL)
      end
    finally
      InternetCloseHandle(hSession)
    end;

  end;

  Info.Info    := 'DOWNLOADED';
  Info.Int64_1 := 0;

end;

{
  InternetConnect(
    hSession,
    '',
    INTERNET_DEFAULT_HTTPS_PORT,
    PChar('lms.cze7@gmail.com'),
    PChar(''),
    INTERNET_SERVICE_HTTP,
    0,
    0);  }

(*  PROXY:

   http://www.cryer.co.uk/brian/delphi/wininet.htm#InternetConnect


InternetConnect(hSession, 'servername',serverport,'username','pass',?dwService ,?dwFlags);
{server port:
INTERNET_DEFAULT_FTP_PORT
Use the default port for FTP servers (port 21).
INTERNET_DEFAULT_GOPHER_PORT
Use the default port for Gopher servers (port 70).
INTERNET_DEFAULT_HTTP_PORT
Use the default port for HTTP servers (port 80).
INTERNET_DEFAULT_HTTPS_PORT
Use the default port for HTTPS servers (port 443).
INTERNET_DEFAULT_SOCKS_PORT
Use the default port for SOCKS firewall servers (port 1080).
INTERNET_INVALID_PORT_NUMBER
}



//  InternetSetOption ( hSession, INTERNET_OPTION_CONNECT_TIMEOUT, &timeout, sizeof(timeout) );


// InternetSetOption() INTERNET_OPTION_CONNECT_TIMEOUT
{
bool ret = InternetSetOption ( m_InternetConnect, INTERNET_OPTION_CONNECT_TIMEOUT, &timeout, sizeof(timeout) );
	assert ( ret );
  }
*)

end.
