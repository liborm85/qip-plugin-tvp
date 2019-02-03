unit uSuperReplace;

interface

uses SysUtils, Classes;

type
  TSuperReplace = class
  public
    Command : WideString;
    Value   : WideString;
  end;

  function SuperReplace(sText: WideString; slData: TStringList): WideString;
  function TagsReplace(sText: WideString): WideString;

implementation

function TagsReplace(sText: WideString): WideString;
begin
  Result := sText;
  Result := StringReplace(Result, '[br]', #13+#10, [rfReplaceAll, rfIgnoreCase]);

end;


function SuperReplace(sText: WideString; slData: TStringList): WideString;
var i: Integer;
begin

  Result := sText;

  Result := StringReplace(Result, '\n', #13+#10, [rfReplaceAll, rfIgnoreCase]);

  i:=0;
  while ( i<= slData.Count - 1 ) do
  begin
    Result := StringReplace(Result, TSuperReplace(slData.Objects[i]).Command, TSuperReplace(slData.Objects[i]).Value, [rfReplaceAll, rfIgnoreCase]);
    Inc(i);
  end;

end;

end.
