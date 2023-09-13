#
# Test sio6bit_code module
#

import sys
import codecs
import ebcdic   # must be installed using pip (special package)

"""
import sio_6bit_code

#for i in range(64):
#   print(" - ", str(i), " - ", chr(i).encode('unicode_escape'), " - ", chr(i))


sio6bit_codepage = sio_6bit_code.CodeTable()

hex_content = "14  14  20  14  00  25  2B  09  00 2d"  # sio-6it  "0010 REM"
outstr = sio6bit_codepage.siohex_to_ascii(hex_content.split())

print(outstr)

sio6bit_codepage.print_table()
"""

# Print file testing out 8 uncode characters using the function chr().
#
# Usage:  python testdummy.py ; cat data_examples/unicode-test.txt
#

def exists_encoding(enc):
    try:
        codecs.lookup(enc)
    except LookupError:
        return False
    return True


def print_chartable(f, ustart, uend, ucount, encoding="utf-8"):
    if exists_encoding(encoding):
        f.write("Characters from codepage <"+encoding+">:\n")
        i = 0
        for iord in range(ustart,uend):
            if encoding == "" or encoding.lower() == "utf-8":
                ichar = chr(iord)
            else:
                ichar=(iord).to_bytes(1, byteorder='big').decode(encoding,'replace')
                # alternative
                #ibyte=(iord).to_bytes(1, byteorder='big')
                #ichar=codecs.decode(ibyte,encoding)

            if i%ucount == 0:  f.write("\n\n*  "+f'{iord:x}'+": ")
            f.write(ichar)
            if i%ucount == 0 or i%ucount < ucount -1:  f.write(" - ")
            i += 1

        f.write("\n\n")
    else:
        f.write("Codec <"+encoding+"> doesn't exist in this python environment\n")


"""
fn = "data_examples/unicode-test.txt"
print("Test unicode characters - writing to file ",fn)
f = open(fn,"w")

i=0
ucount = 16

ustart = 32
uend = 256

#ustart = 9675
##ustart = 8710
##uend = ustart + 256

print_chartable(f, ustart, uend, ucount,"utf-8")

f.write("\nDone.\n")
f.close

print("Done.")
"""

# Access characters from code page by number and print them out in UTF-8
# for Code pages in Python see: https://docs.python.org/2.3/lib/node130.html


f = sys.stdout
print_chartable(f, 32,256,16)
print_chartable(f, 0x20,128,16,"ascii")
print_chartable(f, 0x20,256,16,"iso-8859-1")  # ISO Latin_1 Western Europe
print_chartable(f, 0x40,256,16,"cp037")       # IBM037 IBM039 Englisch
print_chartable(f, 0x40,256,16,"cp1141")          # EBCDIC German

#print_chartable(f, 0,256,16,"cp907")          # 8-Bid modified / extended ASCII
#print_chartable(f, 0x40,256,16,"cp500")       # EBCDIC Western Europe
##print_chartable(f, 0x0,256,16,"hex")  # ISO Latin_1 Western Europe
##print_chartable(f, 0x0,256,16,"base64")  # ISO Latin_1 Western Europe

f.write("Done.\n")
f.close
