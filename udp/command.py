import socket
import time

UDP_IP = '192.168.1.141'
UDP_PORT = 8000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

servoId = int(input("ID: "))
val = int(input("Degree: "))

values = [255, servoId, val]
sock.sendto(bytes(values), (UDP_IP, UDP_PORT))
