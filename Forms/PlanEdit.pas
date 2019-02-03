unit PlanEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls;

type
  TfrmPlanEdit = class(TForm)
    edtNotifyBeforeBegin: TEdit;
    udNotifyBeforeBegin: TUpDown;
    pnlStation: TPanel;
    lblStation: TLabel;
    pnlDate: TPanel;
    lblDate: TLabel;
    lblProgramBegin: TLabel;
    pnlProgramBegin: TPanel;
    pnlProgramEnd: TPanel;
    lblProgramEnd: TLabel;
    pnlProgramTitle: TPanel;
    lblProgramme: TLabel;
    lblNotifyBeforeBeginUnit: TLabel;
    lblNotifyBeforeBegin: TLabel;
    btnConfirmPlan: TBitBtn;
    btnCancelPlan: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure udNotifyBeforeBeginClick(Sender: TObject; Button: TUDBtnType);
    procedure btnCancelPlanClick(Sender: TObject);
    procedure btnConfirmPlanClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPlanEdit: TfrmPlanEdit;
  AddPlan : Boolean;

implementation

uses General, Convs, uLNG, SQLiteFuncs, SQLiteTable3, TVpDLL, u_lang_ids;

{$R *.dfm}

procedure TfrmPlanEdit.btnCancelPlanClick(Sender: TObject);
var
  sSQL : WideString;
begin

  if AddPlan=False then   // EDIT
  begin
    sSQL := 'DELETE FROM Plan WHERE DataID='+IntToStr(FPlanList_DataID)+';';
    ExecSQLUTF8(sSQL);

    LoadPlan;

    FWindow.ShowBookmark(FWindow.tabWindow.TabIndex);
  end;

  Close;
end;

procedure TfrmPlanEdit.btnConfirmPlanClick(Sender: TObject);
var
  sSQL : WideString;
begin

  if AddPlan=False then   // EDIT
  begin
    sSQL := 'UPDATE Plan SET NotifyBeforeBegin='+IntToStr(udNotifyBeforeBegin.Position)+' WHERE DataID='+IntToStr(FPlanList_DataID);
    ExecSQLUTF8(sSQL);
  end
  else    //ADD NEW
  begin
    sSQL := 'INSERT INTO Plan (DataID, NotifyBeforeBegin, Notified) VALUES (' +
                      IntToStr(FPlanList_DataID) + ', '+
                      IntToStr(udNotifyBeforeBegin.Position) + ', '+
                      IntToStr( 0 ) + ');';
    ExecSQLUTF8(sSQL);
  end;

  LoadPlan;

  FWindow.ShowBookmark(FWindow.tabWindow.TabIndex);

  Close;
end;

procedure TfrmPlanEdit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PlanEditIsShow := False;
end;

procedure TfrmPlanEdit.FormShow(Sender: TObject);
var
  SQLtb     : TSQLiteTable;

begin
  PlanEditIsShow := True;

//  Icon := PluginSkin.Plan.Icon;

  Caption := LNG('MENU ContactMenu', 'EditSchedule', 'Edit schedule');

  lblStation.Caption    := LNG('TEXTS', 'Station', 'Station')+':';
  lblProgramme.Caption  := LNG('TEXTS', 'Programme', 'Programme')+':';
  lblDate.Caption       := LNG('TEXTS', 'Date', 'Date')+':';

  lblProgramBegin.Caption   := LNG('TEXTS', 'Begin', 'Begin')+':';
  lblProgramEnd.Caption     := LNG('TEXTS', 'End', 'End')+':';

  lblNotifyBeforeBegin.Caption := LNG('FORM EditSchedule', 'NotifyBeforeBegin', 'Notify before begin')+':';

  edtNotifyBeforeBegin.Left     := lblNotifyBeforeBegin.Left + lblNotifyBeforeBegin.Width + 4;
  udNotifyBeforeBegin.Left      := edtNotifyBeforeBegin.Left + edtNotifyBeforeBegin.Width;
  lblNotifyBeforeBeginUnit.Left := udNotifyBeforeBegin.Left + udNotifyBeforeBegin.Width + 4;

  lblNotifyBeforeBeginUnit.Caption := QIPPlugin.GetLang(LI_MINUTES);

  btnCancelPlan.Caption := LNG('FORM EditSchedule', 'CancelSchedule', 'Cancel schedule');


  SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Data WHERE ID='+IntToStr(FPlanList_DataID)));

  if SQLtb.Count > 0 then
  begin
    pnlStation.Caption := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['StationID']) );
    pnlDate.Caption := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Date']) );
    pnlProgramTitle.Caption := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
    pnlProgramBegin.Caption := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
  end
  else
  begin
//    showmessage('Porad nenalezen');
  end;

  SQLtb.Free;


  SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Plan WHERE DataID='+IntToStr(FPlanList_DataID)));

  if SQLtb.Count > 0 then
  begin //EDIT
    AddPlan := False;

    udNotifyBeforeBegin.Position := SQLtb.FieldAsInteger(SQLtb.FieldIndex['NotifyBeforeBegin']);
    edtNotifyBeforeBegin.Text := IntToStr( udNotifyBeforeBegin.Position );

    //SQLtb.FieldAsInteger(SQLtb.FieldIndex['Notified'])

    btnConfirmPlan.Caption := LNG('FORM EditSchedule', 'SaveChages', 'Save changes');

    Icon := PluginSkin.Plan_Edit.Icon;
  end
  else
  begin // NEW
    AddPlan := True;

    btnConfirmPlan.Caption := LNG('FORM EditSchedule', 'AddToSchedule', 'Add to schedule');

    Icon := PluginSkin.Plan_Add.Icon;
  end;

  SQLtb.Free;

end;

procedure TfrmPlanEdit.udNotifyBeforeBeginClick(Sender: TObject;
  Button: TUDBtnType);
begin
  edtNotifyBeforeBegin.Text := IntToStr( udNotifyBeforeBegin.Position );
end;

end.
