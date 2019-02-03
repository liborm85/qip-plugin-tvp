unit Crypt;

interface

uses
  SysUtils;


  function CryptText(sText: WideString): WideString;
  function EncryptText(sText: WideString): WideString;
  
implementation

uses Convs;

const
{C1 y C2 are used for encryption of Master Password string}
{C1 y C2 aon usadas para encriptar la cadena de la clave}
C1 = 52845;
C2 = 11719;

{ Standard Decryption algorithm - Copied from Borland}
function Decrypt(const S: String; Key: Word): String;
var I: byte;
begin
  SetLength(Result,Length(S));
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(S[I]) + Key) * C1 + C2;
  end;
end;

{ Standard Encryption algorithm - Copied from Borland}
function Encrypt(const S: String; Key: Word): String;
var I: byte;
begin
  SetLength(Result,Length(S));
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(Result[I]) + Key) * C1 + C2;
  end;
end;


function HexToInt(HexNum: string): LongInt;
begin
   Result:=StrToInt('$' + HexNum) ;
end;


{ Standard Encryption algorithm - Copied from Borland}
function EncryptHEX(const S: String; Key: Word): String;
var I: byte;
    b: Byte;
begin
  for I := 1 to Length(S) do
  begin
    b := byte(S[I]) xor (Key shr 8);
    Result := Result + IntToHex(b,2);
    Key := (b + Key) * C1 + C2;
  end;

end;

{ Standard Decryption algorithm - Copied from Borland}
function DecryptHEX(const S: String; Key: Word): String;
var I: byte;
    bS: Byte;
begin

//          UTF8ToWideString()
  i:=1;
  while ( i <= Length(S) ) do
  begin
    bS := HexToInt(Copy(S,i,2));

    Result := Result + char(bS xor (Key shr 8));
    Key := (bS + Key) * C1 + C2;
{
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(S[I]) + Key) * C1 + C2;
                           }
    //showmessage(S);
//       showmessage(IntToStr(HexToInt(Copy(sText,i,2))));
    Inc(i);
    Inc(i);
  end;
          {
//  SetLength(Result,Length(S));
  for I := 1 to Length(S) do
  begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(S[I]) + Key) * C1 + C2;
  end;    }
end;

            {
function HexToInt(strHexValue : string) : Integer;
var
 c,l : integer;
begin
  Val(strHexValue, l, c);
  Result := l;
end;
        }

function CryptText(sText: WideString): WideString;
var S : WideString;
begin

  S := sText;

  S := WideString2UTF8(S);
  S := EncryptHEX(S, 1398);

       {

  S2 := '';
  i:=1;
  while ( i<= Length(S) ) do
  begin
    S2 := S2 + IntToHex(Ord(S[i]),2);

    Inc(i);
  end;
       }
  Result := S{2};

//  Result := sText;

end;

function EncryptText(sText: WideString): WideString;
begin

  Result := UTF82WideString(DecryptHEX(sText, 1398));

(*  S := '';
  i:=1;
  while ( i <= Length(sText) ) do
  begin
    S := S + Chr(HexToInt(Copy(sText,i,2)));

    //showmessage(S);
//       showmessage(IntToStr(HexToInt(Copy(sText,i,2))));
    Inc(i);
    Inc(i);
  end;

  Result := UTF82WideString(Decrypt({sText}S, 1398));
//showmessage(Result+#13+S);
//  Result := sText;
                                 *)
end;

end.
