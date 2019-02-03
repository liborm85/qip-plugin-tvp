(*
    Plugin pro TVp
      teleguide.info
*)

library teleguideinfo;

{$R 'resource.res' 'resource.rc'}

uses
  SysUtils,
  Classes,
  TVp_plugin in 'TVp_plugin.pas',
  TVp_plugin_info in '..\..\SDK\TVp_plugin_info.pas',
  Convs in '..\..\General\Convs.pas',
  DownloadFile in '..\..\General\DownloadFile.pas',
  TextSearch in '..\..\General\TextSearch.pas',
  uOptions in '..\..\General\uOptions.pas',
  FileTools in '..\..\FileTools\FileTools.pas',
  ZLibex in '..\..\FileTools\ZLib\ZLibex.pas',
  LibXmlParser in '..\..\XML\LibXmlParser.pas',
  General in 'General.pas',
  XMLProcess in 'XMLProcess.pas';

{$R *.res}

begin
end.
