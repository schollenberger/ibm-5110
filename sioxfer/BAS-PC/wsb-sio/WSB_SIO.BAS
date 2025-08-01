  $COMPILE EXE                                          'Compiler statements
  $CPU 80386
  $COM 32000             ' You need this to receive long files on slow machines
  $LIB COM+
  ''$LIB LPT ON
  $OPTION CNTLBREAK ON
  $OPTION AUTODIM OFF
  $STACK 3000
  $STATIC

'*******************************************************************************
'* .FILE:         sioxfer.bas                                                  *
'*                                                                             *
'* .DESCRIPTION:  Test functions of BASIC module USB_SIO                       *
'*                Manual Interface to talk with the IBM 5110 via the           *
'*                serial line.                                                 *
'*                                                                             *
'* Initial coding : June 2025 W. Schollenberger                                *
'*                                                                             *
'* Changes:                                                                    *
'*                                                                             *
'* Date       Who  Vers. Changed by Reason                                     *
'*                                                                             *
'* 16.06.2025 WSB  1.0   8-bit EBCDIC GET / PUTtransfer with IBM 5110          *
'*                       IBM 5110 Program SIO8IO                               *
'* 20.07.2025 WSB  1.1   7-bit ASCII support WIP                               *
'*                       Added 2nd Menu for file send/rcv                      *
'* Done:                                                                       *
'*       GET/PUT 8-bit EBCDIC with IBM 5110                                    *
'*       Read SIO flags from command line                                      *
'*                                                                             *
'* To do:                                                                      *
'*       GET to File                                                           *
'*       PUT from file                                                         *
'*       Repect COM status open / close                                                                      *
'*                                                                             *
'*                                                                             *
'*******************************************************************************

  GOTO START
'  GOTO MANSIO

'  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\DISPLAY.BAS"         'Screen Functions
'  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\UNIT.BAS"            'Universal Functions
  $INCLUDE  "..\INCLUDE\DISPLAY.BAS"                    'Screen Functions
  $INCLUDE  "..\INCLUDE\UNIT.BAS"                       'Universal Functions
  $INCLUDE  "CODEGEN.BAS"                               'Code table functions
  $INCLUDE  "USB_SIO.BAS"                               'USB_SIO Functions

START:

  PROG$      = "WSB_SIO"                                 'Program Name
  EC$        = "1.1 (20.7.2025)"                         'program version

  Options$   = UCASE$(LEFT$(COMMAND$,16))
  SIO.Cflg%  = SGN(INSTR(Options$,"/C"))                'Code Pages in Msg File
  SIO.Dflg%  = SGN(INSTR(Options$,"/D"))                'Debug (no serial I/O)
  SIO.Tflg%  = SGN(INSTR(Options$,"/T"))                'Trace data in Tra File
  SIO.Tflg%  = 1        'Overwrite command line during dev phase

  IB.Stat$   = "  "                                     'IB Status
  ComStat%   = 0                                        'COM status 0/1/2 - off/on/opening
  CR$        = CHR$(13)                                 'CR  X'0D'
  LF$        = CHR$(10)                                 'LF  X'0A'
  RS1E$      = CHR$(30)                                 'RS  X'1E'
  DLE$       = CHR$(16)                                 'DLE X'10'
  LFE$       = CHR$(21)+CHR$(30)                        'NL+EB1 X'151E'
  ' LFE$       = CHR$(21)+CHR$(30)+CHR$(31)               'NL+EB1 X'151E1F'
  EOFP$      = CHR$( 4)+CHR$(21)+CHR$(30)+CHR$(31)      'EOT+LF+RS+US X'04151E1F'

' #TODO# need to make EFOG chars code page dependent
'  EOFG$      = CHR$( 4)+CHR$(30)+CHR$(31)               'EOT+RS+US X'041E1F' - EBCDIC
  EOFG$      = CHR$( 3)                                  'EOT X'03' - ASCII - no crlf

  Ef%        = 0                                        ' default values
  EOLIN$     = ""                                       'Current EOL string on get
  EOLOUT$    = ""                                       'Current EOL string on put
  EOBUFIN$   = ""                                       'END OF BUFFER on get (0x8D 0x0A for EBCDIC)
  Men1%      = 2  ' Initial position on first screen
  Men2%      = 3  ' Initial position on second screen
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
  P11$       = "COM1"   : C11$       = "COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8"    ' PO* Port
  P12$       = "9600"   : C12$       = "75 110 150 300 600 1200 1800 2400 4800 9600 19200 38400 57600 115200 "  ' BR* Baudrate
'  P13$       = "N"      : C13$       = "N E O S M"                                  ' PA* Parity
'  P14$       = "8"      : C14$       = "5 6 7 8 H P"                                ' BI  Bits
  P13$       = "E"      : C13$       = "N E O S M"                                  ' PA* Parity
  P14$       = "7"      : C14$       = "5 6 7 8 H P"                                ' BI  Bits
  P15$       = "256"                                                                ' RL  Max. Recordlength (1-32000)
  P16$       = "2"      : C16$       = "1 2"                                        ' ST* Stop Bits
  P17$       = "0"      : C17$       = "0 1 2 3 4 5 6 7 8 9 A B C D E F"            ' IM  Ignore Mode
  P18$       = "EBCDIC" : C18$       = "EBCDIC CP5110 CP5100 ASCII CI5110 CI5100"   ' CI  Code in (Translation on GET)
  P19$       = "EBCDIC" : C19$       = "EBCDIC CP5110 CP5100 ASCII HEX"             ' CO  Code Out (Translation on PUT)
  P19$       = "ASCII"
  P18$       = "ASCII"

  P20$       = "99999"
  P21$       = "0"      : C21$       = "0 1 2 3"

'  P22$       = ""          ' CTS handshake - default timeout
  P22$       = ",CS0"      ' no CTS handshake - not a good idea !!
'  P22$       = ",CS60000"  ' wait long for CTS to become active


  T18$       = ""                   'code page IN
  T19$       = ""                   'code page OUT
  CPlocal$   = ""                   'local code page

  HexChr$    = "0123456789ABCDEF"
  MsgFile$   = PROG$+".msg"
  HistFile$  = PROG$+".his"
  SetFil$    = "TEST"
  SetFile$   = SetFil$+".set"
  TraFil$    = PROG$
  TracFile$  = TraFil$+".tra"
  TestFile$  = PROG$+".tst"

  SrcFile$   = "tput.txt"
  DstFile$   = "tget.txt"
  CtlFil$    = PROG$

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
  PRINT #5,"Select code pages Input = ";P18$;"  Output = ";P19$

  GOSUB CodeSel                 ' assigns configured code pages to T18$, T19$
                                ' and CPlocal$

  IF  SIO.Dflg% = 1 THEN
    CALL SetASCFILE
    CALL Set5110FILE
  END IF

' Here we go
  PRINT #5, "Current values of EOLIN and EOLOUT$: ";StringHex(EOLIN$); " - ";StringHex$(EOLOUT$)

  DIM Scn1$(21),Scn2$(21)

  ' COLOR 15,1 : CLS : GOSUB Header1 : GOSUB Header2
  ' CALL SetCol(25,1,25,80,15,4)   ' set color on last line'
  ' CALL ClrLin(3,23,15,1)

' Screen 1 content'
  Scn1$(1) ="O Open Com Port                           Start new Tracefile (no ext)"
  Scn1$(2) ="C Close Com Port"
  ' Scn1$2) ="P Define Parameters"
  Scn1$(3) =""
  Scn1$(4) ="T Start Transfer"
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

' Screen 2 content'
  Scn2$(1) ="E Menu 1"
  Scn2$(2) =""
  ' Scn2$(2) ="T Specify Filetype"
  Scn2$(3) ="S Specify source directory and filename"
  Scn2$(4) ="D Specify destination directory and filename"
  Scn2$(5) ="P Put file from Host Computer to Guest Computer"
  Scn2$(6) ="G Get file from Guest Computer to Host Computer"
  Scn2$(7) ="M Message"
  Scn2$(8) =""
  Scn2$(9) =""
  Scn2$(10) =""
  ' Scn2$(8) ="C Transfer using a controlfile"
  ' Scn2$(9) ="- Specify dump titleline"
  ' Scn2$(10)="- Generate PALM Processor Code File"
  Scn2$(11)="-"
  Scn2$(12)="-"
  Scn2$(13)=""
  Scn2$(14)=""
  Scn2$(15)=""
  Scn2$(16) =""
  ' Scn2$(16)="Filetype       :"
  Scn2$(17)="Sourcefile     :"
  Scn2$(18)="Destinationfile:"
  Scn2$(19) =""
  Scn2$(20) =""
  Scn2$(21) =""
  ' Scn2$(19)="Message        :"
  ' Scn2$(20)="Ctlfile        :"
  ' Scn2$(21)="Dumptitleline  :"

'  GOTO MANSIO

' Menu1 display and processing

SMenu1:                                                 'MENU 1
  CLOSE #1
  COLOR 15,1 : GOSUB Header1 : GOSUB Header2
  CALL ClrLin(3,24,15,1)
  CALL PrCha(2,34,10,"* MENU 1 *",14,4)
  CALL SetCol(25,1,25,80,15,4) : DELAY(0.1) : CALL Info("",0,0)
  FOR Z%=4  TO 24 : CALL LiPrt(Z%,Scn1$(Z%-3),15,1) : NEXT Z%
  ChkbFlg%=0 : SpinFlg%=0
  GOSUB DefSwPa
  CALL WrComStat

  CALL FSInp(Men1%+2,1,"",15,1,15,1,CL%,CC%,4,10,1,80,"O C   T M D E ",M1%)

  'IF M1%=0 THEN M1%=INT(CL%-3)
  IF M1%=0 THEN M1%=INT((CL%-3)*2)+INT(CC%/40)-1
  IF M1%=0 THEN GOTO SMenu1

  ' Debug
  CALL LiPrt(2,"M1% = "+STR$(M1%),14,1)
  ' CALL Enter

  ON M1% GOTO OpenCom,StTraF,CloseCom,SMenu1,SMenu1,SMenu1,SMenu2,SMenu2,SIOManOp,SMenu1,CDOSin,SMenu1,PEnd,PEnd
  GOTO SMenu1

'*******************************************************************************
SMenu2:                                                 'MENU 2
  KeyIn$=""
  COLOR 15,1 : GOSUB Header1 : GOSUB Header2
  CALL ClrLin(3,24,15,1)
  Call WrCha(25,71,7,"")
  CALL PrCha(2,34,10,"* MENU 2 *",14,4)
  CALL SetCol(25,1,25,80,15,4) : DELAY(0.1) : CALL Info("",0,0)
  FOR Z%=3  TO 23 : CALL LiPrt(Z%,Scn2$(Z%-2),15,1) : NEXT Z%
  'CALL PrCha(18,18,18,FileType$,14,1)
  CALL PrCha(19,18,62,SrcFile$ ,14,1)
  CALL PrCha(20,18,62,DstFile$ ,14,1)
  'CALL PrCha(21,18,62,Message$ ,14,1)
  'CALL PrCha(22,18,62,CtlFil$  ,14,1)
  'CALL PrCha(23,18,62,DmpTline$,14,1)
  CALL WrComStat

  CALL FSInp(Men2%+2,1,"",15,1,15,1,CL%,CC%,3,14,1,80,"E SDPGM     ",M2%)
  IF M2%=0 THEN M2%=CL%-2
  Z%=M2%+2
  ' Debug
  CALL LiPrt(2,"M2% = "+STR$(M2%),14,1)
  ' CALL Enter

  ON M2% GOTO SMenu1,SMenu2,SFile,Dfile,PutFile,GetFile,Messg,Smenu2,Smenu2
  GOTO SMenu2

Sfile:
  CALL RdCha(19,18,62,SrcFile$,15,2)
  SrcFile$=RTRIM$(SrcFile$)
  GOTO SMenu2

Dfile:
  CALL RdCha(20,18,62,DstFile$,15,2)
  DstFile$=RTRIM$(DstFile$)
  GOTO SMenu2

PutFile:
  IF ComStat% = 1 THEN
    GOSUB PFile
    CALL Info("Filetransfer ended - Press enter",1,1)
  ELSE
    Msg$="COM port not open! Press enter to return...."
    GOSUB ErrMsg
  END IF
  GOTO SMenu2

PFile:
  RECS = 0
  CALL Info("Sourcefile="+SrcFile$,0,0)
  IF (P2=1) THEN
    PRINT #6,"PUTFILE Srcfile=";SrcFile$;" to serial"
  END IF
  StartTime=INT(TIMER)
  OPEN SrcFile$ FOR INPUT AS #1
  WHILE NOT EOF(1)
    LINE INPUT #1, Inputline$
    Inputline$=RTRIM$(Inputline$)
    IF P1=1 THEN : CALL Info(Inputline$,0,0)
    CALL PUTSConv(Inputline$)
    CALL PUTS(EOLOUT$)
    DELAY 0.1

  WEND
  CLOSE #1
  PUTS(EOFP$+EOLOUT$)
  StopTime=INT(TIMER)
  RunTime=StopTime-StartTime
  IF (P2=1) THEN
    PRINT #6, "  Date:";DATE$;"  Time:";TIME$;" Runtime:";RunTime;" Sec."
  END IF
  PRINT #2, "PUTFILE Srcfile="+SrcFile$+" to serial"
RETURN

GetFile:
  IF ComStat% = 1 THEN
    GOSUB GFile
    CALL Info("Filetransfer ended - Press enter",1,1)
  ELSE
    Msg$="COM port not open! Press enter to return...."
    GOSUB ErrMsg
  END IF
  GOTO SMenu2

GFile:
  RECS = 0
  CALL BufC
  CALL Info("Desinationfile="+DstFile$,0,0)
  Ef%=0
  IF (P2=1) THEN
    PRINT #6,"GETFILE Dstfile=";DstFile$;" from serial"
  END IF
  StartTime=INT(TIMER)
  OPEN DstFile$ FOR OUTPUT AS#1
  Inputline$=""
  Rec.Cnt%=VAL(P20$)
  PRINT #5, "** GFILE - Start to read file..."
  CALL WrCha(24,61,20,"--Press # to stop")
  WHILE Ef%=0

    Inputline$=GetSConv$(VAL(P15$))
''    Inputline$=GetLine$(2)

    IF Ef%=0 THEN
      Rec.Cnt%=Rec.Cnt%-1
      IF Rec.Cnt%= 0 THEN Ef%=1
      IF SIO.Tflg%=1 THEN : PRINT #6,"** GETS-";Inputline$
      PRINT #1,Inputline$
      ''CALL PrCha(25,71,6,RIGHT$("     "+STR$(RECS),6),15,4)
    ELSE
      PRINT #5,"** GFILE - EOF received - finishing up"
      CALL BufC
   END IF
  WEND
  CALL WrCha(24,61,20,"")
  CLOSE #1
  StopTime=INT(TIMER)
  RunTime=StopTime-StartTime
  IF (P2=1) THEN
    PRINT #6, "  Date:";DATE$;"  Time:";TIME$;" Runtime:";RunTime;" Sec."
  END IF
  PRINT #2, "GETFILE Dstfile="+DstFile$;" from serial"
  PRINT #5, "** GFILE - ...done"
RETURN

Messg:
  IF ComStat% = 1 THEN
    GOSUB Mess
    CALL Info("Message sent - Press enter",1,1)
  ELSE
    Msg$="COM port not open! Press enter to return...."
    GOSUB ErrMsg
  END IF
  GOTO SMenu2

Mess:                                  ' Send message via serial
  GOSUB CodeSel
  CALL RdCha(21,18,62,Message$,15,2)
  Msg$=DLE$+"MESSAGE="+RTRIM$(Message$)
  PUTSconv(Msg$)
  IF P1=1 THEN : CALL Info(Msg$,0,0)
  IF SIO.Tflg%=1 THEN : PRINT #6,"** Mess-";Msg$
  RETURN


MANSIO:
  GOSUB IB.DEB                  ' USB_SIO Menu
  ' CALL SIO.MANOPS
  CALL ClrLin(3,23,15,1)

  PRINT "That's all..."
  END

ERRFINAL:
  KEY OFF : CLS : ON TIMER (5) GOSUB Clock : TIMER ON
  PRINT "Exited with error: "+STR$(ERR)
  GOTO SMENU1
  ''STOP

'************** Menu execution code  *******************************************

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
  ComStat%=2 : CALL WrComStat
  SioOptions$= LTRIM$(RS$+P22$+PE$+ME$+FE$)
  PRINT #5,"**OpenCom--Calling INIT with: ";P11$,P12$,P13$,Bits$,P15$,P16$,SioOptions$
  CALL INIT(P11$,P12$,P13$,Bits$,P15$,P16$,SioOptions$,SIO.Dflg%)
  ComStat%=1 : CALL WrComStat
  PRINT #6,PROG$;" OPEN: ";DATE$;" ";TIME$
  Men1%=6
  GOTO SMenu1

CloseCom:                                               'Close Com port
  ' SIO.Dflg%=1
  ' CALL INIT(P11$,P12$,P13$,P14$,P15$,P16$,SioOptions$,SIO.Dflg%)
  CALL SHUTDOWN(P11$,SIO.Dflg%)
  ComStat%=0 : CALL WrComStat
  PRINT #6,"SIOXFER CLOSE ";DATE$;" ";TIME$
  Men1%=2
  GOTO SMenu1

StTraF:                                                 'Set Trace file
  CALL RdCha(2,62,19,Trafil$,15,2) : TracFile$=RTRIM$(Trafil$)+".tra"
  PRINT #5,"**StTraF--New Tracefile = ";TracFile$
  CLOSE #6
  OPEN TracFile$ FOR OUTPUT AS#6
  PRINT #6,TracFile$+" started: ";DATE$;" ";TIME$
  GOTO Smenu1

CDOSin:                                                 'DOS Prompt
  CALL PrCha(24,1,80,"ENTER DOS COMMAND ",15,4)
  CALL RdCha(24,19,62,A$,15,2)
  COLOR 7,0,0 : CLS : SHELL A$ : CALL Enter
  GOTO SMenu1

SIOManOp:                                'Manual Options (Module USB_SIO)
  IF ComStat% = 1 THEN
    GOSUB IB.DEB
    'CALL SIO.MANOPS
  ELSE
    Msg$="COM port not open! Press enter to return...."
    GOSUB ErrMsg
  END IF
  GOTO SMenu1

PEnd:                                                   'Program - End
  CALL PrCha(24,1,80,"Y = Programend yes",15,1)
  CALL RdCha(24,64,1,A$,15,2)
  IF INSTR("Yy",A$)=0 GOTO SMenu1
  CLOSE
  COLOR 7,0,0
  ' CLS
  END

'************** Subroutines ****************************************************

Clock:
  CALL WrCha(1,65,16,LEFT$(DATE$,6)+RIGHT$(DATE$,2)+"   "+LEFT$(TIME$,5))
  RETURN

Header1:                                                'Headerline 1
  CALL PrCha(1,1,80,PROG$+" "+Options$,10,4)
  CALL PrCha(1,28,34,PROG$+" VERSION: "+EC$,15,4)
  GOSUB Clock
  RETURN

Header2:                                                'Headerline 2
  ' CALL PrCha(2,1,80,"SETFILE: "+SetFil$,10,4)
  CALL ClrLin(2,2,10,4)
  CALL PrCha(2,51,30,"TRACEFILE: "+TraFil$,10,4)
  RETURN

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

CodeSel:                                    'Select code page called via GOSUB to keep
                                            'Variables PUBLIC
  SELECT CASE P18$
    CASE "EBCDIC" : T18$=EBCDIC$ : EOLIN$=LFE$+CR$ : EOBUFIN$=CHR$(141)+CHR$(10)   'END OF BUFFER on get 0x8D 0x0A
    CASE "ASCII"  : T18$=CP437$  : EOLIN$=CR$+LF$  : EOBUFIN$=CR$+LF$
    CASE "CP5110" : T18$=CP5110$ : EOLIN$=LFE$
    CASE "CP5100" : T18$=CP5100$ : EOLIN$=LFE$
    CASE "CI5110" : T18$=CI5110$ : EOLIN$=LFE$
    CASE "CI5100" : T18$=CI5100$ : EOLIN$=LFE$
  END SELECT
  SELECT CASE P19$
    CASE "EBCDIC" : T19$=EBCDIC$ : EOLOUT$=RS1E$+CR$         ' wasLFE$+CR$
    CASE "ASCII"  : T19$=CP437$  : EOLOUT$=CR$
    CASE "CP5110" : T19$=CP5110$ : EOLOUT$=LFE$
    CASE "CP5100" : T19$=CP5100$ : EOLOUT$=LFE$
  END SELECT
  CPlocal$=CP437$
  RETURN

ErrH:                                                   'System Errorhandling
  CALL WrCha(25,1,76,"ERROR "+STR$(ERR))
  CALL Enter
  CALL ClrBlk(25,1,25,70)
  GOTO ERRFINAL
  RETURN

ErrMsg:                                                 'User Errorhandling
  CALL WrCha(25,1,70,Msg$)
  BEEP
  CALL Enter : CALL ClrBlk(25,1,25,70)
  RETURN

PrtScn:                                       '*** Print screen ***
  FOR L0% = 1 TO 25
    CALL RdDis(L0%,1,80,RD$)                  '*** read characters ***
    LPRINT RD$;
  NEXT L0%
  RETURN

'************** BASIC function  ************************************************

FUNCTION Info(Msg$,B%,E%)                     '*** Print info in line 25 ***
  Call WrCha(25,1,70,LEFT$(Msg$,70))
  DELAY 0.05
  IF B%=1 THEN : BEEP
  IF E%=1 THEN : CALL Enter
END FUNCTION

SUB WrComStat SHARED '************ COM port status - use global variable
  SELECT CASE ComStat%
    CASE 0
      CALL IbStat("  ")
    CASE 1
      CALL IbStat("..")
    CASE 2
      CALL IbStat("^^")
    CASE ELSE
      CALL IbStat("??")
  END SELECT
  DELAY(0.1)
END SUB
