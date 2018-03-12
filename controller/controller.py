import pygame
import sys
import time

pygame.init()
pygame.joystick.init()
clock = pygame.time.Clock()
 
print(pygame.joystick.get_count())

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

 
	clock.tick(30)