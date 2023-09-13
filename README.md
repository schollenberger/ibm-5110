# IBM 5110

This repository contains projects (code), memos and docs that I've created
when working with the IBM-5110 computer.
The IBM 5110  is a successor of the IBM 5100, IBM's first "portable" and
personal computer. Both machines can be programmed in APL and BASIC but the BASIC
although the interpreter of the IBM 5110 is more advanced and you can attach
8" floppy drives to the IBM 5110. Therefore, the code here is for the IBM 5110.

The IBM machine types 5100 and 5110 (as well as the 5120) were predecessors of
the IBM 5150 the famous IBM PC but looked completely different.
The IBM PC had a totally different system architecture (Intel x86 processor,
expansion slots, no built-in monitor) and started a new are in computing.

## sio-ebcdic

This project is written in Python and is about character conversion between
the IBM 5110 serial line and a PC. It runs on the PC.

Like IBM's mainframes, the IBM-5110 used EBCDIC character encoding internally.
EBCDIC code page 283 includes the APL characters preserving the basic Latin
letters (https://en.wikipedia.org/wiki/Digital_encoding_of_APL_symbols).

Python support EBCDIC code pages but not the pages containing APL characters.

When transmitting and receiving over the serial line, the IBM 5110 does some
character code translation.
For 7-bit transmission it translates to ASCII, but in 6-bit transmission it
uses a different translation table.

This project deals with converting characters that go over a IBM-5110 serial
line, so that they an be read and processed on an ASCII based PC.

### sio_6bit_code.py

First attempt to cover 6-bit code translation in a class. (## Needs to be
rewised to follow the encoding / decoding patterns in python, like the module
'ebcdic' ##)

### read_sio_6bit_hex.py

Decodes hex bytes in a string using the sio_6bit_code module. Input can be
the Hex output of a terminal program that records what the IBM 5110 sends.


### testdummy.py

Some code snipplets to refresh my memory.
