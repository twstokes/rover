package main

import (
	"flag"
	"log"
	"net"
	"time"

	"github.com/twstokes/rover/go/pkg/mcu"
)

var (
	serialPort = flag.String("serialPort", "/dev/ttyACM0", "serial port") // default port on RPi
	baudRate   = flag.Int("baud", 115200, "serial baud rate")
	udpPort    = flag.Int("udpPort", 8000, "udp port")
	servos     = flag.Int("servos", 4, "number of servos")
	leds       = flag.Int("leds", 8, "number of leds")
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	flag.Parse()

	// connect to the MCU
	m, err := mcu.Connect(*serialPort, *baudRate, *servos, *leds)
	if err != nil {
		panic(err)
	}

	// open up a UDP port to receive data
	addr := net.UDPAddr{
		Port: *udpPort,
	}

	u, err := net.ListenUDP("udp", &addr)
	if err != nil {
		panic(err)
	}

	// set our app config
	c := &config{
		safeWait: time.Second,
	}

	// run a UDP server that sends data to the MCU
	s := udpServer{c, m, u}
	defer s.stop()
	s.start()
}
