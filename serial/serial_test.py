import serial
import time

ser = serial.Serial('/dev/cu.usbmodem1431', baudrate=115200, timeout=1)

val = 0

while val <= 180:
    values = [255, 1, val]
    payload = bytes(values)

    ser.write(payload)

    result = ser.read(1)

    if len(result):
        success = ord(result)
    else:
        success = None

    if success != 0:
        print("Failed")
        print(success)
        print(val)
    # else:
        # print("Success!")
        # print(val)

    val += 1
    # time.sleep(.1)
    success = None

ser.close()
