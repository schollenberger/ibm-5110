# python
#
# Implements the IBM 5110 Serial IO translation capability using 6-bit (sio6)
#
# For now it supports:
#  - sio_hex_to_ascii(string):
#        Decodes of hex array  (["00", "20",  "2d", ...])" according to the
#        SIO6Bit translation table and returns an ASCII string
#

shift_on  = 28  # 0x1C
shift_off = 31  # 0x1F
shift_val = 64

class CodeTable:
    sio6bit_table = ["."] * 128
    sio6bit_table[0x00] = " "
    sio6bit_table[0x2d] = "\n"

    sio6bit_table[0x01+shift_val] = "-"
    sio6bit_table[0x11+shift_val] = "'"
    sio6bit_table[0x28+shift_val] = "="

    sio6bit_table[0x34+shift_val] = ")"
    sio6bit_table[0x35+shift_val] = "("
    sio6bit_table[0x36+shift_val] = ";"

    sio6bit_table[0x14] = "0"
    sio6bit_table[0x20] = "1"
    sio6bit_table[0x10] = "2"
    sio6bit_table[0x30] = "3"
    sio6bit_table[0x08] = "4"
    sio6bit_table[0x28] = "5"
    sio6bit_table[0x18] = "6"
    sio6bit_table[0x38] = "7"
    sio6bit_table[0x04] = "8"
    sio6bit_table[0x24] = "9"
    sio6bit_table[0x23] = "A"
    sio6bit_table[0x13] = "B"
    sio6bit_table[0x33] = "C"
    sio6bit_table[0x0b] = "D"
    sio6bit_table[0x2b] = "E"
    sio6bit_table[0x1b] = "F"
    sio6bit_table[0x3b] = "G"
    sio6bit_table[0x07] = "H"
    sio6bit_table[0x27] = "I"
    sio6bit_table[0x21] = "J"
    sio6bit_table[0x11] = "K"
    sio6bit_table[0x31] = "L"
    sio6bit_table[0x09] = "M"
    sio6bit_table[0x29] = "N"
    sio6bit_table[0x19] = "O"
    sio6bit_table[0x39] = "P"
    sio6bit_table[0x39+shift_val] = "*"
    sio6bit_table[0x05] = "Q"
    sio6bit_table[0x25] = "R"
    sio6bit_table[0x12] = "S"
    sio6bit_table[0x32] = "T"
    sio6bit_table[0x0a] = "U"
    sio6bit_table[0x2a] = "V"
    sio6bit_table[0x1a] = "W"
    sio6bit_table[0x3a] = "X"
    sio6bit_table[0x06] = "Y"
    sio6bit_table[0x26] = "Z"

    sio6bit_table[0x34] = "."
    sio6bit_table[0x36] = ","

    #sio6bit_table[0x] = ""

    def siohex_to_ascii(self, hex_content):
        sh_offset = 0
        outstr = ""
        for hxstr in hex_content:
            x = int(hxstr,16)
        #    print(hxstr,str(x), sio6bit_table[x])
            if x == shift_on:
        #        print("Shift ON  at char pos: ",str(len(outstr)))
                sh_offset = shift_val
            elif x == shift_off:
        #      print("Shift OFF at char pos: ",str(len(outstr)))
                sh_offset = 0
            else:
                outstr = outstr + CodeTable.sio6bit_table[x+sh_offset]
        #        print(sio6bit_table[x+sh_offset],end="")

        return outstr

    def _print_table_row(self,row_no):
        k = row_no*16
        for i in range(16):
            char = CodeTable.sio6bit_table[k+i]
            if k+i == 0x2d:
                print("\\n",end="")
            elif k+i == shift_on:
                print("\\^",end="")
            elif k+i == shift_off:
                print("\\v",end="")
            else:
                print(char +" ",end="")
        print()

    def print_table(self):
        print("Normal:")
        print("     0 1 2 3 4 5 6 7 8 9 a b c d e f")
        for i in range(4):
            print(" "+str(i)+" : ",end="")
            CodeTable._print_table_row(self,i)
        print()
        print("Shifted:")
        print("     0 1 2 3 4 5 6 7 8 9 a b c d e f")
        for i in range(4):
            print(" "+str(i)+" : ",end="")
            CodeTable._print_table_row(self,i+4)
        print()

if __name__ == "__main__":

    sio6bit_codepage = CodeTable()

    sio6bit_codepage.print_table()
    pass
