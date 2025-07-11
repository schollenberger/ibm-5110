' CODEGEN.BAS - Generate code pages for sioxfer
'             - 2025-07-01 WSB - made tmp$ variable local  

SUB SetXltASCII SHARED   '*** SetXlt for ASCII  code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+CHR$(i%-1)
  NEXT i%
  MID$(tmp$, 27,1)=CHR$(223)  ' X'1A'
  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- ASCII Code:"
    FOR i%=1  TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  CP437$=tmp$
END SUB

SUB SetXltEBCDIC SHARED  '*** SetXlt for EBCDIC code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+"_"
  NEXT i%
  MID$(tmp$,  1,16)="����������������"
  MID$(tmp$, 17,16)="����������������"
  MID$(tmp$, 33,16)="����������������"
  MID$(tmp$, 49,16)="����������������"
  MID$(tmp$, 65,16)="�����������.<(+|"
  MID$(tmp$, 81,16)="&���������!$*);^"
  MID$(tmp$, 97,16)="-/��������^,%_>?"
  MID$(tmp$,113,16)="����������:#@'="+CHR$(22)
  MID$(tmp$,129,16)="�abcdefghi������"
  MID$(tmp$,145,16)="�jklmnopqr������"
  MID$(tmp$,161,16)="��stuvwxyz������"
  MID$(tmp$,177,16)="�������\��������"
  MID$(tmp$,193,16)="�ABCDEFGHI������"
  MID$(tmp$,209,16)="�JKLMNOPQR������"
  MID$(tmp$,225,16)="��STUVWXYZ������"
  MID$(tmp$,241,16)="0123456789������"
  MID$(tmp$,  1, 1)=CHR$(  0)' NUL
  MID$(tmp$,  8, 1)=CHR$(127)' DEL
  MID$(tmp$, 17, 1)=CHR$( 16)' DLE  #1
' MID$(tmp$, 18, 1)=CHR$( 17)' DC1  #1
' MID$(tmp$, 19, 1)=CHR$( 18)' DC2  #1
' MID$(tmp$, 20, 1)=CHR$( 22)' SYN  #1
  MID$(tmp$, 22, 1)=CHR$( 21)' NL - straight
' MID$(tmp$, 30, 1)=CHR$( 29)' GS   #1
  MID$(tmp$, 31, 1)=CHR$( 30)' EB1 - straight
' MID$(tmp$, 32, 1)=CHR$( 31)' US   #1
  MID$(tmp$, 56, 1)=CHR$(  4)' EOT
  MID$(tmp$, 65, 1)=CHR$( 32)' SPA
' #1 not official EBCDIC code

  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- EBCDIC Code:"
    FOR i%=1 TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  MID$(tmp$,  6, 1)=CHR$(  9)' HT       Not shown in Msg File
'  MID$(tmp$, 22, 1)=CHR$( 15)' NL-CR    Not shown in Msg File
  MID$(tmp$, 23, 1)=CHR$(  8)' BS       Not shown in Msg File
  MID$(tmp$, 38, 1)=CHR$( 10)' LF       Not shown in Msg File
  MID$(tmp$, 39, 1)=CHR$( 23)' EOB-ETB  Not shown in Msg File
  EBCDIC$=tmp$
END SUB

SUB SetXltCP5110 SHARED  '*** SetXlt for CP5110 code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+"_"
  NEXT i%
  MID$(tmp$,  1,16)="����������������"
  MID$(tmp$, 17,16)="����������������"
  MID$(tmp$, 33,16)="����������������"
  MID$(tmp$, 49,16)="����������������"
  MID$(tmp$, 65,16)=" ����������.<(+|"
  MID$(tmp$, 81,16)="&����������$*);^"
  MID$(tmp$, 97,16)="-/���������,%_>?"
  MID$(tmp$,113,16)="&^�������`:#'="+CHR$(34)
  MID$(tmp$,129,16)="~abcdefghi����"
  MID$(tmp$,145,16)="�jklmnopqr������"
  MID$(tmp$,161,16)="��stuvwxyz��[��"
  MID$(tmp$,177,16)="������\�����]ح"
  MID$(tmp$,193,16)="�ABCDEFGHI�����"
  MID$(tmp$,209,16)="�JKLMNOPQR�!�ϱ�"
  MID$(tmp$,225,16)="��STUVWXYZ�����"
  MID$(tmp$,241,16)="0123456789����� "
  MID$(tmp$,  1, 1)=CHR$(  0)' NUL
  MID$(tmp$,  8, 1)=CHR$(127)' DEL
  MID$(tmp$, 17, 1)=CHR$( 16)' DLE  #1
  MID$(tmp$, 18, 1)=CHR$( 17)' DC1  #1
  MID$(tmp$, 19, 1)=CHR$( 18)' DC2  #1
' MID$(tmp$, 20, 1)=CHR$( 22)' SYN  #1
  MID$(tmp$, 30, 1)=CHR$( 29)' GS   #1
' MID$(tmp$, 31, 1)=CHR$( 30)' RS   #1
' MID$(tmp$, 32, 1)=CHR$( 31)' US   #1
  MID$(tmp$, 56, 1)=CHR$(  4)' EOT
  MID$(tmp$, 65, 1)=CHR$( 32)' SPA
' #1 not official EBCDIC code

  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- CP5110 Code:"
    FOR i%=1 TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  MID$(tmp$,  6, 1)=CHR$(  9)' HT       Not shown in Msg File
  MID$(tmp$, 22, 1)=CHR$( 15)' NL-CR    Not shown in Msg File
  MID$(tmp$, 23, 1)=CHR$(  8)' BS       Not shown in Msg File
  MID$(tmp$, 38, 1)=CHR$( 10)' LF       Not shown in Msg File
  MID$(tmp$, 39, 1)=CHR$( 23)' EOB-ETB  Not shown in Msg File
  CP5110$=tmp$
END SUB

SUB SetXltCI5110 SHARED  '*** SetXlt for CP5110 code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+"_"
  NEXT i%
  MID$(tmp$,  1,16)="����������������"
  MID$(tmp$, 17,16)="����������������"
  MID$(tmp$, 33,16)="����������������"
  MID$(tmp$, 49,16)="����������������"
  MID$(tmp$, 65,16)=" ABCDEFGHI�.<(+|"
  MID$(tmp$, 81,16)="&JKLMNOPQR�$*);^"
  MID$(tmp$, 97,16)="-/STUVWXYZ�,%_>?"
  MID$(tmp$,113,16)="&^�������`:#'="+CHR$(34)
  MID$(tmp$,129,16)="~abcdefghi����"
  MID$(tmp$,145,16)="�jklmnopqr������"
  MID$(tmp$,161,16)="��stuvwxyz��[��"
  MID$(tmp$,177,16)="������\�����]ح"
  MID$(tmp$,193,16)="�ABCDEFGHI�����"
  MID$(tmp$,209,16)="�JKLMNOPQR�!�ϱ�"
  MID$(tmp$,225,16)="��STUVWXYZ�����"
  MID$(tmp$,241,16)="0123456789������"
  MID$(tmp$,  1, 1)=CHR$(  0)' NUL
  MID$(tmp$,  8, 1)=CHR$(127)' DEL
  MID$(tmp$, 17, 1)=CHR$( 16)' DLE  #1
  MID$(tmp$, 18, 1)=CHR$( 17)' DC1  #1
  MID$(tmp$, 19, 1)=CHR$( 18)' DC2  #1
' MID$(tmp$, 20, 1)=CHR$( 22)' SYN  #1
  MID$(tmp$, 30, 1)=CHR$( 29)' GS   #1
' MID$(tmp$, 31, 1)=CHR$( 30)' RS   #1
' MID$(tmp$, 32, 1)=CHR$( 31)' US   #1
  MID$(tmp$, 56, 1)=CHR$(  4)' EOT
  MID$(tmp$, 65, 1)=CHR$( 32)' SPA
' #1 not official EBCDIC code

  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- CI5110 Code:"
    FOR i%=1 TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  MID$(tmp$,  6, 1)=CHR$(  9)' HT       Not shown in Msg File
  MID$(tmp$, 22, 1)=CHR$( 15)' NL-CR    Not shown in Msg File
  MID$(tmp$, 23, 1)=CHR$(  8)' BS       Not shown in Msg File
  MID$(tmp$, 38, 1)=CHR$( 10)' LF       Not shown in Msg File
  MID$(tmp$, 39, 1)=CHR$( 23)' EOB-ETB  Not shown in Msg File
  CI5110$=tmp$
END SUB

SUB SetXltCP5100 SHARED  '*** SetXlt for CP5100 code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+"_"
  NEXT i%
  MID$(tmp$,  1,16)=" ABCDEFGHIJKLMNO"
  MID$(tmp$, 17,16)="PQRSTUVWXYZ01234"
  MID$(tmp$, 33,16)="56789/+�<[],.���"
  MID$(tmp$, 49,16)="��_����'����*?��"
  MID$(tmp$, 65,16)="~���^��<�=�>�"
  MID$(tmp$, 81,16)="�\-�>();:�����Ա"
  MID$(tmp$, 97,16)="!����������Ъ"+CHR$(34)+"&"
  MID$(tmp$,113,16)="@#$%�ۙ���������"
  MID$(tmp$,129,16)="����������������"
  MID$(tmp$,145,16)="����������������"
  MID$(tmp$,161,16)="����������������"
  MID$(tmp$,177,16)="����������������"
  MID$(tmp$,193,16)="����������������"
  MID$(tmp$,209,16)="����������������"
  MID$(tmp$,225,16)="����������������"
  MID$(tmp$,241,16)="����������������"

  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- CP5100 Code:"
    FOR i%=1 TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  CP5100$=tmp$
END SUB

SUB SetXltCI5100 SHARED  '*** SetXlt for CP5100 code ***************************
  LOCAL tmp$
  tmp$=""
  FOR i%=1 TO 256
    tmp$=tmp$+"_"
  NEXT i%
  MID$(tmp$,  1,16)=" ABCDEFGHIJKLMNO"
  MID$(tmp$, 17,16)="PQRSTUVWXYZ01234"
  MID$(tmp$, 33,16)="56789/+�<[],.���"
  MID$(tmp$, 49,16)="��_����'����*?��"
  MID$(tmp$, 65,16)="~���^��<�=�>�"
  MID$(tmp$, 81,16)="�\-�>();:�����Ա"
  MID$(tmp$, 97,16)="!��������Ъ"+CHR$(34)+"&"
  MID$(tmp$,113,16)="@#$%�ۙ���������"
  MID$(tmp$,129,16)=" ABCDEFGHIJKLMNO"
  MID$(tmp$,145,16)="PQRSTUVWXYZ01234"
  MID$(tmp$,161,16)="56789/+�<[],.���"
  MID$(tmp$,177,16)="��_����'����*?��"
  MID$(tmp$,193,16)="~���^��<�=�>�"
  MID$(tmp$,209,16)="�\-�>();:�����Ա"
  MID$(tmp$,225,16)="!��������Ъ"+CHR$(34)+"&"
  MID$(tmp$,241,16)="@#$%�ۙ���������"

  IF SIO.Cflg%=1 THEN
    PRINT #5,"-- CI5100 Code:"
    FOR i%=1 TO 241 STEP 16
      PRINT #5, "-- "+MID$(tmp$,i%,16)
    NEXT i%
    PRINT #5, "-- "
  END IF
  CI5100$=tmp$
END SUB

SUB SetASCFILE SHARED  '*** SetXlt for Debug code ******************************
    ASCFILE1$=""                                 ' Generate Debug ASCII File
    FOR i%=1 TO 241 STEP 16
      ASCFILE1$=ASCFILE1$+MID$(CP437$,i%,16)
      ASCFILE1$=ASCFILE1$+LFE$
    NEXT i%
    ASCFILE1$=ASCFILE1$+MID$(CP437$,241,16)+EOFG$
    ASCFILE2$=ASCFILE1$
    REPLACE LFE$ WITH "" IN ASCFILE2$
    ASCFILE3$=ASCFILE2$
    REPLACE EOFG$ WITH "" IN ASCFILE3$
END SUB

SUB Set5110FILE SHARED  '*** SetXlt for Debug code *****************************
    CP5110FILE1$=""                              ' Generate Debug CP5110 File
    FOR i%=1 TO 241 STEP 16
      CP5110FILE1$=CP5110FILE1$+MID$(CP5110$,i%,16)
      CP5110FILE1$=CP5110FILE1$+LFE$
    NEXT i%
    CP5110FILE1$=CP5110FILE1$+MID$(CP5110$,241,16)+EOFG$
    CP5110FILE2$=CP5110FILE1$
    REPLACE LFE$ WITH "" IN CP5110FILE2$
    CP5110FILE3$=CP5110FILE2$
    REPLACE EOFG$ WITH "" IN CP5110FILE3$
END SUB
