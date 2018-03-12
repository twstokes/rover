import serial
import time

ser = serial.Serial('/dev/cu.usbmodem1431', baudrate=115200, timeout=100)  # open serial port

# ser = serial.Serial('/dev/cu.usbmodem1431')  # open serial port
time.sleep(2)

val = 0

while val < 180:
    # servo = input("ID: ")
    # val = input("Value: ")

    # payload = [int(servo), int(val)]
    payload = [1, val]

    for byte in payload:
        ser.write(byte.to_bytes(1, 'little'))

    # terminator
    ser.write(','.encode(encoding='ascii'))

    success = ord(ser.read())

    if success == 1:
        # print("Success")
        pass
    else:
        print("Failure")
        print(val)
    
    val += 1

# while True:
    # print(ser.readline())

ser.close()
