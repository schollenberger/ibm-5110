# python
#
# Read file with Hex codes from serial output via SIO 6 bit from IBM 5100
#
import sys
import sio_6bit_code

# ** here we start

if __name__ == "__main__":

    fn = "./data_examples/hex-2-sio6bit-short.txt"
    argfn = ""

    print("Argument List:",str(sys.argv))

    if len(sys.argv) > 1:
       fn = sys.argv[1]
       print("File from command line:",fn)
    else:
       print("No filename in command line using default:",fn)

    print("Filename = ",fn)

    f = open(fn, "r")
    content = f.read()
    f.close()

    sio6bit_codepage = sio_6bit_code.CodeTable()

    hex_content = content.split()
    outstr = sio6bit_codepage.siohex_to_ascii(hex_content)

    esc_str = chr(3)
    o_width = 16

    sh_offset = 0
    o_sep   = "  "
    hex_idx = 0

    i = 0
    while i < len(outstr):
       if i+o_width < len(outstr):
          print(" *  ", outstr[i:i+o_width].replace('\n',esc_str), " - ", end="")
          for k in range(o_width):
             hxstr = hex_content[hex_idx]
             if int(hxstr,16) == sio_6bit_code.shift_on:
                o_sep = " *"
                hex_idx += 1
             elif int(hxstr,16) == sio_6bit_code.shift_off:
                o_sep = "  "
                hex_idx += 1
             hxstr = hex_content[hex_idx]
             print(o_sep + hxstr, end="")
             hex_idx += 1
          print()
       else:
          print("Last line:")
          print(" *  ", outstr[i:].replace('\n',esc_str), " - ", end="")

       i = i + o_width

    print()
    print("Final:")
    print(outstr)
    print()
    print ("Done.")
