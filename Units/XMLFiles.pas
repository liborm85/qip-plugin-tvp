unit XMLFiles;

interface

uses SysUtils, Classes, Windows, Forms, Dialogs;

type
(*
  { HEvent }
  THEvent = class
    EvDate    : WideString;
    EvTime    : WideString;
    EvType    : WideString;
    EvMessage : WideString;
  end;

  { XMLHistory }
  TXMLHistory = class
    AccountID   : WideString;
    ContactID   : WideString;
    ContactName : WideString;
    Protocol    : WideString;
    Events      : TStringList;
  end;       *)

  { XML Attrs }
  TXMLAttrs = class
  public
    dataString : RawByteString;
  end;

  procedure LoadXML_CL(sXMLText : RawByteString; Data : TStringList);

  procedure LoadCL;
  procedure SaveCL;



implementation

uses LibXmlParser, General, Convs;

(*
===============================================================================================
TElementNode
===============================================================================================
*)

TYPE
  TElementNode = CLASS
                   Content : AnsiString;
                   Attr    : TStringList;
                   CONSTRUCTOR Create (TheContent : RawByteString; TheAttr : TNvpList);
                   DESTRUCTOR Destroy; OVERRIDE;
                 END;

CONSTRUCTOR TElementNode.Create (TheContent : RawByteString; TheAttr : TNvpList);
VAR
  I : INTEGER;
BEGIN
  INHERITED Create;
  Content := TheContent;
  Attr    := TStringList.Create;
  IF TheAttr <> NIL THEN
    FOR I := 0 TO TheAttr.Count-1 DO
      Attr.Add (TNvpNode (TheAttr [I]).Name + '=' + TNvpNode (TheAttr [I]).Value);
END;


DESTRUCTOR TElementNode.Destroy;
BEGIN
  Attr.Free;
  INHERITED Destroy;
END;

////////////////////////////////////////////////////////////////////////////////

procedure LoadXML_CL(sXMLText : RawByteString; DATA : TStringList);
var
  XmlParser   : TXmlParser;
  sn          : RawByteString;
  EN          : TElementNode;

  idxCL, idxCL2: Integer;

  procedure CommandXML(sCommand: RawByteString; sValue: RawByteString; Attrs: TStringList; bAttrs: Boolean);
  begin
    if (sCommand = 'BEGIN') and (sValue = '/CL/Item') then
    begin
      DATA.Add( 'CL' );
      idxCL := DATA.Count - 1;
      DATA.Objects[idxCL] := TCL.Create;
      TCL(DATA.Objects[idxCL]).Name    := '';
      TCL(DATA.Objects[idxCL]).ID      := '';
      TCL(DATA.Objects[idxCL]).Width   := 0;
      TCL(DATA.Objects[idxCL]).Conf    := '';
    end;

    if (sCommand = 'BEGIN') and (sValue = '/CL/Guide') then
    begin
      DATA.Add( 'CLGuide' );
      idxCL := DATA.Count - 1;
      DATA.Objects[idxCL] := TCLGuide.Create;
      TCLGuide(DATA.Objects[idxCL]).Name    := '';
      TCLGuide(DATA.Objects[idxCL]).Items       := TStringList.Create;
      TCLGuide(DATA.Objects[idxCL]).Items.Clear;
    end;

    if (sCommand = 'BEGIN') and (sValue = '/CL/Guide/Item') then
    begin
      TCLGuide(DATA.Objects[idxCL]).Items.Add( 'CL' );
      idxCL2 := TCLGuide(DATA.Objects[idxCL]).Items.Count - 1;
      TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2] := TCL.Create;

      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Name    := '';
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).ID      := '';
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Width   := 0;
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Conf    := '';
    end;

    if sCommand = '/CL/Item/ID' then
      TCL(DATA.Objects[idxCL]).ID     := UTF8ToWideString( sValue )
    else if sCommand = '/CL/Item/Name' then
      TCL(DATA.Objects[idxCL]).Name   := UTF8ToWideString( sValue )
    else if sCommand = '/CL/Item/Conf' then
      TCL(DATA.Objects[idxCL]).Conf   := UTF8ToWideString( sValue )

    else if sCommand = '/CL/Guide/Name' then
      TCLGuide(DATA.Objects[idxCL]).Name      := UTF8ToWideString( sValue )

    else if sCommand = '/CL/Guide/Item/ID' then
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).ID      := UTF8ToWideString( sValue )
    else if sCommand = '/CL/Guide/Item/Name' then
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Name    := UTF8ToWideString( sValue )
    else if sCommand = '/CL/Guide/Item/Width' then
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Width   := ConvStrToInt( sValue )
    else if sCommand = '/CL/Guide/Item/Conf' then
      TCL(TCLGuide(DATA.Objects[idxCL]).Items.Objects[idxCL2]).Conf    := UTF8ToWideString( sValue )
    ;
    Attrs.Clear;
  end;

  procedure ReadItemXML(s: RawByteString);
  var ii: Integer;
      sAttrs : TStringList;
      hIndex1: Integer;
  begin

    sAttrs := TStringList.Create;
    sAttrs.Clear;

    while XmlParser.Scan do
    begin
      case XmlParser.CurPartType of
        ptXmlProlog : begin
                        CommandXML( 'CODEPAGE' ,XmlParser.CurEncoding, sAttrs, False);
                      end;
        ptDtdc      : begin
                      end;
        ptStartTag,
        ptEmptyTag  : begin
                        if XmlParser.CurAttr.Count > 0 then
                        begin
                          sn:= s + '/' + XmlParser.CurName ;

                          EN := TElementNode.Create ('', XmlParser.CurAttr);

                          sAttrs.Clear;

                          for Ii := 0 TO EN.Attr.Count-1 do
                          begin

                            sAttrs.Add( Trim( EN.Attr.Names [Ii] ) );
                            hIndex1:= sAttrs.Count - 1;
                            sAttrs.Objects[hIndex1] := TXMLAttrs.Create;
                            TXMLAttrs(sAttrs.Objects[hIndex1]).dataString := Trim( EN.Attr.Values [EN.Attr.Names [Ii]]);

                          end;

                          CommandXML( sn, '', sAttrs, True );

                          sAttrs.Clear;

                        end;

                        if XmlParser.CurPartType = ptStartTag then   // Recursion
                        begin
                          sn:= s + '/' + XmlParser.CurName ;

                          CommandXML('BEGIN' , sn, sAttrs, False );

                          ReadItemXML (sn);
                        end

                      end;
        ptEndTag    : begin
                        CommandXML('END' , s, sAttrs, False );
                        BREAK;
                      end;
        ptContent,
        ptCData     : begin
                        if Trim( XmlParser.CurContent)='' then

                        else
                        begin
                          CommandXML( s , Trim( XmlParser.CurContent ), sAttrs, False );
                        end;

                      end;
        ptComment   : begin
                      end;
        ptPI        : begin
                      end;

      end;

    end;

  end;

begin

  if Copy(sXMLText,1,3) = 'ï»¿' then
    sXMLText := Copy(sXMLText,4);

  if (Copy(sXMLText,1,5) <> '<?xml') then  // neplatny XML soubor
  begin
    ShowMessage('Neplatný XML soubor');
    Exit;
  end;


  XmlParser := TXmlParser.Create;

  XmlParser.LoadFromBuffer(  PAnsiChar( sXMLText )  );

  XmlParser.StartScan;
  XmlParser.Normalize := FALSE;

  ReadItemXML('');

  XmlParser.Free;

end;

procedure LoadCL;
var
  F: TextFile;
  sLine, sFileData: RawByteString;
begin
  sFileData := '';
  CL.Clear;

  if FileExists(ProfilePath + 'cl.xml') then
  begin
    AssignFile(F, ProfilePath + 'cl.xml' );
    Reset(F);
    while not eof(F) do
    begin
      Readln(F, sLine );

      if sFileData = '' then
        sFileData := sLine
      else
        sFileData := sFileData + #13 + #10 + sLine;

    end; {while not eof}
    CloseFile(F);

    LoadXML_CL(sFileData,CL);
  end;
end;

procedure SaveCL;
var
  F: TextFile;
  idx1, idx2: Integer;
begin
  AssignFile(F, ProfilePath + 'cl.xml');
  Rewrite(F);
  WriteLn(F, '<?xml version="1.0" encoding="utf-8" ?>');
  WriteLn(F, '<CL>');


  idx1:=0;
  while ( idx1<= CL.Count - 1 ) do
  begin
    Application.ProcessMessages;
    if CL.Strings[idx1]='CL' then
    begin
      WriteLn(F, ' <Item>');
      WriteLn(F, '  <ID><![CDATA['+WideString2UTF8(TCL(CL.Objects[idx1]).ID)+']]></ID>');
      WriteLn(F, '  <Name><![CDATA['+WideString2UTF8(TCL(CL.Objects[idx1]).Name)+']]></Name>');
      WriteLn(F, '  <Conf>'+WideString2UTF8(TCL(CL.Objects[idx1]).Conf)+'</Conf>');
      WriteLn(F, ' </Item>');
    end
    else if CL.Strings[idx1]='CLGuide' then
    begin
      WriteLn(F, ' <Guide>');
      WriteLn(F, '  <Name><![CDATA['+WideString2UTF8(TCLGuide(CL.Objects[idx1]).Name)+']]></Name>');

      idx2:=0;
      while ( idx2<= TCLGuide(CL.Objects[idx1]).Items.Count - 1 ) do
      begin
        Application.ProcessMessages;

        WriteLn(F, '  <Item>');
        WriteLn(F, '   <ID><![CDATA['+WideString2UTF8(TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).ID)+']]></ID>');
        WriteLn(F, '   <Name><![CDATA['+WideString2UTF8(TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).Name)+']]></Name>');
        WriteLn(F, '   <Width>'+IntToStr(TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).Width)+'</Width>');
        WriteLn(F, '   <Conf>'+WideString2UTF8(TCL(TCLGuide(CL.Objects[idx1]).Items.Objects[idx2]).Conf)+'</Conf>');
        WriteLn(F, '  </Item>');

        Inc(idx2);
      end;

      WriteLn(F, ' </Guide>');
    end;

    Inc(idx1);
  end;

  WriteLn(F, '</CL>');
  CloseFile(F);

end;

end.
