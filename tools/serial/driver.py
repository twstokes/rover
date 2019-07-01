import serial
import time

def setServo(id, val):
    payload = createPayload(0, [id, val, 0, 0, 0, 0, 0])
    writeToRover(payload)

def createPayload(command, data):
    return bytes([command] + data)

def writeToRover(payload):

    print("Writing to Rover: {}".format(payload))
    ser.write(payload)

def calculateChecksum(payload):
    sum = 0

    for byte in bytearray(payload):
        sum += byte

    return sum & 255

ser = serial.Serial('/dev/ttyACM0', 115200);

# test individual servos

# servo ID 1
setServo(1, 130)
time.sleep(2)
setServo(1, 90)
time.sleep(2)

ser.close()
