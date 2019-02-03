unit GradientColor;

interface

uses Math,
  SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls;

  procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor) ;
  procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor) ;
  procedure DrawGradient(ACanvas: TCanvas; Rect: TRect;  Horicontal: Boolean; Colors: array of TColor);
implementation


procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor) ;
var
  X:integer;
  dr,dg,db:Extended;
  C1,C2:TColor;
  r1,r2,g1,g2,b1,b2:Byte;
  R,G,B:Byte;
  cnt:integer;
begin
  C1 := FromColor;
  R1 := GetRValue(C1) ;
  G1 := GetGValue(C1) ;
  B1 := GetBValue(C1) ;

  C2 := ToColor;
  R2 := GetRValue(C2) ;
  G2 := GetGValue(C2) ;
  B2 := GetBValue(C2) ;

  dr := (R2-R1) / Rect.Right-Rect.Left;
  dg := (G2-G1) / Rect.Right-Rect.Left;
  db := (B2-B1) / Rect.Right-Rect.Left;

  cnt := 0;
  for X := Rect.Left to Rect.Right-1 do
  begin
    R := R1+Ceil(dr*cnt) ;
    G := G1+Ceil(dg*cnt) ;
    B := B1+Ceil(db*cnt) ;

    Canvas.Pen.Color := RGB(R,G,B) ;
    Canvas.MoveTo(X,Rect.Top) ;
    Canvas.LineTo(X,Rect.Bottom) ;
    inc(cnt) ;
  end;
end;

procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor) ;
var
  Y:integer;
  dr,dg,db:Extended;
  C1,C2:TColor;
  r1,r2,g1,g2,b1,b2:Byte;
  R,G,B:Byte;
  cnt:Integer;
begin
   C1 := FromColor;
   R1 := GetRValue(C1) ;
   G1 := GetGValue(C1) ;
   B1 := GetBValue(C1) ;

   C2 := ToColor;
   R2 := GetRValue(C2) ;
   G2 := GetGValue(C2) ;
   B2 := GetBValue(C2) ;

   dr := (R2-R1) / (Rect.Bottom-Rect.Top);
   dg := (G2-G1) / (Rect.Bottom-Rect.Top);
   db := (B2-B1) / (Rect.Bottom-Rect.Top);

   cnt := 0;
   for Y := Rect.Top to Rect.Bottom-1 do
   begin
      R := R1+Ceil(dr*cnt) ;
      G := G1+Ceil(dg*cnt) ;
      B := B1+Ceil(db*cnt) ;

      Canvas.Pen.Color := RGB(R,G,B) ;
      Canvas.MoveTo(Rect.Left,Y) ;
      Canvas.LineTo(Rect.Right,Y) ;
      Inc(cnt) ;
   end;
end;

procedure DrawGradient(ACanvas: TCanvas; Rect: TRect;
  Horicontal: Boolean; Colors: array of TColor);
type
  RGBArray = array[0..2] of Byte;
var
  x, y, z, stelle, mx, bis, faColorsh, mass: Integer;
  Faktor: double;
  A: RGBArray;
  B: array of RGBArray;
  merkw: integer;
  merks: TPenStyle;
  merkp: TColor;
begin
  mx := High(Colors);
  if mx > 0 then
  begin
    if Horicontal then
      mass := Rect.Right - Rect.Left
    else
      mass := Rect.Bottom - Rect.Top;
    SetLength(b, mx + 1);
    for x := 0 to mx do
    begin
      Colors[x] := ColorToRGB(Colors[x]);
      b[x][0] := GetRValue(Colors[x]);
      b[x][1] := GetGValue(Colors[x]);
      b[x][2] := GetBValue(Colors[x]);
    end;
    merkw := ACanvas.Pen.Width;
    merks := ACanvas.Pen.Style;
    merkp := ACanvas.Pen.Color;
    ACanvas.Pen.Width := 1;
    ACanvas.Pen.Style := psSolid;
    faColorsh := Round(mass / mx);
    for y := 0 to mx - 1 do
    begin
      if y = mx - 1 then
        bis := mass - y * faColorsh - 1
      else
        bis := faColorsh;
      for x := 0 to bis do
      begin
        Stelle := x + y * faColorsh;
        faktor := x / bis;
        for z := 0 to 3 do
          a[z] := Trunc(b[y][z] + ((b[y + 1][z] - b[y][z]) * Faktor));
        ACanvas.Pen.Color := RGB(a[0], a[1], a[2]);
        if Horicontal then
        begin
          ACanvas.MoveTo(Rect.Left + Stelle, Rect.Top);
          ACanvas.LineTo(Rect.Left + Stelle, Rect.Bottom);
        end
        else
        begin
          ACanvas.MoveTo(Rect.Left, Rect.Top + Stelle);
          ACanvas.LineTo(Rect.Right, Rect.Top + Stelle);
        end;
      end;
    end;
    b := nil;
    ACanvas.Pen.Width := merkw;
    ACanvas.Pen.Style := merks;
    ACanvas.Pen.Color := merkp;
  end
 { else
    // Please specify at least two colors
    raise EMathError.Create('Es müssen mindestens zwei Farben angegeben werden.');}
end;



end.
