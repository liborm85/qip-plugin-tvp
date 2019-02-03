unit ProgramInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmProgramInfo = class(TForm)
    btnMore: TBitBtn;
    lblOrigName: TLabel;
    lblName: TLabel;
    lblPrgSpec: TLabel;
    lblPrgType: TLabel;
    lblInfo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnMoreClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProgramInfo: TfrmProgramInfo;


implementation

uses General,  u_lang_ids, uLNG, uURL, Convs,
     XMLFiles,
     SQLiteFuncs, SQLiteTable3,
     TVpDLL;

var
  infProgram : TTVpProgram;

{$R *.dfm}

procedure TfrmProgramInfo.btnMoreClick(Sender: TObject);
begin
  LinkUrl( infProgram.URL );
end;

procedure TfrmProgramInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ProgramInfoIsShow := False;
end;

procedure TfrmProgramInfo.FormShow(Sender: TObject);
var
  SQLtb     : TSQLiteTable;
begin
  ProgramInfoIsShow := True;

  Icon := PluginSkin.Info.Icon;


  infProgram := TTVpProgram.Create;


  btnMore.Caption := LNG('TEXTS', 'More', 'More')+'...';


  SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Data WHERE ID='+''''+IntToStr(FProgramInfo_ProgramID)+''''));
  if SQLtb.Count > 0 then
  begin

    infProgram.DataID     := SQLtb.FieldAsInteger(SQLtb.FieldIndex['ID']);
    infProgram.Time       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
    infProgram.Name       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
    infProgram.OrigName   := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['OrigName']) );
    infProgram.Info       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Info']) );
    infProgram.InfoImage  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['InfoImage']) );
    infProgram.URL        := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['URL']) );
    infProgram.Specifications := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Specifications']) );
    infProgram.IncDate    := SQLtb.FieldAsInteger(SQLtb.FieldIndex['IncDate']);

    infProgram.Planned    := GetStationPlanned(SQLtb.FieldAsInteger(SQLtb.FieldIndex['ID']));

  end
  else
  begin
//    ShowMessage('Porad nenalezen');
  end;


  SQLtb.Free;

  Caption   := QIPPlugin.GetLang(LI_INFORMATION) + ' - ' + infProgram.Name;

  if infProgram.URL = '' then
    btnMore.Visible := False
  else
    btnMore.Visible := True;

  lblName.Caption     := infProgram.Name;
  lblOrigName.Caption := infProgram.OrigName;

  lblPrgSpec.Caption  := '';
  lblPrgType.Caption  := '';
  lblInfo.Caption     := infProgram.Info;

end;

end.
