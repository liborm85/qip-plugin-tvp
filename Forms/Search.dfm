object frmSearch: TfrmSearch
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Search'
  ClientHeight = 435
  ClientWidth = 501
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
  object lblSearch: TLabel
    Left = 16
    Top = 24
    Width = 37
    Height = 13
    Caption = 'Search:'
  end
  object edtSearch: TEdit
    Left = 80
    Top = 21
    Width = 333
    Height = 21
    TabOrder = 0
    OnKeyDown = edtSearchKeyDown
  end
  object chkSelectPlugin: TCheckBox
    Left = 16
    Top = 48
    Width = 225
    Height = 17
    Caption = 'Search only in:'
    TabOrder = 1
    OnClick = chkSelectPluginClick
  end
  object chklbSelectPlugin: TCheckListBox
    Left = 32
    Top = 71
    Width = 209
    Height = 82
    ItemHeight = 13
    TabOrder = 2
  end
  object lvData: TListView
    Left = 8
    Top = 159
    Width = 486
    Height = 222
    Columns = <
      item
        Caption = 'Name'
        Width = 250
      end
      item
        Caption = 'ID'
        Width = 200
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    OnSelectItem = lvDataSelectItem
  end
  object btnAdd: TButton
    Left = 208
    Top = 387
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 4
    Visible = False
    OnClick = btnAddClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 416
    Width = 501
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object btnSearch: TButton
    Left = 419
    Top = 18
    Width = 75
    Height = 25
    Caption = 'Search'
    TabOrder = 6
    OnClick = btnSearchClick
  end
end
