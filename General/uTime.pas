unit uTime;

interface

uses
  SysUtils;

  function IntToTimeStr(I: Integer; Format: String): String;


implementation

function IntToTimeStr(I: Integer; Format: String): String;
var
  MyTime: TDateTime;
  H, M, S: Integer;
begin
  H := I div 3600;
  M := I div 60 - H;
  S := I - (H * 3600 + M * 60);
  MyTime := EncodeTime(H, M, S, 0);
  DateTimeToString(Result, Format, MyTime);
end;

end.
