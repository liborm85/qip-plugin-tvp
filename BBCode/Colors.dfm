object frmColors: TfrmColors
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Colors'
  ClientHeight = 296
  ClientWidth = 230
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lstColors: TListBox
    Left = 0
    Top = 0
    Width = 230
    Height = 255
    Style = lbOwnerDrawFixed
    Align = alClient
    ItemHeight = 32
    TabOrder = 0
    OnDblClick = lstColorsDblClick
    OnDrawItem = lstColorsDrawItem
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 255
    Width = 230
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnApply: TBitBtn
      Left = 61
      Top = 8
      Width = 97
      Height = 25
      Caption = 'Apply'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = btnApplyClick
    end
  end
  object ColorDialog1: TColorDialog
    Left = 8
    Top = 8
  end
end
