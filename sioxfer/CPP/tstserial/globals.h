
#include <iostream.h>
#include <fstream.h>

#include <idate.hpp>
#include <itime.hpp>
#include <itimer.hpp>


#ifndef _GLOBALS_
#define _GLOBALS_


/******************************** Global Variables ****************************/
extern   IString   Prog;		 /* programname          */

extern   IString   Space;
extern   IString   Spaces20;
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

extern   IString   P11$;
extern   IString   P12$;
extern   IString   P13$;
extern   IString   P14$;
extern   IString   P15$;
extern   IString   P16$;
extern   IString   P17$;
extern   IString   P18$;
extern   IString   P19$;
extern   IString   P20$;
extern   IString   P21$;
extern   IString   P22$;
extern   IString   P17b$;
extern   IString   T18$;
extern   IString   T19$;
extern   IString   C11$;
extern   IString   C12$;
extern   IString   C13$;
extern   IString   C14$;
extern   IString   C16$;
extern   IString   C17$;

extern   IString   Sep;
extern   IString   CurDir;
extern   IString   WorkDir;
extern   IString   ToolsDir;
extern   IString   OutMsg;

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

//  IString   SioOptions$    = ""                     ; /* SioOptions$          */
//  IString   RS$            = ""                     ; /* SioOptions$          */
//  IString   ME$            = ""                     ; /* SioOptions$          */
//  IString   PE$            = ""                     ; /* SioOptions$          */
//  IString   FE$            = ""                     ; /* SioOptions$          */
extern    IString   Bits$;



extern   IString   Msg_File;
extern   ofstream  MsgFile;


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