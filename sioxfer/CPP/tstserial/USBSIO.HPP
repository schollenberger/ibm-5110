/*******************************************************************************
* .FILE:         usbsio.hpp                                                    *
*                                                                              *
* .DESCRIPTION:  UsbSio Program Version 1:  Class Header                       *
*                                                                              *
* .CLASSES:      UsbSioWindow                                                  *
*                IbCommandHandler                                              *
*******************************************************************************/

#include <istring.hpp>
#include "globals.h"
#include "rserial.h"

#ifndef _USBSIO_
#define _USBSIO_
/******************************** Global Variables ****************************/

  IString   IBFunc         = " "                    ; /* IB Function          */
  IString   IBInfo         = ""                     ; /* IB Info              */
  IString   IBStat         = ".."                   ; /* IB Status            */
  IString   IBMenu         = " "                    ; /* IB Menu              */
  int       eof            = 0                      ; /* end of file flag     */
  IString   DatStr                                  ; /* temp data            */
  IString   Buf$                                    ; /* temp Buffer          */
  IString   OutDat                                  ; /* output data          */
  IString   InpDat                                  ; /* input data           */
  IString   Recl           = "4"                    ; /* input Recordlength   */
  int       Recl_          = 4                      ; /* Nr. of input bytes   */
  int       CharIndex      = 1                      ; /* Character Position   */
  IString   RN             = "0.00"                 ; /* RepRate <sec>        */
  float     RN_            = 0                      ; /* RepRate <sec>        */
  IString   FilNam         = " "                    ; /* File Name            */
  Rserial   *com                                    ; /* Rserial              */

  extern "C"
  {
/******************************** Functions ***********************************/
  void     INIT     ();
  void     PUTS     (IString&);
  IString  GETS     (int);
  void     BufC     ();
  void     SIOTrac  (IString&);
  void     PutCom   (IString, int);
  void     GetCom   (IString, int);
  void     IbStart  (void *pvParms);
  }


#endif
