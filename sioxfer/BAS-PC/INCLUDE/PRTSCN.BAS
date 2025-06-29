PrtScn:                                          'PRINT SCREEN
  IF Printer%=1 OR PrinterB%=1 THEN
    FOR L0% = 1 TO 25
      CALL RdDis(L0%,1,80,RD$)                   'READ CHARACTERS
      LPRINT RD$;
    NEXT L0%
  END IF
  RETURN
