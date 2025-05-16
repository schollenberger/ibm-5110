
#include <iostream.h>
#include <fstream.h>

#include <itime.hpp>
#include <itimer.hpp>


#ifndef _GLOBALS_
#define _GLOBALS_


/******************************** Global Variables ****************************/
  IString   Vers           = "1.0"                  ; /* version              */
  IString   Prog           = "TstSerial"            ; /* programname          */
  IString   ProgOwner      = "WSB + HR"             ; /* program owner        */
  IString   Date                                    ; /* Date + Time          */
  IString   Dat                                     ; /* Date (Basic Format)  */
  IString   Tim                                     ; /* Time (Basic Format)  */
  IString   Space          = " "                    ; /* Space                */
  IString   Spaces20       = "....|....|....|....|" ; /* 20 Spaces            */
  IString   Spaces40       = "                                        " ;
  time_t    StartTime      = time(NULL)             ; /* Start Time           */
  time_t    StopTime       = time(NULL)             ; /* Stop  Time           */
  int       RunTime                                 ; /* RunTime              */
  int       TotRunTime                              ; /* Total RunTime        */
 
  int       P4             = 0                      ; /*                      */
  int       P5             = 0                      ; /*                      */
  int       P6             = 0                      ; /*                      */
  int       P7             = 0                      ; /*                      */

  IString   P11$           = "COM1"                 ; /*                      */
  IString   P12$           = "9600"                 ; /*                      */
  IString   P13$           = "N"                    ; /*                      */
  IString   P14$           = "8"                    ; /*                      */
  IString   P15$           = 256                    ; /*                      */
  IString   P16$           = "2"                    ; /*                      */
  IString   P17$           = "0"                    ; /*                      */
  IString   P22$           = ""                     ; /*                      */

  IString   C11$           = "COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8";
  IString   C12$           = "75 110 150 300 600 1200 1800 2400 4800 9600 19200 38400 57600 115200 ";
  IString   C13$           = "N E O S M";
  IString   C14$           = "5 6 7 8 H P";
  IString   C16$           = "1 2";
  IString   C17$           = "0 1 2 3 4 5 6 7 8";

  int       SIO_DFlg       = 0                      ; /* SIO debug flag       */

  IString   x04            = "\x04"                 ; /*                      */
  IString   x0A            = "\x0A"                 ; /*                      */
  IString   x0D            = "\x0D"                 ; /*                      */
  IString   x0A0D          = x0A+x0D                ; /*                      */
  IString   x10            = "\x10"                 ; /*                      */
  IString   x15            = "\x15"                 ; /*                      */
//IString   x16            = "\x16"                 ; /*                      */
  IString   x1A            = "\x1A"                 ; /*                      */
  IString   x1E            = "\x1E"                 ; /*                      */
  IString   x1F            = "\x1F"                 ; /*                      */
  IString   x151E          = x15+x1E                ; /*                      */
  IString   x151E1F        = x15+x1E+x1F            ; /*                      */
  IString   x04151E        = x04+x15+x1E            ; /*                      */
  IString   x041E1F        = x04+x1E+x1F            ; /*                      */
  IString   x04151E1F      = x04+x15+x1E+x1F        ; /*                      */
//IString   x17            = "\x17"                 ; /* ETB End of Trans.Blk.*/
  IString   xDF            = "\xDF"                 ; /* ascii 223            */

  IString   Bits$          = "8"                    ; /* P14$ = 8,H,P         */



  IString   Msg_File       = Prog+".msg"            ; /* messagefile          */
  ofstream  MsgFile(Msg_File)                       ; /* messagefile          */


/******************************** Prototypes **********************************/
  extern "C"
  {
/******************************** Subroutines *********************************/
  void      OpenComPort       ();
  void      OpenTraFile       ();
  void      PutFile           ();
  void      GetFile           ();
  void      StartExec         ();
  void      StartPdfgen       ();
  void      GFile             ();
  void      CodeSel           ();
  void      Mess              ();
  void      Disass            ();
  void      CtlFile           ();

/******* Functions ************************************************************/
  void      get_line          (ifstream&, IString&, IString&, IString&, IString&);
  void      error             (int&, int&, int&, IString&, ofstream&);
  void      GetDate           (IString&);
  void      GetCurDir         (IString&, IString&);
  int       DoesExist         (IString&);
  void      *pv;
  }
#endif