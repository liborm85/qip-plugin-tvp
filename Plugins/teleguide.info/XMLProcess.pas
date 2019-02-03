unit XMLProcess;

interface

uses SysUtils, Classes, Dialogs, Graphics, Windows, Forms, TVp_plugin_info,
     WinInet;

type
  {XML Info}
  TXMLInfo = record
    CodePage      : WideString;
  end;

  { XML Attrs }
  TXMLAttrs = class
  public
    dataWideString : WideString;
  end;

  TXMLStations = class
  public
    StationID          : WideString;
    StationName        : WideString;
    StationLogo        : WideString;

    DATADays           : TStringList;
  end;


  procedure ReadTVXMLStations(sHTML: String; var Data: TStringList; var XMLInfo: TXMLInfo);
  procedure ReadTVXMLAvailableDays(sHTML: String; var Data: TStringList; var XMLInfo: TXMLInfo);
  procedure ReadTVXMLProgram(sHTML: String; Stations: TStringList; Dates: TStringList; var Data: TStringList; var XMLInfo: TXMLInfo);



implementation

uses Convs, DownloadFile, TextSearch, General,
     LibXmlParser;

var
  XmlParser   : TXmlParser;

(*
===============================================================================================
TElementNode
===============================================================================================
*)

TYPE
  TElementNode = CLASS
                   Content : STRING;
                   Attr    : TStringList;
                   CONSTRUCTOR Create (TheContent : STRING; TheAttr : TNvpList);
                   DESTRUCTOR Destroy; OVERRIDE;
                 END;

CONSTRUCTOR TElementNode.Create (TheContent : STRING; TheAttr : TNvpList);
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


procedure ReadTVXMLStations(sHTML: String; var Data: TStringList; var XMLInfo: TXMLInfo);
var
  sn : String;

  EN : TElementNode;

  hIndex : Integer;

//  F: TextFile;

//  sEnclosure: WideString;

//  F1: TextFile;
//  sAnsiText, sLine : AnsiString;

  procedure CommandXML(sCommand: WideString; sValue: WideString; Attrs: TStringList; bAttrs: Boolean);
  var  idx: Integer;
      sV : WideString;
//      ix : Integer;
    begin

//    showmessage(sCommand+#13+sValue);

{      writeln(F,sCommand + ' >>> ' + sValue);


      for ix := 0 to Attrs.Count - 1 do
      begin

        writeln(F, '>' + Attrs.Strings[ix] + ' >>> ' + TXMLAttrs(Attrs.Objects[ix]).dataWideString );

      end;      }


      if sCommand='CODEPAGE' then
        XMLInfo.CodePage := sValue;


      if AnsiUpperCase(XMLInfo.CodePage) = 'UTF-8' then
        sValue := UTF82WideString(sValue);
//        sValue := UTF8Decode(sValue);
{
      if AnsiUpperCase(XMLInfo.CodePage) = 'ISO-8859-2' then
        sValue :=  EncodingToUTF16('ISO-8859-2', sValue);

      if AnsiUpperCase(XMLInfo.CodePage) = 'WINDOWS-1251' then
        sValue :=  EncodingToUTF16('windows-1251', sValue);  }

      if sCommand = '/tv/channel' then     //Channel     +  id stanice
      begin
        idx := Attrs.IndexOf('id');
        if idx <> -1 then
          sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //id

        Data.Add('STATION');
        hIndex:= Data.Count - 1;
        Data.Objects[hIndex] := TDLLStations.Create;
        TDLLStations(Data.Objects[hIndex]).StationID       := sV + '@teleguide.info';
        TDLLStations(Data.Objects[hIndex]).StationName     := '';
        TDLLStations(Data.Objects[hIndex]).StationLogo     := '';

//        TDLLStations(Data.Objects[hIndex]).DATADays := TStringList.Create;
//        TDLLStations(Data.Objects[hIndex]).DATADays.Clear;

      end
      else if (sCommand = '/tv/channel/display-name') and (sValue <> '') then  // nazev stanice
      begin
        TDLLStations(Data.Objects[hIndex]).StationName := sValue;
      end
      else if sCommand = '/tv/channel/icon' then      // logo stanice
      begin
        idx := Attrs.IndexOf('src');
        if idx <> -1 then
          sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //src

        TDLLStations(Data.Objects[hIndex]).StationLogo := sV;
      end

          ;


(*
      if sCommand = '/rss' then     //RSS
      begin
        idx := Attrs.IndexOf('version');
        if idx <> -1 then
          sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //version

//        XMLInfo.Encoder    := 'RSS';
//        XMLInfo.EncoderVer := sV;
      end
      else if sCommand = '/rdf:RDF' then       //  rdf:RDF  - RSS
      begin
//        XMLInfo.Encoder    := 'RSS (rdf:RDF)';
//        XMLInfo.EncoderVer := '';
      end
      else if sCommand = '/feed' then       //Atom
      begin

        idx := Attrs.IndexOf('version');          // version 0.3
        if idx <> -1 then
          sV := '0.3';

        idx := Attrs.IndexOf('xmlns');          // version 1.0
        if idx <> -1 then
          sV := '1.0';

//        XMLInfo.Encoder    := 'Atom';
//        XMLInfo.EncoderVer := sV;

      end;


      if XMLInfo.Encoder = 'RSS' then
      begin
        //--- Uvod kanalu ---
        if sCommand = '/rss/channel/title' then
        begin
           XMLInfo.Title := sValue;
        end
        else if sCommand = '/rss/channel/link' then
        begin
          XMLInfo.Link := sValue
        end
        else if sCommand = '/rss/channel/description' then
        begin
          XMLInfo.Description := sValue
        end
        else if sCommand = '/rss/channel/language' then
        begin
          XMLInfo.Language := sValue;
        end
        else if sCommand = '/rss/channel/pubDate' then
        begin
          XMLInfo.PubDate := RFCDTToDT(sValue)
        end
        else if sCommand = '/rss/channel/lastBuildDate' then
        begin
          XMLInfo.LastBuildDate := RFCDTToDT(sValue)
        end
        else if sCommand = '/rss/channel/image/url' then
        begin
          XMLInfo.image := sValue
        end
        else if sCommand = '/rss/channel/image/category' then
        begin
          XMLInfo.category := sValue
        end
        else if sCommand = '/rss/channel/image/generator' then
        begin
          XMLInfo.generator := sValue
        end
        else if sCommand = '/rss/channel/image/ttl' then
        begin
          XMLInfo.ttl := sValue
        end
        // --- Polozky ---
        else if (sCommand = 'BEGIN') and (sValue = '/rss/channel/item') then  //Zacina item
        begin

            if sEnclosure<>'' then
            begin
              if TRSSData(Data.Objects[hIndex]).Enclosure='' then
                TRSSData(Data.Objects[hIndex]).Enclosure := sEnclosure
              else
                TRSSData(Data.Objects[hIndex]).Enclosure := TRSSData(Data.Objects[hIndex]).Enclosure + ' <NEXT /> ' + sEnclosure;

              sEnclosure := '';
            end;

          Data.Add('ITEM');
          hIndex:= Data.Count - 1;
          Data.Objects[hIndex] := TRSSData.Create;
          TRSSData(Data.Objects[hIndex]).Title       := '';
          TRSSData(Data.Objects[hIndex]).Link        := '';
          TRSSData(Data.Objects[hIndex]).Description := '';
          TRSSData(Data.Objects[hIndex]).PubDate     := '';
        end
        else if sCommand = '/rss/channel/item/title' then
        begin
          TRSSData(Data.Objects[hIndex]).Title := sValue;
        end
        else if sCommand = '/rss/channel/item/link' then
        begin
          TRSSData(Data.Objects[hIndex]).Link := sValue;
        end
        else if sCommand = '/rss/channel/item/author' then
        begin
          TRSSData(Data.Objects[hIndex]).author := '[email]="'+sValue+'";';//sValue;
        end
        else if sCommand = '/rss/channel/item/description' then
        begin
          TRSSData(Data.Objects[hIndex]).Description := sValue;
        end
        else if sCommand = '/rss/channel/item/pubDate' then
        begin
          TRSSData(Data.Objects[hIndex]).PubDate := RFCDTToDT( sValue );
        end
        else if sCommand = '/rss/channel/item/category' then
        begin
          TRSSData(Data.Objects[hIndex]).category := sValue;
        end
        else if sCommand = '/rss/channel/item/comments' then
        begin
          TRSSData(Data.Objects[hIndex]).comments := sValue;
        end
        else if sCommand = '/rss/channel/item/guid' then      //jednoznacna identifikace
        begin
          TRSSData(Data.Objects[hIndex]).guid := sValue;
        end

       else if sCommand = '/rss/channel/item/enclosure' then
        begin
          if bAttrs=True then   // odkaz atd
          begin
            if sEnclosure<>'' then
            begin
              if TRSSData(Data.Objects[hIndex]).Enclosure='' then
                TRSSData(Data.Objects[hIndex]).Enclosure := sEnclosure
              else
                TRSSData(Data.Objects[hIndex]).Enclosure := TRSSData(Data.Objects[hIndex]).Enclosure + ' <NEXT /> ' + sEnclosure;

              sEnclosure := '';
            end;

            idx := Attrs.IndexOf('url');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

            idx := Attrs.IndexOf('length');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

            idx := Attrs.IndexOf('type');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

          end
          else
          begin               // popis
            sEnclosure := sEnclosure + '[description]="'+sValue+'";';
          end;

        end

      end

      else if XMLInfo.Encoder = 'RSS (rdf:RDF)' then
      begin
        //--- Uvod kanalu ---
        if sCommand = '/rdf:RDF/channel/title' then
        begin
           XMLInfo.Title := sValue;
        end
        else if sCommand = '/rdf:RDF/channel/link' then
        begin
          XMLInfo.Link := sValue
        end
        else if sCommand = '/rdf:RDF/channel/description' then
        begin
          XMLInfo.Description := sValue
        end
        else if sCommand = '/rdf:RDF/channel/language' then
        begin
          XMLInfo.Language := sValue;
        end
        else if sCommand = '/rdf:RDF/channel/pubDate' then
        begin
          XMLInfo.PubDate := RFCDTToDT(sValue)
        end
        else if sCommand = '/rdf:RDF/channel/lastBuildDate' then
        begin
          XMLInfo.LastBuildDate := RFCDTToDT(sValue)
        end
        else if sCommand = '/rdf:RDF/channel/image/url' then
        begin
          XMLInfo.image := sValue
        end
        else if sCommand = '/rdf:RDF/channel/image/category' then
        begin
          XMLInfo.category := sValue
        end
        else if sCommand = '/rdf:RDF/channel/image/generator' then
        begin
          XMLInfo.generator := sValue
        end
        else if sCommand = '/rdf:RDF/channel/image/ttl' then
        begin
          XMLInfo.ttl := sValue
        end
        // --- Polozky ---
        else if (sCommand = 'BEGIN') and (sValue = '/rdf:RDF/item') then  //Zacina item
        begin

            if sEnclosure<>'' then
            begin
              if TRSSData(Data.Objects[hIndex]).Enclosure='' then
                TRSSData(Data.Objects[hIndex]).Enclosure := sEnclosure
              else
                TRSSData(Data.Objects[hIndex]).Enclosure := TRSSData(Data.Objects[hIndex]).Enclosure + ' <NEXT /> ' + sEnclosure;

              sEnclosure := '';
            end;

          Data.Add('ITEM');
          hIndex:= Data.Count - 1;
          Data.Objects[hIndex] := TRSSData.Create;
          TRSSData(Data.Objects[hIndex]).Title       := '';
          TRSSData(Data.Objects[hIndex]).Link        := '';
          TRSSData(Data.Objects[hIndex]).Description := '';
          TRSSData(Data.Objects[hIndex]).PubDate     := '';
        end
        else if sCommand = '/rdf:RDF/item/title' then
        begin
          TRSSData(Data.Objects[hIndex]).Title := sValue;
        end
        else if sCommand = '/rdf:RDF/item/link' then
        begin
          TRSSData(Data.Objects[hIndex]).Link := sValue;
        end
        else if sCommand = '/rdf:RDF/item/author' then
        begin
          TRSSData(Data.Objects[hIndex]).author := '[email]="'+sValue+'";';//sValue;
        end
        else if sCommand = '/rdf:RDF/item/description' then
        begin
          TRSSData(Data.Objects[hIndex]).Description := sValue;
        end
        else if sCommand = '/rdf:RDF/item/pubDate' then
        begin
          TRSSData(Data.Objects[hIndex]).PubDate := RFCDTToDT( sValue );
        end
        else if sCommand = '/rdf:RDF/item/category' then
        begin
          TRSSData(Data.Objects[hIndex]).category := sValue;
        end
        else if sCommand = '/rdf:RDF/item/comments' then
        begin
          TRSSData(Data.Objects[hIndex]).comments := sValue;
        end
        else if sCommand = '/rdf:RDF/item/guid' then      //jednoznacna identifikace
        begin
          TRSSData(Data.Objects[hIndex]).guid := sValue;
        end

       else if sCommand = '/rdf:RDF/item/enclosure' then
        begin
          if bAttrs=True then   // odkaz atd
          begin
            if sEnclosure<>'' then
            begin
              if TRSSData(Data.Objects[hIndex]).Enclosure='' then
                TRSSData(Data.Objects[hIndex]).Enclosure := sEnclosure
              else
                TRSSData(Data.Objects[hIndex]).Enclosure := TRSSData(Data.Objects[hIndex]).Enclosure + ' <NEXT /> ' + sEnclosure;

              sEnclosure := '';
            end;

            idx := Attrs.IndexOf('url');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

            idx := Attrs.IndexOf('length');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

            idx := Attrs.IndexOf('type');
            if idx <> -1 then
              sEnclosure := sEnclosure + '['+Attrs.Strings[idx]+']="'+TXMLAttrs(Attrs.Objects[idx]).dataWideString+'";';

          end
          else
          begin               // popis
            sEnclosure := sEnclosure + '[description]="'+sValue+'";';
          end;

        end

      end


      else if XMLInfo.Encoder = 'Atom' then
      begin
        //--- Uvod kanalu ---
        if sCommand = '/feed/title' then
        begin
          XMLInfo.Title := sValue
        end
        else if sCommand = '/feed/link' then
        begin

          idx := Attrs.IndexOf('href');
          if idx <> -1 then
            sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;

          XMLInfo.Link := sV;

{          XMLInfo.Link := sValue}
        end
 {       else if sCommand = '/rss/channel/description' then
        begin
          sFeetDescription := sValue
        end
        else if sCommand = '/rss/channel/language' then
        begin
          sFeetLanguage := sValue
        end          }
        else if sCommand = '/feed/updated' then
        begin
          XMLInfo.PubDate := ISO8601DTToDT(sValue)
        end
{        else if sCommand = '/rss/channel/lastBuildDate' then
        begin
          sFeetLastBuildDate := RFCDTToDT(sValue)
        end     }

        // --- Polozky ---
        else if (sCommand = 'BEGIN') and (sValue = '/feed/entry') then  //Zacina item
        begin
//          showmessage('uvod');
          Data.Add('ITEM');
          hIndex:= Data.Count - 1;
          Data.Objects[hIndex] := TRSSData.Create;
          TRSSData(Data.Objects[hIndex]).Title       := '';
          TRSSData(Data.Objects[hIndex]).Link        := '';
          TRSSData(Data.Objects[hIndex]).Description := '';
          TRSSData(Data.Objects[hIndex]).PubDate     := '';
          TRSSData(Data.Objects[hIndex]).author      := '';
          TRSSData(Data.Objects[hIndex]).summary     := '';
        end
        else if sCommand = '/feed/entry/title' then
        begin
          TRSSData(Data.Objects[hIndex]).Title := sValue;
//          showmessage(TRSSData(Data.Objects[hIndex]).Title);
        end
        else if sCommand = '/feed/entry/link' then
        begin
          idx := Attrs.IndexOf('href');
          if idx <> -1 then
          begin
            sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;

            idx := Attrs.IndexOf('rel');
            if idx <> -1 then
            begin
              if TXMLAttrs(Attrs.Objects[idx]).dataWideString = 'alternate' then
                TRSSData(Data.Objects[hIndex]).Link := sV;
            end;
{            alternate
            TSLAttrs(Attrs.Objects[idx]).dataWideString;}

          end;


{          if TSLRSSData(Data.Objects[hIndex]).Link='' then
            TSLRSSData(Data.Objects[hIndex]).Link := sValue;}
        end
        else if sCommand = '/feed/entry/content' then
        begin
          TRSSData(Data.Objects[hIndex]).Description := sValue;
        end
        else if sCommand = '/feed/entry/updated' then     //1.0
        begin
          TRSSData(Data.Objects[hIndex]).PubDate := ISO8601DTToDT( sValue );
        end
        else if sCommand = '/feed/entry/modified' then    //0.3
        begin
          TRSSData(Data.Objects[hIndex]).PubDate := ISO8601DTToDT( sValue );
        end
        else if sCommand = '/feed/entry/summary' then
        begin
          TRSSData(Data.Objects[hIndex]).summary := sValue;
        end
        else if sCommand = '/feed/entry/author/email' then
        begin
          TRSSData(Data.Objects[hIndex]).author := TRSSData(Data.Objects[hIndex]).author + '[email]="'+sValue+'";';
        end
        else if sCommand = '/feed/entry/author/name' then
        begin
          TRSSData(Data.Objects[hIndex]).author := TRSSData(Data.Objects[hIndex]).author + '[name]="'+sValue+'";';
        end
        else if sCommand = '/feed/entry/author/uri' then
        begin
          TRSSData(Data.Objects[hIndex]).author := TRSSData(Data.Objects[hIndex]).author + '[uri]="'+sValue+'";';
        end
        else if sCommand = '/feed/entry/id' then    //jednoznacna identifikace
        begin
          TRSSData(Data.Objects[hIndex]).guid := sValue;
        end

      end;       *)

      Attrs.Clear;
    end;

  procedure ReadItemXML(s: String);
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

//                          sAttrs := TStringList.Create;
                          sAttrs.Clear;

                          for Ii := 0 TO EN.Attr.Count-1 do
                          begin

//                          showmessage(Trim( EN.Attr.Names [Ii] ));

                            sAttrs.Add( Trim( EN.Attr.Names [Ii] ) );
                            hIndex1:= sAttrs.Count - 1;
                            sAttrs.Objects[hIndex1] := TXMLAttrs.Create;
                            TXMLAttrs(sAttrs.Objects[hIndex1]).dataWideString := Trim( EN.Attr.Values [EN.Attr.Names [Ii]]);

//                            CommandXML( sn + '|' + Trim( EN.Attr.Names [Ii] ), Trim( EN.Attr.Values [EN.Attr.Names [Ii]]) , sAttrs);
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
//                showmessage('0');
  XmlParser := TXmlParser.Create;


  XmlParser.LoadFromFile(sHTML);


(*  sAnsiText := '';
  AssignFile(F1, sHTML );
  Reset(F1);
  while not eof(F1) do
  begin

    Readln(F1, sLine );

    if sAnsiText = '' then
      sAnsiText := sLine
    else
      sAnsiText := sAnsiText+#13+#10+sLine;

    Application.ProcessMessages;

  end; {while not eof}

  CloseFile(F1);

  showmessage(sAnsiText);

  XmlParser.LoadFromBuffer(  PAnsiChar( sAnsiText )  );     *)

//showmessage(  sHTML +#13+'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' );

//if sHTML = 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' then
//showmessage('rovna se');


//  XmlParser.LoadFromFile(  PAnsiChar( TVpConf.TempPath + 'teleguideinfo_new.xml' )  );
//  XmlParser.LoadFromFile(  PAnsiChar( sHTML )  );
/////////  XmlParser.LoadFromFile(  PAnsiChar( 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' )  );

//  XmlParser.LoadFromBuffer(  PAnsiChar( sHTML )  );

  XmlParser.StartScan;
  XmlParser.Normalize := FALSE;
//              showmessage('1');
{  AssignFile(F, TVpConf.TempPath + 'cmds.txt');
  Rewrite(F);}

  ReadItemXML('');



{  CloseFile(F);}

  XmlParser.Free;

end;









procedure ReadTVXMLAvailableDays(sHTML: String; var Data: TStringList; var XMLInfo: TXMLInfo);
var
  sn : String;

  EN : TElementNode;

  hIndex : Integer;

//  F: TextFile;

//  sEnclosure: WideString;

  idx1 : Integer;

//  F1: TextFile;
//  sAnsiText, sLine : AnsiString;
    
  procedure CommandXML(sCommand: WideString; sValue: WideString; Attrs: TStringList; bAttrs: Boolean);
  var  idx: Integer;
      sV : WideString;
//      ix : Integer;
    begin

//    showmessage(sCommand+#13+sValue);

    {  writeln(F,sCommand + ' >>> ' + sValue);


      for ix := 0 to Attrs.Count - 1 do
      begin

        writeln(F, '>' + Attrs.Strings[ix] + ' >>> ' + TXMLAttrs(Attrs.Objects[ix]).dataWideString );

      end;    }


      if sCommand='CODEPAGE' then
        XMLInfo.CodePage := sValue;


      if AnsiUpperCase(XMLInfo.CodePage) = 'UTF-8' then
        sValue := UTF82WideString(sValue);
{
      if AnsiUpperCase(XMLInfo.CodePage) = 'ISO-8859-2' then
        sValue :=  EncodingToUTF16('ISO-8859-2', sValue);

      if AnsiUpperCase(XMLInfo.CodePage) = 'WINDOWS-1251' then
        sValue :=  EncodingToUTF16('windows-1251', sValue);  }

      if sCommand = '/tv/programme' then     //datum
      begin

        idx := Attrs.IndexOf('start');
        if idx <> -1 then
          sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //start
          
//        sV  --- preformatovat pouze na datum 2009-01-01
        sV := FormatDateTime('yyyy-mm-dd', UTCtoDT(sV));

        idx := Data.IndexOf(sV);
        if idx = -1 then
        begin

          Data.Add( sV   );             //zpet do tvp poslat s textem 'DATE'
          hIndex:= Data.Count - 1;
          Data.Objects[hIndex] := TDLLAvailableDays.Create;
          TDLLAvailableDays(Data.Objects[hIndex]).DateID     := sV;
        end;

        
      end;


      Attrs.Clear;
    end;

  procedure ReadItemXML(s: String);
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

//                          sAttrs := TStringList.Create;
                          sAttrs.Clear;

                          for Ii := 0 TO EN.Attr.Count-1 do
                          begin

//                          showmessage(Trim( EN.Attr.Names [Ii] ));

                            sAttrs.Add( Trim( EN.Attr.Names [Ii] ) );
                            hIndex1:= sAttrs.Count - 1;
                            sAttrs.Objects[hIndex1] := TXMLAttrs.Create;
                            TXMLAttrs(sAttrs.Objects[hIndex1]).dataWideString := Trim( EN.Attr.Values [EN.Attr.Names [Ii]]);

//                            CommandXML( sn + '|' + Trim( EN.Attr.Names [Ii] ), Trim( EN.Attr.Values [EN.Attr.Names [Ii]]) , sAttrs);
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
//                showmessage('0');
  XmlParser := TXmlParser.Create;

  XmlParser.LoadFromFile(sHTML);

(*
  sAnsiText := '';
  AssignFile(F1, sHTML );
  Reset(F1);
  while not eof(F1) do
  begin

    Readln(F1, sLine );

    if sAnsiText = '' then
      sAnsiText := sLine
    else
      sAnsiText := sAnsiText+#13+#10+sLine;

    Application.ProcessMessages;

  end; {while not eof}

  CloseFile(F1);

  showmessage(sAnsiText);

  XmlParser.LoadFromBuffer(  PAnsiChar( sAnsiText )  );       *)

//showmessage(  sHTML +#13+'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' );

//if sHTML = 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' then
//showmessage('rovna se');


//  XmlParser.LoadFromFile(  PAnsiChar( TVpConf.TempPath + 'teleguideinfo_new.xml' )  );
//  XmlParser.LoadFromFile(  PAnsiChar( sHTML )  );
///////  XmlParser.LoadFromFile(  PAnsiChar( 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' )  );

//  XmlParser.LoadFromBuffer(  PAnsiChar( sHTML )  );

  XmlParser.StartScan;
  XmlParser.Normalize := FALSE;
//              showmessage('1');
{  AssignFile(F, TVpConf.TempPath + 'cmds.txt');
  Rewrite(F);   }

  ReadItemXML('');

 {
  CloseFile(F);   }

  XmlParser.Free;
  
  //Prepsani datumu v Stringu na DATE (aby rozuměl TVp), v Object zůstává datum
  idx1 := 0;
  while ( idx1 <= DATA.Count - 1 ) do
  begin
    Application.ProcessMessages;
    
    DATA.Strings[idx1] := 'DATE';

    Inc(idx1);
  end; {while idx1}    

end;














procedure ReadTVXMLProgram(sHTML: String; Stations: TStringList; Dates: TStringList; var Data: TStringList; var XMLInfo: TXMLInfo);
var
  sn : String;

  EN : TElementNode;

  hIndex : Integer;

//  F: TextFile;

//  sEnclosure: WideString;

  sOldStation, sOldDate : WideString;
  
  StationAdding, DateAdding : Boolean;

//  F1: TextFile;
//  sAnsiText, sLine : AnsiString;
//  i: Integer;

  procedure CommandXML(sCommand: WideString; sValue: WideString; Attrs: TStringList; bAttrs: Boolean);
  var  idx: Integer;
      sV : WideString;
//      ix : Integer;
    begin

//    showmessage(sCommand+#13+sValue);
     {
      writeln(F,sCommand + ' >>> ' + sValue);


      for ix := 0 to Attrs.Count - 1 do
      begin

        writeln(F, '>' + Attrs.Strings[ix] + ' >>> ' + TXMLAttrs(Attrs.Objects[ix]).dataWideString );

      end;        }


      if sCommand='CODEPAGE' then
        XMLInfo.CodePage := sValue;


      if AnsiUpperCase(XMLInfo.CodePage) = 'UTF-8' then
        sValue := UTF82WideString(sValue);
{
      if AnsiUpperCase(XMLInfo.CodePage) = 'ISO-8859-2' then
        sValue :=  EncodingToUTF16('ISO-8859-2', sValue);

      if AnsiUpperCase(XMLInfo.CodePage) = 'WINDOWS-1251' then
        sValue :=  EncodingToUTF16('windows-1251', sValue);  }
        

        
      if sCommand = '/tv/programme' then     //
      begin
        idx := Attrs.IndexOf('channel');
        if idx <> -1 then
          sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //channel



        if sOldStation <> sV then
        begin

          idx := Stations.IndexOf(sV + '@teleguide.info');
          if idx = -1 then  //not found
          begin
            StationAdding := False;

          end
          else
          begin
//showmessage(sV + '@teleguide.info');
//                                     showmessage('ffff');
            StationAdding := True;

            DATA.Add('STATION');
            hIndex:= DATA.Count - 1;
            DATA.Objects[hIndex] := TDLLStations.Create;
            TDLLStations(DATA.Objects[hIndex]).StationID      := sV + '@teleguide.info';
            TDLLStations(DATA.Objects[hIndex]).StationName    := '';//sStationName;
            TDLLStations(DATA.Objects[hIndex]).StationLogo    := '';//sStationLogo;
          end;

          sOldStation := sV;
        end;

        if StationAdding = True then
        begin
          idx := Attrs.IndexOf('start');
          if idx <> -1 then
            sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //start
          //else  showmessage('nenaleezetye');


//showmessage(sV);
          if sOldDate <> FormatDateTime('yyyy-mm-dd', UTCtoDT(sV)) then
          begin

            idx := Dates.IndexOf( FormatDateTime('yyyy-mm-dd', UTCtoDT(sV)) );
            if idx = -1 then  //not found
            begin
              DateAdding := False;
            end
            else
            begin
              DateAdding := True;

              DATA.Add('DATE');
              hIndex:= DATA.Count - 1;
              DATA.Objects[hIndex] := TDLLAvailableDays.Create;
              TDLLAvailableDays(DATA.Objects[hIndex]).DateID     := FormatDateTime('yyyy-mm-dd', UTCtoDT(sV));

            end;

            sOldDate := FormatDateTime('yyyy-mm-dd', UTCtoDT(sV));
          end;

          if DateAdding=True then
          begin
            //vlozeni programu
            DATA.Add('PROGRAM');
            hIndex:= DATA.Count - 1;
            DATA.Objects[hIndex] := TDLLProgramInfo.Create;
            TDLLProgramInfo(DATA.Objects[hIndex]).Time      := FormatDateTime('hh:nn', UTCtoDT(sV));
            TDLLProgramInfo(DATA.Objects[hIndex]).Name      := '';
            TDLLProgramInfo(DATA.Objects[hIndex]).OrigName  := '';
            TDLLProgramInfo(DATA.Objects[hIndex]).Info      := '';
            TDLLProgramInfo(DATA.Objects[hIndex]).InfoImage := '';
            TDLLProgramInfo(DATA.Objects[hIndex]).Specifications := '';
            TDLLProgramInfo(DATA.Objects[hIndex]).URL       := '';

(*           idx := Attrs.IndexOf('stop');
            if idx <> -1 then
              sV := TXMLAttrs(Attrs.Objects[idx]).dataWideString;    //stop
*)
          end;

        end;



      end
      else if (sCommand = '/tv/programme/title') and (sValue <> '') then  // nazev poradu
      begin
        if (StationAdding = True) and (DateAdding = True) then
          TDLLProgramInfo(DATA.Objects[hIndex]).Name := sValue;
      end
      else if (sCommand = '/tv/programme/desc') and (sValue <> '') then  // popis poradu
      begin
        if (StationAdding = True) and (DateAdding = True) then      
          TDLLProgramInfo(DATA.Objects[hIndex]).Info := sValue;
      end      
      else if (sCommand = '/tv/programme/category') and (sValue <> '') then  // kategorie
      begin
        //if (StationAdding = True) and (DateAdding = True) then
        //zatim se nepouziva
        //----- := sValue;
      end
      ;


      Attrs.Clear;
    end;

  procedure ReadItemXML(s: String);
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

//                          sAttrs := TStringList.Create;
                          sAttrs.Clear;

                          for Ii := 0 TO EN.Attr.Count-1 do
                          begin

//                          showmessage(Trim( EN.Attr.Names [Ii] ));

                            sAttrs.Add( Trim( EN.Attr.Names [Ii] ) );
                            hIndex1:= sAttrs.Count - 1;
                            sAttrs.Objects[hIndex1] := TXMLAttrs.Create;
                            TXMLAttrs(sAttrs.Objects[hIndex1]).dataWideString := Trim( EN.Attr.Values [EN.Attr.Names [Ii]]);

//                            CommandXML( sn + '|' + Trim( EN.Attr.Names [Ii] ), Trim( EN.Attr.Values [EN.Attr.Names [Ii]]) , sAttrs);
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
//                showmessage('0');
  XmlParser := TXmlParser.Create;
           {
  for i := 0 to Dates.Count - 1 do
begin
showmessage(Dates.Strings[i]);
end;        }

//showmessage( '>>'+ Stations.Strings[0]  );
(*
  sAnsiText := '';
  AssignFile(F1, sHTML );
  Reset(F1);
  while not eof(F1) do
  begin

    Readln(F1, sLine );

    if sAnsiText = '' then
      sAnsiText := sLine
    else
      sAnsiText := sAnsiText+#13+#10+sLine;

    Application.ProcessMessages;

  end; {while not eof}

  CloseFile(F1);

  showmessage(sAnsiText);

  XmlParser.LoadFromBuffer(  PAnsiChar( sAnsiText )  );        *)

  XmlParser.LoadFromFile(sHTML);

//showmessage(  sHTML +#13+'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' );

//if sHTML = 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' then
//showmessage('rovna se');


//  XmlParser.LoadFromFile(  PAnsiChar( TVpConf.TempPath + 'teleguideinfo_new.xml' )  );
//  XmlParser.LoadFromFile(  PAnsiChar( sHTML )  );

                ///OKOKOKOK dole
////  XmlParser.LoadFromFile(  PAnsiChar( 'C:\QI\QIP Infium 1.6 (9021N1) - TVp (Unicode)\Plugins\TVp\Temp\teleguideinfo_new.xml' )  );




//  XmlParser.LoadFromBuffer(  PAnsiChar( sHTML )  );

  XmlParser.StartScan;
  XmlParser.Normalize := FALSE;
//              showmessage('1');
 { AssignFile(F, TVpConf.TempPath + 'cmds.txt');
  Rewrite(F); }

  ReadItemXML('');

 {

  CloseFile(F);    }

  XmlParser.Free;

end;










end.
