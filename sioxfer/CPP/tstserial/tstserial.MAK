#*******************************************************************************
#* SAMPLE PROJECT: sioxfer Makefile for Windows                                *
#*                                                                             *
#*******************************************************************************

# --- Tool defintions ---
ERASE=ERASE
GCPPC=ICC
GLINK=ICC
GRC=IRC
GRCV=IRCCNV
GIPFC=IPFC
GHCW=HCW
GIPFCVIEW=IVIEW
GIMAGE=IBMPCNV

# --- Tool flags ---
ICLCPPOPTS=/Gm+ /Gd+ /Gh+ /Ti+ /Fb+ /Q+
#ICLCPPOPTS=/Gm+ /Gd- /Gh- /Ti- /Fb- /Q-
GCPPFLAGS=$(LOCALOPTS) $(ICLCPPOPTS)
GCPPLFLAGS=/Tdp /B"/pmtype:pm /debug /browse"
GPERFOBJ=cppwpa3.obj
GRCFLAGS=-DIC_WIN
GRCVFLAGS=
GIPFCFLAGS=/q
GHCWFLAGS=/c /e
GIMAGEFLAGS=

# --- Body ---
all:  tstserial.exe

tstserial.exe:  rserial.obj usbsio.obj tstserial.obj
      $(GLINK) $(GCPPLFLAGS) $(GCPPFLAGS) /Fe"tstserial.exe" \
      rserial.obj usbsio.obj tstserial.obj $(GPERFOBJ) 

rserial.obj:  rserial.cpp 
      $(GCPPC) /C+ $(GCPPFLAGS) rserial.cpp

usbsio.obj:  usbsio.cpp 
      $(GCPPC) /C+ $(GCPPFLAGS) usbsio.cpp

tstserial.obj:  tstserial.cpp tstserial.h
      $(GCPPC) /C+ $(GCPPFLAGS) tstserial.cpp





# --- Cleanup ---
clean:
        -$(ERASE) tstserial.exe
        -$(ERASE) tstserial.obj
        -$(ERASE) tstserial.res

