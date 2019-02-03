object frmPlanEdit: TfrmPlanEdit
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Edit plan'
  ClientHeight = 294
  ClientWidth = 431
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
  object lblStation: TLabel
    Left = 8
    Top = 16
    Width = 38
    Height = 13
    Caption = 'Station:'
  end
  object lblDate: TLabel
    Left = 299
    Top = 16
    Width = 27
    Height = 13
    Caption = 'Date:'
  end
  object lblProgramBegin: TLabel
    Left = 80
    Top = 72
    Width = 30
    Height = 13
    Caption = 'Begin:'
  end
  object lblProgramEnd: TLabel
    Left = 227
    Top = 72
    Width = 22
    Height = 13
    Caption = 'End:'
    Visible = False
  end
  object lblProgramme: TLabel
    Left = 8
    Top = 44
    Width = 58
    Height = 13
    Caption = 'Programme:'
  end
  object lblNotifyBeforeBeginUnit: TLabel
    Left = 212
    Top = 131
    Width = 37
    Height = 13
    Caption = 'minutes'
  end
  object lblNotifyBeforeBegin: TLabel
    Left = 8
    Top = 131
    Width = 97
    Height = 13
    Caption = 'Notify before begin:'
  end
  object edtNotifyBeforeBegin: TEdit
    Left = 154
    Top = 128
    Width = 33
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = '0'
  end
  object udNotifyBeforeBegin: TUpDown
    Left = 189
    Top = 128
    Width = 17
    Height = 21
    Max = 999
    TabOrder = 1
    OnClick = udNotifyBeforeBeginClick
  end
  object pnlStation: TPanel
    Left = 80
    Top = 12
    Width = 209
    Height = 22
    BevelOuter = bvLowered
    Caption = '?'
    TabOrder = 2
  end
  object pnlDate: TPanel
    Left = 345
    Top = 12
    Width = 78
    Height = 22
    BevelOuter = bvLowered
    Caption = '00.00.0000'
    TabOrder = 3
  end
  object pnlProgramBegin: TPanel
    Left = 152
    Top = 68
    Width = 49
    Height = 22
    BevelOuter = bvLowered
    Caption = '00:00'
    TabOrder = 4
  end
  object pnlProgramEnd: TPanel
    Left = 299
    Top = 68
    Width = 49
    Height = 22
    BevelOuter = bvLowered
    Caption = '00:00'
    TabOrder = 5
    Visible = False
  end
  object pnlProgramTitle: TPanel
    Left = 80
    Top = 40
    Width = 343
    Height = 22
    BevelOuter = bvLowered
    Caption = '?'
    TabOrder = 6
  end
  object btnConfirmPlan: TBitBtn
    Left = 114
    Top = 245
    Width = 100
    Height = 25
    Caption = 'Add to plan'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 7
    OnClick = btnConfirmPlanClick
  end
  object btnCancelPlan: TBitBtn
    Left = 226
    Top = 245
    Width = 100
    Height = 25
    Caption = 'Cancel plan'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 8
    OnClick = btnCancelPlanClick
  end
end
