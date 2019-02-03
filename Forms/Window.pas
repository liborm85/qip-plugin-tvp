unit Window;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls, OleCtrls, SHDocVw,
  ImgList, inifiles, Menus, VirtualTrees, Mask, PhryGauge, clipbrd, CommCtrl;

const
  TabSpaces = '     ';

type
  TfrmWindow = class(TForm)
    tabWindow: TTabControl;
    sbStatusBar: TStatusBar;
    pnlTab: TPanel;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    tbBottomRight: TToolBar;
    tbtnClose: TToolButton;
    tbBottom: TToolBar;
    tmrShowBookmark: TTimer;
    ilToolbar: TImageList;
    pmContextMenu: TPopupMenu;
    miContextMenu_ProgramName: TMenuItem;
    miContextMenu_ProgramInfo: TMenuItem;
    miContextMenu_Plan: TMenuItem;
    N1: TMenuItem;
    miContextMenu_Close: TMenuItem;
    miContextMenu_RefreshAll: TMenuItem;
    miContextMenu_Edit: TMenuItem;
    N2: TMenuItem;
    miContextMenu_ContactDetails: TMenuItem;
    N5: TMenuItem;
    miContextMenu_CopyName: TMenuItem;
    miContextMenu_CopyNameAndDescription: TMenuItem;
    pbStatusBar: TProgressBar;
    vdtData: TVirtualDrawTree;
    pnlDate: TPanel;
    pnlDateButtons: TPanel;
    lblDateDay: TLabel;
    btnDateBack: TButton;
    btnDateNext: TButton;
    edtDate: TMaskEdit;
    pnlStationLogo: TPanel;
    imgStationLogo: TImage;
    pnlNP: TPanel;
    lblNPTime2: TLabel;
    lblNPProgramName: TLabel;
    lblNPTime1: TLabel;
    pnlNPGauge: TPanel;
    tmrNP: TTimer;
    miContextMenu_Remove: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tabWindowDrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure FormResize(Sender: TObject);
    procedure tmrShowBookmarkTimer(Sender: TObject);
    procedure tabWindowChange(Sender: TObject);
    procedure tbtnCloseClick(Sender: TObject);
    procedure lvDataMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbtnOptionsClick(Sender: TObject);
    procedure tabWindowMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miContextMenu_CloseClick(Sender: TObject);
    procedure miContextMenu_CleanDatabaseClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure sbStatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure vdtDataDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure vdtDataFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnDateBackClick(Sender: TObject);
    procedure btnDateNextClick(Sender: TObject);

    procedure MeasureMenu(Sender: TObject;
      ACanvas: TCanvas; var Width, Height: Integer);
    procedure DrawMenu(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure tmrNPTimer(Sender: TObject);
    procedure vdtDataHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
      Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode);
    procedure vdtDataGetPopupMenu(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; const P: TPoint; var AskParent: Boolean;
      var PopupMenu: TPopupMenu);
    procedure miContextMenu_ProgramInfoClick(Sender: TObject);
    procedure miContextMenu_CopyNameClick(Sender: TObject);
    procedure miContextMenu_CopyNameAndDescriptionClick(Sender: TObject);
    procedure miContextMenu_RefreshAllClick(Sender: TObject);
    procedure miContextMenu_ContactDetailsClick(Sender: TObject);
    procedure miContextMenu_EditClick(Sender: TObject);
    procedure miContextMenu_PlanClick(Sender: TObject);
    procedure vdtDataAdvancedHeaderDraw(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
    procedure miContextMenu_RemoveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure AddNewTab(Index: Integer);
    procedure RemoveTab(Index: Integer);
    procedure ShowBookmark(Index: Integer);

    procedure ShowContextMenu(idxProgram: Integer; idxColumn: Integer);

    function DrawField(Sender: TBaseVirtualTree; Node : PVirtualNode; Canvas: TCanvas; R : TRect; idxColumn : Int64; idxRow : Int64; CalcHeight : Boolean) : Cardinal;

  end;

var
  frmWindow: TfrmWindow;
  ShowBookmark_Index: Int64;

  Program_Data : TStringList;

  gaugeNP : TPhryGauge;

  ContextMenu_DataID : Int64;
  ContextMenu_idxColumn, ContextMenu_idxProgram  : Integer;

implementation

uses General, u_lang_ids, uLNG, uURL, TextSearch, uINI,
     GradientColor, Convs, uOptions, uColors,
     Drawing, XMLFiles,
     SQLiteFuncs, SQLiteTable3,
     TVpDLL,
     BBCode;

type
  PDataNode = ^TDataNode;
  TDataNode = record
    Index : Int64;
{    Caption  : WideString;
    Index : Int64;
    Date  : WideString;}

  end;

{$R *.dfm}

procedure TfrmWindow.MeasureMenu(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
begin
  Menu_MeasureMenu(Sender, ACanvas, Width, Height);
end;

procedure TfrmWindow.DrawMenu(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  Menu_DrawMenu(Sender, ACanvas, ARect, Selected);
end;

procedure TfrmWindow.AddNewTab(Index: Integer);
var
  idx : Integer;
  wStr : WideString;
begin
  idx := TBookmarkWindow(BookmarkWindow.Objects[Index]).CLPos;

  if CL.Strings[idx]='CL' then
    wStr := TCL(CL.Objects[idx]).Name
  else if CL.Strings[idx]='CLGuide' then
    wStr := TCLGuide(CL.Objects[idx]).Name;

  tabWindow.Tabs.Add( TabSpaces + wStr  + TabSpaces);

  tabWindow.TabIndex := tabWindow.Tabs.Count - 1;

  ShowBookmark(tabWindow.TabIndex);

  FormResize(Self);
end;


procedure TfrmWindow.RemoveTab(Index: Integer);

begin
  if tbtnClose.Enabled = False then Exit;

  tbtnClose.Enabled := False;

  tmrNP.Enabled := False;

  BookmarkWindow.Delete(Index);

  tabWindow.Tabs.Delete(Index);

  if tabWindow.Tabs.Count = 0 then
  begin
   Close;
   Exit;
  end;

  tabWindow.TabIndex := 0;

  FormResize(Self);

  ShowBookmark(tabWindow.TabIndex);

  tmrNP.Enabled := True;

  tbtnClose.Enabled := True;

end;

procedure TfrmWindow.sbStatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin

  if Panel = StatusBar.Panels[0] then
    with pbStatusBar do begin
      Top := Rect.Top;
      Left := Rect.Left;
      Width := Rect.Right - Rect.Left { - 15};
      Height := Rect.Bottom - Rect.Top;
    end;

end;

procedure TfrmWindow.ShowBookmark(Index: Integer);
begin
  ShowBookmark_Index := Index;
  tmrShowBookmark.Enabled := True;
end;



procedure TfrmWindow.tmrNPTimer(Sender: TObject);
var
  idx : Integer;
  NPInfo : TNPInfo;
begin
  tmrNP.Enabled := False;

  idx := tabWindow.TabIndex;
try

  if CL.Strings[TBookmarkWindow(BookmarkWindow.Objects[idx]).CLPos]='CL' then
  begin

    GetNPInfo( TCL(CL.Objects[TBookmarkWindow(BookmarkWindow.Objects[idx]).CLPos]).ID, -2, NPInfo);

    if NPInfo.TimeLength = -1 then  // Stanice prave nic nevysila
    begin
      gaugeNP.MaxValue :=  100;
      gaugeNP.Progress[1] := 0;

      lblNPTime1.Caption := '';
      lblNPTime2.Caption := '';
      lblNPProgramName.Caption := LNG('TEXTS', 'StationIsNotBroadcastJustNow', 'Station isn''t broadcast just now');
    end
    else    // stanice vysila porad
    begin
      if NPInfo.TimeLength = 0 then
      begin
        gaugeNP.MaxValue :=  100;
        gaugeNP.Progress[1] := 0;
      end
      else
      begin
        if NPInfo.TimeLength < 2 then
          gaugeNP.MaxValue :=  1
        else
          gaugeNP.MaxValue :=  NPInfo.TimeLength;

        gaugeNP.Progress[1] := NPInfo.TimePosition;
      end;

      lblNPTime1.Caption := FormatDateTime('hh:mm', NPInfo.TimeBegin);
      lblNPTime2.Caption := FormatDateTime('hh:mm', NPInfo.TimeEnd);
      lblNPProgramName.Caption := NPInfo.Name + '  (' + IntToStr(NPInfo.TimeLength) + ' ' + QIPPlugin.GetLang(LI_MINUTES) + ')';
    end;

  end;

  //else if CL.Strings[TBookmarkWindow(BookmarkWindow.Objects[idx]).CLPos]='CLGuide' then

finally

end;

  tmrNP.Enabled := True;
end;

procedure TfrmWindow.tmrShowBookmarkTimer(Sender: TObject);
var
  SQLtb     : TSQLiteTable;
  Index, idx, idxCL, idxColumn, idxProgram, idxTime, iMaxItems, i, idxProgram2 : Integer;
  dtDate : TDateTime;
  sTime : WideString;
  TimeInfos : TStringList;
  Node, TopN : PVirtualNode;
  tmpImg : TImage;
  iMaxHeight, iHeight : Cardinal;

begin
  if tmrShowBookmark.Tag = 1 then Exit;

  tmrShowBookmark.Enabled := False;
  tmrShowBookmark.Tag := 1;

  Index :=  ShowBookmark_Index;

  idxCL := TBookmarkWindow(BookmarkWindow.Objects[Index]).CLPos;

  Program_Data.Clear;
  vdtData.Clear;
  vdtData.RootNodeCount := 0;
  vdtData.Update;
  vdtData.Header.Columns.Clear;

  TimeInfos := TStringList.Create;
  TimeInfos.Clear;
  TimeInfos.Add('05');
  TimeInfos.Add('10');
  TimeInfos.Add('15');
  TimeInfos.Add('20');
  TimeInfos.Add('00');


  if TBookmarkWindow(BookmarkWindow.Objects[Index]).Date = '' then
    TBookmarkWindow(BookmarkWindow.Objects[Index]).Date := FormatDateTime('yyyy-mm-dd', Now);


  dtDate := StrToDateTime(TBookmarkWindow(BookmarkWindow.Objects[Index]).Date, DTFormatDATETIME);

  edtDate.Text := FormatDateTime('dd/mm/yyyy', dtDate);
  lblDateDay.Caption := FormatDateTime('dddd', dtDate);


  vdtData.Header.Options := [{hoAutoResize,} hoColumnResize, hoVisible];


  // === Sloupec Time !!!!! ===
  vdtData.Header.Columns.Add;
  vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 35;
  vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Style := vsOwnerDraw;

  Program_Data.Add('COLUMN');
  idxColumn := Program_Data.Count - 1;
  Program_Data.Objects[idxColumn] := TTVpColumn.Create;
  TTVpColumn(Program_Data.Objects[idxColumn]).ColumnType   := 0;
  TTVpColumn(Program_Data.Objects[idxColumn]).StationID    := '';
  TTVpColumn(Program_Data.Objects[idxColumn]).StationName  := '';
  TTVpColumn(Program_Data.Objects[idxColumn]).StationLogo  := '';
  TTVpColumn(Program_Data.Objects[idxColumn]).Conf         := '';
  TTVpColumn(Program_Data.Objects[idxColumn]).DATA  := TStringList.Create;
  TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Clear;
  // === === === === ===


  if CL.Strings[idxCL]='CL' then
  begin
    pnlTop.Visible := True;

//    vdtData.Header.Options := [{hoAutoResize,} hoColumnResize{, hoVisible}];

{    vdtData.Header.Columns.Add;
    vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 30;}

    vdtData.Header.Columns.Add;
    if TCL(CL.Objects[idxCL]).Width = 0 then
      vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 200
    else
      vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := TCL(CL.Objects[idxCL]).Width;

//    vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 200;
//    vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Options :=
    vdtData.Header.AutoSizeIndex := vdtData.Header.Columns.Count-1;
    vdtData.Header.Options := [hoAutoResize, hoColumnResize{}{, hoVisible}{}];
    vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Style := vsOwnerDraw;

    Program_Data.Add('COLUMN');
    idxColumn := Program_Data.Count - 1;
    Program_Data.Objects[idxColumn] := TTVpColumn.Create;
    TTVpColumn(Program_Data.Objects[idxColumn]).ColumnType   := 1;
    TTVpColumn(Program_Data.Objects[idxColumn]).StationID    := TCL(CL.Objects[idxCL]).ID;
    TTVpColumn(Program_Data.Objects[idxColumn]).StationName  := TCL(CL.Objects[idxCL]).Name;
    TTVpColumn(Program_Data.Objects[idxColumn]).StationLogo  := '';//TCL(CL.Objects[idxCL]).Logo;

    TTVpColumn(Program_Data.Objects[idxColumn]).Conf         := TCL(CL.Objects[idxCL]).Conf;

    TTVpColumn(Program_Data.Objects[idxColumn]).DATA  := TStringList.Create;
    TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Clear;

    GetStationLogo  (  TCL(CL.Objects[idxCL]).ID, imgStationLogo  )    ;

  end
  else if CL.Strings[idxCL]='CLGuide' then
  begin
    pnlTop.Visible := False;

    vdtData.Header.Options := [{hoAutoResize,} hoColumnResize, hoVisible];

{    vdtData.Header.Columns.Add;
    vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 30;}

    idx:=0;
    while ( idx<= TCLGuide(CL.Objects[idxCL]).Items.Count - 1 ) do
    begin
      Application.ProcessMessages;

      vdtData.Header.Columns.Add;
      if TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Width = 0 then
        vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := 200
      else
        vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Width := TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Width;

      vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Text  := TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Name;
      vdtData.Header.Columns[vdtData.Header.Columns.Count-1].Style := vsOwnerDraw;

      Program_Data.Add('COLUMN');
      idxColumn := Program_Data.Count - 1;
      Program_Data.Objects[idxColumn] := TTVpColumn.Create;
      TTVpColumn(Program_Data.Objects[idxColumn]).ColumnType   := 1;
      TTVpColumn(Program_Data.Objects[idxColumn]).StationID    := TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).ID;
      TTVpColumn(Program_Data.Objects[idxColumn]).StationName  := TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Name;
      TTVpColumn(Program_Data.Objects[idxColumn]).StationLogo  := '';//TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Logo;

      TTVpColumn(Program_Data.Objects[idxColumn]).Conf         := TCL(TCLGuide(CL.Objects[idxCL]).Items.Objects[idx]).Conf;

      TTVpColumn(Program_Data.Objects[idxColumn]).DATA  := TStringList.Create;
      TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Clear;

      Inc(idx);
    end;



  end;

//  idxColumn := 0;
  idxColumn := 1; // Time sloupec ne !!
  while ( idxColumn <= Program_Data.Count - 1 ) do
  begin
    Application.ProcessMessages;

//    showmessage(  inttostr(idxColumn))  ;

    SQLtb := SQLdb.GetTable(WideString2UTF8('SELECT * FROM Data WHERE StationID='+''''+TextToSQLText( TTVpColumn(Program_Data.Objects[idxColumn]).StationID ) +''''+' AND Date= '+''''+TBookmarkWindow(BookmarkWindow.Objects[Index]).Date+''''{' ORDER BY Time'}));
    if SQLtb.Count > 0 then
    begin
      while not SQLtb.EOF do
      begin
        TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Add('ITEM');
        idxProgram := TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1;
        TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram] := TTVpProgram.Create;
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).DataID     := SQLtb.FieldAsInteger(SQLtb.FieldIndex['ID']);
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Name       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Name']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).OrigName   := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['OrigName']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Info       := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Info']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).InfoImage  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['InfoImage']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).URL        := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['URL']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Specifications := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Specifications']) );
        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).IncDate    := SQLtb.FieldAsInteger(SQLtb.FieldIndex['IncDate']);

        TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Planned    := GetStationPlanned(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).DataID);

        {      TTVpProgram(Program_Data.Objects[hIndex]).ExtraSpec  := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(Program_Data.Objects[hIndex]).ShowView   := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );
        TTVpProgram(Program_Data.Objects[hIndex]).Planned    := SQLTextToText( SQLtb.FieldAsString(SQLtb.FieldIndex['Time']) );}

        SQLtb.Next;
      end;

    end;

    SQLtb.Free;


    Inc(idxColumn);
  end;


  idx := 0;
  while ( idx <= TimeInfos.Count - 1 ) do
  begin

    iMaxItems := -1;

    //idxColumn := 0;
    idxColumn := 1; //sloupec TIME nezpracovava
    while ( idxColumn <= Program_Data.Count - 1 ) do
    begin
      Application.ProcessMessages;

      idxProgram := 0;
      while ( idxProgram <= TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 ) do
      begin
        Application.ProcessMessages;

        sTime := Copy(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time,1,2);

        if sTime = TimeInfos.Strings[idx] then
        begin
          if idxProgram >= iMaxItems then
          begin
            iMaxItems := idxProgram;
            break;
          end
        end;

        Inc(idxProgram);
      end;

      Inc(idxColumn);
    end;

//    showmessage(TimeInfos.Strings[idx]+#13+'iMaxItems: '+inttostr(iMaxItems));

    //idxColumn := 0;
    idxColumn := 1; //sloupec TIME nezpracovava
    while ( idxColumn <= Program_Data.Count - 1 ) do
    begin
      Application.ProcessMessages;

      idxProgram := 0;
      while ( idxProgram <= TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 ) do
      begin
        Application.ProcessMessages;

        sTime := Copy(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time,1,2);

        if (sTime = TimeInfos.Strings[idx]) {or ((sTime > TimeInfos.Strings[idx]) and (idx <> 0)) }then
        begin
          if idxProgram < iMaxItems then
          begin

            for i := 0 to (iMaxItems - idxProgram) - 1 do
            begin

              TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Insert(idxProgram,'SPACE');
              TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram] := TTVpProgram.Create;

            end;

            break;

          end;
        end;

        Inc(idxProgram);
      end;

      Inc(idxColumn);
    end;


    Inc(idx);
  end;


  // Zpracovani sloupce time podle slouce 1 (sloupec 1 uz je spracovany) => kopie casu do sloupce 0 ze sloupce 1
  idxColumn := 1;
  idxProgram := 0;
  while ( idxProgram <= TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 ) do
  begin
    Application.ProcessMessages;

    TTVpColumn(Program_Data.Objects[0]).DATA.Add('TIME');
    idx := TTVpColumn(Program_Data.Objects[0]).DATA.Count - 1;
    TTVpColumn(Program_Data.Objects[0]).DATA.Objects[idx] := TTVpProgram.Create;
    TTVpProgram(TTVpColumn(Program_Data.Objects[0]).DATA.Objects[idx]).Time := Copy(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time,1,2);

    Inc(idxProgram);
  end;




  // prirazeni casu do sloupce time
  idxColumn := 0;
  idxProgram := 0;
  while ( idxProgram <= TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 ) do
  begin
    Application.ProcessMessages;

    idxTime := TimeInfos.IndexOf( TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time );
    if idxTime = -1 then
    begin
      TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Strings[idxProgram] := 'SPACE';
      TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time := '';
    end
    else
    begin
      TimeInfos.Delete(idxTime);
    end;

    Inc(idxProgram);
  end;



  vdtData.DefaultNodeHeight := {3*}17{5};

  vdtData.RootNodeCount := TTVpColumn(Program_Data.Objects[1]).DATA.Count;

  vdtData.Update;


  // Roztahnuti vsech polozek , a narolovani na ted hrajici porad
  tmpImg := TImage.Create(nil);

  Node := vdtData.GetFirst;

  TopN := nil;

  idxProgram := 0;
  while ( idxProgram <= vdtData.RootNodeCount ) do
  begin
    Application.ProcessMessages;

    if Node = nil then
      break;

    iMaxHeight := 0;

    idxColumn := 1; // sloupec TIME nedelat
    while ( idxColumn <= Program_Data.Count - 1 ) do
    begin
      Application.ProcessMessages;

      iHeight := DrawField(nil, Node, tmpImg.Canvas , vdtData.GetDisplayRect(Node, idxColumn, false), idxColumn, idxProgram, True);
      if iMaxHeight < iHeight then
        iMaxHeight := iHeight;

      Inc(idxColumn);
    end;

    vdtData.NodeHeight[Node] := iMaxHeight;

//    vdtData.NodeHeight[Node] := DrawField(nil, Node, tmpImg.Canvas , vdtData.GetDisplayRect(Node,1, false), 1, idxProgram, True);



    if TopN = nil then
    begin
      if TBookmarkWindow(BookmarkWindow.Objects[Index]).Date = FormatDateTime('YYYY-MM-DD',Now) then
      begin
        idxColumn := 1;
        if idxProgram <= TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 then
        begin

          if TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Strings[idxProgram]='ITEM' then
          begin
            if StrToTime(FormatDateTime('HH:MM',Now)) <= StrToTime(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Time) then
            begin
              TopN := Node;
              TopN := vdtData.GetPrevious(TopN);
            end;
          end;

        end;
      end;
    end;



    Node := vdtData.GetNext(Node);

    Inc(idxProgram);
  end;

  if TopN <> nil then
    vdtData.TopNode := TopN;



  tmrShowBookmark.Tag := 0;

end;

function TfrmWindow.DrawField(Sender: TBaseVirtualTree; Node : PVirtualNode; Canvas: TCanvas; R : TRect; idxColumn : Int64; idxRow : Int64; CalcHeight : Boolean) : Cardinal;
var
  sText, sInfo, sTime : WideString;
  RectD, RectC1, RectC2 : TRect;
  sPrgText : WideString;
  sSpec1, sSpec2, sSpec3: WideString;
  IdxOf, iPrgSpec, iPrgType, iOldFontSize : Integer;

  slSpecifications, slConf: TStringList;
  sPrgGenre, sPrgType, sPrgScreen : WideString;
  sShowInfo : WideString;
begin
//     if CalcHeight = true then
//         showmessage( BoolToStr( CalcHeight, True) );

  if CalcHeight=False then  //
  begin
    Canvas.Font.Color := clWindowText;

    if Odd(idxRow) then
      Canvas.Brush.Color := TextToColor(clLine1, QIP_Colors)
    else
      Canvas.Brush.Color := TextToColor(clLine2, QIP_Colors);

    Canvas.FillRect(R);
  end;



  if TTVpColumn(Program_Data.Objects[idxColumn]).ColumnType = 0 then
  begin  // Time
    if CalcHeight=False then  //
    begin
      if TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Strings[idxRow]='TIME' then
      begin
        Canvas.Font.style := [fsBold];

        Canvas.Brush.Color := TextToColor(clTimerInfo, QIP_Colors);
        Canvas.FillRect(R);

        sInfo := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Time + ':00';
        Windows.DrawTextW(Canvas.Handle, PWideChar(sInfo), Length(sInfo), R, DT_WORDBREAK + DT_NOPREFIX{, False});

        Canvas.Font.style := [];
      end;
    end;
  end
  else
  begin   // Program

    if idxRow > TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Count - 1 then
      Exit;

    if CalcHeight = False then //
    begin
      if TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Planned = True then
      begin
        Canvas.Brush.Color := TextToColor(clPlanned, QIP_Colors);
        Canvas.FillRect(R);
      end;
    end;

    slSpecifications := TStringList.Create;
    slSpecifications.Clear;
    LoadOptions(TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Specifications,slSpecifications);

    sPrgGenre  := '';
    sPrgType   := '';
    sPrgScreen := '';

    IdxOf := slSpecifications.IndexOf('Genre');
    if IdxOf <> -1 then
      sPrgGenre := TItemOptions(slSpecifications.Objects[IdxOf]).dataWideString;

    IdxOf := slSpecifications.IndexOf('Type');
    if IdxOf <> -1 then
      sPrgType := TItemOptions(slSpecifications.Objects[IdxOf]).dataWideString;

    IdxOf := slSpecifications.IndexOf('Screen');
    if IdxOf <> -1 then
      sPrgScreen := TItemOptions(slSpecifications.Objects[IdxOf]).dataWideString;

    // nahrazeni textu
    if StrPosE(sPrgScreen,'Wide;',1,False) <> 0 then
      sPrgScreen := 'WIDE';

    if StrPosE(sPrgType,'Live;',1,False) <> 0 then
      sPrgType := 'LIVE'
    else if StrPosE(sPrgType,'Premiere;',1,False) <> 0 then
      sPrgType := 'PREMIÉRA'
    else if StrPosE(sPrgType,'Repeat;',1,False) <> 0 then
      sPrgType := 'OPAKOVÁNÍ';

    if StrPosE(sPrgGenre,'Documentary;',1,False) <> 0 then
      sPrgGenre := 'Dokument'
    else if StrPosE(sPrgGenre,'Film;',1,False) <> 0 then
      sPrgGenre := 'Film'
    else if StrPosE(sPrgGenre,'Entertainment;',1,False) <> 0 then
      sPrgGenre := 'Zábava'
    else if StrPosE(sPrgGenre,'Music;',1,False) <> 0 then
      sPrgGenre := 'Hudba'
    else if StrPosE(sPrgGenre,'Sport;',1,False) <> 0 then
      sPrgGenre := 'Sport'
    else if StrPosE(sPrgGenre,'Children;',1,False) <> 0 then
      sPrgGenre := 'Dìtem'
    else if StrPosE(sPrgGenre,'Serial;',1,False) <> 0 then
      sPrgGenre := 'Seriál'
    else if StrPosE(sPrgGenre,'The News;',1,False) <> 0 then
      sPrgGenre := 'Zprávy';
    // ==


    //Calc
    sText := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Name
     + ' ' + sPrgType + ' ' + sPrgScreen;
    Canvas.Font.style := [fsBold];
    RectC1.Left := 0 + 40;
    RectC1.Right := R.Right - R.Left;
    RectC1.Top := 0;
    RectC1.Bottom := 0;
    Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectC1, DT_WORDBREAK + DT_CALCRECT + DT_NOPREFIX{, False});


    slConf := TStringList.Create;
    slConf.Clear;
    LoadOptions(TTVpColumn(Program_Data.Objects[idxColumn]).Conf,slConf);

    sShowInfo  := '';

    IdxOf := slConf.IndexOf('Info');
    if IdxOf <> -1 then
      sShowInfo := TItemOptions(slConf.Objects[IdxOf]).dataWideString;

    // Show Info ?
    if StrPosE(sShowInfo,'False;',1,False) <> 0 then
      sInfo := ''
    else
      sInfo := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Info;

    Canvas.Font.style := [fsItalic];
    RectC2.Left := 0 + 40;
    RectC2.Right := R.Right - R.Left;
    RectC2.Top := 0;
    RectC2.Bottom := 0;
    Windows.DrawTextW(Canvas.Handle, PWideChar(sInfo), Length(sInfo), RectC2, DT_WORDBREAK + DT_CALCRECT + DT_NOPREFIX{, False});



    if CalcHeight = False then //
    begin
      sTime := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxRow]).Time;
      Canvas.Font.style := [fsBold];
      RectD.Left   := R.Left + 2;
      RectD.Right  := R.Right - 5;
      RectD.Top    := R.Top + 2;
      RectD.Bottom := RectC1.Bottom + 5;
      Windows.DrawTextW(Canvas.Handle, PWideChar(sTime), Length(sTime), RectD, DT_WORDBREAK + DT_NOPREFIX{, False});


      // Typ poradu
      iOldFontSize := Canvas.Font.Size;
      Canvas.Font.Size := 5;
      Canvas.Font.style := [fsBold];
      RectD.Left   := R.Left + 2;
      RectD.Right  := R.Right - 5;
      RectD.Top    := R.Top + 2   +   13;
      RectD.Bottom := RectC1.Bottom + 5      +   13;
      Windows.DrawTextW(Canvas.Handle, PWideChar(sPrgGenre), Length(sPrgGenre), RectD, DT_WORDBREAK + DT_NOPREFIX{, False});

      Canvas.Font.Size  :=  iOldFontSize;


      Canvas.Font.style := [fsBold];
      RectD.Left   := R.Left + 40;
      RectD.Right  := R.Right - 5;
      RectD.Top    := R.Top + 2;
      RectD.Bottom := RectC1.Bottom + 5;
      Windows.DrawTextW(Canvas.Handle, PWideChar(sText), Length(sText), RectD, DT_WORDBREAK + DT_NOPREFIX{, False});


      //    sInfo := IntToStr(R.Right - R.Left) + ' '+sInfo;
      //sInfo := IntToStr(RectC2.Bottom - RectC2.Top) + '/'+ IntToStr(RectC2.Right - RectC2.Left) + ' '+sInfo;

      Canvas.Font.style := [fsItalic];
      RectD.Left   := R.Left + 40;
      RectD.Right  := R.Right - 5 ;//-100;
      RectD.Top    := R.Top + (5 + RectC1.Bottom - RectC1.Top);
      RectD.Bottom := (5 + RectC1.Bottom - RectC1.Top) + (RectC2.Bottom - RectC2.Top) + 5{+100}; //R{ectC2}.Bottom;

      //    sInfo := IntToStr(RectD.Bottom - RectD.Top) + '/'+ IntToStr(RectD.Right - RectD.Left) + ' '+sInfo;

      Windows.DrawTextW(Canvas.Handle, PWideChar(sInfo), Length(sInfo), RectD, DT_WORDBREAK + DT_NOPREFIX{, False});

      if Sender.NodeHeight[Node] <{>} (RectC1.Bottom - RectC1.Top) + (RectC2.Bottom - RectC2.Top) then
        Sender.NodeHeight[Node] := (RectC1.Bottom - RectC1.Top) + (5 + RectC2.Bottom - RectC2.Top);
    end
    else
    begin
      Result := (RectC1.Bottom - RectC1.Top) + (5 + RectC2.Bottom - RectC2.Top);
    end;


  end;


end;


procedure TfrmWindow.vdtDataAdvancedHeaderDraw(Sender: TVTHeader;
  var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
var
  R : TRect;
begin
//
  with Sender as TVTHeader, PaintInfo do
  begin
R :=       PaintInfo.PaintRectangle;

//PaintInfo.TargetCanvas;
//R := ContentRect;
//    InflateRect(R, -TextMargin, 0);

//    if Odd(Idx) then
//      Canvas.Brush.Color := clLine1
//    else
{      PaintInfo.Target}Canvas.Brush.Color := clRed;

{    PaintInfo.Target}Canvas.FillRect(R);

      PaintInfo.TargetCanvas.Brush.Color := clRed;

    PaintInfo.TargetCanvas.FillRect(R);
  end;
end;

procedure TfrmWindow.vdtDataDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  R : TRect;

begin



  with Sender as TVirtualDrawTree, PaintInfo do
  begin

    SetBkMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);

    {    Dec(R.Right);
    Dec(R.Bottom);  }

    //Malovat od zacatku (ne jako TreeView (spojovaci cary))
    if (Column=0) OR (Column=-1) then
      R.Left  := 0
    else
      R.Left  := R.Left - 8;
    //   a az do konce
    R.Right := R.Right + 4;

    DrawField(Sender, Node, Canvas, R, Column, Node.Index, False);

{    // Malovat focus
    if (Column = FocusedColumn) and (Node = FocusedNode) then
    begin
      DrawFocusRect(Canvas.Handle, R)
    end;}

  end;


end;

procedure TfrmWindow.vdtDataFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  /////
end;

procedure TfrmWindow.vdtDataGetPopupMenu(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
  var AskParent: Boolean; var PopupMenu: TPopupMenu);
begin
  ShowContextMenu(Node.Index, Column);
end;

procedure TfrmWindow.vdtDataHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
  Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
  DropMark: TVTDropMarkMode);
begin
//
  with Sender as TVTHeader{, PaintInfo} do
  begin
//    if Odd(Idx) then
//      Canvas.Brush.Color := clLine1
//    else
      Canvas.Brush.Color := clRed;

    Canvas.FillRect(R);
  end;

end;

procedure TfrmWindow.ShowContextMenu(idxProgram: Integer; idxColumn: Integer);
var
  where: TPoint;
  Index,i : Integer;

//  NewItem: TMenuItem;

begin

  miContextMenu_ProgramInfo.Caption   := QIPPlugin.GetLang(LI_INFORMATION);

  miContextMenu_CopyName.Caption      := LNG('MENU ContactMenu', 'CopyName', 'Copy name');
  miContextMenu_CopyNameAndDescription.Caption := LNG('MENU ContactMenu', 'CopyNameAndDescription', 'Copy name and description');

  miContextMenu_Close.Caption         := QIPPlugin.GetLang(LI_CLOSE);
  miContextMenu_Edit.Caption          := LNG('MENU ContactMenu', 'Edit', 'Edit');
  miContextMenu_Remove.Caption        := QIPPlugin.GetLang(LI_DELETE);

  miContextMenu_RefreshAll.Caption          := LNG('MENU ContactMenu', 'RefreshAll', 'Refresh all');

  Index := tabWindow.TabIndex;
  if (idxColumn = -1) and (idxProgram=-1) then
  begin
    miContextMenu_ProgramName.Visible := False;
    miContextMenu_ProgramInfo.Visible := False;
    miContextMenu_Plan.Visible := False;

    miContextMenu_CopyName.Visible := False;
    miContextMenu_CopyNameAndDescription.Visible := False;
  end
  else if (idxColumn = 0) or (TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Strings[idxProgram]='SPACE') then
  begin
    miContextMenu_ProgramName.Visible := False;
    miContextMenu_ProgramInfo.Visible := False;
    miContextMenu_Plan.Visible := False;

    miContextMenu_CopyName.Visible := False;
    miContextMenu_CopyNameAndDescription.Visible := False;
  end
  else
  begin
    miContextMenu_ProgramName.Visible := True;
    miContextMenu_ProgramInfo.Visible := True;
    miContextMenu_Plan.Visible := True;

    miContextMenu_CopyName.Visible := True;
    miContextMenu_CopyNameAndDescription.Visible := True;


    miContextMenu_ProgramName.Enabled := False;
    miContextMenu_ProgramName.Caption := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Name;

    ContextMenu_DataID := TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).DataID;

    ContextMenu_idxColumn   := idxColumn;
    ContextMenu_idxProgram  := idxProgram;


    if TTVpProgram(TTVpColumn(Program_Data.Objects[idxColumn]).DATA.Objects[idxProgram]).Planned = True then
    begin
      miContextMenu_Plan.ImageIndex := 9;
      miContextMenu_Plan.Caption := LNG('MENU ContactMenu', 'EditSchedule', 'Edit schedule')
    end
    else
    begin
      miContextMenu_Plan.ImageIndex := 8;
      miContextMenu_Plan.Caption := LNG('MENU ContactMenu', 'ScheduleProgramme', 'Schedule programme');
    end;

  end;


  where := Mouse.CursorPos;
  pmContextMenu.Popup(where.X,where.Y);

end;

procedure TfrmWindow.btnDateBackClick(Sender: TObject);
begin
  TBookmarkWindow(BookmarkWindow.Objects[tabWindow.TabIndex]).Date := FormatDateTime('yyyy-mm-dd',StrToDateTime(TBookmarkWindow(BookmarkWindow.Objects[tabWindow.TabIndex]).Date, DTFormatDATETIME) - 1);
  ShowBookmark(tabWindow.TabIndex);
end;

procedure TfrmWindow.btnDateNextClick(Sender: TObject);
begin
  TBookmarkWindow(BookmarkWindow.Objects[tabWindow.TabIndex]).Date := FormatDateTime('yyyy-mm-dd',StrToDateTime(TBookmarkWindow(BookmarkWindow.Objects[tabWindow.TabIndex]).Date, DTFormatDATETIME) + 1);
  ShowBookmark(tabWindow.TabIndex);
end;

procedure TfrmWindow.FormClose(Sender: TObject; var Action: TCloseAction);
var INI : TIniFile;
begin

  tmrNP.Enabled := False;
  tmrShowBookmark.Enabled := False;

  INIGetProfileConfig(INI);

  INIWriteInteger(INI, 'Window', 'X', Left );
  INIWriteInteger(INI, 'Window', 'Y', Top );

  INIWriteInteger(INI, 'Window', 'Width', Width );
  INIWriteInteger(INI, 'Window', 'Height', Height );

  INIFree(INI);


  if CloseBookmarks = True then
    BookmarkWindow.Clear;


  WindowIsShow := False;
end;

procedure TfrmWindow.FormCreate(Sender: TObject);
var
  ProgressBarStyle: integer;
begin  {
  pbStatusBar.Left := sbStatusBar.Left + 5;
  pbStatusBar.Top := sbStatusBar.Top + 2;
  pbStatusBar.Height := sbStatusBar.Height - 4;
  pbStatusBar.Width := sbStatusBar.Panels[0].Width - 10;


  pbStatusBar.Visible := False;
  pbStatusBar.Position := 0;
        }

  //enable status bar 2nd Panel custom drawing
  sbStatusBar.Panels[0].Style := psOwnerDraw;

  //place the progress bar into the status bar
  pbStatusBar.Parent := sbStatusBar;

  //remove progress bar border
  ProgressBarStyle := GetWindowLong(pbStatusBar.Handle,
                                    GWL_EXSTYLE);
  ProgressBarStyle := ProgressBarStyle
                      - WS_EX_STATICEDGE;
  SetWindowLong(pbStatusBar.Handle,
                GWL_EXSTYLE,
                ProgressBarStyle);

  pbStatusBar.Visible := False;
  pbStatusBar.Position := 0;

end;

procedure TfrmWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (ssCtrl in Shift) then
  begin
    if  (ssShift in Shift) and (ssCtrl in Shift) then
    begin
      if Key=9 then   // Ctrl + Shift + Tab
      begin
        if tabWindow.TabIndex = 0 then
          tabWindow.TabIndex := tabWindow.Tabs.Count - 1
        else
          tabWindow.TabIndex := tabWindow.TabIndex - 1;

        ShowBookmark(tabWindow.TabIndex);
      end;
    end else
    begin
      if Key=9 then   // Ctrl + Tab
      begin
        if tabWindow.TabIndex = tabWindow.Tabs.Count - 1 then
          tabWindow.TabIndex := 0
        else
          tabWindow.TabIndex := tabWindow.TabIndex + 1;

        ShowBookmark(tabWindow.TabIndex);
      end
      else if Key = 87 then  // Ctrl + W
      begin
        RemoveTab(tabWindow.TabIndex);
      end
{      else if Key = 65 then
      begin
        lvData.SelectAll;
      end};
    end;
  end else
  begin
    if Key=27 then
      Close
(*    else if Key=46 then
      SQLRemoveItem(tabWindow.TabIndex, {lvData.ItemIndex}-2)
    else if Key=32 then
      SQLSetReadUnRead(tabWindow.TabIndex, {lvData.ItemIndex}-2, 3)    *)
   end;

end;

procedure TfrmWindow.FormResize(Sender: TObject);
begin
  pnlDateButtons.Left := Round((pnlDate.Width / 2) - (pnlDateButtons.Width / 2));

  pnlNP.Width := pnlTop.Width - pnlNP.Left;
  pnlNPGauge.Width := pnlNP.Width - (pnlNPGauge.Left * 2);

  lblNPTime2.Left := pnlNPGauge.Width + pnlNPGauge.Left - lblNPTime2.Width;
  lblNPProgramName.Width := pnlNPGauge.Width - (lblNPProgramName.Left * 2);

end;

procedure TfrmWindow.FormShow(Sender: TObject);
var i: Int64;
    INI : TIniFile;

  idx : Integer;
  wStr : WideString;
begin
  WindowIsShow := True;

  Icon := PluginSkin.PluginIcon.Icon;

  //32 bit support - transparent atd....
  ilToolbar.Handle := ImageList_Create(ilToolbar.Width, ilToolbar.Height, ILC_COLOR32 or ILC_MASK, ilToolbar.AllocBy, ilToolbar.AllocBy);

  ilToolbar.AddIcon(PluginSkin.Refresh.Icon);
  ilToolbar.AddIcon(PluginSkin.Close.Icon);
{  ilToolbar.AddIcon(PluginSkin.Details.Icon);
  ilToolbar.AddIcon(PluginSkin.Preview.Icon);
  ilToolbar.AddIcon(PluginSkin.Edit.Icon);
  ilToolbar.AddIcon(PluginSkin.AddContact.Icon);
  ilToolbar.AddIcon(PluginSkin.RenameContact.Icon);
  ilToolbar.AddIcon(PluginSkin.RemoveContact.Icon);
  ilToolbar.AddIcon(PluginSkin.Options.Icon);
  ilToolbar.AddIcon(PluginSkin.Gmail.Icon);
  ilToolbar.AddIcon(PluginSkin.Enclosure.Icon);
  ilToolbar.AddIcon(PluginSkin.RSS1.Icon);
  ilToolbar.AddIcon(PluginSkin.RSS2.Icon);
  ilToolbar.AddIcon(PluginSkin.Gmail1.Icon);
  ilToolbar.AddIcon(PluginSkin.Gmail2.Icon);
  ilToolbar.AddIcon(PluginSkin.Remove.Icon); }


{
  miContextMenu_OpenURL.Caption := QIPPlugin.GetLang(LI_OPEN);
  //miContextMenu_OpenMsg.Caption  := LNG('FORM Window', 'ContextMenu.Remove', 'Remove');
  miContextMenu_RemoveMsg.Caption    := LNG('MENU ContactMenu', 'RemoveMsg', 'Remove message');

  miContextMenu_MarkAsRead.Caption    := LNG('MENU ContactMenu', 'MarkAsRead', 'Mark as read');
  miContextMenu_MarkAsUnread.Caption    := LNG('MENU ContactMenu', 'MarkAsUnread', 'Mark as unread');
  miContextMenu_MarkFeedAsRead.Caption    := LNG('MENU ContactMenu', 'MarkFeedAsRead', 'Mark feed as read');
  miContextMenu_MarkFeedAsUnread.Caption    := LNG('MENU ContactMenu', 'MarkFeedAsUnread', 'Mark feed as unread');

  miContextMenu_Close.Caption   := QIPPlugin.GetLang(LI_CLOSE_MSG_TAB_WINDOW);
  miContextMenu_Refresh.Caption := QIPPlugin.GetLang(LI_REFRESH);
  miContextMenu_ContactDetails.Caption := QIPPlugin.GetLang(LI_USER_DETAILS);
  miContextMenu_Edit.Caption    := LNG('MENU ContactMenu', 'Edit', 'Edit');
  miContextMenu_CleanDatabase.Caption    := LNG('MENU ContactMenu', 'CleanDatabase', 'Clean database');

  miContextMenu_AddFeed.Caption  := LNG('MENU ContactMenu', 'AddFeed', 'Add feed');
  miContextMenu_AddGmail.Caption := LNG('MENU ContactMenu', 'AddGmail', 'Add Gmail');
  miContextMenu_RenameFeed.Caption  := LNG('MENU ContactMenu', 'RenameFeed', 'Rename feed');
  miContextMenu_RemoveFeed.Caption  := LNG('MENU ContactMenu', 'RemoveFeed', 'Remove feed');
  miContextMenu_MoveTo.Caption := LNG('MENU ContactMenu', 'MoveTo', 'Move to');

  miContextMenu_Options.Caption  := QIPPlugin.GetLang(LI_OPTIONS);
 }

//  tbtnRefresh.Hint := QIPPlugin.GetLang(LI_REFRESH);

  tbtnClose.Hint := QIPPlugin.GetLang(LI_CLOSE_MSG_TAB_WINDOW);

//  tbtnPreview.Hint := LNG('FORM Window', 'Preview', 'Preview');

//  tbtnDetails.Hint := QIPPlugin.GetLang(LI_USER_DETAILS);
//  tbtnEdit.Hint := LNG('MENU ContactMenu', 'Edit', 'Edit');

//  tbtnAddFeed.Hint  := LNG('MENU ContactMenu', 'AddFeed', 'Add feed');
{  tbtnRenameFeed.Hint  := LNG('MENU ContactMenu', 'RenameFeed', 'Rename feed');
  tbtnRemove.Hint  := LNG('MENU ContactMenu', 'RemoveFeed', 'Remove feed');}

//  miContextMenu_Enclosures.Caption := LNG('MENU ContactMenu', 'Enclosures', 'Enclosures');

//  tbtnOptions.Hint := QIPPlugin.GetLang(LI_OPTIONS);

//  lvData.Column[0].Caption     := QIPPlugin.GetLang(LI_TOPIC);
//  lvData.Column[1].Caption     := LNG('FORM Window', 'Date', 'Date');

//  lblPreviewComments.Caption := LNG('FORM Window', 'Comments', 'Comments');




  INIGetProfileConfig(INI);
  Left := INIReadInteger(INI, 'Window', 'X', 50);
  Top := INIReadInteger(INI, 'Window', 'Y', 50);

  Width := INIReadInteger(INI, 'Window', 'Width', Width);
  Height := INIReadInteger(INI, 'Window', 'Height', Height);

  INIFree(INI);

  Program_Data := TStringList.Create;
  Program_Data.Clear;
  

  tabWindow.Tabs.Clear;

  tabWindow.TabHeight := 20;

  gaugeNP := TPhryGauge.Create(nil);
  gaugeNP.Parent := pnlNPGauge;
  gaugeNP.Align := alClient;
  gaugeNP.MinValue := 0;
  gaugeNP.MaxValue := 100;
  gaugeNP.TextStyle := tsNoText;
  gaugeNP.ProgressCount := 1;
  gaugeNP.Colors[1] := TextToColor(clProgress1, QIP_Colors);//clGreen;
  gaugeNP.BackColor := TextToColor(clProgress2, QIP_Colors);

  gaugeNP.Progress[1] := 50;


  i:=0;
  while ( i<= BookmarkWindow.Count - 1 ) do
  begin
    Application.ProcessMessages;

    idx := TBookmarkWindow(BookmarkWindow.Objects[i]).CLPos;

    if CL.Strings[idx]='CL' then
      wStr := TCL(CL.Objects[idx]).Name
    else if CL.Strings[idx]='CLGuide' then
      wStr := TCLGuide(CL.Objects[idx]).Name;

    tabWindow.Tabs.Add( TabSpaces + wStr  + TabSpaces);


    Inc(i);

  end;


  tmrNP.Enabled := True;

  tabWindow.TabIndex := tabWindow.Tabs.Count - 1; //0;
  ShowBookmark(tabWindow.TabIndex);


end;

procedure TfrmWindow.lvDataMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if Button = mbRight then
  begin
    ShowContextMenu( 0, 0 );
  end;

end;

procedure TfrmWindow.miContextMenu_CleanDatabaseClick(Sender: TObject);
var sSQL: WideString;
begin

end;

procedure TfrmWindow.miContextMenu_CloseClick(Sender: TObject);
begin
  tbtnCloseClick(Sender);
end;

procedure TfrmWindow.miContextMenu_ContactDetailsClick(Sender: TObject);
begin
  showmessage('not implemented!');
end;

procedure TfrmWindow.miContextMenu_CopyNameAndDescriptionClick(Sender: TObject);
var
  A: array[0..65000] of char;
begin
  StrPCopy(A, TTVpProgram(TTVpColumn(Program_Data.Objects[ContextMenu_idxColumn]).DATA.Objects[ContextMenu_idxProgram]).Name+#13+#10+
              TTVpProgram(TTVpColumn(Program_Data.Objects[ContextMenu_idxColumn]).DATA.Objects[ContextMenu_idxProgram]).Info);
  Clipboard.SetTextBuf(A);

end;

procedure TfrmWindow.miContextMenu_CopyNameClick(Sender: TObject);
var
  A: array[0..65000] of char;
begin

  StrPCopy(A, TTVpProgram(TTVpColumn(Program_Data.Objects[ContextMenu_idxColumn]).DATA.Objects[ContextMenu_idxProgram]).Name);
  Clipboard.SetTextBuf(A);

end;

procedure TfrmWindow.miContextMenu_EditClick(Sender: TObject);
begin

  OpenItemOptions( TBookmarkWindow(BookmarkWindow.Objects[ tabWindow.TabIndex ]).CLPos );

end;

procedure TfrmWindow.miContextMenu_PlanClick(Sender: TObject);

begin

  OpenPlanEdit( ContextMenu_DataID );

end;

procedure TfrmWindow.miContextMenu_ProgramInfoClick(Sender: TObject);
begin

  OpenProgramInfo( ContextMenu_DataID );

end;

procedure TfrmWindow.miContextMenu_RefreshAllClick(Sender: TObject);
begin
  NextUpdate := Now;
end;

procedure TfrmWindow.miContextMenu_RemoveClick(Sender: TObject);
begin
  OpenRemoveContact( TBookmarkWindow(BookmarkWindow.Objects[ tabWindow.TabIndex ]).CLPos );
end;

procedure TfrmWindow.tabWindowChange(Sender: TObject);
begin
  ShowBookmark(tabWindow.TabIndex);
end;

procedure TfrmWindow.tabWindowDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  sText, sValue, sMsgCount, sMsgUnreadCount, sMsgNewCount, sMsg : WideString;
  R, R1, R2 : TRect;
begin

  sText := Trim(tabWindow.Tabs[TabIndex]) + ' ' + sMsg;
  R.Left := Rect.Left;
  R.Top  := Rect.Top;
  R.Right:= Rect.Right;
  R.Bottom := Rect.Bottom;

  R1.Left := Rect.Left;
  R1.Top  := Rect.Top;
  R1.Right:= Rect.Right;
  R1.Bottom := Rect.Bottom;

  R2.Left := Rect.Left;
  R2.Top  := Rect.Top;
  R2.Right:= Rect.Right;
  R2.Bottom := Rect.Bottom;

  if Active = True then
  begin
(*    Control.Canvas.Brush.Color := clred;  //QIP_Colors.TabActLiTop;

    Control.Canvas.MoveTo({0,0}Rect.Left,Rect.Top);
//    Control.Canvas.LineTo(Rect.Right - Rect.Left,Rect.Top);

    Control.Canvas.LineTo({Rect.Right - Rect.Left,Rect.Bottom-Rect.Top}Rect.Left+100,Rect.top+20);

//    Control.Canvas.Brush.Color := QIP_Colors.TabActLight;

    Control.Canvas.MoveTo(Rect.Left,Rect.Top + 1);
    Control.Canvas.LineTo(Rect.Right - Rect.Left,Rect.Top + 1);   *)

    SetBkMode(Control.Canvas.Handle, TRANSPARENT);

    GradVertical(Control.Canvas, R2, QIP_Colors.TabActive, QIP_Colors.TabActGrad );

    R1.Left := R1.Left + 26+4-4;

    Control.Canvas.Font.Color := QIP_Colors.TabFontAct;

    R1.Top := R1.Top + 5;
    BBCodeDrawText(Control.Canvas,sText,R1,False,QIP_Colors);

//    DrawTextW(Control.Canvas.Handle, PWideChar(sText), Length(sText), R1, DT_NOPREFIX + DT_LEFT + DT_VCENTER + DT_SINGLELINE  );
(*
    if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Logo.ExistLogo = True then
      Control.Canvas.Draw(Rect.Left + 4+2, Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Logo.SmallImage.Picture.Graphic)
    else
    begin
      if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).MsgsCount.MsgUnreadCount = 0 then
        if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_GMAIL then
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.Gmail2.Image.Picture.Graphic)
        else if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_RPC_SEZNAM then
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.Seznam2.Image.Picture.Graphic)
        else
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.RSS2.Image.Picture.Graphic)
      else
        if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_GMAIL then
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.Gmail1.Image.Picture.Graphic)
        else if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_RPC_SEZNAM then
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.Seznam1.Image.Picture.Graphic)
        else
          Control.Canvas.Draw(Rect.Left + 4+2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8 - 1, PluginSkin.RSS1.Image.Picture.Graphic);
    end;   *)

  end
  else
  begin
    SetBkMode(Control.Canvas.Handle, TRANSPARENT);

    R2.Bottom := R2.Bottom + 3;
    GradVertical(Control.Canvas, R2, QIP_Colors.TabInactive, QIP_Colors.TabInactGrad );

    R1.Top := R1.Top + 1;
    R1.Left := R1.Left + 26-4;

    Control.Canvas.Font.Color := QIP_Colors.TabFontInact;    

//    R1.Top := R1.Top + 2;
    DrawTextW(Control.Canvas.Handle, PWideChar(sText), Length(sText), R1, DT_NOPREFIX + DT_LEFT + DT_VCENTER + DT_SINGLELINE , false );
(*
    if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Logo.ExistLogo = True then
      Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Logo.SmallImage.Picture.Graphic)
    else
    begin
      if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).MsgsCount.MsgUnreadCount = 0 then
        if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_GMAIL then
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.Gmail2.Image.Picture.Graphic)
        else if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_RPC_SEZNAM then
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.Seznam2.Image.Picture.Graphic)
        else
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.RSS2.Image.Picture.Graphic)
      else
        if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_GMAIL then
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.Gmail1.Image.Picture.Graphic)
        else if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).Style = FEED_RPC_SEZNAM then
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.Seznam1.Image.Picture.Graphic)
        else
          Control.Canvas.Draw(Rect.Left +2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.RSS1.Image.Picture.Graphic);
    end;     *)

  end;
(*
  if TFeed(TCL(CL.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).CLPos ]).Feed.Objects[ TBookmarkWindow(BookmarkWindow.Objects[TabIndex]).RSSPos ]).NewItems = True then
    if NotificationNewItems=1 then
      Control.Canvas.Draw(Rect.Left + 2,Rect.Top + Round((Rect.Bottom - Rect.Top) / 2 ) - 8, PluginSkin.Msg.Image.Picture.Graphic);
*)

end;



procedure TfrmWindow.tabWindowMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if Button = mbRight then
  begin
    ShowContextMenu( -1 , -1);
  end;

end;

procedure TfrmWindow.tbtnOptionsClick(Sender: TObject);
begin
  OpenOptions;
end;

procedure TfrmWindow.tbtnCloseClick(Sender: TObject);
begin
  RemoveTab(tabWindow.TabIndex);
end;

end.
