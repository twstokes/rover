import pygame
import socket
import sys
import time

pygame.init()
pygame.joystick.init()
clock = pygame.time.Clock()

UDP_IP = 'rover.tannerstokes.com'
UDP_PORT = 8000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
 
_joystick = pygame.joystick.Joystick(0)
_joystick.init()

def setLights(toggled):
	if toggled:
		values = [2, 1, 1, 0, 127, 0]
	else:
		values = [2, 1, 1, 0, 0, 0]

	sock.sendto(bytes(values), (UDP_IP, UDP_PORT))

def writeVal(id, val):
	print("ID: "+str(id))
	print("Val: "+str(val))

	values = [0, id, val]
	sock.sendto(bytes(values), (UDP_IP, UDP_PORT))

def writeSet(set):
	values = [1] + set
	sock.sendto(bytes(values), (UDP_IP, UDP_PORT))
	print(set)

def processAxis(axis, trim, limitLow, limitHigh, invert):
	rawVal = _joystick.get_axis(axis)

	# round
	axisVal = round(rawVal*100)

	# map to 0-90
	axisVal *= .9

	# make an integer
	axisVal = int(axisVal + 90)

	if invert:
		# invert axis
		axisVal = 180 - axisVal

	# trim
	axisVal += trim

	# safety limits
	if axisVal < limitLow:
		axisVal = limitLow
	
	if axisVal > limitHigh:
		axisVal = limitHigh

	return axisVal

def processThrottle(axis, trim, limitLow, limitHigh, invert):
	rawVal = _joystick.get_axis(axis)

	# round
	axisVal = round(rawVal*100)

	# make positive
	axisVal += 100

	# map to 0-90
	axisVal *= .9

	# make an integer
	axisVal = int(axisVal + 90)

	if invert:
		# invert axis
		axisVal = 180 - axisVal
	
	# trim
	axisVal += trim

	# safety limits
	if axisVal < limitLow:
		axisVal = limitLow
	
	if axisVal > limitHigh:
		axisVal = limitHigh

	return axisVal

# todo - make trim remap rather than cut so we still get full range

steeringVal = 90
throttleVal = 90
camPan = 90
camTilt = 90

lightsToggled = False

while True:
	for event in pygame.event.get():
		if event.type == pygame.JOYBUTTONDOWN:
			# "a" button
			if event.button == 11:
				setLights(lightsToggled)
				lightsToggled = not lightsToggled

		
		if event.type == pygame.JOYAXISMOTION:
			# steering
			if event.axis == 0:
				steeringVal = processAxis(0, 20, 50, 150, True)
			
			# throttle
			if event.axis == 5:
				throttleVal = processThrottle(5, 0, 0, 180, True)

			# reverse
			if event.axis == 2:
				throttleVal = processThrottle(2, 0, 0, 180, False)

			# cam pan
			if event.axis == 4:
				camPan = processAxis(4, 0, 50, 130, False)
			
			# cam tilt
			if event.axis == 3:
				camTilt = processAxis(3, 0, 50, 150, True)
		


	writeSet([steeringVal, throttleVal, camPan, camTilt])

	time.sleep(0.01)

	clock.tick(30)
