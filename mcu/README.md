### Hardware
Arduino Pro Micro Atmega32U4 5V 16Mhz (HiLetgo) 

Note: Though this has "Pro Micro" on the board, it's known as the Leonardo. The SparkFun brands must be the true "Pro Micro". HiLetgo's product page for this says to use Arduino Leonardo. Product ASIN: B01MTU9GOB

### Notes
During development, this board was temporarily bricked via a bad firmware upload.

####How to reset:
- Use the Arduino software and select Arduino Leonardo
- Choose a simple sketch (like Blink) so that it can compile and upload quickly (note: on this board the LED to blink can be pin 17)
- Jumper gnd to rst first time (Windows will chime when this happens and the device will appear in Device Manager)
- Take note of the port
- Set the Arduino software to upload to that port. At this time, the device has probably disconnected but it will try to upload.
- Jumper gnd and rst again so that the board reconnects to the machine and the firmware is uploaded quickly