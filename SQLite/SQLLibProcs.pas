unit SQLLibProcs;

interface

uses
  Windows, SQLite3, Classes, SysUtils, Dialogs;

type

  TWServers = record
    ServerID           : WideString;
  end;

  {sqlite3_open}                TSQLite3_Open             = function(dbname: PAnsiChar; var db: TSqliteDB): integer; cdecl;
  {sqlite3_close}               TSQLite3_Close            = function(db: TSQLiteDB): integer; cdecl;
  {sqlite3_exec}                TSQLite3_Exec             = function(db: TSQLiteDB; SQLStatement: PAnsiChar; CallbackPtr: Pointer; Sender: TObject; var ErrMsg: PAnsiChar): integer; cdecl;
  {sqlite3_libversion}          TSQLite3_Version          = function(): PAnsiChar; cdecl;
  {sqlite3_errmsg}              TSQLite3_ErrMsg           = function(db: TSQLiteDB): PAnsiChar; cdecl;
  {sqlite3_errcode}             TSQLite3_ErrCode          = function(db: TSQLiteDB): integer; cdecl;
  {sqlite3_free}                TSQLite3_Free             = procedure(P: PAnsiChar); cdecl;
  {sqlite3_get_table}           TSQLite3_GetTable         = function(db: TSQLiteDB; SQLStatement: PAnsiChar; var ResultPtr: TSQLiteResult; var RowCount: Cardinal; var ColCount: Cardinal; var ErrMsg: PAnsiChar): integer; cdecl;
  {sqlite3_free_table}          TSQLite3_FreeTable        = procedure(Table: TSQLiteResult); cdecl;
  {sqlite3_complete}            TSQLite3_Complete         = function(P: PAnsiChar): boolean; cdecl;
  {sqlite3_last_insert_rowid}   TSQLite3_LastInsertRowID  = function(db: TSQLiteDB): int64; cdecl;
  {sqlite3_interrupt}           TSQLite3_Interrupt        = procedure(db: TSQLiteDB); cdecl;
  {sqlite3_busy_handler}        TSQLite3_BusyHandler      = procedure(db: TSQLiteDB; CallbackPtr: Pointer; Sender: TObject); cdecl;
  {sqlite3_busy_timeout}        TSQLite3_BusyTimeout      = procedure(db: TSQLiteDB; TimeOut: integer); cdecl;
  {sqlite3_changes}             TSQLite3_Changes          = function(db: TSQLiteDB): integer; cdecl;
  {sqlite3_total_changes}       TSQLite3_TotalChanges     = function(db: TSQLiteDB): integer; cdecl;
  {sqlite3_prepare}             TSQLite3_Prepare          = function(db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer; cdecl;
  {sqlite3_prepare_v2}          TSQLite3_Prepare_v2       = function(db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer; cdecl;
  {sqlite3_column_count}        TSQLite3_ColumnCount      = function(hStmt: TSqliteStmt): integer; cdecl;
  {sqlite3_column_name}         TSQLite3_ColumnName       = function(hStmt: TSqliteStmt; ColNum: integer): pAnsiChar; cdecl;
  {sqlite3_column_decltype}     TSQLite3_ColumnDeclType   = function(hStmt: TSqliteStmt; ColNum: integer): pAnsiChar; cdecl;
  {sqlite3_step}                TSQLite3_Step             = function(hStmt: TSqliteStmt): integer; cdecl;
  {sqlite3_data_count}          TSQLite3_DataCount        = function(hStmt: TSqliteStmt): integer; cdecl;

  {sqlite3_column_blob}         TSQLite3_ColumnBlob       = function(hStmt: TSqliteStmt; ColNum: integer): pointer; cdecl;
  {sqlite3_column_bytes}        TSQLite3_ColumnBytes      = function(hStmt: TSqliteStmt; ColNum: integer): integer; cdecl;
  {sqlite3_column_double}       TSQLite3_ColumnDouble     = function(hStmt: TSqliteStmt; ColNum: integer): double; cdecl;
  {sqlite3_column_int}          TSQLite3_ColumnInt        = function(hStmt: TSqliteStmt; ColNum: integer): integer; cdecl;
  {sqlite3_column_text}         TSQLite3_ColumnText       = function(hStmt: TSqliteStmt; ColNum: integer): pAnsiChar; cdecl;
  {sqlite3_column_type}         TSQLite3_ColumnType       = function(hStmt: TSqliteStmt; ColNum: integer): integer; cdecl;
  {sqlite3_column_int64}        TSQLite3_ColumnInt64      = function(hStmt: TSqliteStmt; ColNum: integer): Int64; cdecl;
  {sqlite3_finalize}            TSQLite3_Finalize         = function(hStmt: TSqliteStmt): integer; cdecl;
  {sqlite3_reset}               TSQLite3_Reset            = function(hStmt: TSqliteStmt): integer; cdecl;



  {sqlite3_bind_blob}           TSQLite3_Bind_Blob        = function(hStmt: TSqliteStmt; ParamNum: integer; ptrData: pointer; numBytes: integer; ptrDestructor: pointer): integer; cdecl;
  {sqlite3_bind_double}         TSQLite3_Bind_Double      = function(hStmt: TSqliteStmt; ParamNum: integer; Data: Double): integer; cdecl;
  {sqlite3_bind_int}            TSQLite3_BindInt          = function(hStmt: TSqLiteStmt; ParamNum: integer; intData: integer): integer; cdecl;
  {sqlite3_bind_int64}          TSQLite3_Bind_int64       = function(hStmt: TSqliteStmt; ParamNum: integer; Data: int64): integer; cdecl;
  {sqlite3_bind_null}           TSQLite3_Bind_null        = function(hStmt: TSqliteStmt; ParamNum: integer): integer; cdecl;
  {sqlite3_bind_text}           TSQLite3_Bind_text        = function(hStmt: TSqliteStmt; ParamNum: integer;
                                                                     Data: PAnsiChar; numBytes: integer; ptrDestructor: pointer): integer; cdecl;
  {sqlite3_bind_parameter_index}TSQLite3_Bind_Parameter_Index = function(hStmt: TSqliteStmt; zName: PAnsiChar): integer; cdecl;
{
function SQLite3_Bind_Double(hStmt: TSqliteStmt; ParamNum: integer; Data: Double): integer;
  cdecl; external SQLiteDLL name 'sqlite3_bind_double';

function SQLite3_BindInt(hStmt: TSqLiteStmt; ParamNum: integer; intData: integer): integer;
  cdecl; external 'sqlite3.dll' name 'sqlite3_bind_int';

function SQLite3_Bind_int64(hStmt: TSqliteStmt; ParamNum: integer; Data: int64): integer;
  cdecl; external SQLiteDLL name 'sqlite3_bind_int64';

function SQLite3_Bind_null(hStmt: TSqliteStmt; ParamNum: integer): integer;
  cdecl; external SQLiteDLL name 'sqlite3_bind_null';

function SQLite3_Bind_text(hStmt: TSqliteStmt; ParamNum: integer;
  Data: PAnsiChar; numBytes: integer; ptrDestructor: pointer): integer;
  cdecl; external SQLiteDLL name 'sqlite3_bind_text';

function SQLite3_Bind_Parameter_Index(hStmt: TSqliteStmt; zName: PAnsiChar): integer;
  cdecl; external SQLiteDLL name 'sqlite3_bind_parameter_index';  }


  {sqlite3_enable_shared_cache} TSQlite3_enable_shared_cache= function(value: integer): integer; cdecl;
  {sqlite3_create_collation}    TSQLite3_create_collation   = function(db: TSQLiteDB; Name: PAnsiChar; eTextRep: integer;  UserData: pointer; xCompare: TCollateXCompare): integer; cdecl;
(*
{MY!!!!}
  {sqlite3_table_column_metadata}  TSQLite3_Table_Column_Metadata = function(db: TSQLiteDB; DbName: PAnsiChar; TableName: PAnsiChar; ColumnName: PAnsiChar; var DataType: PAnsiChar; var CollSeq: PAnsiChar; var NotNull: Integer; var PrimaryKey: Integer; var Autoinc: Integer): integer; cdecl;
{
int sqlite3_table_column_metadata(
  sqlite3 *db,                /* Connection handle */
  const char *zDbName,        /* Database name or NULL */
  const char *zTableName,     /* Table name */
  const char *zColumnName,    /* Column name */
  char const **pzDataType,    /* OUTPUT: Declared data type */
  char const **pzCollSeq,     /* OUTPUT: Collation sequence name */
  int *pNotNull,              /* OUTPUT: True if NOT NULL constraint exists */
  int *pPrimaryKey,           /* OUTPUT: True if column part of PK */
  int *pAutoinc               /* OUTPUT: True if column is auto-increment */
);}
*)

{

function sqlite3_enable_shared_cache(value: integer): integer; cdecl; external SQLiteDLL name 'sqlite3_enable_shared_cache';

//user collate definiton
function sqlite3_create_collation(db: TSQLiteDB; Name: PAnsiChar; eTextRep: integer;
  UserData: pointer; xCompare: TCollateXCompare): integer; cdecl; external SQLiteDLL name 'sqlite3_create_collation';
}

    function  SQLite3_Open             (dbname: PAnsiChar; var db: TSqliteDB): integer;
    function  SQLite3_Close            (db: TSQLiteDB): integer;
    function  SQLite3_Exec             (db: TSQLiteDB; SQLStatement: PAnsiChar; CallbackPtr: Pointer; Sender: TObject; var ErrMsg: PAnsiChar): integer;
    function  SQLite3_Version          (): PAnsiChar;
    function  SQLite3_ErrMsg           (db: TSQLiteDB): PAnsiChar;
    function  SQLite3_ErrCode          (db: TSQLiteDB): integer;
    procedure SQLite3_Free             (P: PAnsiChar);
    function  SQLite3_GetTable         (db: TSQLiteDB; SQLStatement: PAnsiChar; var ResultPtr: TSQLiteResult; var RowCount: Cardinal; var ColCount: Cardinal; var ErrMsg: PAnsiChar): integer;
    procedure SQLite3_FreeTable        (Table: TSQLiteResult);
    function  SQLite3_Complete         (P: PAnsiChar): boolean;
    function  SQLite3_LastInsertRowID  (db: TSQLiteDB): int64;
    procedure SQLite3_Interrupt        (db: TSQLiteDB);
    procedure SQLite3_BusyHandler      (db: TSQLiteDB; CallbackPtr: Pointer; Sender: TObject);
    procedure SQLite3_BusyTimeout      (db: TSQLiteDB; TimeOut: integer);
    function  SQLite3_Changes          (db: TSQLiteDB): integer;
    function  SQLite3_TotalChanges     (db: TSQLiteDB): integer;
    function  SQLite3_Prepare          (db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer;
    function  SQLite3_Prepare_v2       (db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer;
    function  SQLite3_ColumnCount      (hStmt: TSqliteStmt): integer;
    function  SQLite3_ColumnName       (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
    function  SQLite3_ColumnDeclType   (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
    function  SQLite3_Step             (hStmt: TSqliteStmt): integer;
    function  SQLite3_DataCount        (hStmt: TSqliteStmt): integer;

    function  SQLite3_ColumnBlob       (hStmt: TSqliteStmt; ColNum: integer): pointer;
    function  SQLite3_ColumnBytes      (hStmt: TSqliteStmt; ColNum: integer): integer;
    function  SQLite3_ColumnDouble     (hStmt: TSqliteStmt; ColNum: integer): double;
    function  SQLite3_ColumnInt        (hStmt: TSqliteStmt; ColNum: integer): integer;
    function  SQLite3_ColumnText       (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
    function  SQLite3_ColumnType       (hStmt: TSqliteStmt; ColNum: integer): integer;
    function  SQLite3_ColumnInt64      (hStmt: TSqliteStmt; ColNum: integer): Int64;
    function  SQLite3_Finalize         (hStmt: TSqliteStmt): integer;
    function  SQLite3_Reset            (hStmt: TSqliteStmt): integer;

    function  SQLite3_Bind_Blob        (hStmt: TSqliteStmt; ParamNum: integer; ptrData: pointer; numBytes: integer; ptrDestructor: pointer): integer;
    function  SQLite3_Bind_Double       (hStmt: TSqliteStmt; ParamNum: integer; Data: Double): integer; cdecl;
    function  SQLite3_BindInt           (hStmt: TSqLiteStmt; ParamNum: integer; intData: integer): integer; cdecl;
    function  SQLite3_Bind_int64        (hStmt: TSqliteStmt; ParamNum: integer; Data: int64): integer; cdecl;
    function  SQLite3_Bind_null         (hStmt: TSqliteStmt; ParamNum: integer): integer; cdecl;
    function  SQLite3_Bind_text         (hStmt: TSqliteStmt; ParamNum: integer;
                                        Data: PAnsiChar; numBytes: integer; ptrDestructor: pointer): integer; cdecl;
    function  SQLite3_Bind_Parameter_Index (hStmt: TSqliteStmt; zName: PAnsiChar): integer; cdecl;


    function  SQLite3_enable_shared_cache(value: integer): integer;
    function  SQLite3_create_collation(db: TSQLiteDB; Name: PAnsiChar; eTextRep: integer; UserData: pointer; xCompare: TCollateXCompare): integer;
(*
{MY!!}
    function  SQLite3_table_column_metadata(db: TSQLiteDB; DbName: PAnsiChar; TableName: PAnsiChar; ColumnName: PAnsiChar; var DataType: PAnsiChar; var CollSeq: PAnsiChar; var NotNull: Integer; var PrimaryKey: Integer; var Autoinc: Integer): integer;
//{sqlite3_table_column_metadata}  TSQLite3_Table_Column_Metadata = function(db: TSQLiteDB; DbName: PAnsiChar; TableName: PAnsiChar; ColumnName: PAnsiChar; var DataType: PAnsiChar; var CollSeq: PAnsiChar; var NotNull: Integer; var PrimaryKey: Integer; var Autoinc: Integer): integer; cdecl;
*)
    procedure SQLite3_LoadLib(Path: WideString);
    procedure SQLite3_FreeLib();

var
    LibHandle: Cardinal;


implementation

uses SQLiteTable3;

{$WARNINGS OFF}

procedure DllError(sCommand: WideString);
begin

  ShowMessage('Error in function: ' + sCommand +  #13 +
              'Error in library: sqlite3.dll.')

end;

procedure SQLite3_LoadLib(Path: WideString);

begin

  LibHandle := LoadLibraryW( PWideChar(Path + 'sqlite3.dll') );
  if LibHandle<>0 then
  begin

  end
  else
  begin
    ShowMessage('sqlite3.dll not loaded.');
  end;
end;

procedure SQLite3_FreeLib();

begin

  FreeLibrary(LibHandle);

end;




function SQLite3_Open(dbname: PAnsiChar; var db: TSqliteDB): integer;
var fSQL : TSQLite3_Open;
begin

  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_open');

  if @fSQL <> nil then
    Result := fSQL(dbname, db)
  else
    DllError('sqlite3_open');
end;

function  SQLite3_Close            (db: TSQLiteDB): integer;
var fSQL : TSQLite3_Close;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_close');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_close');
end;

function  SQLite3_Exec             (db: TSQLiteDB; SQLStatement: PAnsiChar; CallbackPtr: Pointer; Sender: TObject; var ErrMsg: PAnsiChar): integer;
var fSQL : TSQLite3_Exec;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_exec');

  if @fSQL <> nil then
    Result := fSQL(db, SQLStatement, CallbackPtr, Sender, ErrMsg)
  else
    DllError('sqlite3_exec');
end;

function  SQLite3_Version          (): PAnsiChar;
var fSQL : TSQLite3_Version;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_libversion');

  if @fSQL <> nil then
    Result := fSQL()
  else
    DllError('sqlite3_libversion');
end;

function  SQLite3_ErrMsg           (db: TSQLiteDB): PAnsiChar;
var fSQL : TSQLite3_ErrMsg;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_errmsg');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_errmsg');
end;

function  SQLite3_ErrCode          (db: TSQLiteDB): integer;
var fSQL : TSQLite3_ErrCode;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_errcode');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_errcode');
end;

procedure SQLite3_Free             (P: PAnsiChar);
var fSQL : TSQLite3_Free;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_free');

  if @fSQL <> nil then
    fSQL(P)
  else
    DllError('sqlite3_free');

  // FREE LIBRARY!!!
  SQLite3_FreeLib;
end;

function  SQLite3_GetTable         (db: TSQLiteDB; SQLStatement: PAnsiChar; var ResultPtr: TSQLiteResult; var RowCount: Cardinal; var ColCount: Cardinal; var ErrMsg: PAnsiChar): integer;
var fSQL : TSQLite3_GetTable;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_get_table');

  if @fSQL <> nil then
    Result := fSQL(db, SQLStatement, ResultPtr, RowCount, ColCount, ErrMsg)
  else
    DllError('sqlite3_get_table');
end;

procedure SQLite3_FreeTable        (Table: TSQLiteResult);
var fSQL : TSQLite3_FreeTable;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_free_table');

  if @fSQL <> nil then
    fSQL(Table)
  else
    DllError('sqlite3_free_table');
end;

function  SQLite3_Complete         (P: PAnsiChar): boolean;
var fSQL : TSQLite3_Complete;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_complete');

  if @fSQL <> nil then
    Result := fSQL(P)
  else
    DllError('sqlite3_complete');
end;

function  SQLite3_LastInsertRowID  (db: TSQLiteDB): int64;
var fSQL : TSQLite3_LastInsertRowID;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_last_insert_rowid');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_last_insert_rowid');
end;

procedure SQLite3_Interrupt        (db: TSQLiteDB);
var fSQL : TSQLite3_Interrupt;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_interrupt');

  if @fSQL <> nil then
    fSQL(db)
  else
    DllError('sqlite3_interrupt');
end;

procedure SQLite3_BusyHandler      (db: TSQLiteDB; CallbackPtr: Pointer; Sender: TObject);
var fSQL : TSQLite3_BusyHandler;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_busy_handler');

  if @fSQL <> nil then
    fSQL(db, CallbackPtr, Sender)
  else
    DllError('sqlite3_busy_handler');
end;

procedure SQLite3_BusyTimeout      (db: TSQLiteDB; TimeOut: integer);
var fSQL : TSQLite3_BusyTimeout;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_busy_timeout');

  if @fSQL <> nil then
    fSQL(db, TimeOut)
  else
    DllError('sqlite3_busy_timeout');
end;

function  SQLite3_Changes          (db: TSQLiteDB): integer;
var fSQL : TSQLite3_Changes;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_changes');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_changes');
end;

function  SQLite3_TotalChanges     (db: TSQLiteDB): integer;
var fSQL : TSQLite3_TotalChanges;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_total_changes');

  if @fSQL <> nil then
    Result := fSQL(db)
  else
    DllError('sqlite3_total_changes');
end;

function  SQLite3_Prepare          (db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer;
var fSQL : TSQLite3_Prepare;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_prepare');

  if @fSQL <> nil then
    Result := fSQL(db, SQLStatement, nBytes, hStmt, pzTail)
  else
    DllError('sqlite3_prepare');
end;

function  SQLite3_Prepare_v2       (db: TSQLiteDB; SQLStatement: PAnsiChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PAnsiChar): integer;
var fSQL : TSQLite3_Prepare;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_prepare_v2');

  if @fSQL <> nil then
    Result := fSQL(db, SQLStatement, nBytes, hStmt, pzTail)
  else
    DllError('sqlite3_prepare_v2');
end;

function  SQLite3_ColumnCount      (hStmt: TSqliteStmt): integer;
var fSQL : TSQLite3_ColumnCount;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_count');

  if @fSQL <> nil then
    Result := fSQL(hStmt)
  else
    DllError('sqlite3_column_count');
end;

function  SQLite3_ColumnName       (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
var fSQL : TSQLite3_ColumnName;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_name');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_name');
end;

function  SQLite3_ColumnDeclType   (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
var fSQL : TSQLite3_ColumnDeclType;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_decltype');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_decltype');
end;

function  SQLite3_Step             (hStmt: TSqliteStmt): integer;
var fSQL : TSQLite3_Step;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_step');

  if @fSQL <> nil then
    Result := fSQL(hStmt)
  else
    DllError('sqlite3_step');
end;

function  SQLite3_DataCount        (hStmt: TSqliteStmt): integer;
var fSQL : TSQLite3_DataCount;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_data_count');

  if @fSQL <> nil then
    Result := fSQL(hStmt)
  else
    DllError('sqlite3_data_count');
end;


function  SQLite3_ColumnBlob       (hStmt: TSqliteStmt; ColNum: integer): pointer;
var fSQL : TSQLite3_ColumnBlob;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_blob');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_blob');
end;

function  SQLite3_ColumnBytes      (hStmt: TSqliteStmt; ColNum: integer): integer;
var fSQL : TSQLite3_ColumnBytes;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_bytes');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_bytes');
end;

function  SQLite3_ColumnDouble     (hStmt: TSqliteStmt; ColNum: integer): double;
var fSQL : TSQLite3_ColumnDouble;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_double');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_double');
end;

function  SQLite3_ColumnInt        (hStmt: TSqliteStmt; ColNum: integer): integer;
var fSQL : TSQLite3_ColumnInt;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_int');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_int');
end;

function  SQLite3_ColumnText       (hStmt: TSqliteStmt; ColNum: integer): pAnsiChar;
var fSQL : TSQLite3_ColumnText;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_text');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_text');
end;

function  SQLite3_ColumnType       (hStmt: TSqliteStmt; ColNum: integer): integer;
var fSQL : TSQLite3_ColumnType;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_type');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_type');
end;

function  SQLite3_ColumnInt64      (hStmt: TSqliteStmt; ColNum: integer): Int64;
var fSQL : TSQLite3_ColumnInt64;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_column_int64');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ColNum)
  else
    DllError('sqlite3_column_int64');
end;

function  SQLite3_Finalize         (hStmt: TSqliteStmt): integer;
var fSQL : TSQLite3_Finalize;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_finalize');

  if @fSQL <> nil then
    Result := fSQL(hStmt)
  else
    DllError('sqlite3_finalize');
end;

function  SQLite3_Reset            (hStmt: TSqliteStmt): integer;
var fSQL : TSQLite3_Reset;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_reset');

  if @fSQL <> nil then
    Result := fSQL(hStmt)
  else
    DllError('sqlite3_reset');
end;


function  SQLite3_Bind_Blob         (hStmt: TSqliteStmt; ParamNum: integer; ptrData: pointer; numBytes: integer; ptrDestructor: pointer): integer;
var fSQL : TSQLite3_Bind_Blob;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_blob');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum, ptrData, numBytes, ptrDestructor)
  else
    DllError('sqlite3_bind_blob');
end;


function  SQLite3_Bind_Double       (hStmt: TSqliteStmt; ParamNum: integer; Data: Double): integer; cdecl;
var fSQL : TSQLite3_Bind_Double;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_double');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum, Data)
  else
    DllError('sqlite3_bind_double');
end;


function  SQLite3_BindInt           (hStmt: TSqLiteStmt; ParamNum: integer; intData: integer): integer; cdecl;
var fSQL : TSQLite3_BindInt;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_int');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum, intData)
  else
    DllError('sqlite3_bind_int');
end;


function  SQLite3_Bind_int64        (hStmt: TSqliteStmt; ParamNum: integer; Data: int64): integer; cdecl;
var fSQL : TSQLite3_Bind_int64;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_int64');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum, Data)
  else
    DllError('sqlite3_bind_int64');
end;


function  SQLite3_Bind_null         (hStmt: TSqliteStmt; ParamNum: integer): integer; cdecl;
var fSQL : TSQLite3_Bind_null;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_null');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum)
  else
    DllError('sqlite3_bind_null');
end;


function  SQLite3_Bind_text         (hStmt: TSqliteStmt; ParamNum: integer;
                                        Data: PAnsiChar; numBytes: integer; ptrDestructor: pointer): integer; cdecl;
var fSQL : TSQLite3_Bind_text;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_text');

  if @fSQL <> nil then
    Result := fSQL(hStmt, ParamNum, Data, numBytes, ptrDestructor)
  else
    DllError('sqlite3_bind_text');
end;


function  SQLite3_Bind_Parameter_Index (hStmt: TSqliteStmt; zName: PAnsiChar): integer; cdecl;
var fSQL : TSQLite3_Bind_Parameter_Index;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_bind_parameter_index');

  if @fSQL <> nil then
    Result := fSQL(hStmt, zName)
  else
    DllError('sqlite3_bind_parameter_index');
end;


function  SQLite3_enable_shared_cache(value: integer): integer;
var fSQL : TSQLite3_enable_shared_cache;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_enable_shared_cache');

  if @fSQL <> nil then
    Result := fSQL(value)
  else
    DllError('sqlite3_enable_shared_cache');
end;

function  SQLite3_create_collation(db: TSQLiteDB; Name: PAnsiChar; eTextRep: integer; UserData: pointer; xCompare: TCollateXCompare): integer;
var fSQL : TSQLite3_create_collation;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_create_collation');

  if @fSQL <> nil then
    Result := fSQL(db, Name, eTextRep, UserData, xCompare)
  else
    DllError('sqlite3_create_collation');
end;

{$WARNINGS ON}


(*
{MY !!!!}
function  SQLite3_table_column_metadata(db: TSQLiteDB; DbName: PAnsiChar; TableName: PAnsiChar; ColumnName: PAnsiChar; var DataType: PAnsiChar; var CollSeq: PAnsiChar; var NotNull: Integer; var PrimaryKey: Integer; var Autoinc: Integer): integer;
var fSQL : TSQLite3_table_column_metadata;
begin
  @fSQL := nil;
  @fSQL := GetProcAddress(LibHandle, 'sqlite3_table_column_metadata');

  if @fSQL <> nil then
    Result := fSQL(db, DbName, TableName, ColumnName, DataType, CollSeq, NotNull, PrimaryKey, Autoinc)
  else
    DllError('sqlite3_table_column_metadata');
end;
*)


end.
