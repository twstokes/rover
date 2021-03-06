### Hardware

Arduino Pro Micro Atmega32U4 5V 16Mhz (HiLetgo)

Note: Though this has "Pro Micro" on the board, it's known as the Leonardo. The SparkFun brands must be the true "Pro Micro". HiLetgo's product page for this says to use Arduino Leonardo. Product ASIN: B01MTU9GOB

### Troubleshooting

#### Serial output

Reading the serial output from the MCU is as simple as `pio device monitor`

#### Ubuntu 18.x fails to upload to MCU

If you see something similar to `Writing | #avrdude: butterfly_recv(): programmer is not responding`, it could be the ModemManager service interfering.

- `sudo systemctl stop ModemManager.service`
- `sudo systemctl disable ModemManager.service`

#### How to reset the MCU:

- Use the Arduino software and select Arduino Leonardo
- Choose a simple sketch (like Blink) so that it can compile and upload quickly (note: on this board the LED to blink can be pin 17)
- Jumper gnd to rst first time (Windows will chime when this happens and the device will appear in Device Manager)
- Take note of the port
- Set the Arduino software to upload to that port. At this time, the device has probably disconnected but it will try to upload.
- Jumper gnd and rst again so that the board reconnects to the machine and the firmware is uploaded quickly
