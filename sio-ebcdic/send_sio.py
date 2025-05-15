'''
recv_sio.py  - receive from serial port and translate IBM 5100 characters to
               UTF-8.
               Used to work directly with the IBM 5100, or with the 'sioxfer'
               PC part.
               Maybe to put on a monitor port as well.
'''

import serial
import io

sio_port = "COM1"

if __name__ == "__main__":

'''
    print("Write 'hello' to port "+sio_port)
    with serial.Serial() as ser:
        ser.baudrate = 9600
        ser.port = sio_port
        ser.open()
        ser.write(b'hello')

    print("Receive stuff")

'''
    ser = serial.serial_for_url('loop://', timeout=1)
    sio = io.TextIOWrapper(io.BufferedRWPair(ser, ser))

    sio.write(unicode("hello\n"))
    sio.flush() # it is buffering. required to get the data out *now*
    hello = sio.readline()
    print(hello == unicode("hello\n"))
