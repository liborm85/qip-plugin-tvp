object frmProgramInfo: TfrmProgramInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Program Info'
  ClientHeight = 294
  ClientWidth = 428
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
  object lblOrigName: TLabel
    Left = 16
    Top = 35
    Width = 57
    Height = 13
    Caption = 'lblOrigName'
  end
  object lblName: TLabel
    Left = 16
    Top = 16
    Width = 45
    Height = 13
    Caption = 'lblName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPrgSpec: TLabel
    Left = 288
    Top = 16
    Width = 49
    Height = 13
    Caption = 'lblPrgSpec'
  end
  object lblPrgType: TLabel
    Left = 288
    Top = 35
    Width = 50
    Height = 13
    Caption = 'lblPrgType'
  end
  object lblInfo: TLabel
    Left = 16
    Top = 70
    Width = 393
    Height = 174
    AutoSize = False
    Caption = 'lblInfo'
    WordWrap = True
  end
  object btnMore: TBitBtn
    Left = 345
    Top = 261
    Width = 75
    Height = 25
    Caption = 'More...'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = btnMoreClick
  end
end
