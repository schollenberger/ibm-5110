  $COMPILE EXE                                          'Compiler statements
  $CPU 80386
  $COM 32000
  $LIB COM+
  $LIB LPT ON
  $OPTION CNTLBREAK ON
  $OPTION AUTODIM OFF
  $STACK 3000
  $STATIC

' Test USBSIO functions

  GOTO START

  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\DISPLAY.BAS"                    'Screen Functions
'  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\UNIT.BAS"                       'Universal Functions
  $INCLUDE  "..\INCLUDE\UNIT.BAS"                       'Universal Functions
  $INCLUDE  "CODEGEN.BAS"                               'Code table functions
  $INCLUDE  "USB_SIO.BAS"                               'USB_SIO Functions

START:

  PROG$      = "WSB_SIO"                                 'Program Name
  EC$        = "1.0 (17.6.2025)"                         'program version

  Options$   = UCASE$(LEFT$(COMMAND$,16))
  SIO.Cflg%  = SGN(INSTR(Options$,"/C"))                'Code Pages in Msg File
  SIO.Dflg%  = SGN(INSTR(Options$,"/D"))                'Debug (no serial I/O)
  SIO.Tflg%  = SGN(INSTR(Options$,"/T"))                'Trace data in Tra File
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
  Men1%      = 2  ' Initial position on first screen
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
  P19$       = "ASCII"

  P20$       = "99999"
  P21$       = "0"      : C21$       = "0 1 2 3"
  P22$       = ""
'  P22$       = ",CS60000"

  T18$       = ""
  T19$       = ""

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
  CtlFil$    = "SIOXFER"

  OPEN MsgFile$ FOR OUTPUT AS#5
  PRINT #5,Prog$+" started: ";DATE$;" ";TIME$
  OPEN HistFile$ FOR APPEND AS#2
  PRINT #2,Prog$+" started: ";DATE$;" ";TIME$
  OPEN TracFile$ FOR OUTPUT AS#6
  PRINT #6,TracFile$+" started: ";DATE$;" ";TIME$
  ON ERROR GOTO ErrH : KEY OFF : CLS : ON TIMER (60) GOSUB Clock : TIMER ON

  PRINT #5,"Generating code pages..."
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

  PRINT #5,"Using codepages:  Input = ";P18$,"Output: ";P19$

  DIM Scn1$(21)

'  COLOR 15,1 : CLS : GOSUB Header1 : GOSUB Header2
'  CALL SetCol(25,1,25,80,15,4)
'  CALL ClrLin(3,23,15,1)

  Scn1$(1) ="O Open Com Port"
  Scn1$(2) ="C Close Com Port"
  Scn1$(3) =""
'  Scn1$(3) ="P Define Parameters"
  Scn1$(4) ="  Start new Tracefile"
  Scn1$(5) ="M Manual Serial Bus Operations"
  Scn1$(6) ="D Enter DOS Command                     "
  Scn1$(7) ="E Program -End"
  Scn1$(8) =""
  Scn1$(9) ="    Switches: (0=off 1=on)                    Parameters:"
  Scn1$(10)="    RD  (1=show Data)                         PO* Port"
  Scn1$(11)="    TR  (1=Generate Tracefile)                BR* Baudrate [bit/sec]"
  Scn1$(12)="    SP  (1=spare)                             PA* Parity (N, E, O, S, M)"
  Scn1$(13)="    RS* (1=no signals on RTS)                 BI  Bits (5, 6, 7, 8, H, P)"
  Scn1$(14)="    ME* (1=Suppress all fails)                RL  Max. Recordlength (1-32000)"
  Scn1$(15)="    PE* (1=Paritycheck on)                    ST* Stop Bits (1, 2)"
  Scn1$(16)="    FE* (1=Suppress defect Byte)              IM  Ignore Mode"
  Scn1$(17)="                                              CI  Code in  (EBCDIC CP5110 ASCII)"
  Scn1$(18)="                                              CO  Code out (EBCDIC CP5110 ASCII)"
  Scn1$(19)="                                              MR  Max. Records (1-99999)"
  Scn1$(20)="Rem.: * only during Open Com Port used        DM  Debug mode"
  Scn1$(21)="                                              OP* CS,DS,CD,DT Options"

'  GOTO MANSIO
SMenu1:                                                 'MENU 1
  COLOR 15,1 : GOSUB Header1 : GOSUB Header2
  CALL ClrLin(3,24,15,1)
  CALL PrCha(2,34,10,"* MENU 1 *",14,4)
  CALL SetCol(25,1,25,80,15,4) : DELAY(0.1) : CALL Info("",0,0)
  FOR Z%=4  TO 24 : CALL LiPrt(Z%,Scn1$(Z%-3),15,1) : NEXT Z%
  ChkbFlg%=0 : SpinFlg%=0
  GOSUB DefSwPa
  CALL FSInp(Men1%+2,1,"",15,1,15,1,CL%,CC%,3,9,1,80,"OC  MDE",M1%)

  IF M1%=0 THEN M1%=INT(CL%-3)
  IF M1%=0 THEN GOTO SMenu1

  ' Debug
  CALL LiPrt(2,"SIO.M1% = "+STR$(SIO.M1%),14,1)

  ON M1% GOTO OpenCom,CloseCom,SMenu1,SMenu1,IBManOp,CDOSin,PEnd
  GOTO SMenu1

' StTraF  - set trace file

'  PRINT "Hello WORLD"

MANSIO:  
  GOSUB IB.DEB			' USB_SIO Menu

  CALL ClrLin(3,23,15,1)

  PRINT "That's all..."
  END

ERRFINAL:
  KEY OFF : CLS : ON TIMER (5) GOSUB Clock : TIMER ON
  PRINT "Exited with error: "+STR$(ERR)
'  GOTO SMENU1
  STOP

'************** Subroutines ****************************************************

Clock:
  CALL WrCha(1,65,16,LEFT$(DATE$,6)+RIGHT$(DATE$,2)+"   "+LEFT$(TIME$,5)) : RETURN

Header1:                                                'Headerline 1
  CALL PrCha(1,1,80,PROG$+" "+Options$,10,4)
  CALL PrCha(1,28,34,PROG$+" VERSION: "+EC$,15,4) : GOSUB Clock : RETURN

Header2:                                                'Headerline 2
'  CALL PrCha(2,1,80,"SETFILE: "+SetFil$,10,4)
  CALL ClrLin(2,2,10,4)
  CALL PrCha(2,51,30,"TRACEFILE: "+TraFil$,10,4) : RETURN


DefSwPa:
  CALL ChkBox(13, 2,P1 ,RC$,15,2,ChkbFlg%) : P1 =VAL(RC$)
  CALL ChkBox(14, 2,P2 ,RC$,15,2,ChkbFlg%) : P2 =VAL(RC$)
  CALL ChkBox(15, 2,P3 ,RC$,15,2,ChkbFlg%) : P3 =VAL(RC$)
  CALL ChkBox(16, 2,P4 ,RC$,15,2,ChkbFlg%) : P4 =VAL(RC$)
  CALL ChkBox(17, 2,P5 ,RC$,15,2,ChkbFlg%) : P5 =VAL(RC$)
  CALL ChkBox(18, 2,P6 ,RC$,15,2,ChkbFlg%) : P6 =VAL(RC$)
  CALL ChkBox(19, 2,P7 ,RC$,15,2,ChkbFlg%) : P7 =VAL(RC$)
  ChkbFlg%=0
  CALL SpinBut(13,41, 4,P11$,C11$,1,RC$,15,2,SpinFlg%) : P11$=RC$
  CALL SpinBut(14,40, 5,P12$,C12$,1,RC$,15,2,SpinFlg%) : P12$=RC$
  CALL SpinBut(15,44, 1,P13$,C13$,1,RC$,15,2,SpinFlg%) : P13$=RC$
  CALL SpinBut(16,44, 1,P14$,C14$,1,RC$,15,2,SpinFlg%) : P14$=RC$
  CALL EntrFld(17,40, 5,P15$,       RC$,15,2,SpinFlg%) : P15$=RC$
  CALL SpinBut(18,44, 1,P16$,C16$,1,RC$,15,2,SpinFlg%) : P16$=RC$
  CALL EntrFld(19,43, 2,P17$,       RC$,15,2,SpinFlg%) : P17$=RC$
  CALL SpinBut(20,39, 6,P18$,C18$,1,RC$,15,2,SpinFlg%) : P18$=RC$
  CALL SpinBut(21,39, 6,P19$,C19$,1,RC$,15,2,SpinFlg%) : P19$=RC$
  CALL EntrFld(22,40, 5,P20$,       RC$,15,2,SpinFlg%) : P20$=RC$
  CALL SpinBut(23,44, 1,P21$,C21$,1,RC$,15,2,SpinFlg%) : P21$=RC$
  CALL EntrFld(24,20,25,P22$,       RC$,15,2,SpinFlg%) : P22$=RC$
  SpinFlg%=0
' Men1%=4
  RETURN


ErrH:                                                   'System Errorhandling
  CALL WrCha(25,1,78,"ERROR "+STR$(ERR))
  CALL Enter : 
  CALL ClrBlk(25,1,25,70)
  GOTO ERRFINAL
  RETURN

ErrMsg:                                                 'User Errorhandling
  CALL WrCha(25,1,70,Msg$)
  CALL Enter : CALL ClrBlk(25,1,25,70)
  RETURN

PrtScn:                                       '*** Print screen ***
  FOR L0% = 1 TO 25
    CALL RdDis(L0%,1,80,RD$)                  '*** read characters ***
    LPRINT RD$;
  NEXT L0%
  RETURN

FUNCTION Info(Msg$,B%,E%)                     '*** Print info in line 25 ***
  Call WrCha(25,1,70,LEFT$(Msg$,70))
  DELAY 0.05
  IF B%=1 THEN : BEEP
  IF E%=1 THEN : CALL Enter
END FUNCTION


OpenCom:                                                'Open Com port
  IF SIO.Dflg%=1 THEN
    IF P4=0  THEN RS$ =""    ELSE RS$ =",RS"
    IF P5=0  THEN ME$ =""    ELSE ME$ =",ME"
    IF P6=0  THEN PE$ =""    ELSE PE$ =",PE"
    IF P7=0  THEN FE$ =""    ELSE FE$ =",FE"
  END IF
  Tra%=1 : Hex%=0 : Pdf%=0
  IF INSTR("8HP",P14$)>0 THEN
    Bits$="8"
  ELSE
    Bits$=P14$
  END IF
  SioOptions$= LTRIM$(RS$+P22$+PE$+ME$+FE$)
  CALL INIT(P11$,P12$,P13$,Bits$,P15$,P16$,SioOptions$,SIO.Dflg%)
  CALL IbStat("..")
  PRINT #6,"SIOXFER OPEN: ";DATE$;" ";TIME$
  Men1%=6
  GOTO SMenu1

CloseCom:                                               'Close Com port
'  SIO.Dflg%=1
'  CALL INIT(P11$,P12$,P13$,P14$,P15$,P16$,SioOptions$,SIO.Dflg%)
  CALL SHUTDOWN(P11$,SIO.Dflg%)
  CALL IbStat("  ")
  PRINT #6,"SIOXFER CLOSE ";DATE$;" ";TIME$
  Men1%=2
  GOTO SMenu1

CDOSin:                                                 'DOS Prompt
  CALL PrCha(24,1,80,"ENTER DOS COMMAND ",15,4)
  CALL RdCha(24,19,62,A$,15,2)
  COLOR 7,0,0 : CLS : SHELL A$ : CALL Enter
  GOTO SMenu1

IBManOp:
  GOSUB IB.DEB
  GOTO SMenu1

PEnd:                                                   'Program - End
  CALL PrCha(24,1,80,"Y = Programend yes",15,1)
  CALL RdCha(24,64,1,A$,15,2)
  IF INSTR("Yy",A$)=0 GOTO SMenu1
  CLOSE
  COLOR 7,0,0
'  CLS
  END
  
