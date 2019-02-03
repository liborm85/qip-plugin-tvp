unit PlanList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees;

type
  TfrmPlanList = class(TForm)
    vdtData: TVirtualDrawTree;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vdtDataDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPlanList: TfrmPlanList;

implementation

uses General, Convs, uColors, uLNG, u_lang_ids, TVpDLL, XMLFiles, BBCode;

{$R *.dfm}

procedure TfrmPlanList.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  PlanListIsShow := False;
end;

procedure TfrmPlanList.FormShow(Sender: TObject);
begin
  PlanListIsShow := True;

  Icon := PluginSkin.Plan.Icon;

  Caption := LNG('MENU ContactMenu', 'ScheduledProgrammes', 'Scheduled programmes');


  vdtData.DefaultNodeHeight := 5*13;
  vdtData.RootNodeCount := TVpPlan.Count;
  vdtData.Update;

  if vdtData.RootNodeCount > 0 then
  begin
    vdtData.Selected[vdtData.GetFirst] := True;
    vdtData.FocusedNode := vdtData.GetFirst;
  end;

(*  //  Naplanovane porady - kontrola
  idx1:=0;
  while ( idx1 <= TVpPlan.Count - 1 ) do
  begin
    Application.ProcessMessages;

    if TTVpPlan(TVpPlan.Objects[idx1]).Notified = 0 then
    begin
      if TTVpPlan(TVpPlan.Objects[idx1]).DateTime <= Now then
      begin
        QIPPlugin.AddFadeMsg(1, PluginSkin.PluginIcon.Icon.Handle, PLUGIN_NAME,
                             '' + TTVpPlan(TVpPlan.Objects[idx1]).StationID + ' - ' + TTVpPlan(TVpPlan.Objects[idx1]).Name + '  (' + TTVpPlan(TVpPlan.Objects[idx1]).Time + ')'
                              , True, True, 0, 0);

        TTVpPlan(TVpPlan.Objects[idx1]).Notified := 1;

        sSQL := 'UPDATE Plan SET Notified='+IntToStr(TTVpPlan(TVpPlan.Objects[idx1]).Notified)+' WHERE DataID='+IntToStr(TTVpPlan(TVpPlan.Objects[idx1]).DataID);
        ExecSQLUTF8(sSQL);
      end;

    end;

    Inc(idx1);
  end;         *)


end;

procedure TfrmPlanList.vdtDataDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  R, RectD : TRect;
  idxRow : Integer;
  sText : WideString;

begin

  with Sender as TVirtualDrawTree, PaintInfo do
  begin

    SetBkMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);

    {    Dec(R.Right);
    Dec(R.Bottom);  }

    //Malovat od zacatku (ne jako TreeView (spojovaci cary))
    if (Column=0) OR (Column=-1) then
      R.Left  := 0
    else
      R.Left  := R.Left - 8;
    //   a az do konce
    R.Right := R.Right + 4;

    idxRow := Node.Index;

    Canvas.Font.Color := clWindowText;

    if Odd(idxRow) then
      Canvas.Brush.Color := TextToColor(clLine1, QIP_Colors)
    else
      Canvas.Brush.Color := TextToColor(clLine2, QIP_Colors);

    Canvas.FillRect(R);

    if idxRow > TVpPlan.Count - 1 then
      Exit;

{    if TTVpPlan(TVpPlan.Objects[idxRow]).Notified = 1 then
    begin
      Canvas.Brush.Color := clPlanned;

      Canvas.FillRect(R);
    end;       }


          {
    if CL.Strings[idxRow]='CL' then
    begin
      Canvas.Draw(6, 1, PluginSkin.IconProgram.Image.Picture.Graphic)
    end
    else if CL.Strings[idxRow]='CLGuide' then
    begin
      Canvas.Draw(6, 1, PluginSkin.IconGuide.Image.Picture.Graphic);
    end;  }

//  Canvas.Font.style := [fsBold];
    RectD.Left   := R.Left + 25;
    RectD.Right  := R.Right - 5;
    RectD.Top    := R.Top + 5;
    RectD.Bottom := R.Bottom;

    if TTVpPlan(TVpPlan.Objects[idxRow]).NotifyBeforeBegin=0 then
    begin
      BBCodeDrawText(Canvas, '[b]'+TTVpPlan(TVpPlan.Objects[idxRow]).Name+'[/b][br]'+
                           ''+FormatDateTime('mm.dd.yyyy hh:nn:ss', TTVpPlan(TVpPlan.Objects[idxRow]).DateTime)+'[br]'+
                           '[i]'+TTVpPlan(TVpPlan.Objects[idxRow]).StationID+'[/i]'
                  , RectD, True, QIP_Colors);
    end
    else
    begin
      BBCodeDrawText(Canvas, '[b]'+TTVpPlan(TVpPlan.Objects[idxRow]).Name+'[/b][br]'+
                           ''+FormatDateTime('mm.dd.yyyy hh:nn:ss', TTVpPlan(TVpPlan.Objects[idxRow]).DateTime)+'[br]'+
                           '[i]'+TTVpPlan(TVpPlan.Objects[idxRow]).StationID+'[/i][br]'+
                           ''+LNG('FORM EditSchedule', 'NotifyBeforeBegin', 'Notify before begin')+': [b]'+IntToStr( TTVpPlan(TVpPlan.Objects[idxRow]).NotifyBeforeBegin )+'[/b] ' + QIPPlugin.GetLang(LI_MINUTES)
                  , RectD, True, QIP_Colors);
    end;

            (*
    sText :=  TTVpPlan(TVpPlan.Objects[idxRow]).Name;
    Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectD, DT_SINGLELINE + DT_NOPREFIX{, False});


    Canvas.Font.style := [fsBold];
    RectD.Left   := R.Left + 25;
    RectD.Right  := R.Right - 5;
    RectD.Top    := R.Top + 5 + 16;
    RectD.Bottom := R.Bottom;

    sText := TTVpPlan(TVpPlan.Objects[idxRow]).Time + '  ' + TTVpPlan(TVpPlan.Objects[idxRow]).Date + '  /  '  +  TTVpPlan(TVpPlan.Objects[idxRow]).StationID + '  oznámit ' + IntToStr( TTVpPlan(TVpPlan.Objects[idxRow]).NotifyBeforeBegin ) + ' min pøed';
    Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectD, DT_SINGLELINE + DT_NOPREFIX{, False});
                       *)


    // Malovat focus
    if (Column = FocusedColumn) and (Node = FocusedNode) then
    begin
      DrawFocusRect(Canvas.Handle, R);
    end;


  end;

end;

end.
