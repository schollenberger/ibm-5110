0010 REM  *** SIOOUT   *** WRITE TO SERIAL PORT
0020 REM 2023-08-31 WERNER SCHOLLENBERGER
0030 REM  ***
0040 OPEN FL4, 'A04',OUT
0050 PRINT FL4, '0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ'
0052 PRINT FL4, '! " # $ % &   ( ) * + , - . / [ ] { } \ | § @ µ ~ ^ ° = ?'
0054 PRINT FL4, 'abcdefghijklmnopqrstuvwxyz'
0060 CLOSE FL4
0070 PRINT 'DONE'