unit uImage;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls,
     General, pngimage;

  function LoadImageFromResource(ImageIndex: Integer; hLibrary : THandle): TImage;
  function LoadImageAsIconFromResource(ImageIndex: Integer; hLibrary : THandle): TIcon;
//  function LoadImageAndAsIconResource(ImageIndex: Integer; hLibrary : THandle): TImageIcon;



implementation

uses uIcon;

function LoadImageFromResource(ImageIndex: Integer; hLibrary : THandle): TImage;
var PNG: TPngImage;
begin

  Result := TImage.Create(nil);
  PNG := TPngImage.Create;
  PNG.Transparent := True;
  PNG.LoadFromResourceID(hLibrary, ImageIndex);
  Result.Transparent := True;
  Result.Picture.Assign(PNG);

  PNG.Free;
end;

function LoadImageAsIconFromResource(ImageIndex: Integer; hLibrary : THandle): TIcon;
var img, img2 : TImage;
    R : TRect;
begin
  Result := TIcon.Create;

  img := TImage.Create(nil);
  img2 := TImage.Create(nil);

  img.Transparent := True;
  img2.Transparent := True;
  img := LoadImageFromResource(ImageIndex, hLibrary);


  img2.Picture.Bitmap.Width := 16;
  img2.Picture.Bitmap.Height := 16;

  R.Left   := 0;
  R.Top    := 0;
  R.Right  := 16;
  R.Bottom := 16;
  img2.Canvas.FillRect(R);


  img2.Canvas.Draw(0,0,img.Picture.Graphic);


  Result.Transparent := True;
//  Result := CreateIconFromBitmap(img2.Picture.Bitmap, RGB(255,255,255));
  Result := bmp2ico(img2);

(*  Result := TIcon.Create;

  img := TImage.Create(nil);
  img2 := TImage.Create(nil);
  img.Transparent := True;
  img2.Transparent := True;
  img := LoadImageFromResource(ImageIndex, hLibrary);


  img2.Picture.Bitmap.Width := 16;
  img2.Picture.Bitmap.Height := 16;

  R.Left   := 0;
  R.Top    := 0;
  R.Right  := 16;
  R.Bottom := 16;
  img2.Canvas.FillRect(R);


  img2.Canvas.Draw(0,0,img.Picture.Graphic);

  Result.Transparent := True;
  Result := CreateIconFromBitmap(img2.Picture.Bitmap, RGB(255,255,255));
  //Result := bmp2ico(img2);
*)
end;

(*
function LoadImageAndAsIconResource(ImageIndex: Integer; hLibrary : THandle): TImageIcon;
var{ img,} img2 : TImage;
begin
  Result.Image := TImage.Create(nil);
  Result.Icon  := TIcon.Create;

//  img := TImage.Create(nil);
  img2 := TImage.Create(nil);

  Result.Image.Transparent := True;
  img2.Transparent := True;

  Result.Image := LoadImageFromResource(ImageIndex, hLibrary);

  img2.Picture.Bitmap.Width := 16;
  img2.Picture.Bitmap.Height := 16;

  img2.Canvas.Draw(0,0,Result.Image.Picture.Graphic);

  Result.Image.Transparent := True;
  Result.Icon.Transparent := True;
  Result.Icon := CreateIconFromBitmap(img2.Picture.Bitmap, RGB(255,255,255));

end;
*)





end.
