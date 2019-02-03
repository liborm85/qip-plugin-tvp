object frmEditItem: TfrmEditItem
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit'
  ClientHeight = 140
  ClientWidth = 411
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
  object lblName: TLabel
    Left = 16
    Top = 24
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object lblID: TLabel
    Left = 16
    Top = 51
    Width = 15
    Height = 13
    Caption = 'ID:'
  end
  object edtName: TEdit
    Left = 110
    Top = 21
    Width = 293
    Height = 21
    TabOrder = 0
  end
  object edtID: TEdit
    Left = 110
    Top = 48
    Width = 293
    Height = 21
    Enabled = False
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 112
    Top = 107
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 208
    Top = 107
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object chkAddTo: TCheckBox
    Left = 13
    Top = 77
    Width = 95
    Height = 17
    Caption = 'Add to:'
    TabOrder = 4
    OnClick = chkAddToClick
  end
  object cmbAddTo: TComboBoxEx
    Left = 110
    Top = 75
    Width = 293
    Height = 22
    ItemsEx = <>
    Style = csExDropDownList
    ItemHeight = 16
    TabOrder = 5
    Images = ilIcons
  end
  object ilIcons: TImageList
    Left = 352
    Top = 96
  end
end
