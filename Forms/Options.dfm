object frmOptions: TfrmOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Options: ...'
  ClientHeight = 464
  ClientWidth = 635
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
  object BottomLine: TShape
    Left = -8
    Top = 425
    Width = 657
    Height = 40
    Brush.Color = 5525059
  end
  object lblPluginVersion: TLabel
    Left = 8
    Top = 436
    Width = 70
    Height = 13
    Caption = 'Version ?.?.?.?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object pnlCont: TPanel
    Left = 167
    Top = 8
    Width = 465
    Height = 416
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 5
    Visible = False
  end
  object pnlText: TPanel
    Left = 167
    Top = 8
    Width = 465
    Height = 25
    Caption = 'Unknown'
    Color = 5525059
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 6
  end
  object btnAbout: TBitBtn
    Left = 167
    Top = 431
    Width = 90
    Height = 25
    Caption = 'About plugin...'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 4
    OnClick = btnAboutClick
  end
  object btnOK: TBitBtn
    Left = 343
    Top = 431
    Width = 90
    Height = 25
    Caption = 'OK'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TBitBtn
    Left = 439
    Top = 431
    Width = 90
    Height = 25
    Caption = 'Cancel'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnApply: TBitBtn
    Left = 535
    Top = 431
    Width = 90
    Height = 25
    Caption = 'Apply'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 3
    OnClick = btnApplyClick
  end
  object pgcOptions: TPageControl
    Left = 167
    Top = 39
    Width = 465
    Height = 386
    ActivePage = TabSheet1
    TabOrder = 7
    object TabSheet1: TTabSheet
      Caption = 'General'
      object gbUpdater: TGroupBox
        Left = 3
        Top = 3
        Width = 451
        Height = 105
        Caption = 'Updater'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object lblUpdaterInterval: TLabel
          Left = 40
          Top = 51
          Width = 42
          Height = 13
          Caption = 'Interval:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblUpdaterIntervalUnit: TLabel
          Left = 162
          Top = 51
          Width = 27
          Height = 13
          Caption = 'hours'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object chkUpdaterCheckingUpdates: TCheckBox
          Left = 15
          Top = 25
          Width = 255
          Height = 17
          Caption = 'Checking updates'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object edtUpdaterInterval: TEdit
          Left = 88
          Top = 48
          Width = 33
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
        object udUpdaterInterval: TUpDown
          Left = 139
          Top = 48
          Width = 17
          Height = 21
          Min = 1
          Max = 999
          Position = 1
          TabOrder = 2
          OnClick = udUpdaterIntervalClick
        end
        object btnUpdaterCheckUpdate: TBitBtn
          Left = 195
          Top = 48
          Width = 75
          Height = 25
          Caption = 'Check'
          DoubleBuffered = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentDoubleBuffered = False
          ParentFont = False
          TabOrder = 3
          OnClick = btnUpdaterCheckUpdateClick
        end
        object chkAnnounceBeta: TCheckBox
          Left = 40
          Top = 75
          Width = 129
          Height = 17
          Caption = 'Announce beta version'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
      end
      object gbLanguage: TGroupBox
        Left = 3
        Top = 114
        Width = 451
        Height = 126
        Caption = 'Language'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object lblInfoTransAuthor: TLabel
          Left = 15
          Top = 44
          Width = 37
          Height = 13
          Caption = 'Author:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblInfoTransEmail: TLabel
          Left = 15
          Top = 63
          Width = 32
          Height = 13
          Caption = 'E-mail:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTransAuthor: TLabel
          Left = 100
          Top = 44
          Width = 12
          Height = 13
          Caption = '...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTransEmail: TLabel
          Left = 100
          Top = 63
          Width = 12
          Height = 13
          Cursor = crHandPoint
          Caption = '...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHotLight
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = lblTransEmailClick
          OnMouseEnter = lblTransEmailMouseEnter
          OnMouseLeave = lblTransEmailMouseLeave
        end
        object lblInfoTransWeb: TLabel
          Left = 15
          Top = 82
          Width = 26
          Height = 13
          Caption = 'Web:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTransURL: TLabel
          Left = 100
          Top = 82
          Width = 12
          Height = 13
          Cursor = crHandPoint
          Caption = '...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHotLight
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = lblTransURLClick
          OnMouseEnter = lblTransURLMouseEnter
          OnMouseLeave = lblTransURLMouseLeave
        end
        object lblLanguage: TLabel
          Left = 15
          Top = 25
          Width = 51
          Height = 13
          Caption = 'Language:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblLanguageVersion: TLabel
          Left = 223
          Top = 25
          Width = 12
          Height = 13
          Caption = '...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblLanguageRem: TLabel
          Left = 15
          Top = 101
          Width = 27
          Height = 13
          Caption = 'pozn.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object cmbLangs: TComboBox
          Left = 99
          Top = 21
          Width = 106
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 0
          OnChange = cmbLangsChange
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 1
      object gbAdvancedOptions: TGroupBox
        Left = 3
        Top = 3
        Width = 451
        Height = 89
        Caption = 'Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object chkShowComments: TCheckBox
          Left = 15
          Top = 44
          Width = 200
          Height = 17
          Caption = 'Show comments'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object chkCloseBookmarks: TCheckBox
          Left = 15
          Top = 21
          Width = 393
          Height = 17
          Caption = 'When you close the window, close all tabs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
      object gbContacts: TGroupBox
        Left = 3
        Top = 101
        Width = 451
        Height = 116
        Caption = 'Contact list'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object lblSpecCntText: TLabel
          Left = 37
          Top = 42
          Width = 26
          Height = 13
          Caption = 'Text:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSpecCntFont: TLabel
          Left = 37
          Top = 66
          Width = 26
          Height = 13
          Caption = 'Font:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object chkAlwaysOpenAllStations: TCheckBox
          Left = 15
          Top = 89
          Width = 402
          Height = 17
          Caption = 'Always open all stations'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object chkShowAsOneContact: TCheckBox
          Left = 15
          Top = 21
          Width = 393
          Height = 17
          Caption = 'Zobrazit v'#353'e jako jeden kontakt'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object edtSpecCntText: TEdit
          Left = 88
          Top = 38
          Width = 185
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object edtCLFont: TEdit
          Left = 88
          Top = 62
          Width = 185
          Height = 21
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 3
        end
        object edtCLFontSize: TEdit
          Left = 280
          Top = 62
          Width = 33
          Height = 21
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 4
        end
        object pnlCLFontColor: TPanel
          Left = 323
          Top = 62
          Width = 22
          Height = 22
          BevelOuter = bvLowered
          ParentBackground = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object tbButtons: TToolBar
          Left = 351
          Top = 62
          Width = 58
          Height = 23
          Align = alNone
          Caption = 'tbButtons'
          Images = ilButtons
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          object tbtnCLFont: TToolButton
            Left = 0
            Top = 0
            Hint = 'Font'
            ImageIndex = 0
            OnClick = tbtnCLFontClick
          end
          object tbtnCLColor: TToolButton
            Left = 23
            Top = 0
            Hint = 'Color'
            ImageIndex = 1
            OnClick = tbtnCLColorClick
          end
        end
      end
      object gbUpdateProgram: TGroupBox
        Left = 3
        Top = 240
        Width = 451
        Height = 81
        Caption = 'Update program'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        object lblUpdateProgramInterval: TLabel
          Left = 24
          Top = 27
          Width = 42
          Height = 13
          Caption = 'Interval:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblUpdateProgramIntervalUnit: TLabel
          Left = 146
          Top = 27
          Width = 27
          Height = 13
          Caption = 'hours'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edtUpdateProgramInterval: TEdit
          Left = 72
          Top = 24
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
        object udUpdateProgramInterval: TUpDown
          Left = 123
          Top = 24
          Width = 17
          Height = 21
          Min = 1
          Max = 999
          Position = 1
          TabOrder = 1
          OnClick = udUpdaterIntervalClick
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Layout'
      ImageIndex = 6
      object gbColors: TGroupBox
        Left = 7
        Top = 3
        Width = 185
        Height = 198
        Caption = 'Colors'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object lblColorStation: TLabel
          Left = 20
          Top = 119
          Width = 38
          Height = 13
          Caption = 'Station:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorTimeInfo: TLabel
          Left = 20
          Top = 95
          Width = 26
          Height = 13
          Caption = 'Time:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorPlanned: TLabel
          Left = 20
          Top = 71
          Width = 42
          Height = 13
          Caption = 'Planned:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorLine2: TLabel
          Left = 20
          Top = 45
          Width = 47
          Height = 13
          Caption = 'Even line:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorLine1: TLabel
          Left = 20
          Top = 21
          Width = 43
          Height = 13
          Caption = 'Odd line:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorProgress1: TLabel
          Left = 20
          Top = 143
          Width = 55
          Height = 13
          Caption = 'Progress 1:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblColorProgress2: TLabel
          Left = 20
          Top = 167
          Width = 55
          Height = 13
          Caption = 'Progress 2:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object pnlColorStation: TPanel
          Left = 100
          Top = 116
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = pnlColorStationClick
        end
        object pnlColorTimeInfo: TPanel
          Left = 100
          Top = 92
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = pnlColorTimeInfoClick
        end
        object pnlColorPlanned: TPanel
          Left = 100
          Top = 68
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = pnlColorPlannedClick
        end
        object pnlColorLine2: TPanel
          Left = 100
          Top = 42
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnClick = pnlColorLine2Click
        end
        object pnlColorLine1: TPanel
          Left = 100
          Top = 18
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = pnlColorLine1Click
        end
        object pnlColorProgress1: TPanel
          Left = 100
          Top = 140
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
          OnClick = pnlColorProgress1Click
        end
        object pnlColorProgress2: TPanel
          Left = 100
          Top = 164
          Width = 21
          Height = 21
          BorderStyle = bsSingle
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          OnClick = pnlColorProgress2Click
        end
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Hot keys'
      ImageIndex = 6
      object gbHotKeys: TGroupBox
        Left = 3
        Top = 3
        Width = 451
        Height = 92
        Caption = 'Hot Keys'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object lblHotKeyOpenTVp: TLabel
          Left = 15
          Top = 48
          Width = 51
          Height = 13
          Caption = 'Open TVp:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object HotKey1: THotKey
          Left = 170
          Top = 44
          Width = 121
          Height = 19
          HotKey = 0
          Modifiers = []
          TabOrder = 0
          OnEnter = GetOffHotKey
          OnExit = GetHotKeysActivate
        end
        object chkUseHotKeys: TCheckBox
          Left = 15
          Top = 25
          Width = 426
          Height = 17
          Caption = 'Use Hot Keys'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Plugins'
      ImageIndex = 3
      object lvPlugins: TListView
        Left = 0
        Top = 0
        Width = 457
        Height = 358
        Align = alClient
        Columns = <
          item
            Caption = 'Plugin file'
            Width = 135
          end
          item
            Caption = 'Plugin name'
            Width = 135
          end
          item
            Caption = 'Version'
          end
          item
            Caption = 'Author'
            Width = 100
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Connection'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gbProxy: TGroupBox
        Left = 3
        Top = 3
        Width = 451
        Height = 102
        Caption = 'Proxy'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        Visible = False
        object lblProxyServerInfo: TLabel
          Left = 15
          Top = 75
          Width = 120
          Height = 13
          Caption = '[user:pass@]server:port'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edtProxyServer: TEdit
          Left = 15
          Top = 48
          Width = 425
          Height = 21
          TabOrder = 0
        end
        object chkUseProxyServer: TCheckBox
          Left = 15
          Top = 25
          Width = 209
          Height = 17
          Caption = 'Manual proxy configuration'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
    end
  end
  object lstMenu: TListBox
    Left = 8
    Top = 8
    Width = 153
    Height = 416
    TabStop = False
    Style = lbOwnerDrawFixed
    DoubleBuffered = False
    ExtendedSelect = False
    ItemHeight = 25
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = lstMenuClick
    OnDrawItem = lstMenuDrawItem
    OnMouseDown = lstMenuMouseDown
  end
  object ImageList1: TImageList
    Left = 24
    Top = 328
    Bitmap = {
      494C010101000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      00000000001500000030020100400100003E0000002700000006000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000160D06
      0673542A09C08E511DE3B96614F3AB590DF07D410CDA28150895000000180000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000103A1E0CABDE81
      29FFFFB767FFFFB566FFF39A41FFE47D16FFE17406FFDF750EFF2C1705860000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000001309055EE48021FFFFC7
      84FFF3A75AFFD6700AFFD26B03FFD46E08FFD46F09FFE07408FF824408C30000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021121170F18B22FFFFC9
      8DFFDF7D1DFFD16902FFD56F09FFD56F09FFD46E09FFE07508FF3A1E007C0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000603011BA75504CDEE96
      3FFFEA8E33FFD56D05FFDF7409FFD77009FFD77008FFC7680EF80C06032A0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000C060010582C
      01698545059B924B07AB532B059BA95706E9E57705FF713D1BC4000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000C060150CD6A07FAE27508FF24130E6A000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000D773D07CCE47708FFBC620FF20301011B000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000150B0469DC7209FFE17508FF5A2F0DA900000000000000020000
      00080000000F0000001700000007000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000127E410ED4DF7409FFDC7209FF3E200AA3140B016F21120289301A
      04993F2512AD542D15C30D070655000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000180C0770DD7309FFD66F09FFD46E08FFCC6907FCDE7813FFEE841AFFF68C
      24FFFDA64EFFFFAA4DFF341A0476000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0017864711DBE07408FFD46E09FFD56F09FFD66F08FFD56E07FFD36D07FFCF68
      01FFE37F1AFFD88740F70503042D000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002010
      077BE07408FFD56F09FFD56F09FFD56F09FFD56F09FFD56F09FFD46E08FFD36C
      06FFEC8318FF854C1ECB00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000038546
      17DAE07407FFD46F09FFD56F09FFD26D08FCCE6B08F7C86808F0B96006DFA656
      06C89D5207B22F18015300000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000013E22
      1269713B01824F290360361C0242281401301E100125140A00190904000B0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object ColorDialog1: TColorDialog
    Left = 104
    Top = 96
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 72
    Top = 240
  end
  object ilButtons: TImageList
    Left = 48
    Top = 168
  end
end
