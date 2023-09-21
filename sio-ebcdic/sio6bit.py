"""
Custom Python Character Mapping Codec sio6bit - 13.09.2023 Werner Schollenberger
   -- Codec for IBM 5110 6-bit serial line encoding to UTF-8 and vice versa
   -- This 6-bit code uses shift_on/off characters to extend the number of
      characters being supported. So this codec is stateful.
   -- Note that the IBM 5110 transmits the bytes in reversed order when using
      6-bit mode. Therefore the function 'bit_reverse' has been added to this
      module that

   -- normally stateless codec modules are generated  with gencodec.py using
      a text file, e.g. 'temp/cp1141.txt'
   -- see:  https://github.com/python/cpython/tree/main/Tools/unicode

You want to check statefull codex - e.g. Baudot encode
https://github.com/xvillaneau/python-baudot/


"""
# Ensure the generated codec works with Python 2.6+.
from __future__ import unicode_literals

import codecs

shift_on  = 0x0E  # EBCDIC code
shift_off = 0x3E  # EBCDIC code
shift_val = 64

# bit_reverse() reverses the lower 6 bits in order, it takes a bytearray
def bit_reverse(in_array):             # type bytearray
    #out_array = ['00']*len(barray)  # the output again is a list of 2 char strings
    out_array = bytearray()
    for ichr in in_array:
        out = 0xff
        if (ichr & 0xC0) == 0:
            out = (ichr & 0x20 > 0) + (ichr & 0x10 > 0)*2 + (ichr & 0x08 > 0)*4 + (ichr & 0x04 > 0)*8 + (ichr & 0x02 > 0)*16 + (ichr & 0x01 > 0)*32
        else:
            print("*Error* in converting no ",i," hex: ",hex(ichr), "dec: ",ichr)
        ## print(i," Result: ",out, " hex:", hex(out))
        out_array.extend([out])
    return out_array

# Codec APIs
class Codec(codecs.Codec):
    def encode(self, text, errors='strict'):
        return codecs.charmap_encode(text, errors, encoding_table)

    def decode(self, data, errors='strict'):
        # data is a bytearray or something similar
        # process shift_on / shift_off by incrementing the char by shift_val
        shift_status = False
        out_data = bytearray(len(data))
        out_idx = 0
        # print("Before processing shift chars: ", data)
        for ibyte in data:
            if  ibyte == shift_on:
                # print("Shift ON  at position",out_idx)
                shift_status = True
            elif ibyte == shift_off:
                # print("Shift OFF at position",out_idx)
                shift_status = False
            else:
                if shift_status:
                    # print("Shifted char at position", out_idx, " Value:", hex(ibyte + shift_val))
                    out_data[out_idx] = ibyte + shift_val
                else:
                    out_data[out_idx] = ibyte
                out_idx += 1
        out_data = out_data[:out_idx]
        # print("After processing shift chars:  ", out_data)

        return codecs.charmap_decode(out_data, errors, decoding_table)


class IncrementalEncoder(codecs.IncrementalEncoder):
    def encode(self, text, final=False):
        return codecs.charmap_encode(text, self.errors, encoding_table)[0]


class IncrementalDecoder(codecs.IncrementalDecoder):
    def decode(self, data, final=False):
        return codecs.charmap_decode(data, self.errors, decoding_table)[0]


class StreamWriter(Codec, codecs.StreamWriter):
    pass


class StreamReader(Codec, codecs.StreamReader):
    pass


# encodings module API
def getregentry():
    return codecs.CodecInfo(
        name='sio6bit',
        encode=Codec().encode,
        decode=Codec().decode,
        incrementalencoder=IncrementalEncoder,
        incrementaldecoder=IncrementalDecoder,
        streamreader=StreamReader,
        streamwriter=StreamWriter,
    )


# Decoding Table
decoding_table = (
    ' '         # 0x00 -> Space
    '1'         # 0x01
    '2'         # 0x02
    '3'         # 0x03
    '4'         # 0x04
    '5'         # 0x05
    '6'         # 0x06
    '7'         # 0x07
    '8'         # 0x08
    '9'         # 0x09
    '0'         # 0x0A
    ']'         # 0x0B
    '\x03'      # 0x0C -> Tilde over Circumflex
    '\x03'      # 0x0D -> Zero over Backslash
    '\x03'      # 0x0E -> Delta over Bar
    '\x03'      # 0x0F -> T over Bullet
    '@'         # 0x10 - > AT Symbol / Arrow Left
    '/'         # 0x11
    'S'         # 0x12
    'T'         # 0x13
    'U'         # 0x14
    'V'         # 0x15
    'W'         # 0x16
    'X'         # 0x17
    'Y'         # 0x18
    'Z'         # 0x19
    '&'         # 0x1A
    "'"         # 0x1B
    '\x03'      # 0x1C
    '\x03'      # 0x1D
    '\x03'      # 0x1E -> UC (Upper Shift)
    '\x03'      # 0x1F
    '+'         # 0x20
    'J'         # 0x21
    'K'         # 0x22
    'L'         # 0x23
    'M'         # 0x24
    'N'         # 0x25
    'O'         # 0x26
    'P'         # 0x27
    'Q'         # 0x28
    'R'         # 0x29
    '}'         # 0x2A
    '['         # 0x2B
    '\x03'      # 0x2C
    '\n'        # 0x2D -> NL (New Line)
    '\x03'      # 0x2E
    '\x03'      # 0x2F
    'x'         # 0x30 -> APL cross
    'A'         # 0x31
    'B'         # 0x32
    'C'         # 0x33
    'D'         # 0x34
    'E'         # 0x35
    'F'         # 0x36
    'G'         # 0x37
    'H'         # 0x38
    'I'         # 0x39
    '{'         # 0x3A
    ','         # 0x3B
    '\x00'      # 0x3C
    '\x00'      # 0x3D
    '\x00'      # 0x3E -> LC (Lower Shift)
    '\x00'      # 0x3F
    ' '         # 0x40 -> SPACE
    '"'         # 0x41 -> Double Quote
    '-'         # 0x42 -> Minus
    '<'         # 0x43 -> Less
    '\x03'      # 0x44 -> Less equal
    '='         # 0x45 -> Equal
    '\x03'      # 0x46 -> Greater equal
    '>'         # 0x47 -> Greater
    '\x03'      # 0x48 -> Not equal
    'v'         # 0x49 -> APL check down
    '^'         # 0x4A -> Accent Circumflex
    ')'         # 0x4B -> Closing bracket
    '\x03'      # 0x4C ->
    '\x03'      # 0x4D ->
    '\x03'      # 0x4E ->
    '\x03'      # 0x4F ->
    '\x03'      # 0x50 -> Arrow right / Cent sign
    '\\'        # 0x51 -> Backslash / Question Mark
    '\x00'      # 0x52 ->  / Capital S - Z
    '\x00'      # 0x53 ->
    '\x00'      # 0x54 ->
    '\x00'      # 0x55 ->
    '\x00'      # 0x56 ->
    '\x00'      # 0x57 ->
    '\x00'      # 0x58 ->
    '\x00'      # 0x59 ->
    '\x00'      # 0x5A ->
    ';'         # 0x5B -> Semi-Colon
    '\x00'      # 0x5C ->
    '\x00'      # 0x5D ->
    '\x00'      # 0x5E ->
    '\x00'      # 0x5F ->
    '-'         # 0x60 ->
    '°'         # 0x61 ->
    '\''        # 0x62 ->
    '\x00'      # 0x63 ->
    '\x00'      # 0x64 ->
    '\x00'      # 0x65 ->
    '\x00'      # 0x66 ->
    '*'         # 0x67 -> Star
    '?'         # 0x68 -> Question Mark
    '\x00'      # 0x69 ->
    '\x00'      # 0x6A ->
    ')'         # 0x6B ->
    '\x00'      # 0x6C ->
    '\x00'      # 0x6D ->
    '\x00'      # 0x6E ->
    '\x00'      # 0x6F ->
    ':'         # 0x70 ->
    '\x00'      # 0x71 ->
    '\x00'      # 0x72 ->
    '\x00'      # 0x73 ->
    '\x00'      # 0x74 ->
    '\x00'      # 0x75 ->
    '\x00'      # 0x76 ->
    '\x00'      # 0x77 ->
    '\x00'      # 0x78 ->
    '\x00'      # 0x79 ->
    '\x00'      # 0x7A ->
    ':'         # 0x7B -> Colon
    '\x00'      # 0x7C ->
    "\x00"      # 0x7D ->
    '\x00'      # 0x7E ->
    '\x00'      # 0x7F ->
    )


# Encoding table
encoding_table = codecs.charmap_build(decoding_table)
