object frmCLItems: TfrmCLItems
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Edit stations'
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
  object vdtData: TVirtualDrawTree
    Left = 8
    Top = 40
    Width = 412
    Height = 217
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
  object btnSave: TBitBtn
    Left = 179
    Top = 263
    Width = 75
    Height = 25
    Caption = 'Save'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object tbButtons: TToolBar
    Left = 262
    Top = 11
    Width = 158
    Height = 23
    Align = alNone
    Caption = 'tbButtons'
    Images = ilButtons
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object tbtnItemEdit: TToolButton
      Left = 0
      Top = 0
      Hint = 'Edit'
      ImageIndex = 0
      OnClick = tbtnItemEditClick
    end
    object ToolButton1: TToolButton
      Left = 23
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbtnItemAdd: TToolButton
      Left = 31
      Top = 0
      Hint = 'Add'
      ImageIndex = 1
      OnClick = tbtnItemAddClick
    end
    object tbtnItemRemove: TToolButton
      Left = 54
      Top = 0
      Hint = 'Remove'
      ImageIndex = 2
      OnClick = tbtnItemRemoveClick
    end
    object ToolButton3: TToolButton
      Left = 77
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object tbtnItemUp: TToolButton
      Left = 85
      Top = 0
      Hint = 'Up'
      ImageIndex = 3
      OnClick = tbtnItemUpClick
    end
    object tbtnItemDown: TToolButton
      Left = 108
      Top = 0
      Hint = 'Down'
      ImageIndex = 4
      OnClick = tbtnItemDownClick
    end
  end
  object ilButtons: TImageList
    Left = 144
  end
end
