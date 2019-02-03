unit TVp_plugin_info;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls;

const
  TVp_SDK_VER_MAJOR = 0;
  TVp_SDK_VER_MINOR = 1;

type

  {Result Data}
  TResultData = record
    OK                : Boolean;
    parString         : String;
  end;


  {Plugin info}
  TTVpPluginInfo = record
    SDKVerMajor       : Word;
    SDKVerMinor       : Word;
    PluginVerMajor    : Word;
    PluginVerMinor    : Word;
    PluginName        : WideString;
    PluginAuthor      : WideString;
    PluginType        : Integer;
  end;

  {Servers}
  TDLLServers = class
  public
    ServerID           : WideString;
    ServerName         : WideString;
    ServerIcon         : TImage;
  end;

  {Stations}
  TDLLStations = class
  public
    StationID           : WideString;
    StationName         : WideString;
    StationLogo         : WideString;
  end;

  {Available Days}
  TDLLAvailableDays = class
  public
    DateID              : WideString;
  end;

  {Program Info}
  TDLLProgramInfo = class
  public
    Time              : WideString; {  format:  hh:mm  }
    Name              : WideString;
    OrigName          : WideString;
    Info              : WideString;
    InfoImage         : WideString;
    Specifications    : WideString;
    (*
      Sound
        Mono
        Stereo
        Duo

      Screen
        Wide

      Subtitle
        Subtitle                      ST
        Finger Spelling               ZJ

      Genre
                                      neznámý/žádný   / none
        Documentary                   Dokument
        Film                          Film
        Entertainment                 Zábava
        Music                         Hudba
        Sport                         Sport
        Children                      Dìtem
        Serial                        Seriál
        The News                      Zprávy

      Type
        Live                          Živì
        Premiere                      Premiéra
        Repeat                        Repríza
    *)

//    PrgType           : WideString;
        {
          0 - neznámý/žádný
          1 - Dokument
          2 - Film
          3 - Zábava
          4 - Hudba
          5 - Sport
          6 - Dìtem
          7 - Seriál
          8 - Zprávy
        }
//    PrgSpec           : WideString;


        {

          M   - 0
          S   - 1
          D   - 2
          ========
          ST  - 10
          ZJ  - 20
          ========
          P   - 100
          R   - 200
          L   - 300
          W   - 1000
          wide
           //       If (i And 4) = 4 Then

        }
//    ShowView          : Int64;
    URL               : WideString;
//    ExtraSpec         : Integer;
        {
          x   - LongInfo
          x   - LongInfoImage
          x   - PreviewVideo
          x   - Fotky
          x   - x
          x   - x
          x   - x
          x   - x
        }
//    LongInfo          : WideString;
//    LongInfoImage     : WideString;
//    PreviewVideo      : Boolean;
  end;

  {Programs}
  type TPrograms = record
    Time              : WideString; {  format:  hh:mm  }
    Name              : WideString;
    OrigName          : WideString;
    Info              : WideString;
    InfoImage         : WideString;
    Specifications    : WideString;
    URL               : WideString;
    ExtraSpec         : Integer;
    ShowView          : Int64;
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

  { Set Conf }
  TSetConf = record
    TempPath          : WideString;
    Proxy_Use         : Boolean;
    Proxy_Host        : WideString;
    Proxy_Port        : Integer;
    Proxy_User        : WideString;
    Proxy_Pass        : WideString;
  end;

var TVpConf: TSetConf;

implementation

end.
