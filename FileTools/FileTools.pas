(* Copy, pack and unpack files, create zip archives

   © J. Rathlev, IEAP, Uni-Kiel, (rathlev(a)physik.uni-kiel.de)

   Acknowledgements:
     ZLibEx (Vers. 1.2.3) and ZLib routines from http://www.base2ti.com

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Sept. 2005
   Vers. 2 - Okt. 2005   : Zip64 extensions
   Vers. 2.1 - May 2006  : UserBreak and Progress function added
   Vers. 2.2 - May 2006  : functions for file time conversions added
   Vers. 3.3 - Jul 2006  : function ExistingFile added
   *)

unit FileTools;

interface

uses
  Windows, Classes, SysUtils, ZLibex;

const
  GzExt = '.gz';

  // ZLib parameters
  defWindowBits = -15;  // for GZip format
  defMemLevel = 8;

  // gz signature
  GzSignatur = $8b1f;

  // gzip flag byte
  gfASCII      = $01; { bit 0 set: file probably ascii text }
  gfHeaderCrc  = $02; { bit 1 set: header CRC present }
  gfExtraField = $04; { bit 2 set: extra field present }
  gfFileName   = $08; { bit 3 set: original file name present }
  gfComment    = $10; { bit 4 set: file comment present }
  gfReserved   = $E0; { bits 5..7: reserved }

  // PkZip signatures
  PkLocalSignatur = $04034b50;
  PkDirSignatur = $02014b50;
  PkEndSignatur = $06054b50;
  Pk64RecSignatur = $06064b50;
  Pk64LocSignatur = $07064b50;

  // PkZip Constants
  VersDef = $14;
  VersZip64 = $2D;
  VersDos = 0;
  zipEncryptFlag = 1;     // File is encrypted
  zipMaxDeflFlag = 2;     // Deflating - Maximum (-exx/-ex) compression option was used.
  zipCompMethode = 8;     // The file is dflated
  ExtraZip64 = 1;         // Extra field tag for Zip64

  // error codes
  errOK         = 0;
  errFileCreate = 1;
  errFileOpen   = 2;
  errFileClose  = 3;
  errFileRead   = 4;
  errFileWrite  = 5;
  errFileAttr   = 6;
  errFileFull   = 7;
  errFileGZip   = 8;  // ill. GZip header
  errFileCheck  = 9;  // corrupt packed or crypted file
  errUserBreak  = 20; // process stopped bei user
  errAllCodes   = $0FFF;

  errCopy      = $1000;
  errGZip      = $2000;
  errGUnzip    = $3000;
  errZip       = $4000;
  errEncrypt   = $5000;
  errDecrypt   = $6000;
  errAllTypes  = $F000;

type
  TWord = record
    case integer of
    0 : (Both : word);
    1 : (Lo,Hi : byte);
    2 : (Bytes : array [0..1] of Byte);
    end;

  TLongWord = record
    case integer of
    0 : (LongWord : cardinal);
    1 : (Lo,Hi : word);
    2 : (LoL,LoH,HiL,HiH : byte);
    3 : (Bytes : array [0..3] of Byte);
    end;

  TInt64 = record
    case integer of
    0: (AsInt64 : int64);
    1: (Lo,Hi   : Cardinal);
    2: (Cardinals : array [0..1] of Cardinal);
    3: (Words : array [0..3] of Word);
    4: (Bytes : array [0..7] of Byte);
    end;

  TGzHeader = packed record
    Signature : word;
    Methode,
    Flags     : byte;
    TimeStamp : cardinal;
    XFlags,
    OpSys     : byte;
    end;

  TGzFileInfo = record
    Filename : string;          // original filename
    DateTime : integer;         // original timestamp
    Attr     : word;            // original file attributes
    USize    : cardinal;        // original size
    end;

  TPKExtraLocalField = packed record
    Tag,ESize   : word;
    Buffer      : array [0..3] of int64;
    end;

  TPKExtraEncField = packed record
    Tag,ESize,
    Version,Vendor  : word;
    Mode            : byte;
    Method          : word;
    end;

  TPKLocalHeader = packed record
    Signatur    : cardinal;
    Vers,Flag,
    Method      : word;
    FTimeStamp,
    CRC,
    CSize,USize : cardinal;
    FNLength,
    ExtraLength : word;
    end;

  TPKDirHeader = packed record
    Signatur    : cardinal;
    VersMade,
    VersExtr,
    Flag,
    Method      : word;
    FTimeStamp,
    CRC,
    CSize,USize : cardinal;
    FNLength,
    ExtraLength,
    CommLength,
    DiskStart,
    IntAttr     : word;
    ExtAttr,
    Offset      : cardinal;
    end;

  TPKEndHeader = packed record
    Signatur    : cardinal;
    ThisDisk,
    StartDisk,
    ThisEntries,
    TotalEntries : word;
    DirSize,
    Offset      : cardinal;
    CommLength  : word;
    end;

  TPKZip64CdRecord = packed record
    Signatur    : cardinal;
    Size        : int64;
    VersMade,
    VersExtr    : word;
    ThisDisk,
    StartDisk   : cardinal;
    ThisEntries,
    TotalEntries,
    DirSize,
    Offset      : int64;
    end;

  TPKZip64CdLocator = packed record
    Signatur    : cardinal;
    StartDisk   : cardinal;
    Offset      : int64;
    TotalDisk   : cardinal;
    end;

  EZipError = class(EInOutError)
  public
    ZipError : integer;
    constructor Create (ErrString : string; ErrNR : integer);
    end;

  TPkHeader = class(TObject)
    TimeStamp,CRC   : cardinal;
    GpFlag,Attr,
    CompMethode     : word;
    Offset,
    CSize,USize     : int64;
    Zip64           : boolean;
    constructor Create  (Ts,Chk : cardinal; AA,AF,AM : word; Ofs,CSz,USz : int64);
    end;

type
   TProgressEvent = procedure(Sender: TObject; Increment : integer) of object;

  // base class for all copy functions (compressed and crypted)
  TCopyThread = class (TThread)
  private
    FError           : integer;
    FBuffer          : array of byte;
    FOnProgress      : TProgressEvent;
    function GetDone : boolean;
  protected
    SourceName,
    DestName         : string;
    sSource,sDest    : TFileStream;
    FBufSize         : cardinal;
    FUserBreak       : boolean;
    FErrFlag         : integer;
    FCompLevel       : TZCompressionLevel;
    FCompType        : TZStrategy;
    FCrc             : cardinal;
    UTotal,CTotal    : int64;
    procedure ErrorBreak (Mode,Error : integer);
    function GzCompress (fSource,fDest : TStream) : integer;
    function GzUnCompress (fSource,fDest : TStream) : integer;
    procedure DoProgress (AIncrement : integer); virtual;
    procedure Execute; override;
  public
  // ASourceName  = source file,  ADestName = dest. file
    constructor Create (ASourceName,ADestName : string; ASuspend : Boolean;
                        ABufSize : integer; APriority : TThreadPriority);
    destructor Destroy; override;
    procedure CancelThread;
    property ErrorCode : integer read FError;
    property Done  : boolean read GetDone;
    property OnProgress : TProgressEvent read FOnProgress write FOnProgress;
    end;

  // gzip compatible compression
  TGZipThread = class (TCopyThread)
  protected
    function GzWriteHeader (fDest : TStream; fName : string; fTime : cardinal) : integer;
    function GzWriteTrailer (fDest : TStream; FSize : cardinal) : integer;
    procedure Execute; override;
  public
  // ASourceName  = source file,  ADestName = gz-file
    constructor Create (ASourceName,ADestName : string; ASuspend : Boolean;
                        ABufSize : integer; APriority : TThreadPriority);
    property CompressionLevel : TZCompressionLevel read FCompLevel write FCompLevel;
    property CompressionType : TZStrategy read FCompType write FCompType;
    property Crc : cardinal read FCrc;
    end;

  // gzip compatible uncompression
  TGUnZipThread = class (TCopyThread)
  protected
    function GzReadHeader (fSource : TStream; var fName : string; var fTime : cardinal) : integer;
    function GzReadTrailer (fSource : TStream) : integer;
    procedure Execute; override;
  public
  // ASourceName  = gz-file,  ADestFolder = destination folder
    constructor Create (ASourceName,ADestFolder : string; ASuspend : Boolean;
                        ABufSize : integer; APriority : TThreadPriority);
    property Crc : cardinal read FCrc;
    end;

  // Zip compatible compression
  TZipThread = class (TGZipThread)
  protected
    procedure Execute; override;
  public
    constructor Create (ASourceName : string; ZStream : TStream; ASuspend : Boolean;
                        ABufSize : integer; APriority : TThreadPriority;
                        AOnProgress : TProgressEvent);
    end;

  TZip = class (TFileStream)
  private
    PBase,PDest : string;
    FileList    : TStringList;
    FPriority   : TThreadPriority;
    FBufferSize : integer;
    FErrorFlag  : boolean;
    ZipThread   : TZipThread;
    FOnProgress : TProgressEvent;
  public
    constructor Create (Destination,BasicDirectory : string; ABufSize : integer);
    destructor Destroy; override;
    procedure Add (SourceName : string);
    procedure Suspend;
    procedure Resume;
    property ThreadPriority : TThreadPriority read FPriority write FPriority;
    property OnProgress : TProgressEvent read FOnProgress write FOnProgress;
    property ErrorFlag : boolean read FErrorFlag;
    end;

// get error message
function GetCopyErrMsg (AError : integer) : string;

// retrieve date from gz-file
function GzFileInfo (Filename: string; var FileInfo : TGzFileInfo) : boolean;

// get file size as in64
function LongFileSize (FileName : string) : int64;

// get last write time (UTC) of file
function GetFileLastWriteTime(const FileName: string): TFileTime;

// set last write time (UTC)to file
function SetFileLastWriteTime(const FileName: string; FileTime : TFileTime) : integer;

// convert filetime to Delphi time (TDateTime)
function FileTimeToDateTime (ft : TFileTime) : TDateTime;

// convert Delphi time (TDateTime) to filetime
function DateTimeToFileTime (dt : TDateTime) : TFileTime;

// convert filetime to Unix time
function FileTimeToUnixTime (ft : TFileTime) : cardinal;

// convert Unix time to filetime
function UnixTimeToFileTime (ut : cardinal) : TFileTime;

// convert file attributes to string
function FileAttrToString(Attr : word) : string;

// check if file exists
function ExistingFile (const FileName: string): boolean;

implementation

uses Forms;

const
  MaxCardinal = $FFFFFFFF; // max. value for cardinals (4 bytes)
  MaxSize = $FF000000;     // max. file size for standard zip

type
  TCvTable = array [0..127] of char;
const
  TabToOEM : TCvTable =(
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$AD,#$9B,#$9C,#$20,#$9D,#$B3,#$15,#$20,#$20,#$20,#$AE,#$AA,#$C4,#$20,#$20,
    #$F8,#$F1,#$FD,#$FC,#$20,#$E6,#$E3,#$20,#$20,#$20,#$20,#$AF,#$AC,#$AB,#$20,#$A8,
    #$41,#$41,#$41,#$41,#$8E,#$8F,#$92,#$80,#$45,#$90,#$45,#$45,#$49,#$49,#$49,#$49,
    #$44,#$A5,#$4F,#$4F,#$4F,#$4F,#$99,#$20,#$20,#$55,#$55,#$55,#$9A,#$59,#$20,#$E1,
    #$85,#$61,#$83,#$61,#$84,#$86,#$91,#$87,#$8A,#$82,#$88,#$89,#$8D,#$A1,#$8C,#$8B,
    #$20,#$A4,#$95,#$A2,#$93,#$6F,#$94,#$F6,#$20,#$97,#$A3,#$96,#$81,#$79,#$20,#$98);

{ ---------------------------------------------------------------- }
// convert ANSI-Strings to OEM
function StrToOEM (s : string) : string;
var
  i  : integer;
begin
  for i:=1 to length(s) do begin
    if s[i]>=#128 then s[i]:=TabToOEM[ord(s[i])-128];
    end;
  StrToOEM:=s;
  end;

{ ---------------------------------------------------------------- }
// get last write time (UTC) of file
function GetFileLastWriteTime(const FileName: string): TFileTime;
var
  Handle   : THandle;
  FindData : TWin32FindData;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
      Result:=FindData.ftLastWriteTime; Exit;
      end;
    end;
  with Result do begin
    dwLowDateTime:=0; dwHighDateTime:=0;
    end;
  end;

// set last write time (UTC)to file
function SetFileLastWriteTime(const FileName: string; FileTime : TFileTime) : integer;
var
  Handle   : THandle;
begin
  Handle:=FileOpen(FileName, fmOpenWrite);
  if Handle=THandle(-1) then Result:=GetLastError
  else begin
    if SetFileTime(Handle,nil,nil,@FileTime) then Result:=0
    else Result:=GetLastError;
    FileClose(Handle);
    end;
  end;

{ ------------------------------------------------------------------- }
// convert filetime to Delphi time (TDateTime)
function FileTimeToDateTime (ft : TFileTime) : TDateTime;
var
  st : TSystemTime;
begin
  FileTimeToSystemTime(ft,st);
  with st do Result:=EncodeDate(wYear,wMonth,wDay)+EncodeTime(wHour,wMinute,wSecond,wMilliseconds);
  end;

// convert Delphi time (TDateTime) to filetime
function DateTimeToFileTime (dt : TDateTime) : TFileTime;
var
  st : TSystemTime;
begin
  with st do begin
    DecodeDate(dt,wYear,wMonth,wDay);
    DecodeTime(dt,wHour,wMinute,wSecond,wMilliseconds);
    end;
  SystemTimeToFileTime(st,Result);
  end;

{ ------------------------------------------------------------------- }
// convert Delphi time to Unix time (cardinal) = seconds since 00:00:00 UTC, 1.1.1970
function DateTimeToUnixTime (dt : TDateTime) : cardinal;
begin
  Result:=round(SecsPerDay*(dt-25569));
  end;

function UnixTimeTodateTime (ut : cardinal) : TDateTime;
begin
  Result:=ut/SecsPerDay+25569;
  end;

function FileTimeToUnixTime (ft : TFileTime) : cardinal;
begin
  Result:=DateTimeToUnixTime (FileTimeToDateTime(ft));
  end;

function UnixTimeToFileTime (ut : cardinal) : TFileTime;
begin
  Result:=DateTimeToFileTime(UnixTimeTodateTime(ut));
  end;

function FileTimeToSeconds (ft : TFileTime) : cardinal;
begin
  Result:=TInt64(ft).AsInt64 div 10000000;
  end;

{ ------------------------------------------------------------------- }
function GetFileData(FileName : string; var FileData : TWin32FindData): boolean;
var
  Handle: THandle;
begin
  Handle := FindFirstFile(PChar(FileName),FileData);
  Result:=Handle <> INVALID_HANDLE_VALUE;
  if Result then begin
    Windows.FindClose(Handle);
    Result:=(FileData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0;
    end;
  end;

function GetFileAge (const FileData: TWin32FindData) : integer;
var
  LocalFileTime: TFileTime;
begin
  FileTimeToLocalFileTime(FileData.ftLastWriteTime,LocalFileTime);
  if not FileTimeToDosDateTime(LocalFileTime,LongRec(Result).Hi,LongRec(Result).Lo) then
    Result:=-1;
  end;

function GetFileSize (const FileData: TWin32FindData) : int64;
var
  sz  : TInt64;
begin
  with FileData,sz do begin
    Lo:=nFileSizeLow; Hi:=nFileSizeHigh;
    end;
  Result:=sz.AsInt64;
  end;

function LongFileSize (FileName : string) : int64;
var
  FileData : TWin32FindData;
begin
  if GetFileData(FileName,FileData) then Result:=GetFileSize(FileData)
  else Result:=0;
  end;

{ ------------------------------------------------------------------- }
// convert file attributes to string
function FileAttrToString(Attr : word) : string;
var
  s : string;
begin
  s:='';
  if Attr and faReadOnly =0 then s:=s+'-' else s:=s+'r';
  if Attr and faArchive =0 then s:=s+'-' else s:=s+'a';
  if Attr and faHidden =0 then s:=s+'-' else s:=s+'h';
  if Attr and faSysFile =0 then s:=s+'-' else s:=s+'s';
//  if Attr and faSymLink	=0 then s:=s+'-' else s:=s+'L';
  Result:=s;
  end;

{ ------------------------------------------------------------------- }
// check if file exists
// replaces function FileExists in unit SysUtils
// reason: FileExists returns an error on existing files with illegal date
function ExistingFile (const FileName: string): boolean;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Handle:=FindFirstFile(PChar(FileName),FindData);
  if Handle<>INVALID_HANDLE_VALUE then begin
    Windows.FindClose(Handle);
    Result:=true;
    end
  else Result:=false;
  end;

{ ------------------------------------------------------------------- }
// get error message
function GetCopyErrMsg (AError : integer) : string;
var
  s : string;
begin
  case AError and errAllCodes of
  errFileCreate : s:='Create file error';
  errFileOpen   : s:='Open file error';
  errFileClose  : s:='Close file error';
  errFileRead   : s:='Read file error';
  errFileWrite  : s:='Write file error';
  errFileAttr   : s:='Set file attr. error';
  errFileFull   : s:='Low disk space';
  errFileGZip   : s:='Illegal GZip header';
  errFileCheck  : s:='Corrupt file';
  errUserBreak  : s:='Terminated by user';
  else s:='Unknown error';  // should not happen
    end;
  case AError and errAllTypes of
  errCopy       : s:=s+' (Copy)';
  errGZip       : s:=s+' (GZip)';
  errGUnzip     : s:=s+' (GUnzip)';
  errZip        : s:=s+' (Zip)';
  errEnCrypt    : s:=s+' (Encrypt)';
  errDeCrypt    : s:=s+' (Decrypt)';
    end;
  Result:=s;
  end;

{ ------------------------------------------------------------------- }
function GetGzHeader (fSource   : TStream;
                      var fName : string;
                      var fTime : cardinal) : integer;
var
  Header : TGzHeader;
  n      : word;
  c      : char;
begin
  Result:=errOK;       // o.k.
  fName:=''; fTime:=0;
  try
    fSource.Read(Header,sizeof(TGzHeader));
    with Header do begin
      if Signature<>GzSignatur then begin
        Result:=errFileGZip; exit;
        end;
      fTime:=TimeStamp;
      with fSource do begin
        if Flags and gfExtraField <> 0 then begin   // skip extra field
          Read(n,2);              // length of extra field
          Position:=Position+n;   // adjust stream position
          end;
        if Flags and gfFileName <> 0 then begin   // read filename
          repeat
            Read(c,1);
            if c<>#0 then fName:=fName+c;
            until c=#0;
          end;
        if Flags and gfComment <> 0 then begin   // skip comment
          repeat
            Read(c,1);
            until c=#0;
          end;
        if Flags and gfHeaderCrc <> 0 then Read(n,2) // skip crc16
        end;
      end;
  except
    Result:=errFileRead; exit; // error
    end;
  end;

{ ------------------------------------------------------------------- }
(* retrieve file info from gz-file *)
function GzFileInfo (Filename: string; var FileInfo : TGzFileInfo) : boolean;
var
  sFile : TFileStream;
  utime : cardinal;
  lft   : TFileTime;
begin
  Result:=false;
  try
    sFile:= TFileStream.Create(Filename,fmOpenRead+fmShareDenyNone);
    with FileInfo do begin
      DateTime:=DateTimeToFileDate(Now);
      if GetGzHeader (sFile,Filename,utime)=errOK then begin
        FileTimeToLocalFileTime(DateTimeToFileTime(utime/SecsPerDay+25569),lft);
        FileTimeToDosDateTime(lft,LongRec(DateTime).Hi,LongRec(DateTime).Lo);
        Attr:=FileGetAttr(Filename);
        with sFile do begin
          Seek (-4,soFromEnd);
          Read(USize,4);
          end;
        Result:=true;
        end;
      end;
  finally
    sFile.Free;
    end;
  end;

{ ------------------------------------------------------------------- }
constructor TCopyThread.Create (ASourceName,ADestName : string; ASuspend : Boolean;
                                ABufSize : integer; APriority : TThreadPriority);
begin
  inherited Create (ASuspend);
  SourceName:=ASourceName; DestName:=ADestName;
  Priority:=APriority;
  FOnProgress:=nil;
  FError:=0; FErrFlag:=errCopy;
  FBufSize:=ABufSize;
  SetLength(FBuffer,FBufSize);
  FUserBreak:=false;
  UTotal:=0; CTotal:=0; FCrc:=0;
  FCompLevel:=zcDefault; FCompType:=zsDefault;
  end;

destructor TCopyThread.Destroy;
begin
  FBuffer:=nil;
  inherited Destroy;
  end;

function TCopyThread.GetDone : boolean;
begin
  Result:=Terminated;
  end;

// Mode = 0 : no freeing, 1 = free source, 2 = free dest, 3 free both
procedure TCopyThread.ErrorBreak (Mode,Error : integer);
begin
  FError:=FErrFlag or Error;
  if (Mode and 1)<>0 then try sSource.Free; except end;
  if (Mode and 2)<>0 then try sDest.Free; except end;
  Terminate;
  end;

procedure TCopyThread.CancelThread; 
begin
  FUserBreak:=true;
  end;

function ZipCrc32(Crc : cardinal; const buf; len: Integer): cardinal;
begin
  Result:=Crc32 (Crc,pchar(@buf),len);
  end;

{ ------------------------------------------------------------------- }
function TCopyThread.GzCompress (fSource,fDest : TStream) : integer;
var
  sComp         : TZCompressionStream;
  NRead,NWrite  : cardinal;
  ec            : integer;
begin
  ec:=errOK;       // o.k.
  // setup for GZip compatible compression
  sComp:=TZCompressionStream.Create(fDest,FCompLevel,defWindowBits,defMemLevel,FCompType);
  repeat
    try
      NRead:=fSource.Read(FBuffer[0],FBufSize);
      UTotal:=UTotal+NRead;        // total number of bytes read
      DoProgress(NRead);
      FCrc:=ZipCrc32(FCrc,FBuffer[0],NRead);
    except
      ec:=errFileRead;
      end;
    if ec=errOK then begin
      try
        NWrite:=sComp.Write(FBuffer[0],NRead);
        if NWrite<NRead then ec:=errFileFull;  // dest disk full
      except
        ec:=errFileWrite;
        end;
      if (ec=errOK) and FUserBreak then ec:=errUserBreak;
      end;
    until (NRead<FBufSize) or (ec<>errOK);
  sComp.Free;
  Result:=ec;
  end;

function TCopyThread.GzUnCompress (fSource,fDest : TStream) : integer;
var
  sComp         : TZDecompressionStream;
  NRead,NWrite  : cardinal;
  n             : int64;
  ec            : integer;
begin
  ec:=errOK;       // o.k.
  // setup for GZip compatible decompression
  with fSource do n:=Size-Position-8;
  sComp:=TZDecompressionStream.Create(fSource,n,defWindowBits);
  repeat
    try
      NRead:=sComp.Read(FBuffer[0],FBufSize);
    except
      ec:=errFileRead;
      end;
    if ec=errOK then begin
      try
        FCrc:=ZipCrc32(FCrc,FBuffer[0],NRead);
        if assigned(fDest) then NWrite:=fDest.Write(FBuffer[0],NRead)
        else NWrite:=NRead;
        DoProgress(NRead);
        UTotal:=UTotal+NWrite;        // total number of bytes written
        if (NWrite<NRead) then ec:=errFileFull;    // dest disk full
      except
        ec:=errFileWrite; Exit;
        end;
      if (ec=errOK) and FUserBreak then ec:=errUserBreak;
      end;
    until (NRead<FBufSize) or (ec<>errOK);;
  sComp.Free;
  Result:=ec;
  end;

{ ------------------------------------------------------------------- }
procedure TCopyThread.DoProgress (AIncrement : integer);
begin
  if Assigned(FOnProgress) then FOnProgress(Self,AIncrement);
  end;

{ ------------------------------------------------------------------- }
procedure TCopyThread.Execute;
var
  FTime             : TFileTime;
  n                 : Integer;
  NRead,NWrite      : cardinal;
  Attr              : word;
begin
  if ExistingFile (SourceName) and (length(DestName)>0) then begin
    FTime:=GetFileLastWriteTime(SourceName);
    Attr:=FileGetAttr(SourceName);
    try
      sSource:=TFileStream.Create(SourceName,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do begin
        ErrorBreak(0,errFileOpen); Exit;
        end;
      end;
    // Ziel immer überschreiben
    if ExistingFile(DestName) then begin
      if FileSetAttr(DestName,faArchive)<>0 then begin
        ErrorBreak(1,errFileAttr); Exit;
        end;
      end;
    try
      sDest:=TFileStream.Create(DestName,fmCreate);
    except
      on EFCreateError do begin
        ErrorBreak(1,errFileCreate); Exit;
        end;
      end;
    repeat
      try
        NRead:=sSource.Read(FBuffer[0],FBufSize);
        UTotal:=UTotal+NRead;        // total number of bytes read
        DoProgress(NRead);
      except
        on EReadError do begin
          ErrorBreak(3,errFileRead); Exit;
          end;
        end;
      try
        NWrite:=sDest.Write(FBuffer[0],NRead);
        if NWrite<NRead then begin  // Ziel-Medium voll
          ErrorBreak(3,errFileFull); Exit;
          end;
      except
        on EWriteError do begin
          ErrorBreak(3,errFileWrite); Exit;
          end;
        end;
      if  FUserBreak then begin
        ErrorBreak(3,errUserBreak); Exit;
        end;
      until NRead<FBufSize;
    if  sDest.Size<>sSource.Size then begin
    // z.B. wenn "sSource" gelockt ist (siehe LockFile)
      ErrorBreak(3,errFileRead); Exit;
      end;
    try
      sSource.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(2,errFileClose); Exit;
        end;
      end;
    try
      sDest.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(0,errFileClose); Exit;
        end;
      end;
    n:=SetFileLastWriteTime(DestName,FTime);
    if n=0 then n:=FileSetAttr(DestName,Attr);
    if n>0 then FError:=errFileAttr;
    end
  else FError:=errFileOpen;
  if FError<>errOK then FError:=FErrFlag or FError;
  Terminate;
  end;

{ TGZipThread ------------------------------------------------------------------- }
constructor TGZipThread.Create (ASourceName,ADestName : string; ASuspend : Boolean;
                                ABufSize : integer; APriority : TThreadPriority);
begin
  inherited Create (ASourceName,ADestName,ASuspend,ABufSize, APriority);
  FErrFlag:=errGZip;
  end;

function TGZipThread.GzWriteHeader (fDest : TStream;
                                    fName : string;
                                    fTime : cardinal) : integer;
var
  Header : TGzHeader;
  n      : integer;
begin
  Result:=errOK;       // o.k.
  n:=length(fname);
  with Header do begin
    Signature:=GzSignatur;
    Methode:=Z_DEFLATED;
    if n>0 then Flags:=gfFileName else Flags:=0;
    TimeStamp:=fTime;
    XFlags:=0;
    OpSys:=0;
    end;
  try
    fDest.Write(Header,sizeof(TGzHeader));
    if n>0 then begin   // write filename
      fDest.Write(fName[1],n+1);
      end;
  except
    Result:=errFileWrite; exit; // error
    end;
  // init checksum
  FCrc:=Crc32(0,nil,0);
  end;

function TGZipThread.GzWriteTrailer (fDest : TStream; FSize : cardinal) : integer;
begin
  Result:=errOK;       // o.k.
  try
    fDest.Write(FCrc,4);
    fDest.Write(FSize,4);
  except
    Result:=errFileWrite; exit; // error
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TGZipThread.Execute;
var
  FTime         : TFileTime;
  utime         : cardinal;
  ec,n          : integer;
  fp            : int64;
  Attr          : word;
begin
  if ExistingFile (SourceName) and (length(DestName)>0) then begin
    Attr:=FileGetAttr(SourceName);
    FTime:=GetFileLastWriteTime(SourceName);
    // unix time for gzip
    utime:=round(SecsPerDay*(FileTimeToDateTime(FTime)-25569));
    try
      sSource:=TFileStream.Create(SourceName,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do begin
        ErrorBreak(1,errFileOpen); Exit;
        end;
      end;
    // always overwrite destination, reset attributes
    if ExistingFile(DestName) then begin
      if FileSetAttr(DestName,faArchive)<>0 then begin
        ErrorBreak(1,errFileAttr); Exit;
        end;
      end;
    try
      sDest:=TFileStream.Create(DestName,fmCreate);
    except
      on EFCreateError do begin
        ErrorBreak(1,errFileCreate); Exit;
        end;
      end;
    ec:=GzWriteHeader(sDest,ExtractFilename(SourceName),utime);
    fp:=sDest.Position;
    if ec=errOK then begin
      ec:=GzCompress(sSource,sDest);
      if ec=errOK then begin
        // z.B. wenn "sSource" gelockt ist (siehe LockFile)
        if UTotal<>sSource.Size then ec:=errFileRead;
        CTotal:=sDest.Position-fp;
        if UTotal>MaxCardinal then UTotal:=MaxCardinal;
        n:=GzWriteTrailer (sDest,TInt64(UTotal).Lo);
        if ec=errOK then ec:=n;
        end;
      end;
    if ec<>errOK then begin
      ErrorBreak(3,ec); Exit;
      end;
    try
      sSource.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(2,errFileClose); Exit;
        end;
      end;
    try
      sDest.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(0,errFileClose); Exit;
        end;
      end;
    (* set time stamp of gz-file *)
    n:=SetFileLastWriteTime(DestName,FTime);
    if n=0 then n:=FileSetAttr(DestName,Attr);
    if n>0 then begin
      ErrorBreak(0,errFileAttr); exit;
      end;
    end;
  Terminate;
  end;

{ TGUnZipThread ------------------------------------------------------------------- }
constructor TGUnZipThread.Create (ASourceName,ADestFolder : string; ASuspend : Boolean;
                                  ABufSize : integer; APriority : TThreadPriority);
begin
  inherited Create (ASourceName,IncludeTrailingBackslash(ADestFolder),ASuspend,ABufSize,APriority);
  FErrFlag:=errGUnzip;
  end;

function TGUnZipThread.GzReadHeader (fSource   : TStream;
                                     var fName : string;
                                     var fTime : cardinal) : integer;
begin
  Result:=GetGzHeader (fSource,fName,fTime);
  // init checksum
  FCrc:=Crc32(0,nil,0);
  end;

function TGUnZipThread.GzReadTrailer (fSource : TStream) : integer;
var
  aCrc,FSize : cardinal;
begin
  Result:=errOK;       // o.k.
  try
    fSource.Read(aCrc,4);
    fSource.Read(FSize,4);
    if (FCrc<>aCrc) or (TInt64(UTotal).Lo<>FSize) then begin
      Result:=errFileCheck; exit; // checksum error
      end;
  except
    Result:=errFileWrite; exit; // error
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TGUnZipThread.Execute;
var
  FTime         : TFileTime;
  utime         : cardinal;
  FName         : string;
  ec,n          : integer;
  fp            : int64;
  Attr          : word;
begin
  if ExistingFile (SourceName) and (length(DestName)>0) then begin
    Attr:=FileGetAttr(SourceName);
    FTime:=GetFileLastWriteTime(SourceName);
    try
      sSource:=TFileStream.Create(SourceName,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do begin
        ErrorBreak(1,errFileOpen); Exit;
        end;
      end;
    ec:=GzReadHeader(sSource,FName,utime);
    fp:=sSource.Position;
    if ec=errOK then begin
      if length(FName)>0 then FName:=DestName+FName
      else FName:=DestName+ChangeFileExt(ExtractFilename(SourceName),'');
      // always overwrite destination, reset attributes
      if ExistingFile(FName) then begin
        if FileSetAttr(FName,faArchive)<>0 then begin
          ErrorBreak(1,errFileAttr); Exit;
          end;
        end;
      try
        sDest:=TFileStream.Create(FName,fmCreate);
      except
        on EFCreateError do begin
          ErrorBreak(1,errFileCreate); Exit;
          end;
        end;
      ec:=GzUncompress(sSource,sDest);
      if ec=errOK then begin
        CTotal:=sSource.Position-fp;
        ec:=GzReadTrailer (sSource);
        end;
      end;
    if ec<>errOK then begin
      ErrorBreak(3,ec); Exit;
      end;
    try
      sDest.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(1,errFileClose); Exit;
        end;
      end;
    try
      sSource.Free;
    except
      on EFileStreamError do begin
        ErrorBreak(0,errFileClose); Exit;
        end;
      end;
    (* set time stamp of gz-file *)
    n:=SetFileLastWriteTime(FName,FTime);
    if n=0 then n:=FileSetAttr(FName,Attr);
    if n>0 then begin
      ErrorBreak(0,errFileAttr); exit;
      end;
    end;
  Terminate;
  end;

{ ------------------------------------------------------------------- }
constructor TPkHeader.Create (Ts,Chk : cardinal; AA,AF,AM : word; Ofs,CSz,USz : int64);
begin
  inherited Create;
  Timestamp:=Ts;  CRC:=Chk;
  Attr:=AA; GpFlag:=AF; CompMethode:=AM;
  Offset:=Ofs; CSize:=CSz; USize:=USz;
  Zip64:=(Offset>MaxCardinal) or (CSize>MaxCardinal) or (USize>MaxCardinal);
  end;

{ ------------------------------------------------------------------- }
(* generate error message *)
constructor EZipError.Create (ErrString : string;
                              ErrNR     : integer);
begin
  inherited Create (ErrString);
  ZipError:=ErrNr or ErrZip;
  end;

{ Create ----------------------------------------------------
  Open ZIP archive
---------------------------------------------------------------}
constructor TZip.Create (Destination,BasicDirectory : string; ABufSize : integer);
begin
  try
    inherited Create (Destination,fmCreate);
    FileList:=TStringList.Create;
    FileList.Sorted:=false; FErrorFlag:=false;
    PDest:=Destination; PBase:=BasicDirectory;
    FPriority:=tpNormal; FBufferSize:=ABufSize;
    FOnProgress:=nil;
    ZipThread:=nil;
  except
    on EFCreateError do begin
      raise EZipError.Create ('Error creating '+Destination,errFileCreate);
      end;
    end;
  end;

{ Destroy-------------------------------------------
  Write directory and final block of ZIP archive
---------------------------------------------------------------}
destructor TZip.Destroy;
var
  pke : TPkEndHeader;
  pkd : TPkDirHeader;
  pkl : TPkHeader;
  pkz : TPKZip64CdRecord;
  pko : TPKZip64CdLocator;
  fp  : int64;
  i,n : integer;
  s   : string[255];
  lef : TPKExtraLocalField;

    // Finish building Zip archive
  procedure ReleaseZip (Error : boolean);
  var
    i : integer;
  begin
    if Error then raise EZipError.Create ('Error writing '+PDest,errFileWrite);
    with FileList do begin
      for i:=0 to Count-1 do Objects[i].Free;
      Free;
      end;
    inherited Destroy;
    end;


begin
  fp:=Size;
  with FileList do for i:=0 to Count-1 do begin  // central directory structure
    pkl:=Objects[i] as TPkHeader;
    with pkd do begin
      Signatur:=PkDirSignatur;
      Flag:=pkl.GpFlag;
      Method:=pkl.CompMethode;
      FTimeStamp:=pkl.TimeStamp;
      CRC:=pkl.CRC;
      FNLength:=length(Strings[i]);
      if pkl.Zip64 then begin
        VersMade:=VersZip64+VersDos;
        VersExtr:=VersZip64+VersDos;
        with lef do begin
          Tag:=ExtraZip64;
          n:=0;
          if pkl.USize>MaxCardinal then begin
            USize:=MaxCardinal;
            Buffer[n]:=pkl.USize;
            inc(n);
            end
          else USize:=TInt64(pkl.USize).Lo;
          if pkl.CSize>MaxCardinal then begin
            CSize:=MaxCardinal;
            Buffer[n]:=pkl.CSize;
            inc(n);
            end
          else CSize:=TInt64(pkl.CSize).Lo;
          if pkl.Offset>MaxCardinal then begin
            Offset:=MaxCardinal;
            Buffer[n]:=pkl.Offset;
            inc(n);
            end
          else Offset:=TInt64(pkl.Offset).Lo;
          ESize:=8*n;
          ExtraLength:=4+ESize;
          end;
        end
      else begin
        VersMade:=VersDef+VersDos;
        VersExtr:=VersDef;
        CSize:=TInt64(pkl.CSize).Lo;
        USize:=TInt64(pkl.USize).Lo;
        Offset:=TInt64(pkl.Offset).Lo;
        ExtraLength:=0;
        end;
      CommLength:=0;
      DiskStart:=0;
      IntAttr:=0;
      ExtAttr:=pkl.Attr;
      end;
    s:=Strings[i];
    try
      Write(pkd,sizeof(pkd));
      Write(s[1],pkd.FNLength);
      if pkl.Zip64 then begin       // extra field
        Write(lef,pkd.ExtraLength);
        end;
    except
      ReleaseZip (true); exit;
      end;
    end;
  with pke do begin
    Signatur:=PkEndSignatur;
    ThisDisk:=0;
    StartDisk:=0;
    if FileList.Count>MaxWord then begin
      ThisEntries:=MaxWord;
      TotalEntries:=MaxWord;
      end
    else begin
      ThisEntries:=FileList.Count;
      TotalEntries:=FileList.Count;
      end;
    CommLength:=0;
    end;  // check if file size > 4GB
  if (Position>MaxCardinal) or (FileList.Count>MaxWord) then begin
    // Zip64 end of central directory record
    with pkz do begin
      Signatur:=Pk64RecSignatur;
      Size:=sizeof(TPKZip64CdRecord)-12;
      VersMade:=VersZip64+VersDos;
      VersExtr:=VersZip64+VersDos;
      ThisDisk:=0;
      StartDisk:=0;
      ThisEntries:=FileList.Count;
      TotalEntries:=FileList.Count;
      DirSize:=Position-fp;
      Offset:=fp;
      end;
    with pke do begin
      if pkz.DirSize>MaxCardinal then DirSize:=MaxCardinal
      else DirSize:=pkz.DirSize;
      Offset:=MaxCardinal;
      end;
    fp:=Position;
    // Zip64 end of central directory locator
    with pko do begin
      Signatur:=Pk64LocSignatur;
      StartDisk:=0;
      Offset:=fp;
      TotalDisk:=1;
      end;
    try
      Write(pkz,sizeof(TPKZip64CdRecord));
      Write(pko,sizeof(TPKZip64CdLocator));
    except
      ReleaseZip (true); exit;
      end;
    end
  else with pke do begin
    DirSize:=Position-fp;
    Offset:=TInt64(fp).Lo;
    end;
  try
    Write(pke,sizeof(pke));
  except
    ReleaseZip (true); exit;
    end;
  ReleaseZip (false);
  end;

{ Add to Zip --------------------------------------------------
  Add "Source" to open archive (see MakeZip)
---------------------------------------------------------------}
procedure TZip.Add (SourceName : string);
var
  ZfName    : string;
  ec        : integer;
  utime     : cardinal;
  LFHeader  : TPKLocalHeader;
  lef       : TPKExtraLocalField;
  FileData  : TWin32FindData;
  ut,ct,fp  : int64;
  z64       : boolean;
  rf,fc     : cardinal;
begin
  if ExistingFile (SourceName) then begin
    ZfName:=StrToOEM(ExtractRelativePath(PBase,SourceName)); // ZIP needs OEM characters (like DOS)
    if GetFileData(SourceName,FileData) then begin
      utime:=GetFileAge(FileData);
      z64:=GetFileSize(FileData)>MaxSize;
      with LFHeader do begin
        Signatur:=PKLocalSignatur;
        if z64 then Vers:=VersZip64 else Vers:=VersDef;
        Flag:=zipMaxDeflFlag;
        Method:=zipCompMethode;
        FTimeStamp:=utime;
        CRC:=0;
        FNLength:=length(ZfName);
        if z64 then begin
          with lef do begin
            Tag:=ExtraZip64;
            ESize:=16;
            Buffer[0]:=0;
            Buffer[1]:=0;
            end;
          CSize:=MaxCardinal;
          USize:=MaxCardinal;
          ExtraLength:=20;
          end
        else begin
          CSize:=0;
          USize:=0;
          ExtraLength:=0;
          end;
        end;
      fp:=Position;
      try
        Write(LFHeader,sizeof(TPKLocalHeader));         // local header
        Write(ZfName[1],LFHeader.FNLength);             // filename
        if z64 then Write(lef,LFHeader.ExtraLength);    // extra field
        ZipThread:=TZipThread.Create(SourceName,self,false,FBufferSize,FPriority,FOnProgress);
        with ZipThread do begin
          repeat
            Application.ProcessMessages;
            Sleep(10);
            until Done;
          ec:=ErrorCode and errAllCodes;
          ut:=UTotal;
          ct:=CTotal;
          fc:=FCrc;
          Free;
          end;
        ZipThread:=nil;
        Position:=fp+14;                  // write crc
        Write(fc,sizeof(cardinal));
        if z64 then begin
          // write 8 byte values to extra field
          Position:=fp+sizeof(TPKLocalHeader)+LFHeader.FNLength+4;
          Write (ut,sizeof(int64));
          Write (ct,sizeof(int64));
          end
        else begin
          // write 4 byte values
          rf:=TInt64(ct).Lo;
          Write(rf,sizeof(cardinal));
          rf:=TInt64(ut).Lo;
          Write(rf,sizeof(cardinal));
          end;
        Seek (0,soEnd);
        if ec=errOK then FileList.Addobject(ZfName,TPkHeader.Create(utime,fc,
                 FileGetAttr(SourceName),LfHeader.Flag,LfHeader.Method,fp,ct,ut));
      except
        on EWriteError do ec:=errFileWrite;
        end;
      end
    else ec:=errFileRead;
    if ec<>errOK then begin
      // set error flag on write errors
      FErrorFlag:=(ec=errFileWrite) or (ec=errFileFull);
      raise EZipError.Create (GetCopyErrMsg(ec),ec);
      end;
    end;
  end;

procedure TZip.Suspend;
begin
  if assigned(ZipThread) then with ZipThread do if not Done then Suspend;
  end;

procedure TZip.Resume;
begin
  if assigned(ZipThread) then with ZipThread do if not Done then Resume;
  end;

{ TZipThread ------------------------------------------------------------------- }
constructor TZipThread.Create (ASourceName : string; ZStream : TStream; ASuspend : Boolean;
                               ABufSize : integer; APriority : TThreadPriority;
                               AOnProgress : TProgressEvent);
begin
  inherited Create (ASourceName,'',ASuspend,ABufSize,APriority);
  OnProgress:=AOnProgress;
  sDest:=TFileStream(ZStream);
  FErrFlag:=errZip;
  end;

{ ------------------------------------------------------------------- }
procedure TZipThread.Execute;
var
  fp : int64;
begin
  try
    sSource:=TFileStream.Create(SourceName,fmOpenRead+fmShareDenyNone);
  except
    on EFOpenError do begin
      ErrorBreak(0,errFileOpen); Exit;
      end;
    end;
  fp:=sDest.Position;
  FError:=GzCompress(sSource,sDest);
  if FError=errOK then begin
    // z.B. wenn "sSource" gelockt ist (siehe LockFile)
    if UTotal<>sSource.Size then FError:=errFileRead;
    end;
  CTotal:=sDest.Position-fp;
  sSource.Free;
  if FError<>errOK then FError:=FError or FErrFlag;
  Terminate;
  end;

end.

