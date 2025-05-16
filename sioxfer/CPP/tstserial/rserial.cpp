/*******************************************************************************
* .FILE:         rserial.cpp                                                   *
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

#define STRICT
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <process.h> removed by H.Ruffner 2023/02/21
#include <conio.h>
#include <windows.h>

#include "rserial.h"

  Rserial::Rserial()
    {
    parityMode       = spNONE;
    port[0]          = 0;
    rate             = 0;
    serial_handle    = INVALID_HANDLE_VALUE;
    }

  Rserial::~Rserial()
   {
   if (serial_handle!=INVALID_HANDLE_VALUE)
     CloseHandle(serial_handle);
   serial_handle = INVALID_HANDLE_VALUE;
   }

  void Rserial::disconnect(void)
    {
    if (serial_handle!=INVALID_HANDLE_VALUE)
      CloseHandle(serial_handle);
    serial_handle = INVALID_HANDLE_VALUE;
    }
  int  Rserial::connect (char *port_arg, int baud, IString parity, int bits, int stop, IString options)
    {
    int erreur, op, opts;
    DCB  dcb;
    COMMTIMEOUTS cto = { 0, 0, 0, 0, 0 }; /* always block */
////cto.ReadIntervalTimeout = MAXDWORD; /*  immediate timeout */
/* ------------------------------ */
    if (serial_handle!=INVALID_HANDLE_VALUE)
    CloseHandle(serial_handle);
    serial_handle = INVALID_HANDLE_VALUE;

    erreur = 0;

    if (port_arg!=0)
      {
      strncpy(port, port_arg, 10);
      rate      = baud;
      memset(&dcb,0,sizeof(dcb));

/* ------------------------------ */
      // set DCB to configure the serial port
      dcb.DCBlength       = sizeof(dcb);

/* -- Serial Port Config defaults */
      dcb.fOutxCtsFlow    = 0;
      dcb.fOutxDsrFlow    = 0;
      dcb.fDtrControl     = DTR_CONTROL_HANDSHAKE;
      dcb.fDsrSensitivity = 0;
      dcb.fRtsControl     = RTS_CONTROL_ENABLE;
      dcb.fOutX           = 0;
      dcb.fInX            = 0;

/* -- misc parameters ----------- */
      dcb.fErrorChar      = 0;
      dcb.fBinary         = 1;
      dcb.fNull           = 0;
      dcb.fAbortOnError   = 0;
      dcb.wReserved       = 0;
      dcb.XonLim          = 2;
      dcb.XoffLim         = 4;
      dcb.XonChar         = 0x13;
      dcb.XoffChar        = 0x19;
      dcb.EvtChar         = 0;

      dcb.Parity          = NOPARITY;
      dcb.fParity         = 0;
      dcb.ByteSize        = 8;

/* -- Serial Port Config real --- */
      dcb.BaudRate        = rate;
      dcb.ByteSize        = bits;
      if      (parity=="N") {dcb.Parity = NOPARITY;   dcb.fParity = 0;}
      else if (parity=="E") {dcb.Parity = EVENPARITY; dcb.fParity = 1;}
      else if (parity=="O") {dcb.Parity = ODDPARITY;  dcb.fParity = 1;}
      if      (stop==1) {dcb.StopBits = ONESTOPBIT;}
      else if (stop==2) {dcb.StopBits = TWOSTOPBITS;}
      if      (bits==8) {dcb.ByteSize = 8;}
      else if (bits==7) {dcb.ByteSize = 7;}
      else if (bits==6) {dcb.ByteSize = 6;}
      else if (bits==5) {dcb.ByteSize = 5;}

/* -- Set options ----------- --- */
      options.translate(',',' ');
      opts = options.numWords();
      for (op=1; op<=opts; op++)
        {
        if (options.word(op).subString(1,2)=="RS") {}
//        {dcb.fRtsControl=RTS_CONTROL_DISABLE;}
        else if (options.word(op).subString(1,2)=="CS"){}
//        {dcb.fOutxCtsFlow=atol(options.word(op).subString(3));}
        else if (options.word(op).subString(1,2)=="DS")
          {dcb.fOutxDsrFlow=atol(options.word(op).subString(3));}
//      else if (options.word(op).subString(1,2)=="CD")
//        {dcb.fOutxCtsFlow=atol(options.word(op).subString(3));}

//      if (options.word(op).subString(1,2)=="LF")
//        {dcp.                               }
//      if (options.word(op).subString(1,2)=="PE")
//        {dcp.                               }
//      if (options.word(op).subString(1,2)=="DT")
//        {dcp.
//      if (options.word(op).subString(1,2)=="ME")
//        {dcp.                               }
//      if (options.word(op).subString(1,2)=="FE")
//        {dcp.                               ;}
//      if (options.word(op).subString(1,2)=="IR")
//        {dcp.                               ;}
        }

/* ------------------------------ */
        serial_handle    = CreateFile(port, GENERIC_READ | GENERIC_WRITE,
                               0, NULL,
                                                            OPEN_EXISTING,
                                                                0, // was null
                                                                NULL);
                   // opening serial port


        if (serial_handle    != INVALID_HANDLE_VALUE)
        {
            if(!SetCommMask(serial_handle, 0))
                erreur = 1;

            // set timeouts
            if(!SetCommTimeouts(serial_handle,&cto))
                erreur = 2;

            // set DCB
            if(!SetCommState(serial_handle,&dcb))
                erreur = 4;
        }
        else
            erreur = 8;

    }
    else
        erreur = 16;


/* ------------------------------ */
    if (erreur!=0)
      {
      CloseHandle(serial_handle);
      serial_handle = INVALID_HANDLE_VALUE;
      }
    return(erreur);
    }


/* ------------------------------ */
/* -- sendChar ------------------ */
/* ------------------------------ */
  void Rserial::sendChar(char data)
    {
      sendArray(&data, 1);
    }
/* ------------------------------ */
/* -- sendArray ----------------- */
/* ------------------------------ */
  void Rserial::sendArray(char *buffer, int len)
    {
    unsigned long result;
    if (serial_handle!=INVALID_HANDLE_VALUE)
      WriteFile(serial_handle, buffer, len, &result, NULL);
    }

/* ------------------------------ */
/* -- getChar ------------------- */
/* ------------------------------ */
  char Rserial::getChar(void)
    {
    char c;
    getArray(&c, 1);
    return(c);
    }

/* ------------------------------ */
/* -- getArray ------------------ */
/* ------------------------------ */
  int  Rserial::getArray (char *buffer, int len)
    {
    unsigned long read_nbr;
    read_nbr = 0;
    if (serial_handle!=INVALID_HANDLE_VALUE)
      {
      ReadFile(serial_handle, buffer, len, &read_nbr, NULL);
      }
    return((int) read_nbr);
    }
/* ------------------------------ */
/* -- getNbrOfBytes ------------- */
/* ------------------------------ */
  int Rserial::getNbrOfBytes (void)
    {
    struct _COMSTAT status;
    int             n;
    unsigned long   etat;
    n = 0;
    if (serial_handle!=INVALID_HANDLE_VALUE)
      {
      ClearCommError(serial_handle, &etat, &status);
      n = status.cbInQue;
      }
    return(n);
    }
