/*******************************************************************************
* .FILE:         tstserial.cpp                                                 *
*                                                                              *
* .DESCRIPTION:  Sioxfer Program Version 2:                                    *
*                                                                              *
* Initial coding : 08.05.2025                                                   *
*                                                                              *
* Changes:                                                                     *
*                                                                              *
*                                                                              *
*******************************************************************************/
#include <conio.h>
#include <stdio.h>
#include <iostream.h>

#include "globals.h"
#include "usbsio.hpp"
#include "tstserial.h"


/******************************** Global Variables ****************************/
/******************************** Global Variables ****************************/
  IString   Prog           = "TstSerial"            ; /* programname          */
  IString   Vers           = "1.0"                  ; /* version              */
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
 
  int       P1             = 0                      ; /*                      */
  int       P2             = 0                      ; /*                      */
  int       P3             = 0                      ; /*                      */
  int       P4             = 0                      ; /*                      */
  int       P5             = 0                      ; /*                      */
  int       P6             = 0                      ; /*                      */
  int       P7             = 0                      ; /*                      */

  IString   P11$           = "COM2"                 ; /*                      */
  IString   P12$           = "9600"                 ; /*                      */
  IString   P13$           = "N"                    ; /*                      */
  IString   P14$           = "8"                    ; /*                      */
  IString   P15$           = 256                    ; /*                      */
  IString   P16$           = "2"                    ; /*                      */
  IString   P17$           = "0"                    ; /*                      */
  IString   P18$           = "EBCDIC"               ; /*                      */
  IString   P19$           = "EBCDIC"               ; /*                      */
  IString   P20$           = 99999                  ; /*                      */
  IString   P21$           = "0"                    ; /*                      */
  IString   P22$           = ""                     ; /*                      */
  IString   P17b$          =""                      ; /*                      */
  IString   T18$           = P18$                   ; /*                      */
  IString   T19$           = P19$                   ; /*                      */
  IString   C11$           = "COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8";
  IString   C12$           = "75 110 150 300 600 1200 1800 2400 4800 9600 19200 38400 57600 115200 ";
  IString   C13$           = "N E O S M";
  IString   C14$           = "5 6 7 8 H P";
  IString   C16$           = "1 2";
  IString   C17$           = "0 1 2 3 4 5 6 7 8";

  IString   Sep            = "\x5C"                 ; /* "\" used for DOS     */
  IString   CurDir         = "."                    ; /* current directory    */
  IString   WorkDir        = "."                    ; /* workdirectory        */
  IString   ToolsDir       = "D:"+Sep+"TOOLS"+Sep+"bin"; /* toolsdirectory    */
  IString   OutMsg         = ""                     ; /* message              */

  int       SIO_CFlg       = 0                      ; /* Code Pages in Msg Fil*/
  int       SIO_DFlg       = 0                      ; /* SIO debug flag       */
  int       SIO_TFlg       = 0                      ; /* SIO trace flag       */
  int       SIO_SFlg       = 0                      ; /* SIO status flag      */

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

  IString   SioOptions$    = ""                     ; /* SioOptions$          */
  IString   RS$            = ""                     ; /* SioOptions$          */
  IString   ME$            = ""                     ; /* SioOptions$          */
  IString   PE$            = ""                     ; /* SioOptions$          */
  IString   FE$            = ""                     ; /* SioOptions$          */
  IString   Bits$          = "8"                    ; /* P14$ = 8,H,P         */



  IString   Msg_File       = Prog+".msg"            ; /* messagefile          */
  ofstream  MsgFile(Msg_File)                       ; /* messagefile          */



  IString   Filetype$      = "TXT"                  ; /* Filetype             */
  IString   Srcfile$       = ""                     ; /* Source File          */
  IString   Dstfile$       = ""                     ; /* Destination File     */
  IString   Message$       = ""                     ; /* Message              */
  IString   Ctlfile$       = ""                     ; /* Control File         */
  IString   Ctl_File                                ; /* Control File         */
  IString   DmpTline$      = ""                     ; /* Dump Tline           */
  int       rc             = 0                      ; /* returncode           */

  IString   TraFile        = Prog                   ; /* tracefile            */
  IString   Tra_File       = TraFile+".TRA"         ; /* tracefile            */
  ofstream  TracFile(Tra_File);
  IString   Out_File                                ; /* temp outputfile      */
  IString   Options0       = ""                     ; /* Options0             */
  IString   Options        = ""                     ; /* Options              */
  IString   CP437$         = ""                     ; /* ASCII  code translat.*/
  IString   EBCDIC$        = ""                     ; /* EBCDIC code translat.*/
  IString   CP5110$        = ""                     ; /* CP5110 code translat.*/
  IString   CI5110$        = ""                     ; /* CI5110 code translat.*/
  IString   CP5100$        = ""                     ; /* CP5100 code translat.*/
  IString   CI5100$        = ""                     ; /* CI5100 code translat.*/
  IString   ASCFILE1$      = ""                     ; /* ASCFILE1 for debug   */
  IString   ASCFILE2$      = ""                     ; /* ASCFILE2 for debug   */
  IString   ASCFILE3$      = ""                     ; /* ASCFILE3 for debug   */
  IString   CTLFILE1$      = ""                     ; /* CTLFILE1 for debug   */
  IString   CP5110FILE1$   = ""                     ; /* CP5110FILE1 for debug   */
  IString   CP5110FILE2$   = ""                     ; /* CP5110FILE2 for debug   */
  IString   CP5110FILE3$   = ""                     ; /* CP5110FILE3 for debug   */


  IString   ASCIIChars     = ""                     ; /* ASCII Characters     */

  IString   Variable       = ""                     ; /* Variablename         */
  IString   Value          = ""                     ; /* Value of variable    */
  IString   Group          = ""                     ; /* Setfile parm. group  */
  IString   CC             = "~"                    ; /* contenuation char    */
  IString   Inpline        = ""                     ; /* stripped inputline   */
  IString   Inpline_uc     = ""                     ; /* inputline uppercase  */
  IString   Inpline_uc_g   = ""                     ; /* inputline uc modified*/
  int       ContFlg        = 0                      ; /* continue flag        */
  int       StopFlg        = 0                      ; /* stop flag            */


  int       DFlg           = 0                      ; /* Debug flag           */

  int       PS_Flg         = 0                      ; /* txt2ps flag          */
  int       found          = 0                      ; /* found temp flag      */
  int       Tra            = 1                      ; /* translate flag       */
  int       Hex            = 0                      ; /* hex flag             */
  int       Pdf            = 0                      ; /* pdf flag             */

  int       Ig04           = 0                      ; /* Ignore EOT     ASCII */
  int       Ig08Ig09       = 0                      ; /* Ignore BS+HT   ASCII */
  int       Ig0A           = 0                      ; /* Ignore LF      ASCII */
  int       Ig0A0D         = 0                      ; /* Ignore LF/CR   ASCII */
  int       Ig37           = 0                      ; /* Ignore EOT     EBCDIC*/
  int       Ig16Ig05       = 0                      ; /* Ignore BS+HT   EBCDIC*/
  int       Ig15           = 0                      ; /* Ignore NL      EBCDIC*/
  int       Ig151E         = 0                      ; /* Ignore NL/RS   EBCDIC*/
  int       IlineC         = 0                      ; /* Controlfile inputline*/
  int       RECS           = 0                      ; /* Records              */
  int       Recs           = 0                      ; /* Records              */
  int       RecCnt         = 0                      ; /* Records (P20$)       */

  char      Inputline[4096]                         ; /* Inputline            */
  IString   execline       = ""                     ; /* exec table           */
  IString   pdfline        = ""                     ; /* txt2ps info          */


/******************************** Global Functions ****************************/
//  void      transfer          (int drv, int rcv, IString sta, int len, IString&, IString&, IString&);
//  int       Warning           (IString Info, IString Input);
//  int       MsgEnter          (IString Info);
  int       SetInfo           (IString Info);
  int       SetInfo2          (IString Info);
//  int       SetIbStat         (IString IBInfo ,IString IBStat);


/******************************** Functional Code *****************************/
/*******************************************************************************
*                                 Program Start                                *
*******************************************************************************/
int main(int argc, char **argv)
  {
  Vers = Vers + " comp. " + __DATE__ + " " + __TIME__;
  GetDate(Date);
  GetCurDir(Prog,CurDir);
  WorkDir = CurDir;

  cout << Prog << " Work dir: " << WorkDir << endl;
 

/*
  if (argc == 0)
    {
    Warning("missing SetFile Name - Press y","y");
    }
  else
    {
    SetFile = strupr(argv[1]);
    }
*/
 
  cout << "The work begins..." << endl;

  INIT();

  IString isMsg = "Hallo du da";

  PUTS(isMsg);
  cout << "Waiting for input on serial..." << endl;

  GETS(10);

  com->disconnect();

  cout << "...done." << endl;

  return 0;
  } /* end main() */

/*** get date and time for msgfile ********************************************/
void GetDate(IString& Date)
  {
  IString temp1 = IDate().monthOfYear();
  IString temp2 = IDate().dayOfMonth();
  IString temp3 = IDate().year();
  IString temp4 = ITime().asString();
  Date  = temp1+"/"+temp2+"/"+temp3+" "+temp4;
  return;
  }

/*** get current directory ****************************************************/
void GetCurDir(IString& Prog, IString& CurDir)
  {
  int rc = 0;
  char Inputline0[4096];
  IString temp;
  IString TmpFile = Prog + ".tmp";
  rc = system("dir >> " + TmpFile);
  ifstream InFile0(TmpFile);
  while (!InFile0.eof())
    {
    InFile0.getline(Inputline0,sizeof (Inputline0),'\n'); temp = Inputline0;
    if (temp.word(1).upperCase()=="DIRECTORY"||temp.word(1).upperCase()=="VERZEICHNIS")
      {
      CurDir = temp.word(3);
      }
    }
  InFile0.close();
  rc = system("erase " + TmpFile);
  return;
  }


/*******************************************************************************
*                                 Programs                                     *
*******************************************************************************/

/*** open com port ************************************************************/
  void OpenComPort()
    {
    if (DFlg==1)
      {
      if (P4==0) {RS$="";} else {RS$=",RS";}
      if (P5==0) {ME$="";} else {ME$=",ME";}
      if (P6==0) {PE$="";} else {PE$=",PE";}
      if (P7==0) {FE$="";} else {FE$=",FE";}
      }
    Tra=1; Hex=0; Pdf=0;
    if (P14$.indexOf("8HP")>0) {Bits$="8";} else {Bits$=P14$;}
    SioOptions$=RS$+P22$+PE$+ME$+FE$; SioOptions$.strip();
    MsgFile << "-- : OpenComPort" << endl;
    INIT();
    return;
    }

/*** open trafile *************************************************************/
  void OpenTraFile()
    {
    MsgFile << "-- : Open " << Tra_File << endl;
    Tra_File = TraFile+".TRA";
    TracFile.close();
    ofstream TracFile(Tra_File);
    TracFile << Tra_File << " started: " << Date << endl;
    return;
    }

  void PutFile()
    {
  IString   temp           = ""                     ; /* temp variable        */
  IString   temp0          = ""                     ; /* temp variable        */
  IString   temp1          = ""                     ; /* temp variable        */
  IString   temp2          = ""                     ; /* temp variable        */

    CodeSel();
    StartTime=time(NULL);
    temp0=x10+"BITS="+P14$;
    temp1=x10+"FILETYP="+Filetype$;
    temp2=x10+"DSTFILE="+Dstfile$;
    if (P14$=="8")
      {
      temp=CodeTrans(CP437$,EBCDIC$,temp0)+x151E; PUTS(temp); if (P1==1) {SetInfo2(temp0);}
      temp=CodeTrans(CP437$,EBCDIC$,temp1)+x151E; PUTS(temp); if (P1==1) {SetInfo2(temp1);}
      temp=CodeTrans(CP437$,EBCDIC$,temp2)+x151E; PUTS(temp); if (P1==1) {SetInfo2(temp2);}
      }
    else
      {
      temp=temp0+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp0);}
      temp=temp1+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp1);}
      temp=temp2+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp2);}
      }
    if (P18$!="HEX")
      {
      ifstream Src_File(Srcfile$);
      while (!Src_File.eof())
        {
        Src_File.getline(Inputline,sizeof(Inputline),'\n');
        temp=CodeTrans(CP437$,EBCDIC$,Inputline)+x151E; PUTS(temp);
        if (P1==1) {SetInfo2(temp);}
        }
      Src_File.close();
      PUTS(x04151E);
      if (P1==1) {SetInfo2(x04151E);}
      StopTime=time(NULL); RunTime=StopTime-StartTime;
      }
    if (P2==1)
      {
      TracFile << "PUTFILE Srcfile="+Srcfile$+" Dstfile="+Dstfile$ << endl;
      TracFile << "  Date:" << Date << " Runtime: " << RunTime << " Sec." << endl;
      }
    SetInfo("Filetransfer ended - Press enter");
    return;
    }

  void GetFile()
    {
  IString   temp           = ""                     ; /* temp variable        */
  IString   temp0          = ""                     ; /* temp variable        */
  IString   temp1          = ""                     ; /* temp variable        */
  IString   temp2          = ""                     ; /* temp variable        */
  
    CodeSel();
    eof=0;
    Recs=0;
    temp0=x10+"BITS="+P14$;
    temp1=x10+"FILETYP="+Filetype$;
    temp2=x10+"DSTFILE="+Dstfile$;
    if (P14$=="8")
      {
      temp=CodeTrans(CP437$,EBCDIC$,temp0)+x151E    ; PUTS(temp); if (P1==1) {SetInfo2(temp0);}
      temp=CodeTrans(CP437$,EBCDIC$,temp1)+x151E    ; PUTS(temp); if (P1==1) {SetInfo2(temp1);}
      temp=CodeTrans(CP437$,EBCDIC$,temp2)+x151E    ; PUTS(temp); if (P1==1) {SetInfo2(temp2);}
      }
    else
      {
      temp=temp0+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp0);}
      temp=temp1+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp1);}
      temp=temp2+x151E; PUTS(temp); if (SIO_TFlg==1) {SetInfo(temp2);}
      }
    ofstream Dst_File(Dstfile$);
    temp1="";
    RecCnt=atoi(P20$);
    StartTime=time(NULL);
//    BufC();
    temp=GETS(0);
    while ((eof==0)&&(Recs<=RecCnt))
      {
      temp=GETS(atoi(P15$));
      if      (Tra==1) {temp0=CodeTrans(T18$,CP437$,temp);}
      else if (Hex==1) {temp0=temp;}
      else if (Pdf==1) {temp0=temp;}
      if (P1==1) {SetInfo2(temp0);}
      Dst_File << temp0 << endl;
      SetInfo(temp0);
      Recs=Recs+1;
      }
    Dst_File.close();
    StopTime=time(NULL); RunTime=StopTime-StartTime;
    if (P2==1)
      {
      TracFile << "GETFILE Srcfile="+Srcfile$+" Dstfile="+Dstfile$ << endl;
      TracFile << "  Date:" << Date << " Runtime: " << RunTime << " Sec." << endl;
      }
    SetInfo("Filetransfer ended - Press enter");
    return;
    }
/*** SetInfo ******************************************************************/
int SetInfo(IString Info)
  {
  cout << "Setinfo:" << Info << endl;
  return 0;
  }

/*** SetInfo2 *****************************************************************/
int SetInfo2(IString Info)
  {
  cout << "Setinfo2:" << Info << endl;
  return 0;
  }

  void CodeSel()
    {
    if (P14$=="5") {Tra=1; Hex=0; Pdf=0;}
    if (P14$=="6") {Tra=1; Hex=0; Pdf=0;}
    if (P14$=="7") {Tra=1; Hex=0; Pdf=0;}
    if (P14$=="8") {Tra=1; Hex=0; Pdf=0;}
    if (P14$=="H") {Tra=0; Hex=1; Pdf=0;}
    if (P14$=="P") {Tra=0; Hex=0; Pdf=1;}
    Ig04=0; Ig08Ig09=0; Ig0A=0; Ig0A0D=0; Ig37=0; Ig16Ig05=0; Ig15=0; Ig151E=0;
    if (P17$!="0")
      {
//      P17b$=HexBin$(8,P17$);
      P17b$="00000000";
      if (P17b$.subString(8,1)=="1") {Ig04    =1;}
      if (P17b$.subString(7,1)=="1") {Ig08Ig09=1;}
      if (P17b$.subString(6,1)=="1") {Ig0A    =1;}
      if (P17b$.subString(5,1)=="1") {Ig0A0D  =1;}
      if (P17b$.subString(4,1)=="1") {Ig37    =1;}
      if (P17b$.subString(3,1)=="1") {Ig16Ig05=1;}
      if (P17b$.subString(2,1)=="1") {Ig15    =1;}
      if (P17b$.subString(1,1)=="1") {Ig151E  =1;}
      }
    if(P18$=="EBCDIC") {T18$=EBCDIC$;}
    if(P18$== "ASCII") {T18$=CP437$ ;}
    if(P18$=="CP5110") {T18$=CP5110$;}
    if(P18$=="CP5100") {T18$=CP5100$;}
    if(P18$=="CI5110") {T18$=CI5110$;}
    if(P18$=="CI5100") {T18$=CI5100$;}
    if(P19$=="EBCDIC") {T18$=EBCDIC$;}
    if(P19$== "ASCII") {T18$=CP437$ ;}
    if(P19$=="CP5110") {T18$=CP5110$;}
    if(P19$=="CP5100") {T18$=CP5100$;}
    return;
    }

  void Mess()
    {
    return;
    }
/*** CodeTranslation **********************************************************/
  IString CodeTrans(IString Incode, IString Outcode, IString Instring)
    {
    int i1, index;
    IString Outstring="";
    for (i1=1; i1<=Instring.length(); i1++)
      {
      if (Instring.subString(i1,1)==" ")
        {
        Outstring=Outstring+" ";
        }
      else
        {
//      index=Outcode.indexOf(Instring.subString(i1,1))-1;
        index=Outcode.indexOf(Instring.subString(i1,1));
        Outstring=Outstring+Incode.subString(index,1);
        }
      }
    return Outstring;
    }



