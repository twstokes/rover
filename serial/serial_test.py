import serial

ser = serial.Serial('/dev/tty.SLAB_USBtoUART')  # open serial port

servo = input("ID: ")
val = input("Value: ")

payload = [int(servo), int(val)]
#payload = [1, 50]

for byte in payload:
    ser.write(byte.to_bytes(1, 'little'))

ser.write(','.encode(encoding='ascii'))

success = ord(ser.read())

if success == 1:
    print("Success")
else:
    print("Failure")

# while True:
    # print(ser.readline())

ser.close()