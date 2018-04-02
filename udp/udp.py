import socket
import time

UDP_IP = '192.168.1.141'
UDP_PORT = 8000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

val = 60

while val <= 90:
    values = [255, 1, val]

    sock.sendto(bytes(values), (UDP_IP, UDP_PORT))

    val += 1
    time.sleep(1)

