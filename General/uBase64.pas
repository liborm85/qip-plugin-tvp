unit uBase64;

interface

type
  CharSet = Set of AnsiChar;

const
  b64_MIMEBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  b64_UUEncode   = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  b64_XXEncode   = '+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';


  function EncodeBase64(const S, Alphabet: AnsiString; const Pad: Boolean; const PadMultiple: Integer; const PadChar: AnsiChar): AnsiString;
  function DecodeBase64(const S, Alphabet: AnsiString; const PadSet: CharSet): AnsiString;

  function MIMEBase64Encode(const S: AnsiString): AnsiString;
  function UUDecode(const S: AnsiString): AnsiString;
  function MIMEBase64Decode(const S: AnsiString): AnsiString;
  function XXDecode(const S: AnsiString): AnsiString;

implementation


function EncodeBase64(const S, Alphabet: AnsiString; const Pad: Boolean; const PadMultiple: Integer; const PadChar: AnsiChar): AnsiString;
var R, C : Byte;
    F, L, M, N, U : Integer;
    P : PAnsiChar;
    T : Boolean;
begin
  Assert(Length(Alphabet) = 64, 'Alphabet must contain 64 characters');
  L := Length(S);
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  M := L mod 3;
  N := (L div 3) * 4 + M;
  if M > 0 then
    Inc(N);
  T := Pad and (PadMultiple > 1);
  if T then
    begin
      U := N mod PadMultiple;
      if U > 0 then
        begin
          U := PadMultiple - U;
          Inc(N, U);
        end;
    end else
    U := 0;
  SetLength(Result, N);
  P := Pointer(Result);
  R := 0;
  For F := 0 to L - 1 do
    begin
      C := Byte(S [F + 1]);
      Case F mod 3 of
        0 : begin
              P^ := Alphabet[C shr 2 + 1];
              Inc(P);
              R := (C and 3) shl 4;
            end;
        1 : begin
              P^ := Alphabet[C shr 4 + R + 1];
              Inc(P);
              R := (C and $0F) shl 2;
            end;
        2 : begin
              P^ := Alphabet[C shr 6 + R + 1];
              Inc(P);
              P^ := Alphabet[C and $3F + 1];
              Inc(P);
            end;
      end;
    end;
  if M > 0 then
    begin
      P^ := Alphabet[R + 1];
      Inc(P);
    end;
  For F := 1 to U do
    begin
      P^ := PadChar;
      Inc(P);
    end;
end;

function DecodeBase64(const S, Alphabet: AnsiString; const PadSet: CharSet): AnsiString;
var F, L, M, P : Integer;
    B, OutPos  : Byte;
    OutB       : Array[1..3] of Byte;
    Lookup     : Array[AnsiChar] of Byte;
    R          : PAnsiChar;
begin
  Assert(Length(Alphabet) = 64, 'Alphabet must contain 64 characters');
  L := Length(S);
  P := 0;
  if PadSet <> [] then
    While (L - P > 0) and (S[L - P] in PadSet) do
      Inc(P);
  M := L - P;
  if M = 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, (M * 3) div 4);
  FillChar(Lookup, Sizeof(Lookup), #0);
  For F := 0 to 63 do
    Lookup[Alphabet[F + 1]] := Byte(F);
  R := Pointer(Result);
  OutPos := 0;
  For F := 1 to L - P do
    begin
      B := Lookup[S[F]];
      Case OutPos of
          0 : OutB[1] := B shl 2;
          1 : begin
                OutB[1] := OutB[1] or (B shr 4);
                R^ := AnsiChar(OutB[1]);
                Inc(R);
                OutB[2] := (B shl 4) and $FF;
              end;
          2 : begin
                OutB[2] := OutB[2] or (B shr 2);
                R^ := AnsiChar(OutB[2]);
                Inc(R);
                OutB[3] := (B shl 6) and $FF;
              end;
          3 : begin
                OutB[3] := OutB[3] or B;
                R^ := AnsiChar(OutB[3]);
                Inc(R);
              end;
        end;
      OutPos := (OutPos + 1) mod 4;
    end;
  if (OutPos > 0) and (P = 0) then // incomplete encoding, add the partial byte if not 0
    if OutB[OutPos] <> 0 then
      Result := Result + AnsiChar(OutB[OutPos]);
end;


function MIMEBase64Encode(const S: AnsiString): AnsiString;
begin
  Result := EncodeBase64(S, b64_MIMEBase64, True, 4, '=');
end;

function UUDecode(const S: AnsiString): AnsiString;
begin
  // Line without size indicator (first byte = length + 32)
  Result := DecodeBase64(S, b64_UUEncode, ['`']);
end;

function MIMEBase64Decode(const S: AnsiString): AnsiString;
begin
  Result := DecodeBase64(S, b64_MIMEBase64, ['=']);
end;

function XXDecode(const S: AnsiString): AnsiString;
begin
  Result := DecodeBase64(S, b64_XXEncode, []);
end;


end.
