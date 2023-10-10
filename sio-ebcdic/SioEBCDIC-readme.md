# Serial IO EBCDIC readme

  While the basic routines in this directory are described in the readme file
  one directory level above, this readme captures technical details of the code.

## Links:

 - Stateful encoder example:
   Baudot encode:  https://github.com/xvillaneau/python-baudot/

 - Serial Port support 'pySerial':
   https://pypi.org/project/pyserial/
   https://pyserial.readthedocs.io/en/latest/pyserial.html
   https://github.com/pyserial/pyserial


## Encodings

  IBM 5110 is using EBCDIC.

  What you may need is the module 'ebcdic' which has to be installed:

     pip install ebcdic

     
## Usage of pySerial

  Test code to send and receive over serial lines on windows machines leverage
  the libary 'pySerial'.

  Install: pip install pyserial

  Docs and infos see links above.

  We needed support for non-blocking read operations as well for event driven
  processing.

  Note that you cannot access the Windows COM ports in a Windows bash shell !!
  Run these programs in a windows shell.

### pySerial Tools

  List of COM ports:   python -m serial.tools.list_ports

  Mini-Terminal:
