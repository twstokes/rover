
### About

This uses a BLE library that's basically a wrapper for Linux and macOS' Bluetooth stack.

### Per Gatt README:

`sudo hciconfig hci0 down` # or whatever hci device you want to use

If you have BlueZ 5.14+ (or aren't sure), stop the built-in bluetooth server, which interferes with gatt, e.g.:

`sudo service bluetooth stop`

### Running:

By default we have to run as a superuser. The GOPATH may require being set:

`sudo GOPATH=/home/pi/dev/go ./fence`
