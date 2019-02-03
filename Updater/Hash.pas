unit Hash;

interface

uses Windows,SysUtils,Classes, {ComUtil,TextUtil,ConStream,    }
     MD5{, Crc32, TigerHash, SHA};

  procedure Md5HashProc(Stream: TStream; var StrHash: AnsiString);
  procedure MD5Hash(sText: AnsiString; var StrHash: AnsiString);
  procedure MD5HashFile(sFileName: WideString; var StrHash: AnsiString);

implementation

function LoCase(C: AnsiChar): AnsiChar;
begin
  if (C<='Z')
  and (C>='A')
  then
    C:=AnsiChar(ord(C) or $20);
  Result:=C;
end;

function StrEFmtLocase(Buf,Fmt: PAnsiChar; const Args: array of const): PAnsiChar;
begin
  Buf^:=#0;
  StrLFmt(Buf,$100,Fmt,Args);
  while (Buf^<>#0) do begin
    Buf^:=LoCase(Buf^);
    inc(Buf);
  end;
  Result:=Buf;
end;

procedure Md5HashProc(Stream: TStream; var StrHash: AnsiString);
var Ctx: TMd5Context;
    Digest: TMd5Digest;
    Buffer: array[0..4095] of AnsiChar;
    pc: PAnsiChar;
    i,Size: Longint;
begin
  Md5Init(Ctx);
  //
  while True do begin
    Size:=Stream.Read(Buffer,SizeOf(Buffer));
    if (Size<=0) then
      break;
    Md5Update(Ctx,Buffer[0],Size);
  end;
  //
  Md5Final(Digest,Ctx);
  //
  pc:=Buffer;
  for i:=0 to 15 do begin
    pc:=StrEFmtLocase(pc,'%.2x',[Byte(Digest[i])]);
  end;
  pc:=Buffer;
  StrHash:=pc;
end;

procedure MD5Hash(sText: AnsiString; var StrHash: AnsiString);
var Ctx: TMd5Context;
    Digest: TMd5Digest;
    Buffer: array[0..4095] of AnsiChar;
    pc: PAnsiChar;
    i,Size: Longint;
begin
  Md5Init(Ctx);

  i:=1;
  while ( i<= Length(sText) ) do
  begin
    Buffer[0] := sText[i];// PAnsiChar(Copy(sText,i,1));
    Size := 1;
    Md5Update(Ctx,Buffer[0],Size);
    Inc(i);
  end;
  //
  Md5Final(Digest,Ctx);
  //
  pc:=Buffer;
  for i:=0 to 15 do begin
    pc:=StrEFmtLocase(pc,'%.2x',[Byte(Digest[i])]);
  end;
  pc:=Buffer;
  StrHash:=pc;
end;


procedure MD5HashFile(sFileName: WideString; var StrHash: AnsiString);
var Ctx: TMd5Context;
    Digest: TMd5Digest;
    Buffer2: array[0..4095] of AnsiChar;
    Buffer: PAnsiChar;
    pc: PAnsiChar;
    i,Size: Longint;
    f: File of Byte;
    b: array[0..255] of Byte;
    e: Integer;
begin
  Md5Init(Ctx);

  AssignFile(F, sFileName);
  FileMode := 0;
  Reset(F);
  GetMem(Buffer, SizeOf(B));
  repeat
    FillChar(b, SizeOf(b), 0);
    BlockRead(F, b, SizeOf(b), e);

    Md5Update(Ctx,b,e);

  until (e < 255) or (IOresult <> 0);
  FreeMem(Buffer, SizeOf(B));
  CloseFile(F);

  //
  Md5Final(Digest,Ctx);
  //
  pc:=Buffer2;
  for i:=0 to 15 do begin
    pc:=StrEFmtLocase(pc,'%.2x',[Byte(Digest[i])]);
  end;
  pc:=Buffer2;
  StrHash:=pc;

end; 

end.
