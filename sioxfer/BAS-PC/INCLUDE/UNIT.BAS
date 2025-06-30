' Unuiversa'l Functions 03/24/2023

FUNCTION Keys$    PUBLIC
SHARED KeyLine$
  Keys$=KeyLine$
END FUNCTION

FUNCTION Par8$(Dat$)PUBLIC                       '*** 8 Byte Paritygeneration
  PAR%=0
  FOR L%=1 TO 15 STEP 2
    Par%=Par%+(TALLY("03569ACF",MID$(Dat$,L%,1)) XOR TALLY("12478BDE",MID$(Dat$,L%+1,1)))*2^((15-L%)/2)
  NEXT L%
  Par8$=RIGHT$("0"+HEX$(Par%),2)
END FUNCTION

FUNCTION HexBin$(BinDigits%,HexValue$)PUBLIC     '*** Hex to Binary Conversion
     HexDigits%=LEN(HexValue$)
     BinValue$=""
     FOR L%=1 TO HexDigits%
        BinValue$=BinValue$+RIGHT$("000"+BIN$(INSTR("123456789ABCDEF",MID$(HexValue$,L%,1))),4)
     NEXT L%
     BinValue$=RIGHT$(BinValue$,BinDigits%)
     HexBin$=BinValue$
END FUNCTION

FUNCTION BinHex$(HexDigits%,BinValue$)PUBLIC     '*** Binary to Hex Conversion
  HexValue$=STRING$(HexDigits%,"0")
  BinaryValue$=RIGHT$(STRING$(HexDigits%*4,48)+BinValue$,HexDigits%*4)
  FOR L%=1 TO LEN(HexValue$) : LB%=(L%-1)*4+1
    A8%=VAL(MID$(BinaryValue$,LB%  ,1))*8
    A4%=VAL(MID$(BinaryValue$,LB%+1,1))*4
    A2%=VAL(MID$(BinaryValue$,LB%+2,1))*2
    A1%=VAL(MID$(BinaryValue$,LB%+3,1))
    MID$(HexValue$,L%,1)=HEX$(A8%+A4%+A2%+A1%)
  NEXT L%
  HexValue$=RIGHT$(HexValue$,HexDigits%)
  BinHex$=HexValue$
END FUNCTION

FUNCTION BinHexL$(HexDigits%,BinValue$)PUBLIC    '*** Binary to Hex Left adjusted
  HexValue$=STRING$(HexDigits%,"0")
  BinaryValue$=LEFT$(BinValue$+STRING$(HexDigits%*4,48),HexDigits%*4)
  PRINT "**",BinaryValue$
  FOR L%=1 TO LEN(HexValue$) : LB%=(L%-1)*4+1
    A8%=VAL(MID$(BinaryValue$,LB%  ,1))*8
    A4%=VAL(MID$(BinaryValue$,LB%+1,1))*4
    A2%=VAL(MID$(BinaryValue$,LB%+2,1))*2
    A1%=VAL(MID$(BinaryValue$,LB%+3,1))
    MID$(HexValue$,L%,1)=HEX$(A8%+A4%+A2%+A1%)
  NEXT L%
  HexValue$=RIGHT$(HexValue$,HexDigits%)
  BinHexL$=HexValue$
END FUNCTION

FUNCTION BinDec(BinValue$) PUBLIC                '*** Binary to Decimal Conversion
     DecValue=0 : BinDigits%=LEN(BinValue$)
     J%=VERIFY(1,BinValue$,"01") : IF J%<>0 THEN EXIT FUNCTION
     FOR L%=1 TO BinDigits%
        DecValue=DecValue+VAL(MID$(BinValue$,L%,1))*2^(BinDigits%-L%)
     NEXT L%
     BinDec=DecValue
END FUNCTION

FUNCTION HexDec(HexDigits%,HexValue$) PUBLIC     '*** Hex to Decimal Conversion
     DecValue=0
     FOR L%=1 TO HexDigits%
        DecValue=DecValue+INSTR("123456789ABCDEF",MID$(HexValue$,L%,1))*16^(HexDigits%-L%)
     NEXT L%
     HexDec=DecValue
END FUNCTION

FUNCTION DecHex$(Wert%,Stellen%) PUBLIC          '*** Bel. Decimal -> Hex
   DecHex$=RIGHT$("000"+HEX$(Wert%),Stellen%)
END FUNCTION

FUNCTION ToolsDir$(Pgm$)
  ToolsDir$=""
  F$=DIR$(Pgm$)
  IF F$<>"" THEN
   ToolsDir$=CURDIR$
  ELSE
    PATH$=ENVIRON$("PATH")
    REPLACE ";" WITH " " IN PATH$
    FOR I%=1 TO WORDS%(PATH$)
      IF DIR$(WORD$(PATH$,I%)+"\"+Pgm$)<>"" THEN
        ToolsDir$=WORD$(PATH$,I%) : EXIT FOR
      END IF
    NEXT I%
  END IF
END FUNCTION

FUNCTION DoesExist(DoesExistVariable$,DoesExistInput$,Rc) PUBLIC
  Rc=0
  IF DIR$(DoesExistInput$)="" THEN
    Rc=1
'    CALL WrCha(25,1,79,DoesExistVariable$+" ==>"+DoesExistInput$+"<== not found")
'    CALL Enter : CALL ClrBlk(25,1,25,80)
  END IF
  DoesExist=Rc
END FUNCTION

FUNCTION Word$(R$,W%)
  R$=R$+" "
  P1%=1 : Wrd%=0
  WHILE INSTR(R$,"  ")<>0
    REPLACE "  " WITH " " IN R$
  WEND
  WHILE (INSTR(P1%,R$," ")<>0 AND Wrd%<W%)
    P2%=INSTR(P1%+1,R$," ")
    Word$ = MID$(R$,P1%,P2%-P1%)
    P1%=P2%+1
    Wrd%=Wrd%+1
  WEND
  IF W% > Wrd% THEN Word$=""
END FUNCTION

FUNCTION Words%(R$) PUBLIC
  IF R$<>"" THEN R$=R$+" "
  WHILE INSTR(R$,"  ")<>0
    REPLACE "  " WITH " " IN R$
  WEND
  Words%=TALLY(R$," ")
END FUNCTION
