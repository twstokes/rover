import serial

ser = serial.Serial('/dev/tty.SLAB_USBtoUART')  # open serial port

payload = [1, 180]

for byte in payload:
    ser.write(byte.to_bytes(8, 'little'))

ser.write(b',')

success = ord(ser.read())

if success == 1:
    print("Success")
else:
    print("Failure")

ser.close()