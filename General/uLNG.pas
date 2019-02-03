unit uLNG;

interface

uses SysUtils, IniFiles;

  function LNG(sSection: WideString; sKey: WideString; sDefault: WideString): WideString;

implementation

uses General, Convs, uINI;

{=== LNG ===}
function LNG(sSection: WideString; sKey: WideString; sDefault: WideString): WideString;
var
  INI : TIniFile;
begin
  if Copy(PluginLanguage,1,1)='<' then
    INI := TiniFile.Create(PluginDllPath +
                         'Langs\' + QIPInfiumLanguage + '.lng')
  else
    INI := TiniFile.Create(PluginDllPath +
                         'Langs\' + PluginLanguage + '.lng');

  Result := INIReadStringUTF8(INI, sSection, sKey, sDefault);
//  Result := UTF8ToWideString( INI.ReadString(sSection, sKey, sDefault) );

  INIFree(INI);

end;

end.
