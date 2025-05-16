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
#include "globals.h"
#include "tstserial.h"


#include "usbsio.hpp"

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


/*******************************************************************************
* main  - Application entry point for Sioxfer program                          *
*                                                                              *
* Creates a new object mainWindow of class M1SioWindow                         *
* Sets the size of mainWindow                                                  *
* Sets the window focus to mainWindow                                          *
* Displays the mainWindow                                                      *
* Starts the events processing for the application                             *
*******************************************************************************/
    ICoordinateSystem::setApplicationOrientation(ICoordinateSystem::originUpperLeft );
    srand(time(NULL));
    M1SioWindow mainWindow (WND_MAIN);
    mainWindow.sizeTo(ISize(820,575));
    mainWindow.setFocus();
    mainWindow.show();
    mainWindow.setBackgroundColor(IColor::paleGray);
    IApplication::current().run();

/******************************** Programend **********************************/
  return 0;
  com->disconnect();
  } /* end main() */

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
    BufC();
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

  void StartExec()
    {
    execline = Inpline.subString(Inpline.indexOf(":")+1);
    MsgFile << "-- : starting exec: " << execline << endl;
    system(execline);
    MsgFile << "-- : ending exec: " << execline << endl;
    return;
    }

  void StartPdfgen()
    {
    IString psFile, pdfFile;
    pdfline = Inpline.subString(Inpline.indexOf(":")+1);
    MsgFile << "-- : starting txt2ps : " << pdfline << endl;
    system("txt2ps "+pdfline);
    MsgFile << "-- : ending txt2ps" << endl;
    psFile = pdfline.subString(1,strcspn(pdfline,"."))+".ps";
    pdfFile = pdfline.subString(1,strcspn(pdfline,"."))+".pdf";
    MsgFile << "-- : starting ps2pdf" << endl;
    system("ps2pdf "+psFile+" "+pdfFile);
    system("erase "+psFile);
    system(pdfFile);
    MsgFile << "-- : ending ps2pdf" << endl;
    return;
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
      P17b$=HexBin$(8,P17$);
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

  void CtlFile()
    {
    IString CTL$; int ectl=0; int found=0;
    Ctl_File = WorkDir+Sep+Ctlfile$+".CTL";
    ifstream CFile(Ctl_File);
    if (!CFile)
      {
      Rcc = 29; OutMsg = "E-- " + Ctl_File + " not found";
      error(Rcc,MaxRc,Fails,OutMsg,MsgFile);
      }
    else
      {
      MsgFile << "-- : parsing " << Ctl_File  << endl;
      IlineC=0;
      get_line(CFile,Inpline,Inpline_uc,Inpline_uc_g,CC);
      while ((!CFile.eof()) && (ectl==0))
        {
        IlineC=IlineC+1;
        if (DFlg == 1) {MsgFile << "-- " << Inpline << endl;}
        OutMsg = "Error in Ctlfile: "+Inpline;
        if (Inpline.subString(1,1) != "*")
          {
          GetParms(Inpline,Group,Variable,Value);
          if (Group=="SET")
            {
            SetFile=WorkDir+Sep+Variable;
            SetInfo(" :   Setfile="+SetFile+".SET");
            RdSetFile();
            get_line(CFile,Inpline,Inpline_uc,Inpline_uc_g,CC);
            GetParms(Inpline,Group,Variable,Value);
            }
          if (Group=="PAR") {ReadParms(); Id1->WrtEf();}
          if (Group=="GET") {GetFiles(); found=1; GetFile();}
          if (Group=="PUT") {GetFiles(); found=1; PutFile();}
          if (Group=="EXE") {StartExec();found=1;}
          if (Group=="PDF") {StartPdfgen();found=1;}
          if (Group=="ASS") {found=1; Disass();}
          if (Group=="MSG") {found=1; Id2->m2ef5.setText(Message$);}
          if (Group=="END") {found=1; SetInfo("Filetransferes ended"); ectl=1;}
          }
        get_line(CFile,Inpline,Inpline_uc,Inpline_uc_g,CC);
        }
      if (found==0)
        {
        Rcc = 20; OutMsg = "Illegal Parameter > "+Group+"<";
        error(Rcc,MaxRc,Fails,OutMsg,MsgFile);
        }
      }
    return;
    }
/*** read File Parameters *****************************************************/
void GetFiles()
    {
    Filetype$=Variable;
    Variable=Value.subString(2);
    Srcfile$=Variable.subString(1,Variable.indexOf(","));
    Srcfile$=Srcfile$.translate(","," ");
    Srcfile$=Srcfile$.strip();
    Dstfile$=Value.subString(Value.lastIndexOf(",")+1);
    Id2->m2ef1.setText(Filetype$);
    Id2->m2ef2.setText(Srcfile$);
    Id2->m2ef3.setText(Dstfile$);
    return;
    }

/*** read setfile *************************************************************/
void RdSetFile()
  {
  int found=0;
  Set_File = SetFile+".SET";
  ifstream SFile(Set_File);
  if (!SFile)
    {
    Rcc = 29; OutMsg = "E-- " + Set_File + " not found";
    error(Rcc,MaxRc,Fails,OutMsg,MsgFile);
    }
  else
    {
    MsgFile << "-- : parsing " << Set_File << endl;
    get_line(SFile,Inpline,Inpline_uc,Inpline_uc_g,CC);
    while (!SFile.eof())
      {
      if (DFlg == 1) {MsgFile << "-- " << Inpline << endl;}
      GetParms(Inpline, Group, Variable, Value);
      found = 0;
      if (Inpline.subString(1,1) != "*")
        {
        if (Group == "PARAMETER") {found = 1; ReadParms();}
        if (Group == "TRANSFER" ) {found = 1; ReadFiles();}
        if (Group == "END"      ) {found = 1; break      ;}
        }
      get_line(SFile,Inpline,Inpline_uc,Inpline_uc_g,CC);
      }
    if (found == 0) {Rcc=20; OutMsg = "E-- illegal Group: " + Group; error(Rcc,MaxRc,Fails,OutMsg,MsgFile);}
    }
  return;
  }

/*** read parms ***************************************************************/
  void ReadParms ()
    {
    if      (Variable == "RD")
      {found = 1; P1 =atoi(Value); ChkIntValue(Value, P1, 0, 1);}
    else if (Variable == "TR")
      {found = 1; P2 =atoi(Value); ChkIntValue(Value, P2, 0, 1);}
    else if (Variable == "SP")
      {found = 1; P3 =atoi(Value); ChkIntValue(Value, P3, 0, 1);}
    else if (Variable == "RS")
      {found = 1; P4 =atoi(Value); ChkIntValue(Value, P4, 0, 1);}
    else if (Variable == "ME")
      {found = 1; P5 =atoi(Value); ChkIntValue(Value, P5, 0, 1);}
    else if (Variable == "PE")
      {found = 1; P6 =atoi(Value); ChkIntValue(Value, P6, 0, 1);}
    else if (Variable == "FE")
      {found = 1; P7 =atoi(Value); ChkIntValue(Value, P7, 0, 1);}
    else if (Variable == "PO")
      {found = 1; P11$=Value.strip(); ChkStrValue(Value, C11$);}
    else if (Variable == "BR")
      {found = 1; P12$=Value.strip(); ChkStrValue(Value, C12$);}
    else if (Variable == "PA")
      {found = 1; P13$=Value.strip(); ChkStrValue(Value, C13$);}
    else if (Variable == "BI")
      {found = 1; P14$=Value.strip(); ChkStrValue(Value, C14$);}
    else if (Variable == "RL")
      {found = 1; P15$=Value.strip(); ChkIntValue(Value, atoi(P15$), 1, 32000);}
    else if (Variable == "ST")
      {found = 1; P16$=Value.strip(); ChkStrValue(Value, C16$);}
    else if (Variable == "IM")
      {found = 1; P17$=Value.strip(); ChkIntValue(Value, atoi(P17$), 0, 255);}
    else if (Variable == "CI")
      {found = 1; P18$=Value.strip(); ChkStrValue(Value, C18$);}
    else if (Variable == "CO")
      {found = 1; P19$=Value.strip(); ChkStrValue(Value, C19$);}
    else if (Variable == "MR")
      {found = 1; P20$=Value.strip(); ChkIntValue(Value, atoi(P20$), 0, 99999);}
    else if (Variable == "DM")
      {found = 1; P21$=Value.strip(); ChkStrValue(Value, C21$);}
    else if (Variable == "OP")
      {found = 1; P22$=Value.strip();}
    if (found==0) {Rcc = 20; OutMsg = "e-- illegal Variable '"+Variable; error(Rcc,MaxRc,Fails,OutMsg,MsgFile);}
    return;
    }

/*** read files ***************************************************************/
  void ReadFiles()
    {
    if (Variable == "TY") {Filetype$ = Value.strip();};
    if (Variable == "SO") {Srcfile$  = Value.strip();};
    if (Variable == "DE") {Dstfile$  = Value.strip();};
    if (Variable == "ME") {Message$  = Value.strip();};
    if (Variable == "CT") {Ctlfile$  = Value.strip();};
    if (Variable == "DT") {DmpTline$ = Value.strip();};
    return;
    }

/*** write setfile ************************************************************/
  void WrSetFile()
    {
    Set_File = SetFile+".SET";
    ofstream OutFile(Set_File);
    OutFile << "* Setup parameter file generated " << Date << " by " << Prog << " Version:" << Vers << endl;
    SaveParms(OutFile);
    OutFile.close();
    return;
    }

/*** SaveParms ****************************************************************/
  int SaveParms(ofstream& OutFile)
    {
    OutFile << "Parameter: RD " << P1  << endl;
    OutFile << "Parameter: TR " << P2  << endl;
    OutFile << "Parameter: SP " << P3  << endl;
    OutFile << "Parameter: RS " << P4  << endl;
    OutFile << "Parameter: ME " << P5  << endl;
    OutFile << "Parameter: PE " << P6  << endl;
    OutFile << "Parameter: FE " << P7  << endl;
    OutFile << "Parameter: PO " << P11$ << endl;
    OutFile << "Parameter: BR " << P12$ << endl;
    OutFile << "Parameter: PA " << P13$ << endl;
    OutFile << "Parameter: BI " << P14$ << endl;
    OutFile << "Parameter: RL " << P15$ << endl;
    OutFile << "Parameter: ST " << P16$ << endl;
    OutFile << "Parameter: IM " << P17$ << endl;
    OutFile << "Parameter: CI " << P18$ << endl;
    OutFile << "Parameter: CO " << P19$ << endl;
    OutFile << "Parameter: MR " << P20$ << endl;
    OutFile << "Parameter: DM " << P21$ << endl;
    OutFile << "Parameter: OP " << P22$ << endl;
    OutFile << "Transfer : TY " << Filetype$ << endl;
    OutFile << "Transfer : SO " << Srcfile$  << endl;
    OutFile << "Transfer : DE " << Dstfile$  << endl;
    OutFile << "Transfer : ME " << Message$  << endl;
    OutFile << "Transfer : CT " << Ctlfile$  << endl;
    OutFile << "Transfer : DT " << DmpTline$ << endl;
    OutFile << "End"                                 << endl;
    return 0;
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

/*** GetParms *****************************************************************/
  void GetParms(IString& Inpline, IString& Group, IString& Variable, IString& Value)
    {
    temp1 = Inpline;
    temp1.upperCase();
    temp1.translate(":","  ");                        /* delete separators    */
    Group    = temp1.word(1);
    Variable = temp1.word(2);
    Value    = temp1.words(3);
    return;
    }

  void ChkStrValue(IString& Value, IString& Values)
    {
    int i; int found=0;
    for (i=1; i<=Values.numWords(); i++)
      {
      if (Values.word(i)==Value) {found=1;}
      }
    if (found==0) {Rcc = 20; OutMsg = "e-- illegal Value '"+Value+"'"; error(Rcc,MaxRc,Fails,OutMsg,MsgFile);}
    return;
    }
  void ChkIntValue(IString& Value, int val, int minval, int maxval)
    {
    if (val < minval || val > maxval) {Rcc = 20; OutMsg = "e-- illegal Value '"+Value+"'"; error(Rcc,MaxRc,Fails,OutMsg,MsgFile);}
    return;
    }

/*******************************************************************************
*                                 Functions                                    *
*******************************************************************************/
/*** get a new line from input file *******************************************/
  void get_line(ifstream& Inputfile, IString& Inpline, IString& Inpline_uc, IString& Inpline_uc_g, IString& CC)
    {
    char Inputline[4096];
    IString temp1;
    IString temp2;
    IString temp3;
    Inpline = "";                                     /* reset Inpline        */
    Inpline_uc = "";                                  /* reset Inpline_uc     */
    Inpline_uc_g = "";                                /* reset Inpline_uc_g   */
    Inputfile.getline(Inputline,sizeof(Inputline),'\n');
    temp1 = Inputline;
    temp1.strip();                      /* delete leading and trailing blancs */
     /* add next line, if a continue character (CC) is at the end of the line */
    while ((CC == temp1.subString(temp1.length(),1)) && (temp1 != ""))
      {
      temp2 = temp1.subString(1,temp1.length()-1);
      Inputfile.getline(Inputline,sizeof(Inputline),'\n');
      temp3 = Inputline;
      temp3.strip();
      temp1 = temp2 + temp3;
      }
    temp1.isPrintable();                              /* removes x00-x1F,x7F  */
    temp1.strip();                      /* delete leading and trailing blancs */
    Inpline = temp1;
    temp1.upperCase();                                /* convert to uppercase */
    Inpline_uc = temp1;
    temp1.translate("';","  ");                       /* delete separators    */
    Inpline_uc_g = temp1;
    Inpline_uc_g.strip();
    return;
    }

/*** error handling routine and write infos, warnings and errors to MsgFile ***/
void error(int& Rcc, int& MaxRc, int& Fails, IString& OutMsg, ofstream& MsgFile)
    {
    IString Rcct;
    int Rc;
    Rcct = itoa(Rcc,Rcct,10);                         /* Rcct = 2 digits      */
    Rcct = "0" + Rcct;
    Rcct = Rcct.subString(Rcct.length()-1);
    Rcct = Rcct+" "+OutMsg;
    MsgFile << Rcct << endl;
    if (Rcc>5) {Fails = Fails+1;}                     /* count only Rcc > 5   */
    if (Rcc>MaxRc) {MaxRc = Rcc;}                     /* MaxRc = highest Rcc  */
    if (MaxRc>29)                                     /* Terminate program    */
      {
      exit(MaxRc);
      }
    return;
    }

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

/*** checking for existing directories and files ******************************/
int DoesExist(IString& File)
  {
  int Rc = 0;
  FILE *fp;
  fp = fopen(File, "r");
  if (fp==0x0)
    {
    Rc = 30;

//  SetInfo(File+" does not exist");
//  msgBox.show(File+" does not exist",IMessageBox::warning);
    }
  fclose(fp);
  return Rc;
  }

/*** generate PRINT.PDF file and clear PRINT.FIL ******************************/
//int Pdfgen(IString& Prt_File, IString& Ps_File, IString& Pdf_File)
//{
//IString tmp1, tmp2;
//int Rc = 0;
//tmp1="txt2ps "+Prt_File;
//tmp2="ps2pdf "+Ps_File+" "+Pdf_File;
//rc = system(tmp1);
//rc = system(tmp2);
//rc = system("erase " + Prt_File);
//ofstream  PrtFile(Prt_File);
//PrtFile << "\x017" << "Q" << endl;
//return Rc;
//}

/*** sent PRINT.FIL to HP4L and clear PRINT.FIL *******************************/
//int printHP4L(IString& Prt_File)
//{
//IString tmp1;
//int Rc = 0;
//tmp1="print4l "+Prt_File;
//rc = system(tmp1);
//rc = system("erase " + Prt_File);
//ofstream  PrtFile(Prt_File);
//return Rc;
//}

/*** program end routine ******************************************************/
int ProgramEnd()
  {
  GetDate(Date);
  MsgFile << "-- " << Prog << " ended with closing window " << Date << endl;
  MsgFile.close();
  return 0;
  }

int M1SioWindow::ProgramEnd()
  {
  GetDate(Date);
  MsgFile << "-- : " << Prog << " ended rc = " << MaxRc << "  -- total fails = " << Fails << endl;
  MsgFile << "-- : " << Prog << " ended with ProgramEnd() function " << Date << endl;
  MsgFile.close();
  GetDate(Date);
  HistFile << Prog << "   ended  : " << Date << endl;
  HistFile << endl;
  IApplication::current().exit();
  return 0;
  }

/*******************************************************************************
*        Global Functions                                                      *
*******************************************************************************/
/*** Warning ******************************************************************/
int Warning(IString Info, IString Input)
  {
  int rc=0;
//Id1->info2.setBackgroundColor(IColor::white);
  Id1->info2.setText(Info);
//if (Id1->info2.text()==Input) {rc=0;}
  return rc;
  }

/*** MsgEnter *****************************************************************/
int MsgEnter(IString Info)
  {
  IString buf = "S";
  Id1->info.setText(Info);
//Id1->m1ef15.setText("");
//Id1->m1ef15.setBackgroundColor(IColor::white);
//Id1->m1ef15.enableDataUpdate();
//Id1->m1ef15.setFocus();
//buf=Id1->m1ef15.text();
//MsgFile << buf << endl;
//DELAY(5);
//Id1->m1ef15.setText("1");
//Id1->m1ef15.setBackgroundColor(IColor::paleGray);
//Id1->m1ef15.disableDataUpdate();
    while (buf=="-1")
////while (0==_kbhit())
      {
      buf=_getche();
      MsgFile << "Key=" << buf << "." << endl;
      DELAY(5);
      }
    buf = "T";
    MsgFile << "Key=" << buf << "." << endl;
////MsgFile << "Key=" << _getche() << "." << endl;
////Id1->info.setText(_getche()); DELAY(5);
////buf=_kbhit();
  Id1->info.setText(buf); DELAY(5);
  return 0;
  }

/*** SetInfo ******************************************************************/
int SetInfo(IString Info)
  {
  Id1->info.setText(Info);
//Id1->info.setText(Info); DELAY(5); Id1->info.setText("");
  return 0;
  }

/*** SetInfo2 *****************************************************************/
int SetInfo2(IString Info)
  {
  Id1->info2.setText(Info);
  return 0;
  }

/*** SetIbStat ****************************************************************/
  int SetIbStat(IString IbInfo, IString IbStat)
  {
  Id1->ibinfo.setText(IbInfo);
  Id1->ibstat.setText(IbStat);
  return 0;
  }

/*** Generate Headerline1 *****************************************************/
  IString Headerline1()
  {
  IString tmp1;
  GetDate(Date);
  tmp1="-- : This file was generated by " + Prog + " version " + Vers;
  return tmp1;
  }

