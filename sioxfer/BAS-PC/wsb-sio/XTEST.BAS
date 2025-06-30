  $LIB COM+
  $LIB LPT ON
  $OPTION CNTLBREAK ON
  $OPTION AUTODIM OFF
  $STACK 3000
  $STATIC

' Test Character conversion
 
GOTO START
 
FUNCTION PrintCharTable(ChrTbl$,ChrTblName$)  'SHARED
  PRINT "------ Character Table: ";ChrTblName$
  FOR i%=1 TO 249 STEP 8   ' was 241
     PRINT "- ";RIGHT$("00"+HEX$(i%-1),2);" - ";
     FOR k%=1 TO 8
       xchr$=MID$(ChrTbl$,i%+k%-1,1)
       PRINT xchr$; "-("; RIGHT$("00"+HEX$(ASCII(xchr$)),2);") ";
     NEXT k%
     PRINT
  NEXT i%
  PRINT "------ "

END FUNCTION


FUNCTION StringHex$(InpStr$)	PUBLIC                     ' Returns String with HEX repesentation of a string 
  OutpStr$=""
  FOR i%=1 TO LEN(InpStr$) 
    OutpStr$=OutpStr$+RIGHT$("00"+HEX$(ASCII(MID$(InpStr$,i%,1))),2)
  NEXT i%
  StringHex$=OutpStr$
END FUNCTION  


FUNCTION CodeTrans$(Incode$, Outcode$,Instring$,Flg%) PUBLIC ' *** CodeTranslation
  Outstring$=""
  FOR i1%=1 TO LEN(Instring$)
      index%=INSTR(Outcode$,MID$(Instring$,i1%,1))
      Outstring$=Outstring$+MID$(Incode$,index%,1)
  NEXT i1%
  IF Flg%=1 THEN
    PRINT #5,"** TranI-";Instring$
    PRINT #5,"** TIHex-";StringHex(Instring$)
    PRINT #5,"** TranO-";Outstring$
    PRINT #5,"** TOHex-";StringHex(Outstring$)
  END IF
  CodeTrans$=Outstring$
END FUNCTION


 

'  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\DISPLAY.BAS"                    'Screen Functions
'  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\UNIT.BAS"                       'Universal Functions
  $INCLUDE  "..\INCLUDE\UNIT.BAS"                       'Universal Functions
'  $INCLUDE  "USB_SIO.BAS"                               'USB_SIO Functions
  $INCLUDE  "CODEGEN.BAS"                               'Generate codes and code translation tables
START:

  PROG$      = "xtest"                                  'Program Name
  EC$        = "1.0 (29.06.2025)"                       'program version

  Options$   = UCASE$(LEFT$(COMMAND$,16))
  SIO.Cflg%  = 1                                   'Code Pages in Msg File
  SIO.Dflg%  = 0                                   'no Debug (use serial I/O)
  SIO.Tflg%  = 1                                   'Trace data in Tra File
'  SIO.Cflg%  = SGN(INSTR(Options$,"/C"))                'Code Pages in Msg File
'  SIO.Dflg%  = SGN(INSTR(Options$,"/D"))                'Debug (no serial I/O)
'  SIO.Tflg%  = SGN(INSTR(Options$,"/T"))                'Trace data in Tra File
  IB.Stat$   = "  "                                     'IB Status
  CR$        = CHR$(13)                                 'CR  X'0D'
  LF$        = CHR$(10)                                 'LF  X'0A'
  RS1E$      = CHR$(30)                                 'RS  X'1E'
  DLE$       = CHR$(16)                                 'DLE X'10'
  LFE$       = CHR$(21)+CHR$(30)                        'NL+EB1 X'151E'
' LFE$       = CHR$(21)+CHR$(30)+CHR$(31)               'NL+EB1 X'151E1F'
  EOFP$      = CHR$( 4)+CHR$(21)+CHR$(30)+CHR$(31)      'EOT+LF+RS+US X'04151E1F'
  EOFG$      = CHR$( 4)+CHR$(30)+CHR$(31)               'EOT+RS+US X'041E1F'
  Ef%        = 0                                        ' default values
  Men1%      = 0  ' Set on screen display
  Error.Cnt% = 0
  Rec.Cnt%   = 0
  Tra%       = 0
  Hex%       = 0
  Pdf%       = 0
                                                        ' Switches:
  P1         = 1                                        ' RD  (1=show Data)
  P2         = 1                                        ' TR  (1=Generate Tracefile)
  P3         = 0                                        ' SP  (1=spare)
  P4         = 0                                        ' RS* (1=no signals on RTS)
  P5         = 0                                        ' ME* (1=Suppress all fails)
  P6         = 0                                        ' PE* (1=Paritycheck on)
  P7         = 0                                        ' FE* (1=Suppress defect Byte)

                                                                                    ' Parameters
  P11$       = "COM2"   : C11$       = "COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8"    ' PO* Port
  P12$       = "9600"   : C12$       = "75 110 150 300 600 1200 1800 2400 4800 9600 19200 38400 57600 115200 "  ' BR* Baudrate
  P13$       = "N"      : C13$       = "N E O S M"                                  ' PA* Parity
  P14$       = "8"      : C14$       = "5 6 7 8 H P"                                ' BI  Bits
  P15$       = "256"                                                                ' RL  Max. Recordlength (1-32000)
  P16$       = "2"      : C16$       = "1 2"                                        ' ST* Stop Bits
  P17$       = "0"      : C17$       = "0 1 2 3 4 5 6 7 8 9 A B C D E F"            ' IM  Ignore Mode
  P18$       = "EBCDIC" : C18$       = "EBCDIC CP5110 CP5100 ASCII CI5110 CI5100"   ' CI  Code in (Translation on GET)
  P19$       = "EBCDIC" : C19$       = "EBCDIC CP5110 CP5100 ASCII HEX"                   ' CO  Code Out (Translation on PUT)

  P20$       = "99999"
  P21$       = "0"      : C21$       = "0 1 2 3"
  P22$       = ""
'  P22$       = ",CS60000"

  T18$       = ""                                                                    'CI code page - will be set later 
  T19$       = ""                                                                    'CO code page - will be set later 

  HexChr$    = "0123456789ABCDEF"
  MsgFile$   = PROG$+".msg"
  HistFile$  = PROG$+".his"
  SetFil$    = "TEST"
  SetFile$   = SetFil$+".set"
  TraFil$    = PROG$
  TracFile$  = TraFil$+".tra"
  TestFile$  = PROG$+".tst"
  FileType$  = "?  _C=?  _L=? "
  SrcFile$   = "?"
  DstFile$   = "?"
  DmpTline$  = "?"
  Message$   = "?"
  CtlFil$    = "xtest"

  PRINT PROG$;" - ";EC$

  OPEN MsgFile$ FOR OUTPUT AS#5
  PRINT #5,Prog$+" started: ";DATE$;" ";TIME$
  OPEN HistFile$ FOR APPEND AS#2
  PRINT #2,Prog$+" started: ";DATE$;" ";TIME$
  OPEN TracFile$ FOR OUTPUT AS#6
  PRINT #6,TracFile$+" started: ";DATE$;" ";TIME$

  PRINT "Generating code pages..."
  CALL SetXltASCII
  CALL SetXltEBCDIC
  CALL SetXltCP5110
  CALL SetXltCI5110
  CALL SetXltCP5100
  CALL SetXltCI5100

  IF P18$ = "ASCII" THEN
    T18$=CP437$
  ELSEIF P18$ = "EBCDIC" THEN    
    T18$=EBCDIC$
  END IF 

  IF P19$ = "ASCII" THEN
    T19$=CP437$
  ELSEIF P19$ = "EBCDIC" THEN 
    T19$=EBCDIC$
  END IF 

  CPlocal$=CP437$

  IF  SIO.Dflg% = 1 THEN
    CALL SetASCFILE
    CALL Set5110FILE
  END IF 

  PRINT "Using codepages:  input = ";P18$,"Output: ";P19$
  
  PRINT "Press key to continue ..."
  K$=INPUT$(1)

'  CALL PrintCharTable(CP$, CPName$)
'  PRINT "Press key to continue ..."
'  K$=INPUT$(1)

'  xBin$=HexBin$(32,"AFFE5544")
'  PRINT xBin$
'  xHex$=BinHex$(8, xBin$)
'  PRINT xHex$
'  PRINT BinHex$(6,xBin$)
'  PRINT BinHexL$(6,xBin$)
'  PRINT BinHex(4,xBin$)
'  PRINT BinHexL$(4,xBin$)

  StrASCII$  = "Hallo Du da"
  StrEBCDIC$ = CHR$(240,241,242,243,244)
  
  PRINT "Local String:       ";StrASCII$
  PRINT "Local String (HEX): ";StringHex$(StrASCII$)
  PRINT "EBCDIC String (HEX):";StringHex$(StrEBCDIC$)
  
  temp0$=DLE$+"BITS="+Bits$
  temp1$=DLE$+"FILETYP="+FileType$
  temp2$=DLE$+"DSTFILE="+DstFile$
  
  PRINT "Input conversion:  ";P18$
  temp$=CodeTrans$(T18$,CPlocal$,StrEBCDIC$, SIO.Tflg%)
  PRINT "Result: ";StringHex$(temp$)
  
  PRINT "Output conversion: ";P19$
  temp$=CodeTrans$(CPlocal$,T19$,StrASCII$, SIO.Tflg%)
  PRINT "Result: ";StringHex$(temp$)
  
  PRINT "That's all..."
  