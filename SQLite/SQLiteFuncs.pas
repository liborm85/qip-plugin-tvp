unit SQLiteFuncs;

interface

uses
  SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls,
  SQLiteTable3;

type
  { Table Columns  }
  TSLTableColumns = class
  public
    ColumnName        : WideString;
    ColumnType        : WideString;
    tmpColumnExists   : Boolean;
  end;

  procedure ExecSQLUTF8(sSQL: WideString);
  procedure CheckTable(TableName: WideString; TableColumns: TStringList);
  procedure AddColumnSL(ColumnName: WideString; ColumnType: WideString; var TabCols: TStringList);

var
  SQLdb     : TSQLiteDatabase;
  SQLdbPath : WideString;

implementation

uses Convs;

procedure ExecSQLUTF8(sSQL: WideString);
begin
  SQLdb.ExecSQL(WideString2UTF8(sSQL));
end;


procedure CheckTable(TableName: WideString; TableColumns: TStringList);
var sSQL      : WideString;
    SQLtb     : TSQLiteTable;
    i         : Integer;
    sSQLColumns : WideString;

Label 1;
begin

  if SQLdb.TableExists(TableName) then  //existuje tabulka?
  begin   //kontrola sloupcu
    SQLtb := SQLdb.GetTable(WideString2UTF8('PRAGMA table_info('+TableName+')'));
    {try   }
      if SQLtb.Count > 0 then
      begin
        //display first row

        while not SQLtb.EOF do
        begin
          Application.ProcessMessages;

          i:=0;
          while ( i<= TableColumns.Count - 1 ) do
          begin

            if TSLTableColumns(TableColumns.Objects[i]).ColumnName = SQLtb.FieldAsString(1) then
            begin
              TSLTableColumns(TableColumns.Objects[i]).tmpColumnExists := True;
              break;
            end;

            Inc(i);
          end;



          SQLtb.Next;
        end;

      end;

    { finally     }
      SQLtb.Free;
    { end;   }


    i:=0;
    while ( i<= TableColumns.Count - 1 ) do
    begin

      if TSLTableColumns(TableColumns.Objects[i]).tmpColumnExists = False then
      begin
        sSQL := 'ALTER TABLE '+TableName+' ADD COLUMN ['+TSLTableColumns(TableColumns.Objects[i]).ColumnName+'] '+TSLTableColumns(TableColumns.Objects[i]).ColumnType+'; AFTER ['+TSLTableColumns(TableColumns.Objects[i-1]).ColumnName+'];';
        ExecSQLUTF8(sSQL);
      end;

      Inc(i);
    end;

  end
  else
  begin   //vytvoreni tabulky
    sSQLColumns := '';

    i:=0;
    while ( i<= TableColumns.Count - 1 ) do
    begin
      Application.ProcessMessages;

      if sSQLColumns <> '' then
        sSQLColumns := sSQLColumns + ', ';

      sSQLColumns := sSQLColumns + '['+TSLTableColumns(TableColumns.Objects[i]).ColumnName+']' + ' ' + TSLTableColumns(TableColumns.Objects[i]).ColumnType;

      Inc(i);
    end;


    sSQL := 'CREATE TABLE '+TableName+' ('+sSQLColumns+')';
    ExecSQLUTF8(sSQL);

  end;

end;

procedure AddColumnSL(ColumnName: WideString; ColumnType: WideString; var TabCols: TStringList);
var hIndex: Integer;
begin
  if ColumnType='INTEGER' then
    ColumnType := ColumnType +' NOT NULL default '+''''+'0'+''''
  else if ColumnType='TEXT' then
    ColumnType := ColumnType +' NOT NULL default '+''''+'''';

  TabCols.Add('COLUMN');
  hIndex:= TabCols.Count - 1;
  TabCols.Objects[hIndex] := TSLTableColumns.Create;
  TSLTableColumns(TabCols.Objects[hIndex]).ColumnName := ColumnName;
  TSLTableColumns(TabCols.Objects[hIndex]).ColumnType := ColumnType;
end;

end.
