# python
#
# Read file with Hex codes from serial output via SIO 6 bit from IBM 5100
# assume reverse bit order
#
import sys
import sio6bit


# ** here we start

if __name__ == "__main__":

    fn = "./data_examples/hex-2-sio6bit-short.txt"
    argfn = ""

    # print("Argument List:",str(sys.argv))

    if len(sys.argv) > 1:
       fn = sys.argv[1]
       print("File from command line:",fn)
    else:
       print("No filename in command line using default:",fn)

    # print("Filename = ",fn)

    with open(fn, "r") as f:
        content = f.read()

    # Convert hex string to array of single hex strings
    hex_content = content.split()
    #print("Hex content of file:")
    #print(hex_content)
    #print("--------")

    # Convert to bytearray  - this is what Codecs like
    hex_bytes = bytearray()
    for hex_chr in hex_content: hex_bytes.extend([int(hex_chr,16)])
    #print("Bytearray:")
    #print(hex_bytes)
    #print("--------")

    # We need to reverst the lower 6 bit for IBM 5100 SIO stream
    out_content = sio6bit.bit_reverse(hex_bytes)
    #print("Reversed bits:")
    #print(out_content)
    #print("--------")

    # Let's decode the IBM 5110 6-bit charset - see doc. on conversion chart
    mycodec = sio6bit.Codec()
    outstr = mycodec.decode(out_content)[0]
    print()
    print("Decoded string:")
    print("--------")
    print(outstr)
    print("--------")

    # now print decoded string along with original hex input
    # We need to re-implement the shift state logic to suppress shift codes
    # in hex input and show which characters have been shifted
    
    print()
    print(" *   UTF-8 converted   -   Input Hex Strings  *nn -> shifted characters")
    print(" *   ---------------   -   --------------------------------------------")

    esc_chr = chr(3)  # Escape new line chars with UTF-8(0x13)
    o_width = 16      # Number of chars per line in output

    sh_offset = 0     # initial shift offset
    o_sep   = "  "    # initial Hex separator (non-shifted)

    i = 0             # temp loop vars
    hex_idx = 0

    while i < len(outstr):
        if i+o_width < len(outstr):
            print(" *  ", outstr[i:i+o_width].replace('\n',esc_chr), " - ", end="")
            for k in range(o_width):
                hxstr = hex_content[hex_idx]
#                if int(hxstr,16) == sio_6bit_code.shift_on:
                if int(hxstr,16) == sio6bit.bit_reverse([sio6bit.shift_on])[0]:
                    o_sep = " *"
                    hex_idx += 1
#               elif int(hxstr,16) == sio_6bit_code.shift_off:
                elif int(hxstr,16) == sio6bit.bit_reverse([sio6bit.shift_off])[0]:
                    o_sep = "  "
                    hex_idx += 1
                hxstr = hex_content[hex_idx]
                print(o_sep + hxstr, end="")
                hex_idx += 1
            print()
        else:  # Last line is a bit different
            format_string = '{0:'+str(o_width)+'}'
            print(" *  ", format_string.format(outstr[i:].replace('\n',esc_chr)), " - ", end="")
            for hxstr in hex_content[hex_idx:]:
                if int(hxstr,16) == sio6bit.bit_reverse([sio6bit.shift_on])[0]:
                    o_sep = " *"
                # elif int(hxstr,16) == sio_6bit_code.shift_off:
                elif int(hxstr,16) == sio6bit.bit_reverse([sio6bit.shift_off])[0]:
                    o_sep = "  "
                else:
                    print(o_sep + hxstr, end="")
        i = i + o_width

    print()
    print()
    print ("Done.")
