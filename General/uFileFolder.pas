unit uFileFolder;

interface

uses
  SysUtils, Classes, Windows, Dialogs, uLNG, uSuperReplace;

  function GetFileDateTime(FileName: WideString): TDateTime;

  procedure CheckFolder(Path: WideString; ErrorInfo: Boolean);
  function SetDateToFile(const FileName: WideString; Value: TDateTime): Boolean;

  // File
  function CreateFileIfNotExists(FileName: WideString): Boolean;
  function MoveFileIfExists(FileName, ExtPath: WideString; ReWrite: Boolean = False): Boolean;
  function CopyFileIfExists(ExistingFileName, NewFileName: WideString; Rewrite: Boolean = False): Boolean;
  function DeleteFileIfExists(FileName : WideString): Boolean;

  // Folder
  function CreateFolderIfNotExists(FolderName: WideString): Boolean;
  function RemoveFolderIfExists(FolderName : WideString): Boolean;

implementation

function GetFileDateTime(FileName: WideString): TDateTime;
var intFileAge: LongInt;
begin
  intFileAge := FileAge(FileName);
  if intFileAge = -1 then
    Result := 0
  else
    Result := FileDateToDateTime(intFileAge)
end;

procedure CheckFolder(Path: WideString; ErrorInfo: Boolean);
var rec: TSearchRec;
begin

  if FindFirst(Path, faDirectory, rec) = 0 then

  else
  begin
    try
      if ForceDirectories(Path)=False then
        if ErrorInfo=True then
          ShowMessage( TagsReplace( StringReplace(LNG('Texts', 'DirNotCreate', 'Can''t create directory: %path%') , '%path%', Path, [rfReplaceAll, rfIgnoreCase]) ) );
    except
      if ErrorInfo=True then
        ShowMessage( TagsReplace( StringReplace(LNG('Texts', 'DirNotCreate', 'Can''t create directory: %path%'), '%path%', Path, [rfReplaceAll, rfIgnoreCase]) ) );
    end;

  end;

end;

function SetDateToFile(const FileName: WideString; Value: TDateTime): Boolean;
var
  hFile: THandle;
begin
  Result := False;
  hFile := 0;
  try
    {open a file handle}
    hFile := FileOpen(FileName, fmOpenWrite or fmShareDenyNone);

    {if opened succesfully}
    if (hFile > 0) then
      {convert a datetime into DOS format and set a date}
      Result := (FileSetDate(hFile, DateTimeToFileDate(Value)) = 0)
  finally
    {close an opened file handle}
    FileClose(hFile);
  end;
end;


{  FILE  }

function CreateFileIfNotExists(FileName: WideString): Boolean;
var
  F: TextFile;
begin
  if not FileExists(FileName) then
  begin
    AssignFile(F, FileName);
    ReWrite(F);
    WriteLn(F,'; Code page: UTF-8');
    WriteLn(F);
    CloseFile(F);
  end;

  Result := FileExists(FileName);
end;


function MoveFileIfExists(FileName, ExtPath: WideString; ReWrite: Boolean = False): Boolean;
begin
  CreateFolderIfNotExists(ExtPath);                                                   // existuje cílový adresáø ?

  if CopyFileIfExists(FileName, ExtPath + ExtractFileName(FileName), ReWrite) then // byl zkopírováno ?
    DeleteFileW( PWideChar(FileName) );                                            // tak smaž pùvodní soubor

  if not FileExists(FileName) then                                                 // byl smazán pùvodní soubor ?
    Result := FileExists(ExtPath + ExtractFileName(FileName))                      // byl pøesunut ?
  else
    Result := False;                                                               // nahlaš chybu
end;


function CopyFileIfExists(ExistingFileName, NewFileName: WideString; ReWrite: Boolean = False): Boolean;
begin
  if FileExists(ExistingFileName) then
    CopyFileW( PWideChar(ExistingFileName), PWideChar(NewFileName), not ReWrite); // not ReWrite = FALSE => Soubor bude pøepsán

  Result := FileExists(ExistingFileName);
end;


function DeleteFileIfExists(FileName : WideString): Boolean;
begin
  if FileExists(FileName) then
    DeleteFileW( PWideChar(FileName) );

  Result := not FileExists(FileName);
end;



{  FOLDER  }

function CreateFolderIfNotExists(FolderName: WideString): Boolean;
begin
  if not DirectoryExists(FolderName) then
    CreateDir( FolderName );

  Result := DirectoryExists(FolderName);
end;


function RemoveFolderIfExists(FolderName : WideString): Boolean;
begin
  if DirectoryExists(FolderName) then
    RemoveDirectoryW( PChar(FolderName) );

  Result := not DirectoryExists(FolderName);
end;



end.
