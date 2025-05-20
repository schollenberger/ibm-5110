/*******************************************************************************
* .FILE:         usbsio.cpp                                                    *
*                                                                              *
* .DESCRIPTION:  USBSIO Program Version 2:  Class Implementation               *
*                19.02.2023 modified from USBPIO (remove IEEE Bus functions)   *
*                10.05.2025 removed Windows stuff to compile as command line   *
*                           program                                            *
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
//#include "windows.h"
#include "rserial.h"

#include "globals.h"
#include "usbsio.hpp"

/******************************** Global Variables ****************************/
  IString   IBFunc         = " "                    ; /* IB Function          */
  IString   IBInfo         = ""                     ; /* IB Info              */
  IString   IBStat         = ".."                   ; /* IB Status            */
  IString   IBMenu         = " "                    ; /* IB Menu              */

  int       eof            = 0                      ; /* end of file flag     */
//  IString   DatStr                                  ; /* temp data            */
  IString   Buf$                                    ; /* temp Buffer          */
//  IString   OutDat                                  ; /* output data          */
//  IString   InpDat                                  ; /* input data           *
//  IString   Recl           = "4"                    ; /* input Recordlength   */
//  int       Recl_          = 4                      ; /* Nr. of input bytes   */
  int       CharIndex      = 1                      ; /* Character Position   */
//  IString   RN             = "0.00"                 ; /* RepRate <sec>        */
//  float     RN_            = 0                      ; /* RepRate <sec>        */
//  IString   FilNam         = " "                    ; /* File Name            */
  Rserial   *com                                    ; /* Rserial              */



/******************************** Functions ******************************/
/*  defined in header file
*   void     INIT     ();
*   void     PUTS     (IString&);
*   IString  GETS     (int);
*   void     BufC     ();
*   void     SIOTrac  (IString&);
*   void     PutCom   (IString, int);
*   void     GetCom   (IString, int);
*** void     IbStart  (void *pvParms);                                   *
**************************************************************************/


/* -----------------------------------------------------------------------------
| The following routines are special for the USBSIO card using VCOM port       |
|-----------------------------------------------------------------------------*/

  void INIT()
    {
//    IString MsgFile;  // defined in global.h

    MsgFile << "-- : ** INIT() Start **" << endl;

    IString Port, Parity, SIO_Options, Comparm;
    int Baud, Bits, StopBits;

    int lrc;  // local return code
    IString is_lrc; // return code as IString

    DCB dcb;
    serial_parity parity_arg;
    MsgFile << "-- : ** com disconnect **" << endl;
    com=new Rserial();
    //com->disconnect();
    if (SIO_DFlg == 0)
    {
      Port=P11$;
      Baud=atoi(P12$);
      Parity=P13$;
      Bits=atoi(Bits$);
      StopBits=atoi(P16$);
//      SIO_Options="";
      SIO_Options=SioOptions$;  // *WSB* copy global sio options set in caller OpenComPort()
//      if (P4==1) {SIO_Options=",RS";}
//      if (P5==1) {SIO_Options=",ME";}
//      if (P6==1) {SIO_Options=",PE";}
//      if (P7==1) {SIO_Options=",FE";}
//      SIO_Options=SIO_Options+P22$;
      if (DFlg == 1)
        {
        MsgFile << "-- Port            = " << Port            << endl;
        MsgFile << "-- Baud            = " << Baud            << endl;
        MsgFile << "-- Parity          = " << Parity          << endl;
        MsgFile << "-- Bits            = " << Bits            << endl;
        MsgFile << "-- StopBits        = " << StopBits        << endl;
        MsgFile << "-- SIO_Options     = " << SIO_Options     << endl;
        }
      MsgFile << "-- : ** com connect **" << endl;

      // cout << "INIT(): SIO_Options: <" << SIO_Options << ">" << endl;

      lrc = com->connect(Port, Baud, Parity, Bits, StopBits, SIO_Options);
    } else {
	  lrc = 0;
      MsgFile << "INIT(): simulating COM port - skipping connect()" << endl;
    }
    IBFunc="INIT"; IBStat="--";                       /* SET CONTROLLER FLAG  */
    is_lrc = lrc;
    IBInfo="INIT "+Port+" - rc = "+ is_lrc;
    MsgFile << "-- : ** INIT() End **" << endl;
    SIOTrac(IBInfo);
    if (SIO_SFlg == 1) {SetIbStat(IBInfo, IBStat);}
    if (lrc != 0)
	{
		rc = lrc;
		MsgFile << "INIT(): Failed to open COM port "+Port+" error code = "
			+is_lrc+" updated global rc variable" << endl;
	}
    return; /* end INIT() */
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
    return; /* end PUTS() */
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
  void BufC()
    {
    IString IByte$; int i=0;
    if (SIO_DFlg==0)
      {
//    while (com->loc()>0)
//      {
//IByte$=INPUT$(1,#7)
//      i=i+1;
//      }
//    IF SIO.Tflg%=1 THEN : PRINT #6.........
      }
    return; /* end Clear Buffer */
    }
/* -------------------------------*/
  void SIOTrac(IString& EFlg)
    {
    if (EFlg=="") {return;}
    IBInfo=IBMenu + ": " +EFlg;
    Rcc=0; OutMsg=IBInfo;
    error(Rcc,MaxRc,Fails,OutMsg,MsgFile);
    IBInfo=" ";
    return; /* end SIOTrac */
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
