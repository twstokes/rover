## Rover Go library
### `cmd/udp` - a UDP server for controlling the rover
- Run `cmd -h` to see all possible flags.

The UDP server runs on the on-board Raspberry Pi and by default listens on port 8000 for payloads.

#### Setting a servo in Python 3:

```
import socket

UDP_IP = [RPi IP address here]
UDP_PORT = 8000

# command zero is setting a servo
command = 0

# id 1 is the first servo on the MCU
servoId = 1

# 90 degrees
servoVal = 90

payload = [command, servoId, servoVal]

# the UDP server expects a constant data flow
while True:
	sock.sendto(bytes(payload), (UDP_IP, UDP_PORT))
```


### Important:
- The `bytes` built-in for Python 3 is much different than the version in Python 2. Data sent to the UDP server is expected to be raw bytes and not characters, so we use Python 3 for the above example.
- The UDP server expects a constant flow of payloads. In the event that this flow stops for more than the duration defined by `safeWait` (e.g. possibly due to a failed network connection), it should stop the rover if in motion.
- The payload format and size is dependent on the command and doesn't have to match the `MAX_PAYLOAD` constant set by the MCU. The `mcu` package will handle any differences and prevent a payload too large.