  $COMPILE EXE                                          'Compiler statements
  $CPU 80386
  $COM 32000
  $LIB COM+
  $LIB LPT ON
  $OPTION CNTLBREAK ON
  $OPTION AUTODIM OFF
  $STACK 3000
  $STATIC
'*******************************************************************************
'* .FILE:         sioxfer.bas                                                  *
'*                                                                             *
'* .DESCRIPTION:  Sioxfer Program Version 3:                                   *
'*                                                                             *
'* Initial coding : 22.10.2007                                                 *
'*                                                                             *
'* Changes:                                                                    *
'*                                                                             *
'* Date       Vers. Changed by Reason                                          *
'* 28. 3.2023 2.0   Complete new                                               *
'* 30. 3.2023       New SpinBut and ChkBox functions                           *
'* 31. 3.2023       Optimize Transfer time in Getfile                          *
'*  3. 4.2023       New Menu with more functions                               *
'* 11. 4.2023       Optimize COM Parameters                                    *
'* 30. 4.2023       Generate CP5100 Codepage                                   *
'*  8. 5.2023       Debug Controlfile functions, change FileType fom HEX to ALC*
'* 25. 5.2023       Define new FileTypes                                       *
'*  3. 6.2023       Define P14$ H(Hex), I(Disable EF), 9(Disable EF)           *
'*  8. 6.2023       Allow End of File EFS=x'1A', EFL=x'1A151E1F'               *
'* 18. 6.2023       Debug PALM Diassembler, change EOF detection in USB_SIO.BAS*
'* 27. 6.2023       Generate debug codepages and implement Debug Mode (0-3)    *
'*  3. 7.2023       Implement BufC function to delete unused records           *
'*  5. 7.2023       Change EOF (x'1A') to EOT (x'04') and change CP5110 table  *
'* 14. 7.2023       Implement BufC Function                                    *
'* 15. 7.2023       Implement Ignore Mode in Gets Function                     *
'* 16. 7.2023       Implement Message Function                                 *
'* 18. 7.2023       Implement Filetype 500 Function                            *
'* 20. 7.2023       Implement Ignore Mode in Puts Function                     *
'* 24. 7.2023       Define new EOFG as x'041E1F' and EOFP$ as 'x'04151E'       *
'* 25. 7.2023       Delete Function for Guest Computer                         *
'* 28. 7.2023       Change Switches P1..P10 to P1..P7                          *
'*                  Do not allow ASCII as Code out                             *
'*  1. 8.2023       Change IM Ignore Mode to 2 Hex Digits                      *
'*  2. 8.2023       Add 'End' Statement to *.SET Files                         *
'*  5. 8.2023       ADD 'P' for PDF Statement to BI Bits                       *
'*  5. 2.2025       Implement 7 Bit Support                                    *
'*                                                                             *
'*                                                                             *
'* To do:                                                                      *
'*       Warning if argc = 1                                                   *
'*       Manual Serial Bus Operations                                          *
'*       Save .set File delete blanc at end of line                            *
'*       DASS: Verify ROTR,SHFTR,GETR,GETRB instructions                                                                      *
'*       Delete end of file signals at Hex%=1                                  *
'*       EBCDIC Code add some more characters                                  *
'*       Putfile HEX                                                           *
'*       Handle Pdf%                                                           *
'*       getfile for 5,6,7 Bit code                                            *
'*       delete pdf option                                                     *
'******************************************************************************/

  GOTO StartProgram

  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\DISPLAY.BAS"                    'Screen Functions
  $INCLUDE  "D:\TOOLS\BAS\INCLUDE\UNIT.BAS"                       'Universal Functions
  $INCLUDE  "USB_SIO.BAS"                               'USB_SIO Functions
  $INCLUDE  "CODEGEN.BAS"                               'Generate codes
  $INCLUDE  "PALMDISA.BAS"                              'PALM Diassembler

StartProgram:                                           'Programstart
' COLOR 15,1,0 : CLS : LOCATE 1,1,0,7,7
  PROG$      = "SIOXFER3"                               'Program Name
  EC$        = "3.0 (17.6.2025)"                        'Sioxfer program version
  Options$   = UCASE$(LEFT$(COMMAND$,16))
  SIO.Cflg%  = SGN(INSTR(Options$,"/C"))                'Code Pages in Msg File
  SIO.Dflg%  = SGN(INSTR(Options$,"/D"))                'Debug (no serial I/O)
  SIO.Tflg%  = SGN(INSTR(Options$,"/T"))                'Trace data in Tra File
  IB.Stat$   = "  "                                     'IB Status
  LF$        = CHR$(10)                                 'LF  X'0A'
  RS1E$      = CHR$(30)                                 'RS  X'1E'
  DLE$       = CHR$(16)                                 'DLE X'10'
  LFE$       = CHR$(21)+CHR$(30)                        'NL+EB1 X'151E'
' LFE$       = CHR$(21)+CHR$(30)+CHR$(31)               'NL+EB1 X'151E1F'
  EOFP$      = CHR$( 4)+CHR$(21)+CHR$(30)+CHR$(31)      'EOT+LF+RS+US X'04151E1F'
  EOFG$      = CHR$( 4)+CHR$(30)+CHR$(31)               'EOT+RS+US X'041E1F'
  Ef%        = 0                                        ' default values
  Men1%      = 1
  Error.Cnt% = 0
  Rec.Cnt%   = 0
  Tra%       = 0
  Hex%       = 0
  Pdf%       = 0
  Ig151E%    = 0
  Ig15%      = 0
  Ig1A%      = 1
  IgEf%      = 0
  P1         = 1
  P2         = 1
  P3         = 0
  P4         = 0
  P5         = 0
  P6         = 0
  P7         = 0
  P11$       = "COM1"   : C11$       = "COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8"
  P12$       = "9600"   : C12$       = "75 110 150 300 600 1200 1800 2400 4800 9600 19200 38400 57600 115200 "
  P13$       = "N"      : C13$       = "N E O S M"
  P14$       = "8"      : C14$       = "5 6 7 8 H P"
  P15$       = "256"
  P16$       = "2"      : C16$       = "1 2"
  P17$       = "0"      : C17$       = "0 1 2 3 4 5 6 7 8 9 A B C D E F"
  P18$       = "EBCDIC" : C18$       = "EBCDIC CP5110 CP5100 ASCII CI5110 CI5100"
  P19$       = "EBCDIC" : C19$       = "EBCDIC CP5110 CP5100 HEX"
  P20$       = "99999"
  P21$       = "0"      : C21$       = "0 1 2 3"
  P22$       = ",CS60000"
  T18$       = EBCDIC$
  T19$       = EBCDIC$

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

  DIM Scn1$(21),Scn2$(21),Pa$(10)
  KEY OFF : WIDTH "LPT1:",132 : ON KEY(31) GOSUB PrtScn : KEY(31) ON
  OPEN MsgFile$ FOR OUTPUT AS#5
  PRINT #5,Prog$+" started: ";DATE$;" ";TIME$
  OPEN HistFile$ FOR APPEND AS#2
  PRINT #2,Prog$+" started: ";DATE$;" ";TIME$
  OPEN TracFile$ FOR OUTPUT AS#6
  PRINT #6,TracFile$+" started: ";DATE$;" ";TIME$
  ON ERROR GOTO ErrH : KEY OFF : CLS : ON TIMER (60) GOSUB Clock : TIMER ON
  COLOR 15,1 : CLS : GOSUB Header1 : GOSUB Header2
  CALL SetCol(25,1,25,80,15,4)
  CALL ClrLin(3,23,15,1)
  CALL SetXltASCII  : T18$=CP437$  : T19$=CP437$
  CALL SetXltEBCDIC : T18$=EBCDIC$ : T19$=EBCDIC$
  CALL SetXltCP5110 : T18$=CP5110$ : T19$=CP5110$
  CALL SetXltCI5110 : T18$=CI5110$ : T19$=CI5110$
  CALL SetXltCP5100 : T18$=CP5100$ : T19$=CP5100$
  CALL SetXltCI5100 : T18$=CI5100$ : T19$=CI5100$
  CALL SetASCFILE
  CALL Set5110FILE
  Scn1$(1) ="L Load .set File                          Save .set File"
  Scn1$(2) ="  Start new Tracefile"
  Scn1$(3) ="S Define Switches                       P Define Parameters"
  Scn1$(4) ="O Open Com Port                           Close Com Port"
  Scn1$(5) ="T Start Transfer                          Disconnect Guest Computer"
  Scn1$(6) ="D Enter DOS Command                     M Manual Serial Bus Operations"
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

  Scn2$(1) ="E Menu 1"
  Scn2$(2) ="T Specify Filetype"
  Scn2$(3) ="S Specify source directory and filename"
  Scn2$(4) ="D Specify destination directory and filename"
  Scn2$(5) ="P Put file from Host Computer to Guest Computer"
  Scn2$(6) ="G Get file from Guest Computer to Host Computer"
  Scn2$(7) ="M Message"
  Scn2$(8) ="C Transfer using a controlfile"
  Scn2$(9) ="- Specify dump titleline"
  Scn2$(10)="- Generate PALM Processor Code File"
  Scn2$(11)="-"
  Scn2$(12)="-"
  Scn2$(13)=""
  Scn2$(14)=""
  Scn2$(15)=""
  Scn2$(16)="Filetype       :"
  Scn2$(17)="Sourcefile     :"
  Scn2$(18)="Destinationfile:"
  Scn2$(19)="Message        :"
  Scn2$(20)="Ctlfile        :"
  Scn2$(21)="Dumptitleline  :"

SMenu1:                                                 'MENU 1
  CLOSE #1
  COLOR 15,1 : GOSUB Header1 : GOSUB Header2
  CALL ClrLin(3,24,15,1)
  CALL PrCha(2,34,10,"* MENU 1 *",14,4)
  CALL SetCol(25,1,25,80,15,4) : DELAY(0.1) : CALL Info("",0,0)
  FOR Z%=3  TO 23 : CALL LiPrt(Z%,Scn1$(Z%-2),15,1) : NEXT Z%
  ChkbFlg%=0 : SpinFlg%=0
  GOSUB DefSwPa
  CALL FSInp(Men1%+2,1,"",15,1,15,1,CL%,CC%,3,9,1,80,"L   SPO T DME",M1%)
  IF M1%=0 THEN M1%=INT((CL%-2)*2)+INT(CC%/40)-1
  Men2%=3
  ON M1% GOTO LdSetF,SvSetF,StTraF,SMenu1,DefSw,DefPa,OpenCom,CloseCom,SMenu2,StopGuest,CDOSin,IBManOp,PEnd
   GOTO SMenu1

LdSetF:                                                 'Handle set file
  CALL RdDis(2,10,19,Setfil$)
  CALL RdCha(2,10,19,Setfil$,15,2) : SetFile$=RTRIM$(Setfil$)+".set"
  GOSUB RdSetF
  Men1%=4
  GOTO Smenu1

SvSetF:
  CALL RdDis(2,10,19,Setfil$)
  CALL RdCha(2,10,19,Setfil$,15,2) : SetFile$=RTRIM$(Setfil$)+".set"
  OPEN SetFile$ FOR OUTPUT AS#1
  PRINT #1,"* Setup parameter file generated ";DATE$;" ";TIME$;" by Sioxfer Version EC:";EC$
  PRINT #1,"Parameter: RD";P1
  PRINT #1,"Parameter: TR";P2
  PRINT #1,"Parameter: SP";P3
  PRINT #1,"Parameter: RS";P4
  PRINT #1,"Parameter: ME";P5
  PRINT #1,"Parameter: PE";P6
  PRINT #1,"Parameter: FE";P7
  PRINT #1,"Parameter: PO ";LTRIM$(P11$)
  PRINT #1,"Parameter: BR ";LTRIM$(P12$)
  PRINT #1,"Parameter: PA ";LTRIM$(P13$)
  PRINT #1,"Parameter: BI ";LTRIM$(P14$)
  PRINT #1,"Parameter: RL ";LTRIM$(P15$)
  PRINT #1,"Parameter: ST ";LTRIM$(P16$)
  PRINT #1,"Parameter: IM ";LTRIM$(P17$)
  PRINT #1,"Parameter: CI ";LTRIM$(P18$)
  PRINT #1,"Parameter: CO ";LTRIM$(P19$)
  PRINT #1,"Parameter: MR ";LTRIM$(P20$)
  PRINT #1,"Parameter: DM ";LTRIM$(P21$)
  PRINT #1,"Parameter: OP ";LTRIM$(P22$)
  PRINT #1,"Transfer : TY ";FileType$
  PRINT #1,"Transfer : SO ";SrcFile$
  PRINT #1,"Transfer : DE ";DstFile$
  PRINT #1,"Transfer : ME ";"?"
  PRINT #1,"Transfer : CT ";CtlFil$
  PRINT #1,"Transfer : DT ";DmpTline$
  PRINT #1,"End"
  CLOSE #1
  Men1%=2
  GOTO Smenu1

StTraF:
  CALL RdCha(2,62,19,Trafil$,15,2) : TracFile$=RTRIM$(Trafil$)+".tra"
  CLOSE #6
  OPEN TracFile$ FOR OUTPUT AS#6
  PRINT #6,TracFile$+" started: ";DATE$;" ";TIME$
  GOTO Smenu1

DefSw:                                                  'define Switches
  ChkbFlg%=1 : GOSUB DefSwPa
  GOTO SMenu1

DefPa:                                                  'define Parameters
  SpinFlg%=1 : GOSUB DefSwPa
  GOTO SMenu1

DefSwPa:
  CALL ChkBox(12, 2,P1 ,RC$,15,2,ChkbFlg%) : P1 =VAL(RC$)
  CALL ChkBox(13, 2,P2 ,RC$,15,2,ChkbFlg%) : P2 =VAL(RC$)
  CALL ChkBox(14, 2,P3 ,RC$,15,2,ChkbFlg%) : P3 =VAL(RC$)
  CALL ChkBox(15, 2,P4 ,RC$,15,2,ChkbFlg%) : P4 =VAL(RC$)
  CALL ChkBox(16, 2,P5 ,RC$,15,2,ChkbFlg%) : P5 =VAL(RC$)
  CALL ChkBox(17, 2,P6 ,RC$,15,2,ChkbFlg%) : P6 =VAL(RC$)
  CALL ChkBox(18, 2,P7 ,RC$,15,2,ChkbFlg%) : P7 =VAL(RC$)
  ChkbFlg%=0
  CALL SpinBut(12,41, 4,P11$,C11$,1,RC$,15,2,SpinFlg%) : P11$=RC$
  CALL SpinBut(13,40, 5,P12$,C12$,1,RC$,15,2,SpinFlg%) : P12$=RC$
  CALL SpinBut(14,44, 1,P13$,C13$,1,RC$,15,2,SpinFlg%) : P13$=RC$
  CALL SpinBut(15,44, 1,P14$,C14$,1,RC$,15,2,SpinFlg%) : P14$=RC$
  CALL EntrFld(16,40, 5,P15$,       RC$,15,2,SpinFlg%) : P15$=RC$
  CALL SpinBut(17,44, 1,P16$,C16$,1,RC$,15,2,SpinFlg%) : P16$=RC$
  CALL EntrFld(18,43, 2,P17$,       RC$,15,2,SpinFlg%) : P17$=RC$
  CALL SpinBut(19,39, 6,P18$,C18$,1,RC$,15,2,SpinFlg%) : P18$=RC$
  CALL SpinBut(20,39, 6,P19$,C19$,1,RC$,15,2,SpinFlg%) : P19$=RC$
  CALL EntrFld(21,40, 5,P20$,       RC$,15,2,SpinFlg%) : P20$=RC$
  CALL SpinBut(22,44, 1,P21$,C21$,1,RC$,15,2,SpinFlg%) : P21$=RC$
  CALL EntrFld(23,20,25,P22$,       RC$,15,2,SpinFlg%) : P22$=RC$
  SpinFlg%=0
' Men1%=4
  RETURN

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
  Men1%=5
  GOTO SMenu1

CloseCom:                                               'Close Com port
  SIO.Dflg%=1
  CALL INIT(P11$,P12$,P13$,P14$,P15$,P16$,SioOptions$,SIO.Dflg%)
  CALL IbStat("  ")
  PRINT #6,"SIOXFER CLOSE ";DATE$;" ";TIME$
  Men1%=4
  GOTO SMenu1

StopGuest:
  CALL Info("Disconnect Guest Computer",0,0)
  Msg$=DLE$+"STOP"
  PUTS(Msg$)
  GOTO CloseCom

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
  CLOSE : COLOR 7,0,0 : CLS : END

RdSetF:
  IF DoesExist ("SetFile",SetFile$,0)=0 THEN
    OPEN SetFile$ FOR INPUT AS #1
    Iline%=1
    LINE INPUT #1, Inputline$
    WHILE Inputline$<>"End"
      CALL GetParms(Inputline$,Group$,Variable$,Value$)
      Msg$="Error in SetFile line"+STR$(Iline%)+": "+Inputline$+" -- Press Enter"
      IF Group$="PARAMETER" THEN
        SELECT CASE Variable$
          IF Value$="?" THEN GOSUB ErrMsg
          CASE "RD" : P1 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "TR" : P2 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "SP" : P3 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "RS" : P4 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "ME" : P5 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "PE" : P6 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "FE" : P7 =VAL(Value$) : IF VERIFY(Value$,"01")>0         THEN GOSUB ErrMsg
          CASE "PO" : P11$=Value$
          CASE "BR" : P12$=Value$
          CASE "PA" : P13$=Value$    : IF VERIFY(Value$,"SOMEN")     >0 THEN GOSUB ErrMsg
          CASE "BI" : P14$=Value$    : IF VERIFY(Value$,"5678HP")    >0 THEN GOSUB ErrMsg
          CASE "RL" : P15$=Value$   ': IF VERIFY(Value$,"0123456789")>0 THEN GOSUB ErrMsg
          CASE "ST" : P16$=Value$    : IF VERIFY(Value$,"12")        >0 THEN GOSUB ErrMsg
          CASE "IM" : P17$=Value$    : IF VERIFY(Value$,C17$)        >0 THEN GOSUB ErrMsg
          CASE "CI" : P18$=Value$
          CASE "CO" : P19$=Value$
          CASE "MR" : P20$=Value$
          CASE "DM" : P21$=Value$
          CASE "OP" : P22$=Value$
        END SELECT
      END IF
      IF Group$="TRANSFER" THEN
        SELECT CASE Variable$
          CASE "TY" : FileType$=Value$
          CASE "SO" : SrcFile$ =Value$
          CASE "DE" : DstFile$ =Value$
          CASE "ME" : Message$ =Value$
          CASE "CT" : CtlFil$  =Value$
          CASE "DT" : DmpTline$=Value$
        END SELECT
      END IF
      IF SioDflg%=1 THEN
        P15$="16"
        P20$="16"
      END IF
      Iline%=Iline%+1
      LINE INPUT #1, Inputline$
    WEND
    CLOSE #1
  END IF
  RETURN

FUNCTION GetParms(Inpline$,Group$,Variable$,Value$)
  temp1$=UCASE$(RTRIM$(Inpline$))
  Group$=RTRIM$(MID$(temp1$,1,INSTR(temp1$,":")-1))
  temp1$=LTRIM$(MID$(temp1$,INSTR(temp1$,":")+1))
  Variable$=MID$(temp1$,1,INSTR(temp1$," ")-1)
  Variable$=EXTRACT$(Variable$," ")
  Value$=LTRIM$(MID$(temp1$,INSTR(temp1$," ")+1)) : VALUE$=RTRIM$(VALUE$)
  IF Value$="" THEN Value$="?"
END FUNCTION

'*******************************************************************************
SMenu2:                                                 'MENU 2
  KeyIn$=""
  COLOR 15,1 : GOSUB Header1 : GOSUB Header2
  CALL ClrLin(3,24,15,1)
  Call WrCha(25,71,7,"")
  CALL PrCha(2,34,10,"* MENU 2 *",14,4)
  CALL SetCol(25,1,25,80,15,4) : DELAY(0.1) : CALL Info("",0,0)
  FOR Z%=3  TO 23 : CALL LiPrt(Z%,Scn2$(Z%-2),15,1) : NEXT Z%
  CALL PrCha(18,18,18,FileType$,14,1)
  CALL PrCha(19,18,62,SrcFile$ ,14,1)
  CALL PrCha(20,18,62,DstFile$ ,14,1)
  CALL PrCha(21,18,62,Message$ ,14,1)
  CALL PrCha(22,18,62,CtlFil$  ,14,1)
  CALL PrCha(23,18,62,DmpTline$,14,1)
  CALL FSInp(Men2%+2,1,"",15,1,15,1,CL%,CC%,3,14,1,80,"EFSDPGMC    ",M2%)
  IF M2%=0 THEN M2%=CL%-2
  Z%=M2%+2
  ON M2% GOTO SMenu1,FType,SFile,Dfile,PutFile,GetFile,Messg,CFile,Dtline,DisAss,Smenu2,Smenu2
  GOTO Smenu2

CodeSel:
  SELECT CASE P14$
    CASE "5" : Tra%=1 : Hex%=0 : Pdf%=0
    CASE "6" : Tra%=1 : Hex%=0 : Pdf%=0
    CASE "7" : Tra%=1 : Hex%=0 : Pdf%=0
    CASE "8" : Tra%=1 : Hex%=0 : Pdf%=0
    CASE "H" : Tra%=0 : Hex%=1 : Pdf%=0
    CASE "P" : Tra%=0 : Hex%=0 : Pdf%=1
  END SELECT
  P17b$= HexBin$(8,P17$)
  IgS4%=0 : IgS3%=0 : IgS2%=0 : IgS1%=0 : Ig151E%=0 : Ig15%=0 : Ig04%=0 : Ig05%=0
  IF MID$(P17b$,8,1)="1" THEN Ig05%=1
  IF MID$(P17b$,7,1)="1" THEN Ig04%=1
  IF MID$(P17b$,6,1)="1" THEN Ig15%=1
  IF MID$(P17b$,5,1)="1" THEN Ig151E%=1
  IF MID$(P17b$,4,1)="1" THEN IgS1%=1
  IF MID$(P17b$,3,1)="1" THEN IgS2%=1
  IF MID$(P17b$,2,1)="1" THEN IgS3%=1
  IF MID$(P17b$,1,1)="1" THEN IgS4%=1
  SELECT CASE P18$
    CASE "EBCDIC" : T18$=EBCDIC$
    CASE " ASCII" : T18$=CP437$
    CASE "CP5110" : T18$=CP5110$
    CASE "CP5100" : T18$=CP5100$
    CASE "CI5110" : T18$=CI5110$
    CASE "CI5100" : T18$=CI5100$
  END SELECT
  SELECT CASE P19$
    CASE "EBCDIC" : T19$=EBCDIC$
    CASE "ASCII"  : T19$=CP437$
    CASE "CP5110" : T19$=CP5110$
    CASE "CP5100" : T19$=CP5100$
  END SELECT
RETURN

FType:
  CALL RdCha(18,18,18,FileType$,15,2)
  FileType$=RTRIM$(FileType$)
  GOTO SMenu2

Sfile:
  CALL RdCha(19,18,62,SrcFile$,15,2)
  SrcFile$=RTRIM$(SrcFile$)
  GOTO SMenu2

Dfile:
  CALL RdCha(20,18,62,DstFile$,15,2)
  DstFile$=RTRIM$(DstFile$)
  GOTO SMenu2

Dtline:
  CALL RdCha(23,18,62,DmpTline$,15,2)
  DstFile$=RTRIM$(DmpTline$)
  GOTO SMenu2

PutFile:
  GOSUB PFile
  CALL Info("Filetransfer ended - Press enter",1,1)
  GOTO SMenu2

PFile:
  RECS = 0
  GOSUB CodeSel
  CALL BufC
  CALL Info("Sourcefile="+SrcFile$,0,0)
  IF (P2=1) THEN
    PRINT #6,"PUTFILE Srcfile=";SrcFile$;" Dstfile=";DstFile$
  END IF
  StartTime=INT(TIMER)
  temp0$=DLE$+"BITS="+Bits$
  temp1$=DLE$+"FILETYP="+FileType$
  temp2$=DLE$+"DSTFILE="+DstFile$
  IF Bits$="8" THEN
    temp$=CodeTrans$(CP437$,EBCDIC$,temp0$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp0$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
    temp$=CodeTrans$(CP437$,EBCDIC$,temp1$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp1$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
    temp$=CodeTrans$(CP437$,EBCDIC$,temp2$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp2$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
  ELSE
    PUTS(temp0$+LFE$) : PUTS(temp1$+LFE$) : PUTS(temp2$+LFE$)
    IF SIO.Tflg%=1 THEN
      PRINT #6,"** PUTS-";temp0$ : PRINT #6,"** PUTS-";temp1$ : PRINT #6,"** PUTS-";temp2$
    END IF
  END IF
  IF P18$<>"HEX" THEN
    OPEN SrcFile$ FOR INPUT AS #1
    WHILE NOT EOF(1)
      LINE INPUT #1, Inputline$ : Inputline$=RTRIM$(Inputline$)
      IF P1=1 THEN : CALL Info(Inputline$,0,0)
      temp$=CodeTrans$(CP437$,T19$,Inputline$,SIO.Dflg%)+LFE$ : PUTS(temp$)
    WEND
  END IF
  CLOSE #1
  PUTS(EOFP$)
  StopTime=INT(TIMER)
  RunTime=StopTime-StartTime
  IF (P2=1) THEN
    PRINT #6, "  Date:";DATE$;"  Time:";TIME$;" Runtime:";RunTime;" Sec."
  END IF
  temp$=EOFP$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp$,0,0)
  PRINT #2, "PUTFILE Srcfile="+SrcFile$+" Dstfile="+DstFile$
RETURN

GetFile:
  GOSUB GFile
  CALL Info("Filetransfer ended - Press enter",1,1)
  GOTO SMenu2

GFile:
  RECS = 0
  GOSUB CodeSel
  CALL BufC
  CALL Info("Desinationfile="+DstFile$,0,0)
  Ef%=0
  IF (P2=1) THEN
    PRINT #6,"GETFILE Srcfile=";SrcFile$;" Dstfile=";DstFile$
  END IF
  StartTime=INT(TIMER)
  temp0$=DLE$+"BITS="+Bits$
  temp1$=DLE$+"FILETYP="+FileType$
  temp2$=DLE$+"SRCFILE="+SrcFile$
  IF Bits$="8" THEN
    temp$=CodeTrans$(CP437$,EBCDIC$,temp0$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp1$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
    temp$=CodeTrans$(CP437$,EBCDIC$,temp1$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp1$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
    temp$=CodeTrans$(CP437$,EBCDIC$,temp2$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp2$,0,0)
    IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
  ELSE
    PUTS(temp0$+LFE$) : PUTS(temp0$+LFE$) : PUTS(temp1$+LFE$) : PUTS(temp2$+LFE$)
    IF SIO.Tflg%=1 THEN
      PRINT #6,"** PUTS-";temp0$ : PRINT #6,"** PUTS-";temp1$ : PRINT #6,"** PUTS-";temp2$
    END IF
  END IF
  OPEN DstFile$ FOR OUTPUT AS#1
  Inputline$=""
  Rec.Cnt%=VAL(P20$)
  CALL WrCha(24,61,20,"--Press # to stop")
  CALL BufC
  WHILE Ef%=0
    Inputline$=GetS$(VAL(P15$))
    IF Ef%=0 THEN
      Rec.Cnt%=Rec.Cnt%-1
      IF Rec.Cnt%= 0 THEN Ef%=1
      IF Tra%=1 THEN
        temp$=CodeTrans$(T18$,CP437$,Inputline$,SIO.Dflg%)
      ELSEIF Hex%=1 THEN
        temp$=Inputline$
      ELSEIF Pdf%=1 THEN
        temp$=Inputline$
      END IF
      IF P1=1 THEN : CALL Info(temp$,0,0)
      IF SIO.Tflg%=1 THEN : PRINT #6,"** GETS-";temp$
      PRINT #1,temp$
    END IF
  WEND
  WHILE Ef%=0
    temp$=GetS$(VAL(P15$))
    IF temp$<>"" THEN : CALL Info(temp$+" ignored",0,0)
  WEND
  CALL BufC
  CALL WrCha(24,61,20,"")
  CLOSE #1
  StopTime=INT(TIMER)
  RunTime=StopTime-StartTime
  IF (P2=1) THEN
    PRINT #6, "  Date:";DATE$;"  Time:";TIME$;" Runtime:";RunTime;" Sec."
  END IF
  PRINT #2, "GETFILE Srcfile="+SrcFile$+" Dstfile="+DstFile$
RETURN

Messg:
  GOSUB Mess
  GOTO SMenu2

Mess:
  GOSUB CodeSel
  CALL RdCha(21,18,62,Message$,15,2)
  Msg$=DLE$+"MESSAGE="+RTRIM$(Message$)
  temp$=CodeTrans$(CP437$,T19$,Msg$,SIO.Dflg%)+LFE$ : PUTS(temp$) : IF P1=1 THEN : CALL Info(temp1$,0,0)
  IF SIO.Tflg%=1 THEN : PRINT #6,"** PUTS-";temp$
  RETURN

CFile:
  GOSUB CoFile
  GOTO SMenu2

CoFile:
  CALL RdCha(22,18,62,CtlFil$,15,2)
  CtlFile$=RTRIM$(CtlFil$)+".CTL"
  CALL WrCha(25,1,70,"Ctlfile="+CtlFil$) : DELAY(1)
  IF DoesExist ("Ctlfile",CtlFile$,0)=0 THEN
    PRINT #2, "CTLFILE="+CtlFile$
    IlineC%=0
    OPEN CtlFile$ FOR INPUT AS #4
  END IF
    WHILE NOT EOF(4)
      LINE INPUT #4, InputlineC$
      IlineC%=IlineC%+1
      Msg$="Error in CtlFile line"+STR$(IlineC%)+": "+InputlineC$
      InputlineC$=RTRIM$(LTRIM$(InputlineC$))
      IF MID$(InputlineC$,1,1)<>"*" THEN
        Ctl$=MID$(InputlineC$,1,INSTR(InputlineC$,":")-1)
        Ctl$=UCASE$(RTRIM$(CTL$))
        InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,":")+1)))
        SELECT CASE Ctl$
          CASE "SET"
            SetFile$=RTRIM$(MID$(InputlineC$,INSTR(InputlineC$,":")+1))+".SET"
            CALL WrCha(25,1,70,"Setfile="+SetFile$)
            GOSUB RdSetF
          CASE "GET"
            FileType$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            SrcFile$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            DstFile$=InputlineC$
            CALL PrCha(18,18,18,FileType$,14,1)
            CALL PrCha(19,18,62,SrcFile$,14,1)
            CALL PrCha(20,18,62,DstFile$,14,1)
            GOSUB GFile
          CASE "PUT"
            FileType$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            SrcFile$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            DstFile$=InputlineC$
            CALL PrCha(18,18,18,FileType$,14,1)
            CALL PrCha(19,18,62,SrcFile$,14,1)
            CALL PrCha(20,18,62,DstFile$,14,1)
            GOSUB PFile
          CASE "ASS"
            FileType$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            SrcFile$=MID$(InputlineC$,1,INSTR(InputlineC$,",")-1)
            InputlineC$=RTRIM$(LTRIM$(MID$(InputlineC$,INSTR(InputlineC$,",")+1)))
            DstFile$=InputlineC$
            CALL PrCha(18,18,18,FileType$,14,1)
            CALL PrCha(19,18,62,SrcFile$,14,1)
            CALL PrCha(20,18,62,DstFile$,14,1)
            CALL PrCha(23,18,62,DmpTline$,14,1)
            GOSUB DAss
          CASE "MSG"
            Message$=InputlineC$
            CALL PrCha(21,18,62,Message$,14,1)
            GOSUB Mess
          CASE "END"
            tempc$=RTRIM$(MID$(InputlineC$,1))
            CALL Info(tempc$,1,1)
            EXIT LOOP
          CASE ELSE
            GOSUB ErrMsg
        END SELECT
      END IF
    WEND
  CLOSE #4
  RETURN

DisAss:
  GOSUB DAss
  CALL Info("Disassembler ended - Press enter",1,1)
  GOTO SMenu2

'************** Subroutines ****************************************************

Clock:
  CALL WrCha(1,65,16,LEFT$(DATE$,6)+RIGHT$(DATE$,2)+"   "+LEFT$(TIME$,5)) : RETURN

Header1:                                                'Headerline 1
  CALL PrCha(1,1,80,"SIOXFER "+Options$,10,4)
  CALL PrCha(1,28,34,"SIOXFER VERSION: "+EC$,15,4) : GOSUB Clock : RETURN

Header2:                                                'Headerline 2
  CALL PrCha(2,1,80,"SETFILE: "+SetFil$,10,4)
  CALL PrCha(2,51,30,"TRACEFILE: "+TraFil$,10,4) : RETURN

ErrH:                                                   'System Errorhandling
  CALL WrCha(25,1,78,"ERROR "+STR$(ERR))
  CALL Enter : CALL ClrBlk(25,1,25,70) : CLOSE #1 : RESUME SMenu1

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

FUNCTION CodeTrans$(Incode$, Outcode$,Instring$,Flg%) PUBLIC '*** CodeTranslation
  Outstring$=""
  FOR i1%=1 TO LEN(Instring$)
      index%=INSTR(Outcode$,MID$(Instring$,i1%,1))
      Outstring$=Outstring$+MID$(Incode$,index%,1)
  NEXT i1%
  IF Flg%=1 THEN
    PRINT #5,"** Tran-";Instring$
    PRINT #5,"** Tran-";Outstring$
  END IF
  CodeTrans$=Outstring$
END FUNCTION

