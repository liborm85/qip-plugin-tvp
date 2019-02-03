object frmItemOptions: TfrmItemOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Item Options'
  ClientHeight = 315
  ClientWidth = 650
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblName: TLabel
      Left = 16
      Top = 14
      Width = 31
      Height = 13
      Caption = 'Name:'
    end
    object edtName: TEdit
      Left = 61
      Top = 11
      Width = 574
      Height = 21
      TabOrder = 0
    end
  end
  object pnlMiddle: TPanel
    Left = 0
    Top = 41
    Width = 650
    Height = 233
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object vdtData: TVirtualDrawTree
      Left = 16
      Top = 13
      Width = 300
      Height = 214
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = -1
      Header.Options = [hoColumnResize, hoDrag]
      TabOrder = 0
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnChange = vdtDataChange
      OnDrawNode = vdtDataDrawNode
      Columns = <>
    end
    object pnlItem: TPanel
      Left = 328
      Top = 17
      Width = 307
      Height = 210
      BevelOuter = bvNone
      TabOrder = 1
      object pgcItem: TPageControl
        Left = 0
        Top = 0
        Width = 305
        Height = 179
        ActivePage = tsGeneral
        TabOrder = 0
        object tsGeneral: TTabSheet
          Caption = 'General'
          object lblItemName: TLabel
            Left = 3
            Top = 53
            Width = 31
            Height = 13
            Caption = 'Name:'
          end
          object lblItemID: TLabel
            Left = 3
            Top = 5
            Width = 15
            Height = 13
            Caption = 'ID:'
          end
          object edtItemName: TEdit
            Left = 3
            Top = 72
            Width = 265
            Height = 21
            TabOrder = 0
          end
          object edtItemID: TEdit
            Left = 3
            Top = 24
            Width = 265
            Height = 21
            Enabled = False
            TabOrder = 1
          end
        end
        object tsWindow: TTabSheet
          Caption = 'Window'
          ImageIndex = 1
          object lblItemWidthUnit: TLabel
            Left = 125
            Top = 11
            Width = 12
            Height = 13
            Caption = 'px'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblItemWidth: TLabel
            Left = 3
            Top = 11
            Width = 32
            Height = 13
            Caption = 'Width:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object udItemWidth: TUpDown
            Left = 102
            Top = 8
            Width = 17
            Height = 21
            Min = 1
            Max = 999
            Position = 1
            TabOrder = 0
            OnClick = udItemWidthClick
          end
          object edtItemWidth: TEdit
            Left = 51
            Top = 8
            Width = 50
            Height = 21
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            ReadOnly = True
            TabOrder = 1
            Text = '0'
          end
          object chkItemShowInfo: TCheckBox
            Left = 3
            Top = 41
            Width = 265
            Height = 17
            Caption = 'Show informations about program'
            TabOrder = 2
          end
        end
        object Hint: TTabSheet
          Caption = 'Hint'
          ImageIndex = 2
          object lblCountNextPrograms: TLabel
            Left = 3
            Top = 14
            Width = 55
            Height = 13
            Caption = 'Show next:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblCountNextProgramsUnit: TLabel
            Left = 125
            Top = 14
            Width = 45
            Height = 13
            Caption = 'programs'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object edtCountNextPrograms: TEdit
            Left = 80
            Top = 11
            Width = 21
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
          object udCountNextPrograms: TUpDown
            Left = 102
            Top = 11
            Width = 17
            Height = 21
            Max = 999
            TabOrder = 1
            OnClick = udCountNextProgramsClick
          end
        end
      end
      object btnApply: TBitBtn
        Left = 118
        Top = 185
        Width = 75
        Height = 25
        Caption = 'Apply'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 1
        OnClick = btnApplyClick
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 274
    Width = 650
    Height = 41
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    object btnSave: TBitBtn
      Left = 291
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Save'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = btnSaveClick
    end
  end
end
