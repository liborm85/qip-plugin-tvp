unit uINI;

interface

uses
  SysUtils, IniFiles;

  procedure INIGetProfileConfig(var INI: TINIFile); Overload;
  procedure INIGetProfileConfig(var sText: WideString); Overload;
  procedure INIGetProfileStatistic(var INI: TINIFile); Overload;
  procedure INIGetProfileStatistic(var sText: WideString); Overload;
  procedure INIGetProfileStations(var sText: WideString);

  procedure INIWriteStringUTF8(var INI: TINIFile; Section: String; Ident: String; Value: WideString);
  function INIReadStringUTF8(var INI: TINIFile; Section: String; Ident: string; Default: WideString) : WideString;

  procedure INIWriteBool(var INI: TINIFile; Section: String; Ident: String; Value: Boolean);
  function INIReadBool(var INI: TINIFile; Section: String; Ident: string; Default: Boolean) : Boolean;

  procedure INIWriteInteger(var INI: TINIFile; Section: String; Ident: String; Value: Integer);
  function INIReadInteger(var INI: TINIFile; Section: String; Ident: string; Default: Integer) : Integer;

  procedure INIDeleteKey(var INI: TINIFile; Section: String; Key: String);

  procedure INIFree(var INI: TINIFile);


implementation

uses General, uFileFolder, Convs, u_qip_plugin;

procedure INIGetProfileConfig(var INI: TINIFile); Overload;
begin
  CreateFileIfNotExists(ProfilePath + 'config.ini');
  INI := TINIFile.Create(ProfilePath + 'config.ini');
end;

procedure INIGetProfileConfig(var sText: WideString); Overload;
begin
  sText := ProfilePath + 'config.ini';
  CreateFileIfNotExists(sText);
end;

procedure INIGetProfileStatistic(var INI: TINIFile); Overload;
begin
  CreateFileIfNotExists(ProfilePath + 'statistic.ini');
  INI := TINIFile.Create(ProfilePath + 'statistic.ini');
end;

procedure INIGetProfileStatistic(var sText: WideString); Overload;
begin
  sText := ProfilePath + 'statistic.ini';
  CreateFileIfNotExists(sText);
end;

procedure INIGetProfileStations(var sText: WideString);
begin
  sText := ProfilePath + 'stations.ftx';
  CreateFileIfNotExists(sText);
end;


procedure INIWriteStringUTF8(var INI: TINIFile; Section: String; Ident: String; Value: WideString);
begin

  Value := StringReplace(Value, #13+#10, '\n', [rfReplaceAll, rfIgnoreCase]);

  INI.WriteString(Section,Ident,WideString2UTF8(Value));

end;

function INIReadStringUTF8(var INI: TINIFile; Section: string; Ident: string; Default: WideString) : WideString;
begin

  Default := StringReplace(Default, #13+#10, '\n', [rfReplaceAll, rfIgnoreCase]);

  Result := UTF82WideString( INI.ReadString(Section, Ident, WideString2UTF8(Default)) );

  Result := StringReplace(Result, '\n', #13+#10, [rfReplaceAll, rfIgnoreCase]);

end;


procedure INIWriteBool(var INI: TINIFile; Section: String; Ident: String; Value: Boolean);
begin

  INI.WriteInteger(Section, Ident, BoolToInt(Value));

end;

function INIReadBool(var INI: TINIFile; Section: string; Ident: string; Default: Boolean) : Boolean;
begin

  Result := IntToBool( INI.ReadInteger(Section, Ident, BoolToInt(Default)) );

end;

procedure INIWriteInteger(var INI: TINIFile; Section: String; Ident: String; Value: Integer);
begin

  INI.WriteInteger(Section, Ident, Value);

end;

function INIReadInteger(var INI: TINIFile; Section: string; Ident: string; Default: Integer) : Integer;
begin

  Result := INI.ReadInteger(Section, Ident, Default);

end;


procedure INIDeleteKey(var INI: TINIFile; Section: String; Key: String);
begin

  INI.DeleteKey(Section, Key);

end;


procedure INIFree(var INI: TINIFile);
begin

  INI.Free;

end;


end.
