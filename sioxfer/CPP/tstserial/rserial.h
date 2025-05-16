/*******************************************************************************
* .FILE:         rserial.h                                                     *
*                                                                              *
* .DESCRIPTION:  RSERIAL Program Version 1                                     *
*                                                                              *
* Changes:                                                                     *
*                                                                              *
* Date       Vers. Changed by Reason                                           *
* 30. 4.2025 1.0   H.Ruffner  New                                              *
*                                                                              *
*                                                                              *
*                                                                              *
* To do:                                                                       *
*                                                                              *
*                                                                              *
*                                                                              *
*******************************************************************************/

#ifndef RSERIAL_H
#define RSERIAL_H

#include <istring.hpp>
#include <stdio.h>
#include <windows.h>

enum serial_parity  { spNONE,    spODD, spEVEN };

class Rserial
  {
  protected:
    char              port[10];                      // port name "com1",...
    int               rate;                          // baudrate
    serial_parity     parityMode;
    HANDLE            serial_handle;                 // ...
  public:
                  Rserial();
                 ~Rserial();
    int           connect          (char *port_arg, int baud, IString parity, int bits, int stop, IString options);
    void          sendChar         (char c);
    void          sendArray        (char *buffer, int len);
    char          getChar          (void);
    int           getArray         (char *buffer, int len);
    int           getNbrOfBytes    (void);
    void          disconnect       (void);
  };
#endif
