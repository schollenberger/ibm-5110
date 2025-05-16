
#include <iostream.h>
#include <fstream.h>

#include <idate.hpp>
#include <itime.hpp>
#include <itimer.hpp>


#ifndef _GLOBALS_
#define _GLOBALS_


/******************************** Global Variables ****************************/
extern   IString   Prog;		 /* programname          */

//extern   IString   Space;
//extern   IString   Spaces20;
extern   time_t    StartTime;
extern   time_t    StopTime;
extern   int       RunTime;
extern   int       TotRunTime;
 
extern   int       P1, P2, P3, P4, P5, P6, P7;
//extern    int       P2             = 0                      ; /*                      */
//extern    int       P3             = 0                      ; /*                      */
//extern    int       P4             = 0                      ; /*                      */
//extern    int       P5             = 0                      ; /*                      */
//extern    int       P6             = 0                      ; /*                      */
//extern    int       P7             = 0                      ; /*                      */

extern   IString   P11$, P12$, P13$, P14$, P15$, P16$, P17$, P18$, P19$, P20$, P21$, P22$;
extern   IString   P17b$;
extern   IString   T18$, T19$;
extern   IString   C11$, C12$, C13$, C14$, C15$, C16$, C17$;

extern   int       rc;                       /* returncode           */
extern   int       Rcc;                      /* returncode           */
extern   int       MaxRc;                    /* Max. returncode      */
extern   int       Fails;                    /* nr. of fails         */

extern   IString   Sep;
extern   IString   CurDir;
extern   IString   WorkDir;
extern   IString   ToolsDir;
extern   IString   OutMsg;

extern   int       DFlg;
extern   int       SIO_CFlg, SIO_DFlg,SIO_TFlg, SIO_SFlg;

extern   IString   x04;
extern   IString   x0A;
extern   IString   x0D;
//extern   IString   x0A0D          = x0A+x0D                ; /*                      */
//extern   IString   x10            = "\x10"                 ; /*                      */
//extern   IString   x15            = "\x15"                 ; /*                      */
//extern   IString   x16            = "\x16"                 ; /*                      */
//  IString   x1A            = "\x1A"                 ; /*                      */
//  IString   x1E            = "\x1E"                 ; /*                      */
//  IString   x1F            = "\x1F"                 ; /*                      */
//  IString   x151E          = x15+x1E                ; /*                      */
//  IString   x151E1F        = x15+x1E+x1F            ; /*                      */
//  IString   x04151E        = x04+x15+x1E            ; /*                      */
//  IString   x041E1F        = x04+x1E+x1F            ; /*                      */
//  IString   x04151E1F      = x04+x15+x1E+x1F        ; /*                      */
//IString   x17            = "\x17"                 ; /* ETB End of Trans.Blk.*/
//  IString   xDF            = "\xDF"                 ; /* ascii 223            */

extern    IString   SioOptions$;                      /* SioOptions$          */
//  IString   RS$            = ""                     ; /* SioOptions$          */
//  IString   ME$            = ""                     ; /* SioOptions$          */
//  IString   PE$            = ""                     ; /* SioOptions$          */
//  IString   FE$            = ""                     ; /* SioOptions$          */
extern    IString   Bits$;                            /* SIO number of bits */



extern   IString   Msg_File;
extern   ofstream  MsgFile;

/******************************** Global Functions ****************************/
//  void      transfer          (int drv, int rcv, IString sta, int len, IString&, IString&, IString&);
//  int       Warning           (IString Info, IString Input);
//  int       MsgEnter          (IString Info);

extern   int       SetInfo           (IString Info);
extern   int       SetInfo2          (IString Info);
extern   int       SetIbStat         (IString IBInfo ,IString IBStat);
//  IString   Headerline1       ();


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
  IString   CodeTrans         (IString Incode, IString Outcode, IString Instring);

/******* Functions ************************************************************/
  void      get_line          (ifstream&, IString&, IString&, IString&, IString&);
  void      error             (int&, int&, int&, IString&, ofstream&);
  void      GetDate           (IString&);
  void      GetCurDir         (IString&, IString&);
  int       DoesExist         (IString&);
//  void      *pv;
  }
#endif