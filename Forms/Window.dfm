object frmWindow: TfrmWindow
  Left = 0
  Top = 0
  Caption = 'TVp'
  ClientHeight = 464
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnMouseUp = tabWindowMouseUp
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tabWindow: TTabControl
    Left = 0
    Top = 0
    Width = 484
    Height = 445
    Align = alClient
    MultiLine = True
    OwnerDraw = True
    TabOrder = 0
    Tabs.Strings = (
      'A'
      'B'
      'C')
    TabIndex = 0
    TabStop = False
    OnChange = tabWindowChange
    OnDrawTab = tabWindowDrawTab
    OnMouseUp = tabWindowMouseUp
    object pnlTab: TPanel
      Left = 4
      Top = 24
      Width = 476
      Height = 417
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      OnMouseUp = tabWindowMouseUp
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 476
        Height = 73
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        OnMouseUp = tabWindowMouseUp
        object pnlStationLogo: TPanel
          Left = 5
          Top = 5
          Width = 64
          Height = 64
          BevelOuter = bvNone
          TabOrder = 0
          object imgStationLogo: TImage
            Left = 0
            Top = 0
            Width = 64
            Height = 64
            Center = True
          end
        end
        object pnlNP: TPanel
          Left = 75
          Top = 26
          Width = 326
          Height = 41
          BevelOuter = bvNone
          TabOrder = 1
          object lblNPTime2: TLabel
            Left = 284
            Top = 28
            Width = 28
            Height = 13
            Caption = '99:99'
            ShowAccelChar = False
          end
          object lblNPProgramName: TLabel
            Left = 34
            Top = 28
            Width = 244
            Height = 13
            Alignment = taCenter
            AutoSize = False
            Caption = '...'
            ShowAccelChar = False
          end
          object lblNPTime1: TLabel
            Left = 6
            Top = 28
            Width = 28
            Height = 13
            Caption = '99:99'
            ShowAccelChar = False
          end
          object pnlNPGauge: TPanel
            Left = 6
            Top = 8
            Width = 306
            Height = 13
            BevelOuter = bvNone
            TabOrder = 0
          end
        end
      end
      object pnlBottom: TPanel
        Left = 0
        Top = 395
        Width = 476
        Height = 22
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        OnMouseUp = tabWindowMouseUp
        object tbBottomRight: TToolBar
          Left = 451
          Top = 0
          Width = 25
          Height = 22
          Align = alRight
          Caption = 'tbBottomRight'
          Images = ilToolbar
          TabOrder = 0
          OnMouseUp = tabWindowMouseUp
          object tbtnClose: TToolButton
            Left = 0
            Top = 0
            Caption = 'tbtnClose'
            ImageIndex = 1
            ParentShowHint = False
            ShowHint = True
            OnClick = tbtnCloseClick
            OnMouseUp = tabWindowMouseUp
          end
        end
        object tbBottom: TToolBar
          Left = 0
          Top = 0
          Width = 451
          Height = 22
          Align = alClient
          Images = ilToolbar
          TabOrder = 1
          OnMouseUp = tabWindowMouseUp
        end
      end
      object vdtData: TVirtualDrawTree
        Left = 0
        Top = 73
        Width = 476
        Height = 271
        Align = alClient
        Header.AutoSizeIndex = -1
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Options = [hoColumnResize, hoDrag, hoOwnerDraw]
        TabOrder = 2
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
        OnAdvancedHeaderDraw = vdtDataAdvancedHeaderDraw
        OnDrawNode = vdtDataDrawNode
        OnFreeNode = vdtDataFreeNode
        OnGetPopupMenu = vdtDataGetPopupMenu
        OnHeaderDraw = vdtDataHeaderDraw
        OnKeyUp = FormKeyUp
        Columns = <
          item
            Position = 0
            Style = vsOwnerDraw
          end>
      end
      object pnlDate: TPanel
        Left = 0
        Top = 344
        Width = 476
        Height = 51
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        OnMouseUp = tabWindowMouseUp
        object pnlDateButtons: TPanel
          Left = 100
          Top = 6
          Width = 226
          Height = 36
          BevelOuter = bvNone
          TabOrder = 0
          object lblDateDay: TLabel
            Left = 81
            Top = 2
            Width = 64
            Height = 13
            Alignment = taCenter
            AutoSize = False
            Caption = '...'
          end
          object btnDateBack: TButton
            Left = 0
            Top = 11
            Width = 75
            Height = 25
            Caption = '<<<'
            TabOrder = 0
            OnClick = btnDateBackClick
            OnKeyUp = FormKeyUp
          end
          object btnDateNext: TButton
            Left = 151
            Top = 11
            Width = 75
            Height = 25
            Caption = '>>>'
            TabOrder = 1
            OnClick = btnDateNextClick
            OnKeyUp = FormKeyUp
          end
          object edtDate: TMaskEdit
            Left = 81
            Top = 15
            Width = 64
            Height = 21
            EditMask = '!99/99/0000;1;_'
            MaxLength = 10
            ReadOnly = True
            TabOrder = 2
            Text = '00.00.0000'
            OnKeyUp = FormKeyUp
          end
        end
      end
    end
  end
  object sbStatusBar: TStatusBar
    Left = 0
    Top = 445
    Width = 484
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
    OnMouseUp = tabWindowMouseUp
    OnDrawPanel = sbStatusBarDrawPanel
  end
  object pbStatusBar: TProgressBar
    Left = 27
    Top = 451
    Width = 54
    Height = 17
    Position = 50
    TabOrder = 2
  end
  object tmrShowBookmark: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tmrShowBookmarkTimer
    Left = 320
    Top = 216
  end
  object ilToolbar: TImageList
    Left = 392
    Top = 216
  end
  object pmContextMenu: TPopupMenu
    Images = ilToolbar
    Left = 232
    Top = 216
    object miContextMenu_ProgramName: TMenuItem
      Caption = '...name...'
      Enabled = False
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_ProgramInfo: TMenuItem
      Caption = 'Info'
      ImageIndex = 6
      Visible = False
      OnClick = miContextMenu_ProgramInfoClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_Plan: TMenuItem
      Caption = 'Plan'
      ImageIndex = 8
      OnClick = miContextMenu_PlanClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object N1: TMenuItem
      Caption = '-'
      OnDrawItem = DrawMenu
    end
    object miContextMenu_CopyName: TMenuItem
      Caption = 'Copy name'
      OnClick = miContextMenu_CopyNameClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_CopyNameAndDescription: TMenuItem
      Caption = 'Copy name and description'
      OnClick = miContextMenu_CopyNameAndDescriptionClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object N5: TMenuItem
      Caption = '-'
      OnDrawItem = DrawMenu
    end
    object miContextMenu_Close: TMenuItem
      Caption = 'Close'
      ImageIndex = 7
      OnClick = miContextMenu_CloseClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_ContactDetails: TMenuItem
      Caption = 'Contact details'
      Visible = False
      OnClick = miContextMenu_ContactDetailsClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_Edit: TMenuItem
      Caption = 'Edit'
      ImageIndex = 1
      OnClick = miContextMenu_EditClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object miContextMenu_Remove: TMenuItem
      Caption = 'Remove'
      ImageIndex = 10
      OnClick = miContextMenu_RemoveClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
    object N2: TMenuItem
      Caption = '-'
      OnDrawItem = DrawMenu
    end
    object miContextMenu_RefreshAll: TMenuItem
      Caption = 'Refresh all'
      ImageIndex = 2
      OnClick = miContextMenu_RefreshAllClick
      OnDrawItem = DrawMenu
      OnMeasureItem = MeasureMenu
    end
  end
  object tmrNP: TTimer
    Enabled = False
    OnTimer = tmrNPTimer
    Left = 168
    Top = 216
  end
end
