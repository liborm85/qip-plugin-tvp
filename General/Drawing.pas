unit Drawing;

interface

uses
  Windows, Graphics, Menus;

  procedure Menu_MeasureMenu(Sender: TObject;
    ACanvas: TCanvas; var Width, Height: Integer);
  procedure Menu_DrawMenu(Sender: TObject;
    ACanvas: TCanvas; ARect: TRect; Selected: Boolean);

implementation

uses General;

procedure DrawItemText(X: integer; ACanvas: TCanvas; ARect: TRect;Text: string);
begin
 ARect.Left := X;
 DrawTextW(ACanvas.Handle, PChar(Text), -1, ARect, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DT_HIDEPREFIX {or DT_NOPREFIX} );
end;

procedure Menu_MeasureMenu(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  R : TRect;
begin
  DrawTextW(ACanvas.Handle, PWideChar((Sender as TMenuItem).Caption), Length((Sender as TMenuItem).Caption), R, DT_CALCRECT  {+DT_SINGLELINE});

  Width  := (R.Right - R.Left) + (2*19);

  Height := 19;
end;

procedure Menu_DrawMenu(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
 sText : WideString;
 iImageIndex : Integer;
 bEnabled : Boolean;
begin
  ARect.Left := 0;

  sText := TMenuItem(Sender).Caption;
  iImageIndex := TMenuItem(Sender).ImageIndex;
  bEnabled := TMenuItem(Sender).Enabled;

  if Selected then
  begin
    ACanvas.Brush.Color := $FFE0C2{QIP_Colors.Focus};
    ACanvas.FillRect(ARect);
    ACanvas.Brush.Color := $FF9933{QIP_Colors.FocusFrame};
    ACanvas.FrameRect(ARect);
  end
  else
  begin
    ACanvas.Brush.Color := clMenu;
    ACanvas.FillRect(ARect);
    ACanvas.Brush.Color := clMenu;
    ACanvas.FrameRect(ARect);
  end;

  if iImageIndex <> -1 then
  begin
    DrawIconEx(Acanvas.Handle,4,ARect.Top + 2, TIcon(PluginSkin.MenuIcons.Objects[iImageIndex]).Handle, 16, 16, 0, 0, DI_NORMAL);
  end
  else
  begin
    if (Sender as TmenuItem).Checked then
      DrawIconEx(Acanvas.Handle,4,ARect.Top + 2, PluginSkin.CheckMenuItem.Handle, 16, 16, 0, 0, DI_NORMAL)
  end;


  SetBkMode(ACanvas.Handle, TRANSPARENT);


  if sText = '-' then
  begin
    ACanvas.Pen.Color := clSilver;
    ACanvas.MoveTo(ARect.Left+2, ARect.Top + ((ARect.Bottom - ARect.Top) div 2));
    ACanvas.LineTo(ARect.Right-2, ARect.Top + ((ARect.Bottom - ARect.Top) div 2));
    ACanvas.Pen.Color := clWhite;
    ACanvas.MoveTo(ARect.Left+2, ARect.Top + ((ARect.Bottom - ARect.Top) div 2)+1);
    ACanvas.LineTo(ARect.Right-2, ARect.Top + ((ARect.Bottom - ARect.Top) div 2)+1);
  end
  else
  begin
    if bEnabled = False then
    begin
      ACanvas.Font.Color := clGrayText;
      ACanvas.Font.Style := [{fsBold}];
    end
    else
    begin
      ACanvas.Font.Color := clWindowText;
      ACanvas.Font.Style := [{fsBold}];
    end;

    DrawItemText(27,ACanvas,ARect,sText);
  end;

end;

end.
