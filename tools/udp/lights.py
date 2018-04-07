# NOTE - Python 3 only! bytes() is much different in Python 2.x

import socket
import time
import random

# UDP_IP = '192.168.1.141'
UDP_IP = '127.0.0.1'
UDP_PORT = 8000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    c = [random.randint(1, 10), random.randint(1, 10), random.randint(1, 10)]
    for x in range(1, 9):
        values = [1, 1, 1, x] + c
        sock.sendto(bytes(values), (UDP_IP, UDP_PORT))
        time.sleep(0.01)

# for x in range(1, 9):
#     values = [253, x, 0, 0, 0]
#     sock.sendto(bytes(values), (UDP_IP, UDP_PORT))
#     time.sleep(0.01)

# setting an entire row

# command = 1 # set lights
# lid = 1 # id 1 (first light)
# lmode = 1 # light mode 0 is single light, light mode 1 is an entire row

# values = [command, lid, lmode, 0, 127, 0]
# sock.sendto(bytes(values), (UDP_IP, UDP_PORT))

# servo
# values = [0, 1, 90]
# sock.sendto(bytes(values), (UDP_IP, UDP_PORT))