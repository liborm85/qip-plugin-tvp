unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, jpeg;

type
  TfrmAbout = class(TForm)
    lblTitle: TLabel;
    lblVersion: TLabel;
    lblAuthor: TLabel;
    lblA: TLabel;
    lblEmail: TLabel;
    lblAuthorEmail: TLabel;
    lblLangs: TLabel;
    lblWeb: TLabel;
    lblPluginWeb: TLabel;
    imgBg: TImage;
    btnClose: TBitBtn;
    Shape1: TShape;
    lblIconPackAuthor: TLabel;
    lblHint: TLabel;
    lblAuthorEmail2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure lblAuthorEmailClick(Sender: TObject);
    procedure lblPluginWebClick(Sender: TObject);
    procedure lblIconPackAuthorClick(Sender: TObject);
    procedure lblAuthorEmailMouseEnter(Sender: TObject);
    procedure lblAuthorEmailMouseLeave(Sender: TObject);
    procedure lblPluginWebMouseLeave(Sender: TObject);
    procedure lblPluginWebMouseEnter(Sender: TObject);
    procedure lblIconPackAuthorMouseEnter(Sender: TObject);
    procedure lblIconPackAuthorMouseLeave(Sender: TObject);
    procedure lblAuthorEmail2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses General, u_qip_plugin, u_lang_ids, uLNG, uComments, uLinks;

{$R *.dfm}

procedure TfrmAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AboutIsShow := False;
  FAbout.Destroy;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
//  Color := frmBgColor;

  Icon := PluginSkin.Info.Icon;

  //imgBg.Picture := PluginSkin.PluginIconBig.Picture;

  btnClose.Caption := QIPPlugin.GetLang(LI_Close);

  lblVersion.Caption := PluginVersion;
  lblVersion.Color   := lblTitle.Color;

  lblHint.Caption := LNG('Info', 'Hint', PLUGIN_HINT);
  lblHint.Color   := Shape1.Brush.Color;

  lblAuthor.Caption := QIPPlugin.GetLang(LI_AUTHOR) + ':';
  lblAuthor.Color   := Shape1.Brush.Color;
  lblA.Caption := PLUGIN_AUTHOR;
  lblA.Color   := Shape1.Brush.Color;

  lblEmail.Caption := QIPPlugin.GetLang(LI_EMAIL) + ':';
  lblEmail.Color   := Shape1.Brush.Color;
  lblAuthorEmail.Caption := PLUGIN_AUTHOR_EMAIL;
  lblAuthorEmail.Color   := Shape1.Brush.Color;
  lblAuthorEmail2.Color  := Shape1.Brush.Color;

  lblWeb.Caption := QIPPlugin.GetLang(LI_WEB_SITE) + ':';
  lblWeb.Color   := Shape1.Brush.Color;
  lblPluginWeb.Caption := PLUGIN_WEB;
  lblPluginWeb.Color   := Shape1.Brush.Color;

  lblTitle.Caption := PLUGIN_NAME;
  Caption := PLUGIN_NAME + ' | ' + LNG('FORM Options', 'About', 'About plugin...');

  lblLangs.Caption := LNG('Texts', 'About.WriteOnly', 'Write only czech, slovak or english.');
  lblLangs.Color   := Shape1.Brush.Color;
  lblIconPackAuthor.Caption := LNG('Texts', 'About.IconPack', 'Icon Pack %pack% by %author%.');
  lblIconPackAuthor.Caption := StringReplace(lblIconPackAuthor.Caption, '%pack%', '''Silk''', [rfReplaceAll, rfIgnoreCase]);
  lblIconPackAuthor.Caption := StringReplace(lblIconPackAuthor.Caption, '%author%', 'Mark James', [rfReplaceAll, rfIgnoreCase]);
  lblIconPackAuthor.Color   := Shape1.Brush.Color;

  AddComments(FAbout);
  AboutIsShow := True;
end;

procedure TfrmAbout.lblAuthorEmail2Click(Sender: TObject);
begin
  OnClickLinkUrl(Sender,'?subject=FMtune');
end;

procedure TfrmAbout.lblAuthorEmailClick(Sender: TObject);
begin
  OnClickLinkUrl(Sender,'?subject=FMtune');
end;

procedure TfrmAbout.lblAuthorEmailMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmAbout.lblAuthorEmailMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmAbout.lblIconPackAuthorClick(Sender: TObject);
begin
  LinkUrl('http://www.famfamfam.com/lab/icons/silk');
end;

procedure TfrmAbout.lblIconPackAuthorMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmAbout.lblIconPackAuthorMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

procedure TfrmAbout.lblPluginWebClick(Sender: TObject);
begin
  LinkUrl(  lblPluginWeb.Caption );
end;

procedure TfrmAbout.lblPluginWebMouseEnter(Sender: TObject);
begin
  OnMouseOverLink(Sender);
end;

procedure TfrmAbout.lblPluginWebMouseLeave(Sender: TObject);
begin
  OnMouseOutLink(Sender);
end;

end.
