unit PhryGauge;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls;

type
  TPhryGaugeKind = (gkText, gkHorizontalBar, gkVerticalBar, gkPie, gkNeedle);
  TTextStyle = (tsNoText, tsShowAll, tsShowSum);

  TPhryGaugeProgress = class(TCollectionItem)
  public
    Color :TColor;
    Progress :integer;
  end;

  TPhryGauge = class(TGraphicControl)
  private
    { Private declarations }
    FMinValue: Longint;
    FMaxValue: Longint;
    FKind: TPhryGaugeKind;
    FTextStyle: TTextStyle;
    FBorderStyle: TBorderStyle;
    FBackColor: TColor;
    FProgresses: TCollection;
    FSplitAfter: byte;
    procedure PaintBackground(AnImage: TBitmap);
    procedure PaintAsText(AnImage: TBitmap; PaintRect: TRect; index: byte);
    procedure PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
    procedure SeTPhryGaugeKind(Value: TPhryGaugeKind);
    procedure SetTextStyle(Value: TTextStyle);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetBackColor(Value: TColor);
    procedure SetMinValue(Value: Longint);
    procedure SetMaxValue(Value: Longint);
    function GetPercentDone(index: byte): Longint;
    function GetProgressCount: byte;
    procedure SetProgressCount(Value: byte);
    function GetProgress(index: byte): Longint;
    procedure SetProgress(index: byte; Value: Longint);
    function GetColor(index: byte): TColor;
    procedure SetColor(index: byte; Value: TColor);
    procedure SetSplitAfter(Value: byte);
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property PercentDone[index: byte]: Longint read GetPercentDone;
    property ProgressCount: byte read GetProgressCount write SetProgressCount;
    property Progress[index: byte]: Longint read GetProgress write SetProgress;
    property Colors[index: byte]: TColor read GetColor write SetColor;
    procedure Blit(Surface: TCanvas; R:TRect);
  published
    { Published declarations }
    property Align;
    property Anchors;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property Kind: TPhryGaugeKind read FKind write SeTPhryGaugeKind default gkHorizontalBar;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
    property MaxValue: Longint read FMaxValue write SetMaxValue default 100;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SplitAfter: byte read FSplitAfter write SetSplitAfter default 0;
    property TextStyle: TTextStyle read FTextStyle write SetTextStyle default tsShowSum;
    property Visible;
  end;

procedure Register;

implementation

uses Consts;

type
  TBltBitmap = class(TBitmap)
    procedure MakeLike(ATemplate: TBitmap);
  end;

{ TBltBitmap }

procedure TBltBitmap.MakeLike(ATemplate: TBitmap);
begin
  Width := ATemplate.Width;
  Height := ATemplate.Height;
  Canvas.Brush.Color := clWindowFrame;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, Width, Height));
end;

{ This function solves for x in the equation "x is y% of z". }
function SolveForX(Y, Z: Longint): Longint;
begin
  Result := Longint(Trunc( Z * (Y * 0.01) ));
end;

{ This function solves for y in the equation "x is y% of z". }
function SolveForY(X, Z: Longint): Longint;
begin
  if Z = 0 then Result := 0
  else Result := Longint(Trunc( (X * 100.0) / Z ));
end;

{ TPhryGauge }

constructor TPhryGauge.Create(AOwner: TComponent);

var
  Progress :TPhryGaugeProgress;

begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed, csOpaque];
  { default values }
  FMinValue := 0;
  FMaxValue := 100;
  FKind := gkHorizontalBar;
  FTextStyle := tsShowSum;
  FBorderStyle := bsSingle;
  FBackColor := clWhite;
  FProgresses := TCollection.Create(TPhryGaugeProgress);
  Progress := TPhryGaugeProgress(FProgresses.Add);
  Progress.Color := clBlack;
  Progress.Progress := 0;
  Width := 100;
  Height := 100;
end;

function TPhryGauge.GetPercentDone(index: byte): Longint;
var
  i :integer;
  CurValue :Longint;

begin
  CurValue := 0;
  if index > 0 then
    CurValue := Progress[index] - FMinValue
  else
    for i := 1 to ProgressCount do
      inc(CurValue, Progress[i] - FMinValue);

  Result := SolveForY(CurValue, FMaxValue - FMinValue);
end;

procedure TPhryGauge.Paint;
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;
begin
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;
      PaintBackground(TheImage);
      PaintRect := ClientRect;
      if FBorderStyle = bsSingle then InflateRect(PaintRect, -1, -1);
      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        case FKind of
          gkText: PaintAsNothing(OverlayImage, PaintRect);
          gkHorizontalBar, gkVerticalBar: PaintAsBar(OverlayImage, PaintRect);
          gkPie: PaintAsPie(OverlayImage, PaintRect);
          gkNeedle: PaintAsNeedle(OverlayImage, PaintRect);
        end;
        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
      finally
        OverlayImage.Free;
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;

procedure TPhryGauge.Blit(Surface :TCanvas; R :TRect);
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;
begin
  with Surface do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := R.Bottom - R.Top + 1;
      TheImage.Width := R.Right - R.Left + 1;
      PaintBackground(TheImage);
      PaintRect := TheImage.Canvas.ClipRect;
      if FBorderStyle = bsSingle then InflateRect(PaintRect, -1, -1);
      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        case FKind of
          gkText: PaintAsNothing(OverlayImage, PaintRect);
          gkHorizontalBar, gkVerticalBar: PaintAsBar(OverlayImage, PaintRect);
          gkPie: PaintAsPie(OverlayImage, PaintRect);
          gkNeedle: PaintAsNeedle(OverlayImage, PaintRect);
        end;
        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
      finally
        OverlayImage.Free;
      end;
      Surface.CopyMode := cmSrcCopy;
      Surface.Draw(R.Left, R.Top, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;

procedure TPhryGauge.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmBlackness;
    ARect := Rect(0, 0, AnImage.Width, AnImage.Height);
    CopyRect(ARect, Animage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TPhryGauge.PaintAsText(AnImage: TBitmap; PaintRect: TRect; index :byte);
var
  S: string;
  X, Y: Integer;
  OverRect: TBltBitmap;
begin
  OverRect := TBltBitmap.Create;
  try
    OverRect.MakeLike(AnImage);
    PaintBackground(OverRect);
    S := Format('%d%%', [PercentDone[index]]);
    with OverRect.Canvas do
    begin
      Brush.Style := bsClear;
      Font := Self.Font;
      Font.Color := clWhite;
      with PaintRect do
      begin
        X := Left + (Right - Left + 1 - TextWidth(S)) div 2;
        Y := Top + (Bottom - Top + 1 - TextHeight(S)) div 2;
      end;
      TextRect(PaintRect, X, Y, S);
    end;
    AnImage.Canvas.CopyMode := cmSrcInvert;
    AnImage.Canvas.Draw(0, 0, OverRect);
  finally
    OverRect.Free;
  end;
end;

procedure TPhryGauge.PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
begin
  with AnImage do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(PaintRect);
  end;
  if (TextStyle = tsShowSum) or (TextStyle = tsShowAll) then
    PaintAsText(AnImage, PaintRect, 0);
end;

procedure TPhryGauge.PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
var
  FillSize, FullSize: Longint;
  W, H: Integer;
  i, splitter :integer;
  r :TRect;
begin
  W := PaintRect.Right - PaintRect.Left + 1;
  H := PaintRect.Bottom - PaintRect.Top + 1;
  with AnImage.Canvas do
  begin
    Brush.Color := BackColor;
    FillRect(PaintRect);
    Pen.Width := 1;
    case FKind of
      gkHorizontalBar:
        begin
          Splitter := FSplitAfter;
          if (Splitter = 0) or (Splitter > ProgressCount) then
            Splitter := ProgressCount;

          FullSize := 0;
          for i := 1 to Splitter do
          begin
            Pen.Color := Colors[i];
            Brush.Color := Colors[i];
            FillSize := SolveForX(PercentDone[i], W);
            if FillSize + FullSize >= W then FillSize := W - FullSize - 1;
            if FillSize > 0 then
            begin
              if i = ProgressCount then inc(FillSize);
              r := Rect(PaintRect.Left + FullSize, PaintRect.Top,
                        PaintRect.Left + FullSize + FillSize, H);
              FillRect(r);
              if TextStyle = tsShowAll then
                PaintAsText(AnImage, r, i);
              inc(FullSize, FillSize);
            end;
          end;

          FullSize := 0;
          for i := Splitter + 1 to ProgressCount do
          begin
            Pen.Color := Colors[i];
            Brush.Color := Colors[i];
            FillSize := SolveForX(PercentDone[i], W);
            if FillSize + FullSize >= W then FillSize := W - FullSize - 1;
            if FillSize > 0 then
            begin
              if i = ProgressCount then inc(FillSize);
              r := Rect(W - FillSize - FullSize, PaintRect.Top, W - FullSize, H);
              FillRect(r);
              if TextStyle = tsShowAll then
                PaintAsText(AnImage, r, i);
              inc(FullSize, FillSize);
            end;
          end;
          if TextStyle = tsShowSum then
            PaintAsText(AnImage, PaintRect, 0);
        end;
      gkVerticalBar:
        begin
          Splitter := FSplitAfter;
          if (Splitter = 0) or (Splitter > ProgressCount) then
            Splitter := ProgressCount;

          FullSize := 0;
          for i := 1 to Splitter do
          begin
            Pen.Color := Colors[i];
            Brush.Color := Colors[i];
            FillSize := SolveForX(PercentDone[i], H);
            if FillSize + FullSize >= H then FillSize := H - FullSize - 1;
            if FillSize > 0 then
            begin
              if i = ProgressCount then inc(FillSize);
              r := Rect(PaintRect.Left, H - FillSize - FullSize, W, H - FullSize);
              FillRect(r);
              if TextStyle = tsShowAll then
                PaintAsText(AnImage, r, i);
              inc(FullSize, FillSize);
            end;
          end;
          if TextStyle = tsShowSum then
            PaintAsText(AnImage, PaintRect, 0);

          FullSize := 0;
          for i := Splitter + 1 to ProgressCount do
          begin
            Pen.Color := Colors[i];
            Brush.Color := Colors[i];
            FillSize := SolveForX(PercentDone[i], H);
            if FillSize + FullSize >= H then FillSize := H - FullSize - 1;
            if FillSize > 0 then
            begin
              if i = ProgressCount then inc(FillSize);
              r := Rect(PaintRect.Left, PaintRect.Top + FullSize,
                        W, PaintRect.Top + FullSize + FillSize);
              FillRect(r);
              if TextStyle = tsShowAll then
                PaintAsText(AnImage, r, i);
              inc(FullSize, FillSize);
            end;
          end;
          if TextStyle = tsShowSum then
            PaintAsText(AnImage, PaintRect, 0);
        end;
    end;
  end;
end;

procedure TPhryGauge.PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX, MiddleY: Integer;
  Angle1, Angle2: Double;
  W, H: Integer;
  i :integer;
  FullPercent, FillPercent :Longint;
begin
  W := PaintRect.Right - PaintRect.Left;
  H := PaintRect.Bottom - PaintRect.Top;
  if FBorderStyle = bsSingle then
  begin
    Inc(W);
    Inc(H);
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := clBlack;
    Pen.Width := 1;
    Ellipse(PaintRect.Left, PaintRect.Top, W, H);
    if PercentDone[0] > 0 then
    begin
      FullPercent := 0;
      MiddleX := W div 2;
      MiddleY := H div 2;
      for i := 1 to ProgressCount do
      begin
        Brush.Color := Colors[i];
        Pen.Color := Colors[i];
        FillPercent := PercentDone[i] + FullPercent;
        Angle1 := (Pi * ((FullPercent / 50) + 0.5));
        Angle2 := (Pi * ((FillPercent / 50) + 0.5));
        Pie(PaintRect.Left, PaintRect.Top, W, H,
          Integer(Round(MiddleX * (1 - Cos(Angle2)))),
          Integer(Round(MiddleY * (1 - Sin(Angle2)))),
          Integer(Round(MiddleX * (1 - Cos(Angle1-0.01)))),
          Integer(Round(MiddleY * (1 - Sin(Angle1-0.01)))));
        FullPercent := FillPercent;
      end;
    end;
  end;
  if (TextStyle = tsShowSum) or (TextStyle = tsShowAll) then
    PaintAsText(AnImage, PaintRect, 0);
end;

procedure TPhryGauge.PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX: Integer;
  Angle: Double;
  X, Y, W, H: Integer;
  i :integer;
  FillPercent :Longint;
begin
  with PaintRect do
  begin
    X := Left;
    Y := Top;
    W := Right - Left;
    H := Bottom - Top;
    if FBorderStyle = bsSingle then
    begin
      Inc(W);
      Inc(H);
    end;
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := clBlack;
    Pen.Width := 1;
    Pie(X, Y, W, H * 2 - 1, X + W, PaintRect.Bottom - 1, X, PaintRect.Bottom - 1);
    MoveTo(X, PaintRect.Bottom);
    LineTo(X + W, PaintRect.Bottom);
    if PercentDone[0] > 0 then
    begin
      MiddleX := Width div 2;
      for i := 1 to ProgressCount do
      begin
        Pen.Color := Colors[i];
        MoveTo(MiddleX, PaintRect.Bottom - 1);
        FillPercent := PercentDone[i];
        Angle := (Pi * ((FillPercent / 100)));
        LineTo(Integer(Round(MiddleX * (1 - Cos(Angle)))),
          Integer(Round((PaintRect.Bottom - 1) * (1 - Sin(Angle)))));
      end;
    end;
  end;
  if (TextStyle = tsShowSum) or (TextStyle = tsShowAll) then
    PaintAsText(AnImage, PaintRect, 0);
end;

procedure TPhryGauge.SeTPhryGaugeKind(Value: TPhryGaugeKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetTextStyle(Value: TTextStyle);
begin
  if Value <> FTextStyle then
  begin
    FTextStyle := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetMinValue(Value: Longint);
var
  i :integer;
begin
  if Value <> FMinValue then
  begin
    if Value > FMaxValue then
      if not (csLoading in ComponentState) then
        raise EInvalidOperation.CreateFmt(SOutOfRange, [-MaxInt, FMaxValue - 1]);
    FMinValue := Value;
    for i := 1 to ProgressCount do
      if Progress[i] < Value then Progress[i] := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetMaxValue(Value: Longint);
var
  i :integer;
begin
  if Value <> FMaxValue then
  begin
    if Value < FMinValue then
      if not (csLoading in ComponentState) then
        raise EInvalidOperation.CreateFmt(SOutOfRange, [FMinValue + 1, MaxInt]);
    FMaxValue := Value;
    for i := 1 to ProgressCount do
      if Progress[i] > Value then Progress[i] := Value;
    Refresh;
  end;
end;

function TPhryGauge.GetProgressCount: byte;
begin
  Result := FProgresses.Count;
end;

procedure TPhryGauge.SetProgressCount(Value: byte);
var
  i :integer;
  TempPercent: Longint;
  TheProgress :TPhryGaugeProgress;
begin
  TempPercent := PercentDone[0];
  if Value > FProgresses.Count then
    for i := ProgressCount + 1 to Value do
    begin
      TheProgress := TPhryGaugeProgress(FProgresses.Add);
      TheProgress.Color := clBlack;
      TheProgress.Progress := FMinValue;
    end
  else
    while (FProgresses.Count > 1) and (Value < FProgresses.Count) do
      FProgresses.Items[FProgresses.Count-1].Free;
  if TempPercent <> PercentDone[0] then
    Refresh;
end;

function TPhryGauge.GetProgress(index: byte): Longint;
var
  TheProgress :TPhryGaugeProgress;
begin
  TheProgress := nil;
  if index > 0 then
    TheProgress := TPhryGaugeProgress(FProgresses.Items[index-1]);
  if TheProgress = nil then
    Result := FMinValue
  else
    Result := TheProgress.Progress;
end;

procedure TPhryGauge.SetProgress(index: byte; Value: Longint);
var
  TempPercent: Longint;
  TheProgress :TPhryGaugeProgress;
begin
  TempPercent := PercentDone[0];  { remember where we were }
  if Value < FMinValue then
    Value := FMinValue
  else if Value > FMaxValue then
    Value := FMaxValue;
  if index > FProgresses.Count then
    SetProgressCount(index);
  TheProgress := TPhryGaugeProgress(FProgresses.Items[index-1]);
  if TheProgress.Progress <> Value then
  begin
    TheProgress.Progress := Value;
    if PercentDone[0] > 100 then
      TheProgress.Progress := SolveForX(100 - TempPercent, FMaxValue - FMinValue) + FMinValue;
    if TempPercent <> PercentDone[0] then { only refresh if percentage changed }
      Refresh;
  end;
end;

function TPhryGauge.GetColor(index: byte): TColor;
var
  TheProgress :TPhryGaugeProgress;
begin
  TheProgress := nil;
  if index > 0 then
    TheProgress := TPhryGaugeProgress(FProgresses.Items[index-1]);
  if TheProgress = nil then
    Result := clBlack
  else
    Result := TheProgress.Color;
end;

procedure TPhryGauge.SetColor(index: byte; Value: TColor);
var
  TheProgress :TPhryGaugeProgress;
begin
  if index > FProgresses.Count then
    SetProgressCount(index);
  TheProgress := TPhryGaugeProgress(FProgresses.Items[index-1]);
  if TheProgress.Color <> Value then
  begin
    TheProgress.Color := Value;
    Refresh;
  end;
end;

procedure TPhryGauge.SetSplitAfter(Value: byte);
begin
  if FSplitAfter <> Value then
  begin
    FSplitAfter := Value;
    Refresh;
  end;
end;

procedure Register;
begin
  RegisterComponents('Phry', [TPhryGauge]);
end;

end.
