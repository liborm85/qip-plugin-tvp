{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://www.qip.im             }
{                                     }
{*************************************}

library TVp;

uses
  u_qip_plugin in 'u_qip_plugin.pas',
  u_common in 'QIP Infium SDK\u_common.pas',
  u_lang_ids in 'QIP Infium SDK\u_lang_ids.pas',
  u_plugin_info in 'QIP Infium SDK\u_plugin_info.pas',
  u_plugin_msg in 'QIP Infium SDK\u_plugin_msg.pas',
  fQIPPlugin in 'fQIPPlugin.pas' {frmQIPPlugin},
  About in 'Forms\About.pas' {frmAbout},
  Options in 'Forms\Options.pas' {frmOptions},
  General in 'General.pas',
  DownloadFile in 'General\DownloadFile.pas',
  TextSearch in 'General\TextSearch.pas',
  GradientColor in 'General\GradientColor.pas',
  Convs in 'General\Convs.pas',
  Crypt in 'General\Crypt.pas',
  Hash in 'Updater\Hash.pas',
  KAZip in 'Updater\KAZip.pas',
  MD5 in 'Updater\MD5.pas',
  UpdaterUnit in 'Updater\UpdaterUnit.pas',
  Updater in 'Updater\Updater.pas' {frmUpdater},
  BZIP2 in 'Updater\bzip2\BZIP2.PAS',
  HotKeyManager in 'General\HotKeyManager.pas',
  Drawing in 'General\Drawing.pas',
  uToolTip in 'General\uToolTip.pas',
  uBase64 in 'General\uBase64.pas',
  uURL in 'General\uURL.pas',
  uFileFolder in 'General\uFileFolder.pas',
  uLNG in 'General\uLNG.pas',
  uSuperReplace in 'General\uSuperReplace.pas',
  uImage in 'General\uImage.pas',
  uIcon in 'General\uIcon.pas',
  uComments in 'General\uComments.pas',
  uTime in 'General\uTime.pas',
  uColors in 'General\uColors.pas',
  uLinks in 'General\uLinks.pas',
  uINI in 'General\uINI.pas',
  JVCLVer in 'RichEdit\JVCLVer.pas',
  JvConsts in 'RichEdit\JvConsts.pas',
  JvExControls in 'RichEdit\JvExControls.pas',
  JvExStdCtrls in 'RichEdit\JvExStdCtrls.pas',
  JvFixedEditPopUp in 'RichEdit\JvFixedEditPopUp.pas',
  JvResources in 'RichEdit\JvResources.pas',
  JvRichEdit in 'RichEdit\JvRichEdit.pas',
  JvThemes in 'RichEdit\JvThemes.pas',
  JvTypes in 'RichEdit\JvTypes.pas',
  MSAAIntf in 'Virtual Treeview\MSAAIntf.pas',
  VirtualTrees in 'Virtual Treeview\VirtualTrees.pas',
  VTAccessibility in 'Virtual Treeview\VTAccessibility.pas',
  VTAccessibilityFactory in 'Virtual Treeview\VTAccessibilityFactory.pas',
  VTHeaderPopup in 'Virtual Treeview\VTHeaderPopup.pas',
  PhryGauge in 'Gauge\PhryGauge.pas',
  SQLite3 in 'SQLite\SQLite3.pas',
  SQLiteFuncs in 'SQLite\SQLiteFuncs.pas',
  SQLiteTable3 in 'SQLite\SQLiteTable3.pas',
  SQLLibProcs in 'SQLite\SQLLibProcs.pas',
  LibXmlComps in 'XML\LibXmlComps.pas',
  LibXmlParser in 'XML\LibXmlParser.pas',
  TVpDLL in 'Units\TVpDLL.pas',
  XMLFiles in 'Units\XMLFiles.pas',
  EditItem in 'Forms\EditItem.pas' {frmEditItem},
  Search in 'Forms\Search.pas' {frmSearch},
  Window in 'Forms\Window.pas' {frmWindow},
  TVp_plugin_info in 'SDK\TVp_plugin_info.pas',
  BBCode in 'BBCode\BBCode.pas',
  PlanEdit in 'Forms\PlanEdit.pas' {frmPlanEdit},
  PlanList in 'Forms\PlanList.pas' {frmPlanList},
  uOptions in 'General\uOptions.pas',
  ItemOptions in 'Forms\ItemOptions.pas' {frmItemOptions},
  ProgramInfo in 'Forms\ProgramInfo.pas' {frmProgramInfo},
  CLItems in 'Forms\CLItems.pas' {frmCLItems},
  Colors in 'Forms\Colors.pas' {frmColors},
  RegExpr in 'General\RegExpr.pas';

{***********************************************************}
function CreateInfiumPLUGIN(PluginService: IQIPPluginService): IQIPPlugin; stdcall;
begin
  Result := TQipPlugin.Create(PluginService);
end;

exports
  CreateInfiumPLUGIN name 'CreateInfiumPLUGIN';

end.
