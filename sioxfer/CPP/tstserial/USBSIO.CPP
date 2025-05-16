/*******************************************************************************
* .FILE:         usbsio.cpp                                                    *
*                                                                              *
* .DESCRIPTION:  USBSIO Program Version 1:  Class Implementation               *
*                19.2.2023 modified from USBPIO (remove IEEE Bus functions)    *
*                                                                              *
* .CLASSES:      UsbSioWindow                                                  *
*                IbCommandHandler                                              *
*                                                                              *
* Changes:                                                                     *
*                                                                              *
* Date       Vers. Changed by Reason                                           *
* 11.3.2025  3.0   H.Ruffner  New                                              *
* 30.3.2025        H.Ruffner  Cleanup GETS function                            *
*                                                                              *
*                                                                              *
* To do: Add EOI to last byte                                                  *
*        Options CS,DS,CD,DT,ME,FE,IR2-15 ?                                    *
*        BufC                                                                  *
*        debug ignore modes                                                    *
*                                                                              *
*******************************************************************************/
#include "windows.h"
#include "rserial.h"

#include "globals.h"
#include "usbsio.hpp"

/* -----------------------------------------------------------------------------
| The following routines are special for the USBSIO card using VCOM port       |
|-----------------------------------------------------------------------------*/

  void INIT()
    {
    IString MsgFile;

    IString Port, Parity, SIO_Options, Comparm;
    int Baud, Bits, StopBits;
    DCB dcb;
    serial_parity parity_arg;
    com=new Rserial();
    com->disconnect();
//  if (SIO_DFlg == 0)
//    {
      Port=P11$;
      Baud=atoi(P12$);
      Parity=P13$;
      Bits=atoi(Bits$);
      StopBits=atoi(P16$);
      SIO_Options="";
      if (P4==1) {SIO_Options=",RS";}
      if (P5==1) {SIO_Options=",ME";}
      if (P6==1) {SIO_Options=",PE";}
      if (P7==1) {SIO_Options=",FE";}
      SIO_Options=SIO_Options+P22$;

      com->connect(Port, Baud, Parity, Bits, StopBits, SIO_Options);
//    }
    return; /* end INIT */
    }
/* -------------------------------*/
  void PUTS(IString& OutDat)
    {
    IString tmp, tmp1;
    tmp=OutDat;
//  CharIndex%=1;
    tmp.change(x0A,""); tmp.change(x0D,""); tmp1=tmp;
//  tmp.change(x1A,xDF);                              /* x'1A' close Files    */
//  if (SIO_DFlg == 1)
      {MsgFile << "-- ** PUTS ** " << tmp1 << endl;}
// else
      {PutCom(tmp1,tmp1.length());}
    return; /* end PUTS */
    }
/* -------------------------------*/
  IString GETS(int Recl_)
    {
    IString IByte$="", RecDat="", InputlineG$="";
    char c;
    int i;
    if (Recl_==0) {CharIndex=1;}
    Buf$="";
    eof=0;
    i=1;
    while ((i<=Recl_) && (eof==0))
      {
      c=com->getChar();
      IByte$=c;
      InputlineG$=InputlineG$+IByte$;
      i++;
      }
    if (SIO_DFlg == 1) {MsgFile << "-- ** GETS ** " << InputlineG$ << endl;}

    return InputlineG$;
    }


/* -------------------------------*/
  void PutCom(IString Data, int len)
    {
    IString PCD;
    if (SIO_DFlg==0)
      {
      com->sendArray(Data,len);
      }
    return; /* end PutCom */
    }
/* -------------------------------*/
  void GetCom(IString Data, int len)
    {
    if (SIO_DFlg==0)
      {
      com->getArray(Data,len);
      }
    return; /* end GetCom */
    }

