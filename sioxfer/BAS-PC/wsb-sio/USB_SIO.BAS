' USBSIO Functions 2025-06-30 - modified Werner Schollenberger
'                             - Code conversions inside the basic functions

   '****************************************************************************
   '* Subroutines for SIO transfers                                            *
   '****************************************************************************

''SUB SIO.MANOPS STATIC
''  PRINT #5, "** Entering SIO.MANOPS
''  PRINT #5, "** EOLIN and EOLOUT: ";StringHex(EOLIN$); " - ";StringHex$(EOLOUT$)
''  GOSUB IB.DEB
''  PRINT #5, "** Leaving SIO.MANOPS
''  EXIT SUB

IB.DEB:                                          'Debug Routine for SIO

   COLOR 15,1 : CLS : GOSUB Header1
   CALL PrCha(3,24,30,"* SIO Port/Bus MANUAL OPERATIONS *",14,1)
   CALL SetCol(25,1,25,80,10,4)
   CALL LiPrt( 4,"E Program end                                        ",15,1)
   CALL LiPrt( 5,"                                                     ",15,1)
   CALL LiPrt( 6,"P PUTS        Put String on Bus                      ",15,1)
   CALL LiPrt( 7,"G GETS        Get String from Bus                    ",15,1)
   CALL LiPrt( 8,"- PUTS + GETS Put String on Bus / Get String from Bus",15,1)
   CALL LiPrt( 9,"- GETR        Get String repeating                   ",15,1)
   CALL LiPrt(10,"R RPUT        Repeat Put String                      ",15,1)
   CALL LiPrt(11,"                                                     ",15,1)
   CALL LiPrt(12,"- R.PUTS/GET  Repeat PUTS / GETS                     ",15,1)
   CALL LiPrt(13,"- R.CNTR      Repeat Control                         ",15,1)
   CALL LiPrt(14,"- RPUT + RDBS Repeat Put String / Read Bus Status    ",15,1)

   CALL FSInp( 5,1,"",15,1,15,1,CL%,CC%,4,15,1,80,"ECPG  R    ",SIO.M1%)
   IF SIO.M1%=0 THEN SIO.M1%=CL%-3
   CALL SetCol(SIO.M1%+3,1,SIO.M1%+3,80,15,2) : POI.EFLG%=0
'
   CALL LiPrt(2,"SIO.M1% = "+STR$(SIO.M1%),14,1)
'
   IF SIO.M1%=1 THEN RETURN
   ON SIO.M1%-1 GOSUB Pmenu1 ,Pmenu2 ,Pmenu3 ,Pmenu4, Pmenu5, Pmenu6, Pmenu7, Pmenu8, Pmenu9, Pmenu10

   GOTO IB.DEB

 Pmenu1:                                         'CNTR (IEEE-Controls)
'  CALL LiPrt(16,"Valid Controlcommands:",14,1)
'  CALL LiPrt(17,"/G  = IFC (Interface clear",14,1)
'  CALL LiPrt(18,"/C  = REN ON, /D = REN OFF (Remote Enable    (default=D)",14,1)
'  CALL LiPrt(19,"/A  = ATN ON, /B = ATN OFF (Address Mode     (default=B)",14,1)
'  CALL LiPrt(20,"/Q  = EOI ON, /R = EOI OFF (EOI to last Byte (default=R)",14,1)
'  CALL LiPrt(21,"/Sx = End of String Definition               (default=ASC(10))",14,1)
'  CALL LiPrt(22,"/T  = Tra ON, /U = Tra OFF (Trace Mode       (default=U)",14,1)
'  CALL LiPrt(23,"Example : /A?_C4/B  where C=PC-Talker 4=CurveTracer-Listener",14,1)
'  CALL PrCha(24,1,80,"CONTROLCOMANDS =",15,1)
'  CALL RdCha(24,18,63,Datstr$,15,2) : Datstr$=RTRIM$(Datstr$)
'  CALL CNTR(Datstr$) : RETURN
   RETURN
 Pmenu2:                                         'PUTS (Put String on Bus)
   CALL PrCha(24,1,80,"Data: ",15,1)
   CALL RdCha(24,7,74,Datstr$,15,2) : Datstr$=RTRIM$(Datstr$)
   PRINT #5,"PMenu2: Sending Datstr$ (Hex): <";StringHex$(Datstr$);"> followed by <";StringHex$(EOLOUT$);">"
   ' CALL PUTS(Datstr$)
   CALL PUTSConv(Datstr$)   'Don't convert the EOL characters
   CALL PUTS(EOLOUT$)
   RETURN
 Pmenu3:                                         'GETS (Get String from Bus)
   CALL PrCha(24,1,80,"Length of Record: ",15,1)
   CALL RdNum(24,19,2,RN,15,2)
   ' Datstr$ = GETS$(INT(RN))
   Datstr$ = GETSConv$(INT(RN))
   CALL PrCha(24,1,80,Datstr$,15,1)
   PRINT #5,"PMenu3: Got Datstr$ (Hex): <";StringHex$(Datstr$);">"
   CALL Enter
   RETURN
 Pmenu4:                                         'PUTS + GETS
   CALL PrCha(24,1,80,"Output Data:                Input Data: ",15,1)
   CALL RdCha(24,13,15,Datstr$,15,2)
'   CALL PUTS(Datstr$)
   CALL PUTSConv(Datstr$)
'   Datstr$=GETS$(4)
   Datstr$=GETSConv$(4)
   CALL PrCha(24,41,40,MID$(Datstr$,1,4),15,1)
   CALL Enter : RETURN
 Pmenu5:                                         'GETR (Get String from Bus)
   CALL PrCha(24,1,80,"Datarate in sec: ",15,1)
   CALL RdNum(24,18,6,RN,15,2)
   SIO.BRK$=""
   WHILE SIO.BRK$<>CHR$(27)
'     A$ = GETS$(4)
     A$ = GETSConv$(20)
     CALL WrCha(22,1,60,A$) : DELAY(RN)
     SIO.BRK$=INKEY$
   WEND
   RETURN
 Pmenu6:                                         'RPUT (Put String on Bus)
   CALL PrCha(24,1,80,"Datarate in sec: ",15,1)
   CALL RdNum(24,18,6,RN,15,2)
   CALL PrCha(24,1,80,"Data: ",15,1)
   CALL RdCha(24,7,74,Datstr$,15,2) : Datstr$=RTRIM$(Datstr$)
   REPLACE "|" WITH CHR$(16) IN Datstr$          'use | for DLE
   SIO.STP$=""
   WHILE SIO.STP$<>CHR$(27)
'     CALL PUTS(Datstr$) : DELAY(RN)
     CALL PUTSConv(Datstr$+EOLOUT$) : DELAY(RN)
     SIO.STP$=INKEY$
   WEND
   RETURN

 Pmenu7:
'  OPEN "IEEEOUT.FIL" FOR INPUT AS #1
'  WHILE NOT EOF(1)
'    LINE INPUT #1,A$
'    CALL PUTS(A$)
'  WEND
'  CLOSE #1
   RETURN

 Pmenu8:                                         'REPEAT PUTS + GETS
   CALL PrCha(24,1,80,"Datarate in sec: ",15,1)
   CALL RdNum(24,18,6,RN,15,2)
   CALL PrCha(24,1,80,"Output Data:                Input Data: ",15,1)
   CALL RdCha(24,13,15,DatstrO$,15,2)
   SIO.STP$=""
   WHILE SIO.STP$<>CHR$(27)
'    CALL PUTS(DatstrO$) : DELAY(RN)
    CALL PUTSConv(DatstrO$+EOLOUT$)
    Datstr$=GETS$(4)
    CALL PrCha(24,41,4,MID$(Datstr$,1,4),15,1)
    SIO.STP$=SIO.BRK$
   WEND
   RETURN

 Pmenu9:                                         'RCNTR (IEEE-Controls)
   CALL LiPrt(16,"Valid Controlcommands:",14,1)
   CALL LiPrt(17,"/G  = IFC (Interface clear",14,1)
   CALL LiPrt(18,"/C  = REN ON, /D = REN OFF (Remote Enable    (default=D)",14,1)
   CALL LiPrt(19,"/A  = ATN ON, /B = ATN OFF (Address Mode     (default=B)",14,1)
   CALL LiPrt(20,"/Q  = EOI ON, /R = EOI OFF (EOI to last Byte (default=R)",14,1)
   CALL LiPrt(21,"/Sx = End of String Definition               (default=ASC(10))",14,1)
   CALL LiPrt(22,"/T  = Tra ON, /U = Tra OFF (Trace Mode       (default=U)",14,1)
   CALL LiPrt(23,"Example : /A?_C4/B  where C=PC-Talker 4=CurveTracer-Listener",14,1)
   CALL PrCha(24,1,80,"CONTROLCOMANDS =",15,1)
   CALL RdCha(24,18,63,Datstr$,15,2) : Datstr$=RTRIM$(Datstr$)
   SIO.STP$=""
   WHILE SIO.STP$<>CHR$(27)
    SIO.STP$=INKEY$
   WEND
   RETURN

 Pmenu10:                                        'REPEAT PUTS + RDBS
   CALL PrCha(24,1,80,"Datarate in sec: ",15,1)
   CALL RdNum(24,18,6,RN,15,2)
   CALL PrCha(24,1,80,"Data: ",15,1)
   CALL RdCha(24,7,30,Datstr$,15,2) : Datstr$=RTRIM$(Datstr$)
   REPLACE "|" WITH CHR$(16) IN Datstr$          'use | for DLE
   SIO.STP$=""
   WHILE SIO.STP$<>CHR$(27)
'   CALL PUTS(Datstr$) : CALL RDBS(Rbs$)
    CALL PUTS(Datstr$)
    i%=ASC(Rbs$) : BST$=RIGHT$("00000000"+BIN$(i%),8)+" "+Rbs$
    CALL PrCha(24,41,10,BST$,15,1) : DELAY(RN)
    CALL PrCha(24,41,10,"........ .",15,1)
    SIO.STP$=INKEY$
   WEND
   RETURN

''END SUB

'*** USB_SIO Functions ***

FUNCTION INIT(Port$,Baud$,Parity$,Bits$,Recl$,SBits$,SioOptions$,Flg%) SHARED
  Comparm$=Port$+":"+LTRIM$(Baud$)+","+Parity$+","+LTRIM$(Bits$)+","+LTRIM$(SBits$)+SioOptions$
' Comparm$=CHR$(34)+Port$+":"+LTRIM$(STR$(Baud))+","+Parity$+","+LTRIM$(STR$(Bits))+","+LTRIM$(STR$(SBits))+SioOptions$+CHR$(34)
' Comparm$="COM1:"+LTRIM$(STR$(Baud))+","+Parity$+","+LTRIM$(STR$(Bits))+","+LTRIM$(STR$(SBits))+SioOptions$
 PRINT #5,"OPEN ";CHR$(34);Comparm$;CHR$(34);" AS #7 LEN=";Recl$;"     Flg%=";Flg%
  IF Flg%=0 THEN
    CLOSE #7
    OPEN Comparm$ AS #7 LEN=32000
  END IF
  PRINT #5,"...DONE OPEN ";CHR$(34);Port$;CHR$(34)

END FUNCTION

FUNCTION SHUTDOWN(Port$,Flg%) SHARED
  PRINT #5,"CLOSE ";CHR$(34);Port$;CHR$(34);" AS #7            Flg%=";Flg%
  IF Flg%=0 THEN
    CLOSE #7
  END IF
END FUNCTION

FUNCTION PutSConv(DataStr$) SHARED
  LOCAL ConvStr$
  PRINT #5,"** PUTSCONV--input:     ";StringHex(DataStr$)
  ConvStr$=Codetrans$(CPLocal$,T19$,DataStr$,SIO.Tflg%)
  PRINT #5,"** PUTSCONV--converted: "StringHex(ConvStr$)
  CALL PUTS(ConvStr$)
  ' CALL PUTS(Codetrans$(CPlocal$,T19$,DataStr$,SIO.Cflg%))
END FUNCTION

FUNCTION PutS(InputlineP$) SHARED '*********** PUTS  ( Outputline$ BUSOUT ) ****
  SIO.FCTN$="PUTS"
  CALL IbStat(">>")
  ' REPLACE CHR$(10) WITH "" IN InputlineP$
  ' REPLACE CHR$(13) WITH "" IN InputlineP$
  REPLACE CHR$(26) WITH CHR$(223) IN InputlineP$  ' x'1A' does close files!
  CharIndex%=1
  Buf$="   "
  PRINT #5,"** PUTS--SIO-Debug =";SIO.Dflg%
  PRINT #5,"** PUTS->" ;InputlineP$

  IF SIO.Dflg=0 THEN
    PRINT #7, InputlineP$;
    PRINT #5,"** PUTS--Send completed"
  END IF
  IF P1=1 THEN
    CALL Info("** PUTS-"+InputlineP$,2,0)
  END IF
  SIO.FCTN$="PUTS"
  CALL IbStat("> ")
  RECS=RECS+1
  CALL PrCha(25,71,6,RIGHT$("     "+STR$(RECS),6),15,4)
END FUNCTION

FUNCTION GetSConv$(LRec) SHARED 'Calls Gets$() and returns converted string
  LOCAL InpStr$, ConvStr$
  PRINT #5,"** GETSCONV--reading    ";LREC;" Characters"
  InpStr$ = GETS$(LRec)
  PRINT #5,"** GETSCONV--Read       <";InpStr$;">"
  PRINT #5,"** GETSCONV--Read (Hex) <";StringHex(InpStr$);">"
  ConvStr$=Codetrans$(T18$,CPLocal$,InpStr$,SIO.Tflg%)
  PRINT #5,"** GETSCONV--Converted: <";ConvStr$;">"
  GetSConv$ = ConvStr$
End FUNCTION


FUNCTION GetS$(LRec) SHARED '************** GETS  ( BUSIN Datstr$ ) ************
  LOCAL i%, j%, InputlineG$, IByte$
  SIO.FCTN$="GETS"
  CALL IbStat("<<")
  KeyB$=INKEY$
  IF KeyB$="#" THEN
    Ef%=1
    CALL SIOTrac("USER BREAK")                   'INTERRUPTED BY OPERATOR
    GOTO ENDGS
  END IF
  InputlineG$=""
  Buf$=""

  PRINT #5, "** GETS$--EOLIN$ (hex)= ";StringHex$(EOLIN$);" EOBUFIN$ (hex)= ";StringHex$(EOBUFIN$);"   Flag Tra% = ";Tra%

  FOR i%=1 TO LRec
    IRun%=0
    IF SIO.Dflg%=1 THEN
      'PRINT #5,"** GETS$(Sio.Debug)--ASCFILEx$ Len = " ;LEN(ASCFILE1$),LEN(ASCFILE2$),LEN(ASCFILE3$)
      IF P21$="0" THEN
        IByte$="9"
      ELSEIF P21$="1" THEN
        IByte$=MID$(ASCFILE1$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(ASCFILE1$) THEN : CharIndex%=1
      ELSEIF P21$="2" THEN
        IByte$=MID$(ASCFILE2$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(ASCFILE2$) THEN : CharIndex%=1
      ELSEIF P21$="3" THEN
        IByte$=MID$(ASCFILE3$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(ASCFILE3$) THEN : CharIndex%=1
      ELSEIF P21$="4" THEN
        IByte$=MID$(CP5110FILE1$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(CP5110FILE1$) THEN : CharIndex%=1
      ELSEIF P21$="5" THEN
        IByte$=MID$(CP5110FILE2$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(CP5110FILE2$) THEN : CharIndex%=1
      ELSEIF P21$="6" THEN
        IByte$=MID$(CP5110FILE3$,CharIndex%,1) : CharIndex%=CharIndex%+1
        IF CharIndex%>LEN(CP5110FILE3$) THEN : CharIndex%=1
      END IF
    ELSE
      GETFF:
      IByte$=INPUT$(1,#7)
      IF IByte$=CHR$(255) GOTO GETFF
      PRINT #5,"** GETS$<= ";IByte$;"  Hex: ";StringHex$(IByte$)
    END IF
    Buf$=RIGHT$(Buf$,2)+IByte$
    IF Tra%=1 THEN
      InputlineG$=InputlineG$+IByte$
      PRINT #5, "** GETS$(Tra)--Content Buf$=";StringHex$(Buf$)
      IF RIGHT$(Buf$,LEN(EOLIN$))=EOLIN$ THEN
        PRINT #5, "** GETS$(Tra)--Found EOL, removing it from input and finish"
        REPLACE EOLIN$ WITH "" IN InputlineG$
        GOTO ENDGS
      ELSEIF  RIGHT$(Buf$,LEN(EOBUFIN$))=EOBUFIN$ THEN
        PRINT #5, "** GETS$(Tra)--Found END OF BUFFER, removing it from input and continue"
        REPLACE EOBUFIN$ WITH "" IN InputlineG$
        ' GOTO ENDGS
      ELSEIF Buf$=EOFG$ THEN
        PRINT #5, "** GETS$(Tra)--Found EOFG, removing it from input and finish"
        REPLACE EOFG$ WITH "" IN InputlineG$
        Ef%=1
        GOTO ENDGS
      ELSE
        GOTO GETBS
      END IF
    ELSEIF Hex%=1 THEN
      IF Buf$=EOFG$ THEN
        REPLACE EOFG$ WITH "" IN Buf$
        Ef%=1
        GOTO ENDGS
      END IF
      IByte$=RIGHT$("00"+HEX$(ASC(IByte$)),2)
      InputlineG$=InputlineG$+IByte$
      GOTO GETBS
    ELSEIF Pdf%=1 THEN
      InputlineG$=InputlineG$+IByte$
      FOR j%= 0 to 32
        PRINT #5,CHR$(j%);
        REPLACE CHR$(j%) WITH CHR$(250) IN InputlineG$
      NEXT j%
      PRINT #5,CHR$(j%);
      IF Buf$=EOFG$ THEN
        REPLACE EOFG$ WITH "" IN Buf$
        Ef%=1
        GOTO ENDGS
      END IF
      GOTO GETBS
    END IF
    GETBS:
  NEXT i%
  ENDGS:
  PRINT #5,"** GETS$--Received ";LEN(InputlineG$);" Character."
  PRINT #5,"** GETS$--Data: <-";InputlineG$;"->"
  ' Ingore char section - controlled by Ignore Mode (IM) parameter P17$'
     IF Ig151E%=1 THEN : REPLACE LFE$     WITH ""        IN InputlineG$
     IF Ig15%  =1 THEN : REPLACE CHR$(21) WITH CHR$(223) IN InputlineG$
     IF Ig04%  =1 THEN : REPLACE CHR$( 4) WITH CHR$(223) IN InputlineG$
     IF Ig05%  =1 THEN : REPLACE CHR$( 5) WITH CHR$(223) IN InputlineG$
     IF Ig1A%  =1 THEN : REPLACE CHR$(26) WITH CHR$(223) IN InputlineG$
    ' IF IgS1%  =1 THEN : REPLACE CHR$(??) WITH CHR$(223) IN InputlineG$
    ' IF IgS2%  =1 THEN : REPLACE CHR$(??) WITH CHR$(223) IN InputlineG$
    ' IF IgS3%  =1 THEN : REPLACE CHR$(??) WITH CHR$(223) IN InputlineG$
    ' IF IgS4%  =1 THEN : REPLACE CHR$(??) WITH CHR$(223) IN InputlineG$
  Outputline$=InputlineG$
  PRINT #5,"** GETS$--Returning: <";OutputLine$;">"
  GetS$=Outputline$
  CALL IbStat(" >")
  RECS=RECS+1
  CALL PrCha(25,71,6,RIGHT$("     "+STR$(RECS),6),15,4)
  PRINT #5,"** GETS$--End"
END FUNCTION

SUB BufC SHARED '************************** BufferClear ************************
  LOCAL IByte$, i%
  i%=0
  IF SIO.Dflg%=0 THEN
    WHILE LOC(7)>0
      IByte$=INPUT$(1,#7)
      i%=i%+1
    WEND
    IF SIO.Tflg%=1 THEN : PRINT #6,"** BUFC-";i%;" Bytes cleared"
  END IF
END SUB

FUNCTION StringHex$(InpStr$)	PUBLIC                     ' Returns String with HEX repesentation of a string
  OutpStr$=""
  FOR i%=1 TO LEN(InpStr$)
    OutpStr$=OutpStr$+RIGHT$("00"+HEX$(ASCII(MID$(InpStr$,i%,1))),2)
  NEXT i%
  StringHex$=OutpStr$
END FUNCTION


FUNCTION AString2Hex$(Instring$) PUBLIC                    'Returns a string containing the HEX-ASCII representation
                                                           '    the parameter string, separated with blanks     res$=HEX$(ASC(MID$(Instring$,1,1)))
  FOR i1%=2 TO LEN(Instring$)
    char1$=MID$(Instring$,i1%,1)
    res$=res$+" "+HEX$(ASC(char1$))
  NEXT i1%
  AString2Hex$=res$
END FUNCTION


FUNCTION CodeTrans$(Incode$, Outcode$,Instring$,Flg%) SHARED ' *** CodeTranslation
  LOCAL Outstring$, index%, ichar$
  Outstring$=""
  FOR i1%=1 TO LEN(Instring$)
    ichar$=MID$(Instring$,i1%,1)
    index%=INSTR(Outcode$,ichar$)
    IF index%=0 THEN index%=1 : PRINT #5, "** CODETRANS--Char 0x";StringHex$(ichar$);" not found!! - Index set to 1"
    ' index%=INSTR(Outcode$,MID$(Instring$,i1%,1))
    Outstring$=Outstring$+MID$(Incode$,index%,1)
  NEXT i1%
  IF Flg%=1 THEN
    PRINT #5,"** CODETRANS--In        : ";Instring$
    PRINT #5,"** CODETRANS--In (Hex)  : ";StringHex(Instring$)
    PRINT #5,"** CODETRANS--Out       : ";Outstring$
    PRINT #5,"** CODETRANS--Out (Hex) : ";StringHex(Outstring$)
  END IF
  CodeTrans$=Outstring$
END FUNCTION


SUB SIOTrac(EFLG$) SHARED '************* TRACE ROUTINE *************************
  LOCAL WC$
  IF EFLG$="" THEN EFLG$="NO ERR"
  WC$=EFLG$+"  "+SIO.FCTN$
  CALL PrCha(25,1,70,WC$,15,4)
' IF EFLG$<>"NO ERR" THEN CALL ENTER : CALL ClrLin(25,25,10,4)
END SUB

SUB IbStat (Stat$) SHARED '************ Ib Status ******************************
  CALL WrCha(25,78,2,Stat$)
' DELAY(0.1)
END SUB
