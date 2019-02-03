unit uIcon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,{ Forms,}
  Dialogs, StdCtrls, ExtCtrls, CommCtrl;

  function bmp2ico(Image: TImage) : TIcon;

  function CreateIconFromBitmap(Bitmap: TBitmap; TransparentColor: TColor): TIcon;
  function ImageToBitmap(Image: TImage): TBitmap;
  function IconToBitmap(Image: TIcon): TBitmap;

  procedure AddIconToStringList(StringList: TStringList; Icon : TIcon; Position: Integer = -1);

  procedure DrawTransparentBmp(Cnv: TCanvas; x,y: Integer; Bmp: TBitmap; clTransparent: TColor);

implementation


function bmp2ico(Image: TImage) : TIcon;
var
  Bmp: TBitmap;
 // Icon: TIcon;
  ImageList: TImageList;
begin
  Bmp := TBitmap.Create;
  Result := TIcon.Create;
  try
    Bmp.Assign(Image.Picture);
    ImageList := TImageList.CreateSize(Bmp.Width, Bmp.Height);

    //32 bit support - transparent atd....
    ImageList.Handle := ImageList_Create(ImageList.Width, ImageList.Height, ILC_COLOR32 or ILC_MASK, ImageList.AllocBy, ImageList.AllocBy);

    try
      ImageList.AddMasked(Bmp, Bmp.TransparentColor);
      ImageList.GetIcon(0, Result);
      //Icon.SaveToFile(FileName);
    finally
      ImageList.Free;
    end;
  finally
    Bmp.Free;
    //Icon.Free;
  end;
end;

function CreateIconFromBitmap(Bitmap: TBitmap; TransparentColor: TColor): TIcon;
begin
  with TImageList.CreateSize(Bitmap.Width, Bitmap.Height) do
  begin
    try
      AllocBy := 1;
      AddMasked(Bitmap, TransparentColor);
      Result := TIcon.Create;
      try
        GetIcon(0, Result);
      except
        Result.Free;
        raise;
      end;
    finally
      Free;
    end;
  end;
end;


function ImageToBitmap(Image: TImage): TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.Width := Image.Picture.Graphic.Width;
    Result.Height := Image.Picture.Graphic.Height;
    Result.Canvas.Draw(0, 0, Image.Picture.Graphic) ;
  finally
    //bmp.Free;
  end;
end;


function IconToBitmap(Image: TIcon): TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.Width := Image.Width;
    Result.Height := Image.Height;
    Result.Canvas.Draw(0, 0, Image);
  finally
    //bmp.Free;
  end;
end;


procedure AddIconToStringList(StringList: TStringList; Icon : TIcon; Position: Integer = -1);
var
  hIndex: Integer;
begin
  // První položka je 0
  if (Position > -1) then
  begin
    while Position >= StringList.Count do
      StringList.Add('');
    hIndex := Position
  end
  else
  begin
    StringList.Add('');
    hIndex := StringList.Count - 1;
  end;

  StringList.Objects[hIndex] := TIcon.Create;
  TIcon(StringList.Objects[hIndex]).Assign(Icon);
end;


procedure DrawTransparentBmp(Cnv: TCanvas; x,y: Integer; Bmp: TBitmap; clTransparent: TColor);
var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  try
    bmpAND := TBitmap.Create;
    bmpAND.Width := Bmp.Width;
    bmpAND.Height := Bmp.Height;
    bmpAND.Monochrome := True;
    oldcol := SetBkColor(Bmp.Canvas.Handle, ColorToRGB(clTransparent));
    BitBlt(bmpAND.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    SetBkColor(Bmp.Canvas.Handle, oldcol);

    bmpINVAND := TBitmap.Create;
    bmpINVAND.Width := Bmp.Width;
    bmpINVAND.Height := Bmp.Height;
    bmpINVAND.Monochrome := True;
    BitBlt(bmpINVAND.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, bmpAND.Canvas.Handle, 0, 0, NOTSRCCOPY);

    bmpXOR := TBitmap.Create;
    bmpXOR.Width := Bmp.Width;
    bmpXOR.Height := Bmp.Height;
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, bmpINVAND.Canvas.Handle, 0, 0, SRCAND);

    bmpTarget := TBitmap.Create;
    bmpTarget.Width := Bmp.Width;
    bmpTarget.Height := Bmp.Height;
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Cnv.Handle, x, y, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    BitBlt(Cnv.Handle, x, y, Bmp.Width, Bmp.Height, bmpTarget.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    bmpXOR.Free;
    bmpAND.Free;
    bmpINVAND.Free;
    bmpTarget.Free;
  end;
end;


end.
