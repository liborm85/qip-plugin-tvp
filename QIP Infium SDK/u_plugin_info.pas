{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://www.qip.im             }
{                                     }
{*************************************}
unit u_plugin_info;

interface

uses Windows, u_plugin_msg, u_common;

const
  QIP_SDK_VER_MAJOR = 1;
  QIP_SDK_VER_MINOR = 6;

type
  {Plugin info}
  TPluginInfo = record
    DllHandle         : DWord;      //dll instance/handle will be updated by QIP after successful loading of plugin library
    DllPath           : PWideChar;  //this should be updated by plugin library after receiving PM_PLUGIN_LOAD_SUCCESS from QIP
    QipSdkVerMajor    : Word;       //major version of sdk for core compatibility check
    QipSdkVerMinor    : Word;       //minor version of sdk for core compatibility check
    PlugVerMajor      : Word;
    PlugVerMinor      : Word;
    PluginName        : PWideChar;
    PluginAuthor      : PWideChar;
    PluginDescription : PWideChar;
    PluginHint        : PWideChar;    
    PluginIcon        : HICON;
  end;
  pPluginInfo = ^TPluginInfo;

  {QIP2Plugin instant message record}
  TQipMsgPlugin = record
    MsgType    : Byte;        //see below, MSG_TYPE_....
    MsgTime    : DWord;       //unix datetime, local time
    ProtoName  : PWideChar;
    SenderAcc  : PWideChar;
    SenderNick : PWideChar;
    RcvrAcc    : PWideChar;
    RcvrNick   : PWideChar;
    MsgText    : PWideChar;
    Blocked    : Boolean;     //received msg blocked by antispam
  end;
  pQipMsgPlugin = ^TQipMsgPlugin;

  {Fading window which popups from tray}
  TFadeWndInfo = record
    FadeType     : Byte;        //0 - message style, 1 - information style, 2 - warning style
    FadeIcon     : HICON;       //icon in the top left corner of the window
    FadeTitle    : WideString;
    FadeText     : WideString;
    TextCentered : Boolean;     //if true then text will be centered inside window
    NoAutoClose  : Boolean;     //if NoAutoClose is True then wnd will be always shown until user close it. Not recommended to set this param to True.
  end;
  pFadeWndInfo = ^TFadeWndInfo;

  {Contact details}
  TContactDetails = record
    AccountName : WideString;
    ContactName : WideString;  //as showing in contact list
    NickName    : WideString;
    FirstName   : WideString;
    LastName    : WideString;
    AccRegDate  : DWord;       //unix datetime, account registration date
    ExtIPs      : WideString;  //ips divided by CRLF
    LastSeen    : DWord;       //unix datetime, last seen online
    Email       : WideString;
    HomeCountry : WideString;
    HomeCity    : WideString;
    HomeState   : WideString;
    HomeZip     : WideString;
    HomePhone   : WideString;
    HomeFax     : WideString;
    HomeCell    : WideString;
    HomeAddress : WideString;
    OrigCountry : WideString;  //Original (motherland)
    OrigCity    : WideString;
    OrigState   : WideString;
    WorkCountry : WideString;
    WorkCity    : WideString;
    WorkState   : WideString;
    WorkZip     : WideString;
    WorkPhone   : WideString;
    WorkFax     : WideString;
    WorkAddress : WideString;
    WorkCompany : WideString;
    WorkDepart  : WideString;
    WorkOccup   : WideString;
    WorkPos     : WideString;
    WorkPage    : WideString;
    PersGender  : WideString;
    PersAge     : WideString;
    PersPage    : WideString;
    PersMarital : WideString;
    BirthDate   : Double;      //TDateTime
    Lang1       : WideString;
    Lang2       : WideString;
    Lang3       : WideString;
    Inter1      : WideString;  //interests
    Inter1Keys  : WideString;
    Inter2      : WideString;
    Inter2Keys  : WideString;
    Inter3      : WideString;
    Inter3Keys  : WideString;
    Inter4      : WideString;
    Inter4Keys  : WideString;
    About       : WideString;
    Note        : WideString;  //user added note for this contact
    Additional  : WideString;
  end;
  pContactDetails = ^TContactDetails;

  {Connection settings}
  TNetParams = record
    ConType     : Byte;       //Connection type, 0=direct, 1=auto, 2=manual
    PrxHost     : WideString;
    PrxPort     : Word;
    PrxUser     : WideString;
    PrxPass     : WideString;
    PrxType     : Byte;       //Proxy type, 0=none, 1=http, 2=https, 3=socks4, 4=socks4a, 5=socks5.
    PrxAuth     : Byte;       //Authentication method, 0=none, 1=socks, 2=basic, 3=ntlm.
    KeepAlive   : Boolean;    //Keep connection alive
  end;
  pNetParams = ^TNetParams;


  {QIP gives to plugin this interface}
  IQIPPluginService = interface
    function  PluginOptions(DllHandle: LongInt): pPluginSpecific; stdcall;
    procedure OnPluginMessage(var PlugMsg: TPluginMessage); stdcall;
  end;
  pIQIPPluginService = ^IQIPPluginService;


  {Plugin gives to QIP this interface}
  IQIPPlugin = interface
    function  GetPluginInfo: pPluginInfo; stdcall;
    procedure OnQipMessage(var PlugMsg: TPluginMessage); stdcall;
  end;
  pIQIPPlugin = ^IQIPPlugin;


  {Internal QIP Plugin item in Plugins List}
  TPluginItem = record
    DllHandle  : LongInt;
    PluginFile : WideString;
    Enabled    : Boolean;
    PluginIntf : IQIPPlugin;
  end;
  pPluginItem = ^TPluginItem;


  {Internal QIP plugin manager, INTF_PLUGINS_MAN}
  IQIPPluginMan = interface
    procedure BroadcastMsgToPlugins(var PlugMsg: TPluginMessage); stdcall;
    procedure SendMsgToPlugin(aDllHandle: DWord; var PlugMsg: TPluginMessage); stdcall;
    function  GetPlugin(aDllHandle: LongInt): pPluginItem; stdcall;
    function  EnumPlugins(var PluginIndex: integer; var Plugin: pPluginItem): Boolean; stdcall;
  end;
  pIQIPPluginMan = ^IQIPPluginMan;


const
  {Messages qip <-> plugin}
  {All messages "plugin -> qip" have to be with actual PluginMsg.DllHandle parameter}
  {=== Plugin main messages =======}
  PM_PLUGIN_LOAD_SUCCESS    =  1; //qip -> plugin
  PM_PLUGIN_RUN             =  2; //qip -> plugin
  PM_PLUGIN_QUIT            =  3; //qip -> plugin
  PM_PLUGIN_ENABLE          =  4; //qip -> plugin
  PM_PLUGIN_DISABLE         =  5; //qip -> plugin
  PM_PLUGIN_OPTIONS         =  6; //qip -> plugin
  {=== Plugin specific messages ===}
  PM_PLUGIN_SPELL_CHECK     =  7; //qip -> plugin, WParam = PWideChar to checking word, LParam = MissSpelledColor (delphi TColor). Return LParam with own color if needed and Result = True if word misspelled.
  PM_PLUGIN_SPELL_POPUP     =  8; //qip -> plugin, WParam = PWideChar to misspelled word, LParam is PPoint where PopupMenu should be popuped (screen coordinates). Return Result = True to ignore qip default menu popup.
  PM_PLUGIN_SPELL_REPLACE   =  9; //plugin -> qip, WParam = PWideChar to right word which will replace old misspelled word. Qip will return Result = True if misspelled word was successfully replaced.
  PM_PLUGIN_XSTATUS_UPD     = 10; //plugin -> qip, WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture will be removed.
  PM_PLUGIN_XSTATUS_GET     = 11; //plugin -> qip, core will return WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture not set by user.
  PM_PLUGIN_XSTATUS_CHANGED = 12; //qip -> plugin, user manually changed custom status picture/text, WParam = custom status picture number (from 0 to 35 or more if new custom status pics added), LParam = PWideChar of Status text (max 20 chars), NParam = PWideChar of status description text (max 512 chars). If WParam = 0 then custom status picture was removed by user.
  PM_PLUGIN_SOUND_GET       = 13; //plugin -> qip, if core returned WParam = True then qip sound enabled else sound disabled.
  PM_PLUGIN_SOUND_SET       = 14; //plugin -> qip, if WParam = True then qip will enable sound else will disable.
  PM_PLUGIN_SOUND_CHANGED   = 15; //qip -> plugin, user manually switched sound On/Off. if WParam = True the sound enabled.
  PM_PLUGIN_MSG_RCVD        = 16; //qip -> plugin, WParam = pQipMsgPlugin. Return result = True to allow core accept this msg else message will be IGNORED, CAREFUL here! If you will add to LParam pointer to own widestring then original msg text will be replaced by yours own text.
  PM_PLUGIN_MSG_SEND        = 17; //qip -> plugin, WParam = pQipMsgPlugin. Return result = True to allow send this msg else user will not be able to send this message, CAREFUL here! If you will add to LParam pointer to own widestring then original msg text will be replaced by yours own text.
  PM_PLUGIN_SPELL_RECHECK   = 18; //plugin -> qip, rechecks spelling for all message editing boxes
  PM_PLUGIN_MSG_RCVD_NEW    = 19; //qip -> plugin, notifier, qip received new message and its still not read by user. WParam = PWideChar to accountname of sender, LParam = PWideChar to nickname of sender. Plugin will receive this message periodically (~400 msec) until user will open msg window and read this msg.
  PM_PLUGIN_MSG_RCVD_READ   = 20; //qip -> plugin, notifier, new received message has been read by user and qip core will stop notifing with PM_PLUGIN_MSG_RCVD_NEW message. WParam = PWideChar to accountname of sender, LParam = PWideChar to nickname of sender. Plugin will receive this message only once after message or event will be read by user.
  PM_PLUGIN_WRONG_SDK_VER   = 21; //qip -> plugin, qip sends this message if plugin sdk version higher than qip's sdk version, after this msg qip will send PM_PLUGIN_QUIT message.
  PM_PLUGIN_CAN_ADD_BTNS    = 22; //qip -> plugin, broadcasted to all plugins, core creates message window and plugin can add buttons to panel below avatars, this message will be sent always on message window creation or tabs changing. WParam is PWideChar of account name of msg tab or wnd, LParam is PWideChar of protocol name of account, NParam is dll handle of protocol(for spec plugin msg sending needs);
  PM_PLUGIN_ADD_BTN         = 23; //plugin -> qip, wParam is pAddBtnInfo, core will return Result = Unique Action ID, which plugin will receive on every click on this btn, if Result will be returned  = 0 then btn was not added;
  PM_PLUGIN_MSG_BTN_CLICK   = 24; //qip -> plugin, occurs when user clicked on msg button below avatar. WParam is Unique Action ID given by core on adding this btn, LParam is PWideChar of account name of msg tab or wnd, NParam is PWideChar of protocol name of account, Result is dll handle of protocol(for spec plugin msg sending needs). Since Sdk 1.6, DllHandle is pBtnClick can be found in u_common.pas;
  PM_PLUGIN_SPEC_SEND       = 25; //plugin -> qip, WParam is protocol dll handle, LParam is PWideChar of receiver account name, NParam is special msg text/data. if Result returned = True then special message was sent else failed to send.
  PM_PLUGIN_SPEC_RCVD       = 26; //qip -> plugin, broadcasted to all plugins, WParam is protocol dll handle, LParam is PWideChar of sender account name, NParam is special msg text/data, Result is protocol name.
  PM_PLUGIN_ANTIBOSS        = 27; //qip -> plugin, user activated/deactivated antiboss, plugin have to hide/show own windows. If WParam is True then hide windows, if WParam is False then show windows.
  PM_PLUGIN_CURRENT_LANG    = 28; //qip -> plugin, means that current language changed. WParam is PWideChar of current language name.
  PM_PLUGIN_GET_LANG_STR    = 29; //plugin -> qip, plugin requesting language string. WParam have to be LI_... in file u_lang_ids. Core will return Result with PWideChar of requested language string.
  PM_PLUGIN_FADE_MSG        = 30; //plugin -> qip, showing fading popup window, WParam is pFadeWndInfo. If core will return Result = False then window was not shown cauz of any reason else Result will be unique id of fade msg.
  PM_PLUGIN_GET_NAMES       = 31; //plugin -> qip, plugin requesting display name and profile name. If core will return Result = True then names added to your message, WParam will be PWideChar od display name, LParam will be PWideChar of profile name.
  PM_PLUGIN_STATUS_GET      = 32; //plugin -> qip, plugin requesting current global status. If core will return Result = True then global status got successfuly and status will be returned in WParam and global privacy status will be returned in LParam. Status codes u can see in this file below, it's QIP_ST_....
  PM_PLUGIN_STATUS_SET      = 33; //plugin -> qip, plugin sets current global status(allowed to change status once in 1 minute). WParam have to be status code QIP_ST_... of new status (excepting QIP_STATUS_CONNECTING), if WParam will be -1 then status will not be changed and LParam have to be Privacy status (if LParam will be -1 then privacy status will not be changed). If core will return Result = True then status changed.
  PM_PLUGIN_STATUS_CHANGED  = 34; //qip -> plugin, global status changed by user or by plugins. WParam is current global status (if WParam = -1 then only privacy status was changed), LParam is current privacy status (if LParam = -1 then only global status was changed).
  PM_PLUGIN_RCVD_IM         = 35; //qip -> plugin, our user successfuly received new instant message. WParam is protocol handle, LParam is account name of sender, NParam is PWideChar of message text, Result is message type MSG_TYPE_... .
  PM_PLUGIN_SEND_IM         = 36; //plugin -> qip, plugin sends instant message to contact which is in contact list on in "not in list" group. WParam have to be protocol handle, LParam is account name of receiver, NParam is PWideChar of message text. If core returned Result = True then instant message send successfuly.
  PM_PLUGIN_CONTACT_STATUS  = 37; //qip -> plugin, core sends to plugin this message every time when contact status updated. WParam is PWideChar of protocol name, LParam is PWideChar of contact account name, NParam is contact status, Result is contact xstatus, DllHandle is protocol handle.
  PM_PLUGIN_DETAILS_GET     = 38; //plugin -> qip, plugin requesting saved LOCAL contact details. WParam have to be protocol handle, LParam have to be PWideChar of contact account name. If core will return Result = True then details found and to NParam added pContactDetails;
  PM_PLUGIN_CHAT_TAB        = 39; //qip -> plugin, occurs when started/closed new chat tab window. WParam is PWideChar of chat name, LParam is PWideChar of own nick. If NParam is True then chat opened else chat was closed, Result is PWideChar of chat tab caption, DllHandle is protocol handle.
  PM_PLUGIN_CHAT_CAN_BTNS   = 40; //qip -> plugin, broadcasted to all plugins, core creates chat tab window and plugin can add buttons to middle panel, this message will be sent always on chat tab window creation. WParam is PWideChar of chat name, LParam is PWideChar of protocol name, NParam is dll handle of protocol, Result is PWideChar of tab caption of chat;
  PM_PLUGIN_CHAT_ADD_BTN    = 41; //plugin -> qip, WParam is pAddBtnInfo, core will return Result = Unique Action ID, which plugin will receive on every click on this btn, if Result will be returned  = 0 then btn was not added;
  PM_PLUGIN_CHAT_BTN_CLICK  = 42; //qip -> plugin, occurs when user clicked on your chat button in middle panel. WParam is Unique Action ID given by core on adding this btn, LParam is PWideChar of chat name, NParam is PWideChar of chat protocol name, Result is dll handle of protocol. Since Sdk 1.6, DllHandle is pBtnClick can be found in u_common.pas;
  PM_PLUGIN_CHAT_MSG_RCVD   = 43; //qip -> plugin, occurs when chat message received (even if own message was sent). WParam is PWideChar of chat name, LParam is chat text type see below, NParam is PWideChar of sender nickname, Result is PWideChar of received message text, DllHandle is protocol handle.
  PM_PLUGIN_CHAT_SENDING    = 44; //qip -> plugin, our user going to send message to chat, occurs before message was sent to protocol. WParam is PWideChar of chat name, LParam is PWideChar of our user nickname, NParam is PWideChar of sending message text, DllHandle is protocol handle. Return Result = True if plugin edited message text and add it to NParam as PWideChar to send plugin edited text.
  PM_PLUGIN_CHAT_MSG_SEND   = 45; //plugin -> qip, plugin sends chat message to chat. WParam have to be PWideChar of chat name, LParam have to be protocol handle, NParam have to be PWideChar of sending message text. If core returned Result = True then plugin chat msg was sent.
  PM_PLUGIN_PLAY_WAV_SND    = 46; //plugin -> qip, plugin can play Wave sounds from plugin. WParam have to be QIP_SND_ID... below. If plugin have own wave files, then WParam have to be 0 and LParam have to be PWideChar of wave sound file path. if NParam will be True, then sound will be played according option "Always play unique sounds", else sound will be played according core sound enabled/disabled setting.
  PM_PLUGIN_SPEC_ADD_CNT    = 48; //plugin -> qip, plugin can add special owner draw contact. Can be sent only after PM_PLUGIN_RUN msg. WParam is contact height in contact list (default is 19, cant be lower than 8 and higher than 100). LParam can be pointer to your any record or object, else have to be 0. Core will return Result = unique dword id of contact.
  PM_PLUGIN_SPEC_DEL_CNT    = 49; //plugin -> qip, plugin can delete own special contact. WParam is unique dword id of contact. If core returned Result = True then contact deleted successfuly.
  PM_PLUGIN_SPEC_REDRAW     = 50; //plugin -> qip, plugin can redraw own special contact when needed. WParam is unique dword id of contact.
  PM_PLUGIN_SPEC_DRAW_CNT   = 51; //qip -> plugin, core drawing contact list, plugin have to draw own contact. WParam is unique contact id, LParam is your plugin data pointer (if added), NParam is Canvas HDC, Result is PRect of drawing rectangle.
  PM_PLUGIN_SPEC_DBL_CLICK  = 52; //qip -> plugin, user double clicked or pressed enter on spec contact. WParam is unique contact id, LParam is your plugin data pointer (if added).
  PM_PLUGIN_SPEC_RIGHT_CLK  = 53; //qip -> plugin, user right clicked on spec contact to see popup menu. WParam is unique contact id, LParam is your plugin data pointer (if added). NParam is PPoint where PopupMenu can be popuped (screen coordinates).
  PM_PLUGIN_FADE_CLICK      = 54; //qip -> plugin, user left clicked on plugin created fade message. WParam is unique fade msg id given in Result of PM_PLUGIN_FADE_MSG.
  PM_PLUGIN_FADE_CLOSE      = 55; //plugin -> qip, plugin can close own fade msg. WParam is unique fade msg id. If Result = True then found and closed, else was already closed or not found.
  PM_PLUGIN_GET_PROFILE_DIR = 56; //plugin -> qip, plugin can get QIP Infium "Profiles" folder to write there any needed files in case if access denied when trying to write into Plugins folder. If Core returns Result = True then it returns WParam = PWideChar of profiles folder path.
  PM_PLUGIN_GET_COLORS_FONT = 57; //plugin -> qip, plugin can get contact list font name and size and qip colors. Core will return WParam = PWideChar of contact list font name, LParam = font size, NParam = pQipColors (pQipColors definition can be found in u_common.pas).
  PM_PLUGIN_HINT_GET_WH     = 58; //qip -> plugin, user moved mouse cursor over spec contact, WParam is unique spec contact id, Result is your plugin data pointer (if added). To show hint window core have to know size of hint window. Plugin should return LParam = Width of hint window and NParam = Height of hint window.
  PM_PLUGIN_HINT_DRAW       = 59; //qip -> plugin, follows after PM_PLUGIN_HINT_GET_WH if mouse cursor still over spec contact. Here hint can be drawn by plugin. WParam is spec contact id, LParam is Canvas HDC, NParam is PRect of drawing rectangle, Result is your plugin data pointer (if added);
  PM_PLUGIN_GET_CONTACT_ST  = 60; //plugin -> qip, plugin can get current contact status. WParam have to be protocol handle, LParam = PWideChar of contact account name. If Core returned Result = False then there is NO such contact in contact list and in "not in list" group. If Core returned Result = True then contact found and status added to NParam.
  PM_PLUGIN_INFIUM_CLOSE    = 61; //plugin -> qip, plugin can close or restart QIP Infium. If Wparam = 0 then infium will be closed, if WParam = 1 then will be restarted. Becareful using this msg, it will destroy everything, including your plugin;
  PM_PLUGIN_GET_NET_SET     = 62; //plugin -> qip, plugin can get network connection parameters. If Core returns Result = True then it added to WParam pointer pNetParams (pNetParams definition can be found in u_plug_info.pas);
  PM_PLUGIN_BROADCAST       = 63; //plugin -> qip -> plugins (excepting plugin-sender and disabled plugins), plugins can exchange any data if needed, WParam, LParam, NParam, Result can be changed by any plugin. Do NOT change Msg and DllHandle values of message on broadcast. Plugin-receiver can stop broadcast by setting Msg value = 0;
  PM_PLUGIN_FIND            = 64; //plugin -> qip, plugin can check if any other plugin exists and enabled/disabled. WParam is plugin name added by its author to find (not case sensetive). Core will return Result = True if plugin with this name loaded/enabled and WParam will be pPluginInfo of requested plugin, LParam will be count of plugins with this name (can be more than 1), if NParam = True then plugin Enabled;
  PM_PLUGIN_MESSAGE         = 65; //plugin -> qip -> plugin. Plugins can exchange any data if needed, WParam is receiver plugin DllHandle found by PM_PLUGIN_FIND. You can add any data to LParam, NParam and Result for receiver plugin;
  PM_PLUGIN_ENUM_PLUGINS    = 66; //plugin -> qip. Plugin can enumerate all plugins (including disabled plugins). PM_PLUGIN_ENUM_INFO will be sent with plugin info(can be more than one message), every message for every plugin;
  PM_PLUGIN_ENUM_INFO       = 67; //qip -> plugin. Enumeration reply. WParam is pPluginInfo of one of the enumerated plugin, if LParam = True then plugin Enabled, if NParam = True then this is the last plugin info and enumeration finished;

  //to be continued ...


  {QIP msg types}
  MSG_TYPE_UNK        = $00; //unknown msg type
  MSG_TYPE_TEXT       = $01;
  MSG_TYPE_CHAT       = $02;
  MSG_TYPE_FILE       = $03;
  MSG_TYPE_URL        = $04;
  MSG_TYPE_AUTH       = $05;
  MSG_TYPE_ADDED      = $06;
  MSG_TYPE_SERVER     = $07;
  MSG_TYPE_WEB        = $08;
  MSG_TYPE_CONTACTS   = $09;
  MSG_TYPE_AUTO       = $0A;
  MSG_TYPE_SERVICE    = $0B;
  MSG_TYPE_EMAIL      = $0C;
  MSG_TYPE_OFFMSG     = $0D;
  MSG_TYPE_AUTHREPLY  = $0E;

  {QIP global statuses for plugins}
  QIP_STATUS_ONLINE 	        = $00;
	QIP_STATUS_INVISIBLE 	      = $01;
	QIP_STATUS_INVISFORALL	    = $02;
  QIP_STATUS_FFC	 	          = $03;
  QIP_STATUS_EVIL	            = $04;
  QIP_STATUS_DEPRES           = $05;
  QIP_STATUS_ATHOME		        = $06;
  QIP_STATUS_ATWORK		        = $07;
  QIP_STATUS_OCCUPIED	        = $08;
	QIP_STATUS_DND		          = $09;
  QIP_STATUS_LUNCH		        = $0A;
  QIP_STATUS_AWAY		          = $0B;
  QIP_STATUS_NA		            = $0C;
  QIP_STATUS_OFFLINE 	        = $0D;
  QIP_STATUS_CONNECTING       = $0E;
  QIP_STATUS_NOTINLIST        = $0F;

  {QIP global privacy status}
  QIP_STATUS_PRIV_VIS4ALL     = $01;
  QIP_STATUS_PRIV_INVIS4ALL   = $02;
  QIP_STATUS_PRIV_VIS4VIS     = $03;
  QIP_STATUS_PRIV_VISNORM     = $04;
  QIP_STATUS_PRIV_VIS4CL      = $05;

  {Chat text types}
  CHAT_TEXT_TOPIC        =  0;
  CHAT_TEXT_OWN_MESSAGE  =  1;
  CHAT_TEXT_MESSAGE      =  2;
  CHAT_TEXT_JOINED       =  3;
  CHAT_TEXT_QUIT         =  4;
  CHAT_TEXT_DISCONNECTED =  5;
  CHAT_TEXT_NOTIFICATION =  6;
  CHAT_TEXT_HIGHLIGHTED  =  7;
  CHAT_TEXT_INFORMATION  =  8;
  CHAT_TEXT_ACTION       =  9;
  CHAT_TEXT_KICKED       = 10;
  CHAT_TEXT_MODE         = 11;

  {QIP SOUND IDs}
  QIP_SND_ID_STARTUP        = 1;
  QIP_SND_ID_INC_MSG        = 2;
  QIP_SND_ID_MSG_SENT       = 3;
  QIP_SND_ID_ONLINE_ALERT   = 4;
  QIP_SND_ID_STATUS_NOTIFY  = 5;
  QIP_SND_ID_TRAY_NOTIFY    = 6;
  QIP_SND_ID_AUTH_REQUEST   = 7;
  QIP_SND_ID_AUTH_DENIED    = 8;
  QIP_SND_ID_AUTH_GRANTED   = 9;
  QIP_SND_ID_ADDED          = 10;
  QIP_SND_ID_INC_FILE       = 11;
  QIP_SND_ID_FT_COMPLETE    = 12;
  QIP_SND_ID_SERVER_MSG     = 13;
  QIP_SND_ID_EMAIL_MSG      = 14;


implementation

end.
