{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://www.qip.im             }
{                                     }
{*************************************}

unit u_qip_plugin;

interface

uses Windows, SysUtils, u_plugin_info, u_plugin_msg, u_common;

const
  PLUGIN_VER_MAJOR    = 0;
  PLUGIN_VER_MINOR    = 5;
  PLUGIN_VER_RELEASE  = 0;
  PLUGIN_VER_BUILD    = 7;
  PLUGIN_VER_BETA     : WideString = ''; // defaultnì ''; jsem se píše Alfa, Beta, apod.
  PLUGIN_NAME         : WideString = 'TVp';
  PLUGIN_AUTHOR       : WideString = 'Lms, panther7';
  PLUGIN_AUTHOR_EMAIL : WideString = 'lms.cze7@gmail.com';
  PLUGIN_WEB          : WideString = 'http://qipim.cz/viewtopic.php?t=1830';
  PLUGIN_DESC         : WideString = 'Television programme';
  PLUGIN_HINT         : WideString = '-';

type
  TQipPlugin = class(TInterfacedObject, IQIPPlugin)
  private
    FPluginSvc      : IQIPPluginService;
    FPluginInfo     : TPluginInfo;
    FDllPath        : WideString;
    procedure LoadSuccess(PlugMsg: TPluginMessage);
    procedure CreateQIPPlugin;
    procedure FreeQIPPlugin;

  public
    {+++ create/destroy +++++++++++++++++++++++}
    constructor Create(const PluginService: IQIPPluginService);
    destructor  Destroy; override;
    {+++ IQIPPlugin interface funcs. Qip Core will use it to get info and send messages +++}
    function  GetPluginInfo: pPluginInfo; stdcall;
    procedure OnQipMessage(var PlugMsg: TPluginMessage); stdcall;
  end;

implementation

uses Dialogs, General, fQIPPlugin, uImage, uLNG, Convs, IniFiles, uINI;


{ TQipPlugin }
{***********************************************************}
constructor TQipPlugin.Create(const PluginService: IQIPPluginService);
begin
  FPluginSvc := PluginService;
end;

{***********************************************************}
destructor TQipPlugin.Destroy;
begin
  inherited;
end;

{***********************************************************}
function TQipPlugin.GetPluginInfo: pPluginInfo;
begin
  Result := @FPluginInfo;
end;

{***********************************************************}
procedure TQipPlugin.OnQipMessage(var PlugMsg: TPluginMessage);
begin

  case PlugMsg.Msg of
    PM_PLUGIN_LOAD_SUCCESS    : LoadSuccess(PlugMsg); {updating FPluginInfo, ONLY!!!}
    PM_PLUGIN_RUN             : begin
                                  CreateQIPPlugin;

                                  QIPPlugin.CreateControls;
                                  QIPPlugin.LoadPluginOptions;
                                end;
    PM_PLUGIN_QUIT            : begin
                                  QIPPlugin.SavePluginOptions;
                                  QIPPlugin.FreeControls;

                                  FreeQIPPlugin;
                                end;
    PM_PLUGIN_DISABLE         : begin
                                  QIPPlugin.FreeControls;

                                  FreeQIPPlugin;
                                end;
    PM_PLUGIN_ENABLE          : begin
                                  CreateQIPPlugin;

                                  QIPPlugin.CreateControls;
                                  QIPPlugin.LoadPluginOptions;
                                end;
    PM_PLUGIN_OPTIONS         : QIPPlugin.ShowPluginOptions;
    PM_PLUGIN_WRONG_SDK_VER   : ShowMessage('Wrong SDK version. Core SDK ver. ' + IntToStr(PlugMsg.WParam) + '.' + IntToStr(PlugMsg.LParam)+#13+'Please update QIP Infium.');
//    PM_PLUGIN_SPELL_CHECK     : QIPPlugin.SpellCheck(PlugMsg);
//    PM_PLUGIN_SPELL_POPUP     : QIPPlugin.SpellPopup(PlugMsg);
    PM_PLUGIN_XSTATUS_CHANGED : QIPPlugin.XstatusChangedByUser(PlugMsg);
    PM_PLUGIN_SOUND_CHANGED   : QIPPlugin.QipSoundChanged(PlugMsg);
    PM_PLUGIN_MSG_RCVD        : QIPPlugin.InstantMsgRcvd(PlugMsg);
    PM_PLUGIN_MSG_SEND        : QIPPlugin.InstantMsgSend(PlugMsg);
    PM_PLUGIN_MSG_RCVD_NEW    : QIPPlugin.NewMessageFlashing(PlugMsg);
    PM_PLUGIN_MSG_RCVD_READ   : QIPPlugin.NewMessageStopFlashing(PlugMsg);
    PM_PLUGIN_CAN_ADD_BTNS    : QIPPlugin.AddNeededBtns(PlugMsg);
    PM_PLUGIN_MSG_BTN_CLICK   : QIPPlugin.MsgBtnClicked(PlugMsg);
    PM_PLUGIN_SPEC_RCVD       : QIPPlugin.SpecMsgRcvd(PlugMsg);
    PM_PLUGIN_ANTIBOSS        : QIPPlugin.AntiBoss(Boolean(PlugMsg.WParam));
    PM_PLUGIN_CURRENT_LANG    : QIPPlugin.CurrentLanguage(PWideChar(PlugMsg.WParam));
    PM_PLUGIN_STATUS_CHANGED  : QIPPlugin.StatusChanged(PlugMsg);
    PM_PLUGIN_RCVD_IM         : QIPPlugin.ImRcvdSuccess(PlugMsg);
    PM_PLUGIN_CONTACT_STATUS  : QIPPlugin.ContactStatusRcvd(PlugMsg);
    PM_PLUGIN_CHAT_TAB        : QIPPlugin.ChatTabAction(PlugMsg);
    PM_PLUGIN_CHAT_CAN_BTNS   : QIPPlugin.AddNeededChatBtns(PlugMsg);
    PM_PLUGIN_CHAT_BTN_CLICK  : QIPPlugin.ChatBtnClicked(PlugMsg);
    PM_PLUGIN_CHAT_MSG_RCVD   : QIPPlugin.ChatMsgRcvd(PlugMsg);
    PM_PLUGIN_CHAT_SENDING    : QIPPlugin.ChatMsgSending(PlugMsg);
    PM_PLUGIN_SPEC_DRAW_CNT   : QIPPlugin.DrawSpecContact(PlugMsg);
    PM_PLUGIN_SPEC_DBL_CLICK  : QIPPlugin.SpecContactDblClick(PlugMsg);
    PM_PLUGIN_SPEC_RIGHT_CLK  : QIPPlugin.SpecContactRightClick(PlugMsg);
    PM_PLUGIN_FADE_CLICK      : QIPPlugin.LeftClickOnFadeMsg(PlugMsg);
    PM_PLUGIN_HINT_GET_WH     : QIPPlugin.GetSpecContactHintSize(PlugMsg);
    PM_PLUGIN_HINT_DRAW       : QIPPlugin.DrawSpecContactHint(PlugMsg);
    //One of another plugin broadcasted some message to all plugins
//    PM_PLUGIN_BROADCAST       :{do anything};
    //One of another or this(for test?) plugin sent message
//    PM_PLUGIN_MESSAGE         :{do anything};
    //Your plugin requested enumeration of all plugins
//    PM_PLUGIN_ENUM_INFO       : EnumInfo(PlugMsg);
  end;//case

end;

{***********************************************************}
procedure TQipPlugin.LoadSuccess(PlugMsg: TPluginMessage);
var buf      : array[0..MAX_PATH] of WideChar;
    sFile, sLng    : WideString;
    hLibraryPics    : THandle;
    INI : TIniFile;
begin
  {Getting and updating Plugin dll path and filling FProtoInfo record}
  GetModuleFileNameW(FPluginInfo.DllHandle, buf, SizeOf(buf));
  FDllPath := buf;
  FPluginInfo.DllPath          := PWideChar(FDllPath);

  PluginDllPath                := ExtractFilePath(FDllPath);
  QIPInfiumPath                := ExtractFilePath(FDllPath)+'..\..\';

  //commneted strings below can be helpful
  ///Core_SDK_VER_MAJOR := PlugMsg.WParam;
  ///Core_SDK_VER_MINOR := PlugMsg.LParam;

  FPluginInfo.QipSdkVerMajor    := QIP_SDK_VER_MAJOR;
  FPluginInfo.QipSdkVerMinor    := QIP_SDK_VER_MINOR;
  FPluginInfo.PlugVerMajor      := PLUGIN_VER_MAJOR;
  FPluginInfo.PlugVerMinor      := PLUGIN_VER_MINOR;
  FPluginInfo.PluginName        := PWideChar(PLUGIN_NAME);
  FPluginInfo.PluginAuthor      := PWideChar(PLUGIN_AUTHOR);
//  FPluginInfo.PluginHint        := PWideChar(PLUGIN_HINT);
//  FPluginInfo.PluginDescription := PWideChar(PLUGIN_DESC);

  INI := TiniFile.Create(PluginDllPath + PLUGIN_NAME + '.ini');
  sLng := INIReadStringUTF8(INI, 'Language', 'QIP', 'English' );
  INIFree(INI);

  INI := TiniFile.Create(PluginDllPath + 'Langs\' + sLng + '.lng');
  INT_PLUGIN_DESC := INIReadStringUTF8(INI, 'Info', 'Description', PLUGIN_DESC );
  INT_PLUGIN_HINT := INIReadStringUTF8(INI, 'Info', 'Hint', PLUGIN_HINT );
  INIFree(INI);

  FPluginInfo.PluginHint := PWideChar( INT_PLUGIN_HINT );
  FPluginInfo.PluginDescription := PWideChar( INT_PLUGIN_DESC );

  hLibraryPics := LoadLibrary(PChar(PluginDllPath + 'pics.dll'));

  if hLibraryPics<>0 then
  begin
    PluginSkin.PluginIcon.Image := LoadImageFromResource(11, hLibraryPics);
    PluginSkin.PluginIcon.Icon  := LoadImageAsIconFromResource(11, hLibraryPics);

    FPluginInfo.PluginIcon := PluginSkin.PluginIcon.Icon.Handle;
  end;

  FreeLibrary(hLibraryPics);

{  sFile := PluginDllPath + 'icon.ico';
  FPluginInfo.PluginIcon := LoadImage(0, PChar(sFile), IMAGE_ICON, 16, 16, LR_LOADFROMFILE or LR_DEFAULTCOLOR or LR_SHARED or LR_LOADTRANSPARENT );}

  PluginVersion := IntToStr( PLUGIN_VER_MAJOR ) +  '.' + IntToStr( PLUGIN_VER_MINOR ) + '.' + IntToStr( PLUGIN_VER_RELEASE );
  PluginVersionWithoutBuild := PluginVersion;
  if PLUGIN_VER_BUILD<>0 then PluginVersion := PluginVersion + '.' + IntToStr( PLUGIN_VER_BUILD );
  if not (PLUGIN_VER_BETA='') then PluginVersion := PluginVersion + PLUGIN_VER_BETA;

end;

{***********************************************************}
procedure TQipPlugin.CreateQIPPlugin;
begin
  QIPPlugin := TfrmQIPPlugin.Create(nil);
  QIPPlugin.Height := 0;
  QIPPlugin.Width := 0;
  QIPPlugin.PluginSvc  := @FPluginSvc;
  QIPPlugin.DllHandle  := FPluginInfo.DllHandle;
  QIPPlugin.DllPath    := FDllPath;
  SetWindowPos(QIPPlugin.Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

{***********************************************************}
procedure TQipPlugin.FreeQIPPlugin;
begin
  if Assigned(QIPPlugin) then FreeAndNil(QIPPlugin);
end;


end.


