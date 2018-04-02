# Rover

### Current status:
The vehicle can be controlled remotely via UDP

* A Python script sends input from an Xbox One controller to an on-board Raspberry Pi via UDP packet.
* UDP packets are read by a Go server that sends the data serially to the on-board MCU.
* A Python script running on the on-board Raspberry Pi serves an MJPEG of the Pi camera video

### Notes:
* Data is expected to be sent continously. If no data is received via UDP for one second, the server resets all servos.