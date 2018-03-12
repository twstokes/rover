import pygame
import socket
import sys
import time

pygame.init()
pygame.joystick.init()
clock = pygame.time.Clock()

UDP_IP = '192.168.1.141'
UDP_PORT = 8000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
 
_joystick = pygame.joystick.Joystick(0)
_joystick.init()

while True:
	for event in pygame.event.get():
		leftXAxis = _joystick.get_axis(0)
		# round
		leftXAxis = round(leftXAxis*100)
		# adjust to positive number
		leftXAxis += 100
		# map to 0-180
		leftXAxis *= .9
		# make an integer
		leftXAxis = int(leftXAxis)
 

	print(leftXAxis)

	values = [255, 1, leftXAxis]
	sock.sendto(bytes(values), (UDP_IP, UDP_PORT))
 
	clock.tick(30)