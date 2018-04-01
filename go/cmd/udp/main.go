package main

import (
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"time"

	"github.com/twstokes/rover/go/mcu"
)

var (
	serialPort = flag.String("serialPort", "/dev/ttyACM0", "serial port")
	baudRate   = flag.Int("baud", 115200, "serial baud rate")
	udpPort    = flag.Int("udpPort", 8000, "udp port")
	servos     = flag.Int("servos", 4, "number of servos")
)

type config struct {
	safeWait time.Duration // duration of not receiving UDP data before resetting servos
}

type udpServer struct {
	config *config
	mcu    *mcu.Controller
	udp    *net.UDPConn
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	flag.Parse()

	// connect to the MCU
	m, err := mcu.Connect(*serialPort, *baudRate, *servos)
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

	s := udpServer{c, m, u}
	defer s.stop()
	s.start()
}

func (u *udpServer) start() {
	stopchan := make(chan os.Signal, 1)
	signal.Notify(stopchan, os.Interrupt)

	// create our safety timer
	t := time.NewTimer(u.config.safeWait)

	for {
		select {
		case <-t.C:
			log.Print("Safety timeout reached.")
			u.mcu.ResetServos()
			t.Reset(u.config.safeWait)
		case <-stopchan:
			log.Print("Stopping...")
			return
		default:
			// timeout for reading new data
			u.udp.SetReadDeadline(time.Now().Add(time.Millisecond * 10))

			buf := make([]byte, 3)
			n, _, err := u.udp.ReadFrom(buf)
			if err != nil {
				// may be a timeout
				continue
			}

			// expected three bytes
			if n == 3 {
				if buf[0] != 255 {
					log.Print("Didn't get delimiter!")
					continue
				}

				id := int(buf[1])
				val := int(buf[2])

				go func() {
					_, err := u.mcu.SetServo(id, val)
					if err != nil {
						log.Print(err)
					}
				}()

				t.Reset(u.config.safeWait)
			}
		}
	}
}

func (u *udpServer) stop() {
	log.Print("Cleaning up.")
	u.udp.Close()
	u.mcu.Close()
}
