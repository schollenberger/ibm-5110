'*******************************************************************************
'*      DISPLAY SUBROUTINES WRITTEN BY H.RUFFNER         04/02/92              *
'*                                                                             *
'* Changes:                                                                    *
'*                                                                             *
'* Date       Changed by Reason                                                *
'* 03/30/2023 H.Ruffner  Add SpinBut, ChkBox, EntrFld function                 *
'* 07/08/2025 W. Schollenberger  Empty input buffer on SUB Enter               *
'*                                                                             *
'*                                                                             *
'*******************************************************************************

SUB LiPrt(L%,WC$,CFT%,CBT%)                      'LINE PRINT
    '(L%=LINE, WC$=TEXT, CFT%=COLOR FOREGROUND TEXT, CBT%=COLOR BACKGROUNG TEXT)
      WC$=WC$+SPACE$(80-LEN(WC$)) : LOCATE L%,1,0 : COLOR CFT%,CBT% : PRINT WC$;
END SUB

SUB SetCol(L1%,C1%,L2%,C2%,CFT%,CBT%)         'SET COLORS WITHOUT CHANGING CHARACTERS
    '(L1%=FIRST LINE, C1%=FIRST COLUMN,
    ' L2%=LAST  LINE, C2%=LAST  COLUMN, CFT%=COLOR FOREGROUND TEXT, CBT%=COLOR BACKGROUNG TEXT)
      DEF SEG=&HB800
      FOR L0% = L1% TO L2%
        FOR C0% = C1% TO C2%
          POKE ((L0%-1)*160 + ((C0%-1)*2)+1),CBT%*16+CFT%
        NEXT C0%
      NEXT L0%
END SUB

SUB ClrLin(L1%,L2%,CFT%,CBT%)                 'CLEAR LINES
    '(L1%=FIRST LINE, L2%=LAST  LINE, CFT%=COLOR FOREGROUND TEXT, CBT%=COLOR BACKGROUNG TEXT)
      FOR L0% = L1% TO L2%
        COLOR CFT%,CBT% : LOCATE L0%,1,0 : PRINT SPACE$(80);
      NEXT L0%
END SUB

SUB ClrBlk(L1%,C1%,L2%,C2%)                   'CLEAR BLOCK WITHOUT CHANGING COLORS
    '(L1%=FIRST LINE, C1%=FIRST COLUMN, L2%=LAST  LINE, C2%=LAST  COLUMN)
      DEF SEG=&HB800
      FOR L0% = L1% TO L2%
        FOR C0% = C1% TO C2%
          POKE ((L0%-1)*160 + (C0%-1)*2),0
        NEXT C0%
      NEXT L0%
END SUB

SUB WrCha(L%,C%,W%,WC$)                       'WRITE CHARACTERS WITHOUT CHANGING COLORS
    '(L%=LINE, C%=COLUMN, W%=WIDTH, WC$=TEXT)
      WC$=WC$+SPACE$(W%-LEN(WC$)) : DEF SEG=&HB800
      FOR C0% = 1 TO W% : POKE ((L%-1)*160 + (C0%+C%-2)*2), ASC(MID$(WC$,C0%,1)) : NEXT C0%
END SUB

SUB PrCha(L%,C%,W%,WC$,CFT%,CBT%)             'PRINT CHARACTERS
    '(L%=LINE, C%=COLUMN, W%=WIDTH, WC$=TEXT, CFT%=COLOR FOREGROUND TEXT, CBT%=COLOR BACKGROUNG TEXT)
      LOCATE L%,C%,0 : COLOR CFT%,CBT% : PRINT SPACE$(W%); : LOCATE L%,C%,0 : PRINT WC$;
END SUB

SUB RdCha(L%,C%,W%,RC$,CFI%,CBI%)             'READ CHARACTERS
    '(L%=LINE, C%=COLUMN, W%=WIDTH, RC$=TEXT, CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT)
     LOCAL C0%, CHAR$
     CALL SetCol(L%,C%,L%,C%+W%-1,CFI%,CBI%)
 RdCha0:
     RC$=SPACE$(W%) : FOR C0%=C% TO C%+W%-1
 RdCha1:
     LOCATE L%,C0%,1 : CHAR$=INKEY$ : IF CHAR$="" GOTO RdCha1
     IF ASC(CHAR$)=13 GOTO RdCha3 ELSE
     IF CHAR$=CHR$(0)+CHR$(75) AND C0%>1 THEN C0%=C0%-1 : GOTO RdCha1 ELSE
     IF CHAR$=CHR$(0)+CHR$(77) GOTO RdCha2
     IF LEN(CHAR$)=2 GOTO RdCha0 ELSE COLOR CFI%,CBI% : PRINT CHAR$;
 RdCha2:
     NEXT C0%
 RdCha3:
     FOR C0%=C% TO C%+W%-1 : MID$(RC$,C0%-C%+1,1)=CHR$(SCREEN(L%,C0%)) : NEXT C0%
     CALL SetCol(L%,C%,L%,C%+W%-1,15,1)
END SUB


SUB RdDis(L%,C%,W%,RD$)                       'READ CHARACTERS
    '(L%=LINE, C%=COLUMN, W%=WIDTH, RD$=TEXT)
     RD$=SPACE$(W%)
     LOCAL C0%
     FOR C0%=C% TO C%+W%-1 : MID$(RD$,C0%-C%+1,1)=CHR$(SCREEN(L%,C0%)) : NEXT C0%
END SUB

SUB RdNum(L%,C%,W%,RN,CFI%,CBI%)                 'READ NUMBERS (L%=LINE, C%=COLUMN, W%=WIDTH, RN=NUMBERS)
    '(L%=LINE, C%=COLUMN, W%=WIDTH, RN=NUMBERS, CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT)
     LOCAL C0%, CHAR$
     CALL SetCol(L%,C%,L%,C%+W%-1,CFI%,CBI%)
 RdNum0:
      RN$="" : FOR C0%=C% TO C%+W%-1
 RdNum1:
     LOCATE L%,C0%,1 : CHAR$=INKEY$ : IF CHAR$="" GOTO RdNum1
     IF ASC(CHAR$)=13 GOTO RdNum3 ELSE
     IF CHAR$=CHR$(0)+CHR$(75) AND C0%>1 THEN C0%=C0%-1 : GOTO RdNum1 ELSE
     IF CHAR$=CHR$(0)+CHR$(77) GOTO RdNum2
     IF LEN(CHAR$)=2 GOTO RdNum0 ELSE COLOR CFI%,CBI% : PRINT CHAR$;
     IF INSTR(" .0123456789+-",CHAR$)=0 GOTO RdNum1
 RdNum2:
     NEXT C0%
 RdNum3:
     FOR C0%=C% TO C%+W%-1 : RN$=RN$+CHR$(SCREEN(L%,C0%)) : NEXT C0% : RN=VAL(RN$)
END SUB

SUB RdHex(L%,C%,W%,RH$,CFI%,CBI%)             'READ HEXCHAR. (L%=LINE, C%=COLUMN, W%=WIDTH, RH$=HEXCHAR.)
    '(L%=LINE, C%=COLUMN, W%=WIDTH, RH$=HEXCHAR., CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT)
     LOCAL C0%, CHAR$
     CALL SetCol(L%,C%,L%,C%+W%-1,CFI%,CBI%)
 RdHex0:
      RH$="" : FOR C0%=C% TO C%+W%-1
 RdHex1:
     LOCATE L%,C0%,1 : CHAR$=INKEY$ : IF CHAR$="" GOTO RdHex1
     IF ASC(CHAR$)=13 GOTO RdHex3 ELSE
     IF CHAR$=CHR$(0)+CHR$(75) AND C0%>1 THEN C0%=C0%-1 : GOTO RdHex1 ELSE
     IF CHAR$=CHR$(0)+CHR$(77) GOTO RdHex2
     IF LEN(CHAR$)=2 GOTO RdHex0 ELSE COLOR CFI%,CBI% : CHAR$=UCASE$(CHAR$) : PRINT CHAR$;
     IF INSTR("0123456789ABCDEF",CHAR$)=0 GOTO RdHex1
 RdHex2:
     NEXT C0%
 RdHex3:
     FOR C0%=C% TO C%+W%-1 : RH$=RH$+CHR$(SCREEN(L%,C0%)) : NEXT C0%
END SUB

SUB FSInp(L%,C%,WC$,CFT%,CBT%,CFI%,CBI%,CL%,CC%,LB%,LE%,CB%,CE%,ME$,ME%)
                                              'FULL SCREEN TEXTINPUT
    '(L%=LINE, C%=COLUMN, WC$=TEXT, CFT%=COLOR FOREGROUND TEXT,  CBT%=COLOR BACKGROUNG TEXT)
    '(                              CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT)
    '(                              CL% =CURSOR LINE POSITION,   CC% =CURSOR COLUMN POSITION)
    '(                              LB% =FIRST ALLOWABLE LINE,   LE% =LAST ALLOWABLE LINE)
    '(                              CB% =FIRST ALLOWABLE COLUMN, CE% =LAST ALLOWABLE COLUMN)
    '(                              ME$ =ALLOWABLE MENU CHAR.,   ME% =PRESSED KEY)
 LOCATE L%,C% : CL%=L% : CC%=C% : IF WC$="" GOTO FSInp1 ELSE COLOR CFT%,CBT% : PRINT WC$;
 FSInp1:
     LOCATE CL%,CC%,1 : CHAR$=INKEY$ : IF CHAR$="" GOTO FSInp1
     ME%=INSTR(ME$,UCASE$(CHAR$)) : IF ASC(CHAR$)=13 OR ME%<>0 GOTO FSInp3
     IF ASC(CHAR$)=13 GOTO FSInp3
     IF CHAR$=CHR$(0)+CHR$(75) AND CC%>CB% THEN CC%=CC%-1 : GOTO FSInp2
     IF CHAR$=CHR$(0)+CHR$(77) AND CC%<CE% THEN CC%=CC%+1 : GOTO FSInp2
     IF CHAR$=CHR$(0)+CHR$(72) AND CL%>LB% THEN CL%=CL%-1 : GOTO FSInp2
     IF CHAR$=CHR$(0)+CHR$(80) AND CL%<LE% THEN CL%=CL%+1 : GOTO FSInp2
     IF CHAR$=CHR$(0)+CHR$(116)            THEN CC%=41    : GOTO FSInp2
     IF CHAR$=CHR$(0)+CHR$(115)            THEN CC%= 1    : GOTO FSInp2
 FSInp2:
     IF LEN(CHAR$)=2 GOTO FSInp1 ELSE COLOR CFI%,CBI% : PRINT CHAR$; : IF CC%<80 THEN CC%=CC%+1
     GOTO FSInp1
 FSInp3:
END SUB

SUB Enter                                     'WAIT FOR ENTER
' New version of enter 2025-07-20 - abort on CTRL-C and ESC key
     PRINT #5,"Cleaning input buffer"
     i$ = INKEY$
     WHILE LEN(i$) <> 0
        i$ = INKEY$
     WEND
     PRINT #5,"Waiting for CR"
  Enter1:
     DELAY(0.2)
     i$ = INKEY$
     IF i$=CHR$(13) GOTO Enter2
     IF i$=CHR$(03) GOTO PEnd
     IF i$=CHR$(27) GOTO PEnd
     GOTO Enter1
  Enter2:
     PRINT #5,"Continue..."
END SUB

SUB UsDelay(t)                                'Us Delay
     Et1=0 : Et2=0
     WHILE Et1<t
       MTIMER : Et1=Et1+Et2: Et2=MTIMER
     WEND
END SUB

SUB SpinBut(L%,C%,W%,IW$,CW$,WP%,OW$,CFI%,CBI%,ChFlg%)  'SPIN BUTTON
    '(L%=LINE, C%=COLUMN, W%=WIDTH, IW$=INWORD, CW$=CHKWORD, WP%=WORDPOSITION,
    'OW$=OUTWORD, CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT,
    'ChFlg%=Change Flag)
     OW$=IW$ : CALL WrCha(L%,C%+W%,1,CHR$(18)) : LOCATE L%,C%,1
     IF ChFlg%=1 THEN
     CALL SetCol(L%,C%,L%,C%+W%-1,CFI%,CBI%)
       WHILE INKEY$ <>"" : WEND
       MaxWords%=Words%(CW$)
       IF ((INSTR(IW$,Word$(IW$,WP%))=0) OR (WP%>Words%(IW$))) THEN WP%=1
      SpinBut0:
       Ky$=INKEY$
       IF MID$(Ky$,2,1)="H" GOTO ScrollUp
       IF MID$(Ky$,2,1)="P" GOTO ScrollDn
       IF Ky$=CHR$(13) GOTO Continue
       GOTO SpinBut0
      ScrollUp:
       WP%=WP%+1 : IF WP%>MaxWords% THEN WP%=MaxWords%
       OW$=Word$(CW$,WP%)
       CALL WrCha(L%,C%,W%,OW$)
       GOTO SpinBut0
      ScrollDn:
       WP%=WP%-1 : IF WP%<1         THEN WP%=1
       OW$=Word$(CW$,WP%)
       CALL WrCha(L%,C%,W%,OW$)
       GOTO SpinBut0
      Continue:
     END IF
     OW$=RIGHT$(SPACE$(W%)+RTRIM$(OW$),W%) : CALL WrCha(L%,C%,W%,OW$)
     CALL SetCol(L%,C%,L%,C%+W%-1,15,5)
END SUB

SUB ChkBox(L%,C%,Pin,PO$,CFI%,CBI%,ChFlg%)              'CHECK BOX
    '(L%=LINE, C%=COLUMN, CFI%=COLOR FOREGROUND INPUT,
    'CBI%=COLOR BACKGROUND INPUT, ChFlg%=Change Flag)
     PO$=LTRIM$(STR$(Pin))
     CALL WrCha(L%,C%+1,1,CHR$(18)) : LOCATE L%,C%,1
     IF ChFlg%=1 THEN
     WHILE INKEY$ <>"" : WEND
      CALL SetCol(L%,C%,L%,C%,CFI%,CBI%)
      ChkBox0:
       Ky$=INKEY$
       IF MID$(Ky$,2,1)="H" GOTO ChkBoxUp
       IF MID$(Ky$,2,1)="P" GOTO ChkBoxDn
       IF Ky$=CHR$(13) GOTO ChkBox1
       GOTO ChkBox0
      ChkBoxUp:
         PO$="1"
         CALL WrCha(L%,C%,1,PO$)
         GOTO ChkBox0
      ChkBoxDn:
         PO$="0"
         CALL WrCha(L%,C%,1,PO$)
         GOTO ChkBox0
      ChkBox1:
     END IF
     CALL WrCha(L%,C%,1,PO$)
     CALL SetCol(L%,C%,L%,C%,15,5)
END SUB

SUB EntrFld(L%,C%,W%,IW$,OW$,CFI%,CBI%,ChFlg%)  'ENTRY FIELD
    '(L%=LINE, C%=COLUMN, W%=WIDTH, IW$=INWORD, OW$=OUTWORD,
    'CFI%=COLOR FOREGROUND INPUT, CBI%=COLOR BACKGROUND INPUT,
    'ChFlg%=Change Flag)
     OW$=IW$ : OW$=RIGHT$(SPACE$(W%)+RTRIM$(OW$),W%) : CALL WrCha(L%,C%,W%,OW$) : LOCATE L%,C%,1
     IF ChFlg%=1 THEN
      CALL RdCha(L%,C%,W%,OW$,CFI%,CBI%)
     END IF
     OW$=RIGHT$(SPACE$(W%)+OW$,W%) : CALL WrCha(L%,C%,W%,OW$)
     CALL SetCol(L%,C%,L%,C%+W%-1,15,5)
END SUB

