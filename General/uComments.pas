unit uComments;

interface

uses
  SysUtils, Classes, Dialogs, Graphics, Windows, Forms, ExtCtrls, Controls,
  fQIPPlugin,  StdCtrls;

  procedure AddComments(Form: TForm);

implementation

uses General, uToolTip, u_lang_ids;


procedure AutoSize(Obj: TControl);
const
  //DelkaChkBox = 16; // pro ne-klasickej vzhled
  DelkaChkBox = 18;
var
  PomLabel: TLabel;
begin
  PomLabel := TLabel.Create(nil);
  PomLabel.Font := TLabel(Obj).Font;
  PomLabel.Caption := TLabel(Obj).Caption;
  PomLabel.AutoSize := True;
  if UpperCase(Obj.ClassName) = 'TCHECKBOX' then
    Obj.Width := PomLabel.Width + DelkaChkBox;
  (*else
    Obj.Width := PomLabel.Width;*)
  PomLabel.Free;
end;

procedure DeleteComments(Form: TForm);
var
  i: integer;
begin
  i := 0;
  while i <= Form.ComponentCount - 1 do
    begin
      if (StrPos( PChar(TControl(Form.Components[i]).Name), PChar('Commentary') ) <> nil) then
        begin
          TControl(Form.Components[i]).Destroy;
          Dec(i,2);
        end;
      Inc(i);
    end;
end;


procedure AddComments(Form: TForm);
var
  i, j, x, CommentNum: integer;
  Comment: {TImage}TPanel;
  CommentImage: TImage;
  sText: string;
  Typy: array[0..1] of ShortString;
  iZacatek, iKonec, pom: Integer;

label
  0, 1, 2;
begin
  Typy[0] := 'TLabel';
  Typy[1] := 'TCheckBox';

  DeleteComments(Form);
  CreateToolTips(Form.Handle);
  CommentNum := 0;

  for i:=0 to Form.ComponentCount - 1 do
    begin

      for j:=0 to High(Typy) do
        begin
          if UpperCase(TControl(Form.Components[i]).ClassName) = UpperCase(Typy[j]) then
            begin
              AutoSize(TControl(Form.Components[i]));
              if ShowComments then
                GoTo 1;
            end;
        end;
      GoTo 2;
      1:
      if (TControl(Form.Components[i]).Hint <> '') then
        begin
          TControl(Form.Components[i]).ShowHint := False;

          Comment := TPanel.Create(Form);
          CommentImage := TImage.Create(Comment);

          try
            Comment.Parent := TControl(Form.Components[i]).Parent;
          except
            Comment.Parent := Form;
          end;

          CommentImage.Parent := Comment;
          Comment.BevelOuter := bvNone;

          Comment.Width := 16; //musí být uèinìno ruènì, nevím proè
          Comment.Height := 16;
          Comment.Left := TControl(Form.Components[i]).Left + TControl(Form.Components[i]).Width;
          Comment.Top  := TControl(Form.Components[i]).Top + Round( (TControl(Form.Components[i]).Height - Comment.Height) / 2 );

          CommentImage.Picture.Assign(PluginSkin.Comment.Image.Picture);
          CommentImage.Left := 0;
          CommentImage.Top  := 0;
          CommentImage.Width := Comment.Width;
          CommentImage.Height := Comment.Height;

          sText := TControl(Form.Components[i]).Hint;

          // uprav zobrazení HINT
          x := 35;
          j := x;
          while Length(sText) > j do
          begin
            if sText[j] = ' ' then
            begin
              sText[j] := #13;
              inc(j,x-1);
            end;

            (*//* Nalezení zaèátku a konce slova a urèení, kde je nejblíže mezera od body zalomení
            pom := j;
            while (sText[pom] <> ' ') or (pom > 0) do
            begin
              Dec(pom);
            end;
            iZacatek := j - pom;

            pom := j;
            while (sText[pom] <> ' ') or (Length(sText) < pom) do
            begin
              Inc(pom);
            end;
            iKonec := pom - j;

            if j - iZacatek >= iKonec - j then
            begin
              sText[iKonec] := #13;
              j := iKonec;
            end
            else
            begin
              sText[iZacatek] := #13;
              j := iZacatek;
            end;
            //**)

            //Inc(j,x-1);
            Inc(j);
          end;
          //----

          Comment.Hint := sText;
          Comment.ShowHint := {True}False;
          Comment.Visible := True;
          Comment.Name := Format('Commentary_%d',[CommentNum]);
          Comment.Caption := '';
          Comment.BringToFront;
          Inc(CommentNum);

          AddToolTip(Comment.Handle, @ti, 1, PWideChar(Comment.Hint), PWideChar(QIPPlugin.GetLang(LI_CLR_HINT)));
          (*
          ShowMessage(
          'OBJECT: ' + TControl(Form.Components[i]).Name + ' [' + IntToStr(i+1) + '/' + IntToStr(Form.ComponentCount) + '] ' + #13 +
          'Class: ' + TControl(Form.Components[i]).ClassName + #13 +
          'Width: ' + IntToStr(TControl(Form.Components[i]).Width) + #13 +
          'Height: ' + IntToStr(TControl(Form.Components[i]).Height) + #13 +
          'Top: ' + IntToStr(TControl(Form.Components[i]).Top) + #13 +
          'Left: ' + IntToStr(TControl(Form.Components[i]).Left) + #13 +
          'COMMENT: ' + Comment.Name + #13 +
          'Class: ' + Comment.ClassName + #13 +
          'Comment Width: ' + IntToStr(Comment.Width) + #13 +
          'Comment Height: ' + IntToStr(Comment.Height) + #13 +
          'Comment Left: ' + IntToStr(TControl(Form.Components[i]).Left) + ' + ' + IntToStr(TControl(Form.Components[i]).Width) + ' = ' + IntTostr(TControl(Form.Components[i]).Left + TControl(Form.Components[i]).Width) + #13 +
          'Comment Top: ' + IntToStr(TControl(Form.Components[i]).Top) + ' + (' + IntToStr(TControl(Form.Components[i]).Height) + ' - ' + IntTostr(Comment.Height) + ') / 2 = ' + IntToStr(TControl(Form.Components[i]).Top + Round( (TControl(Form.Components[i]).Height - Comment.Height) / 2 ))
          );*)
        end;
      2:
    end;
  0:
end;



end.
