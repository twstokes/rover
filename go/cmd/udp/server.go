package main

import (
	"log"
	"net"
	"os"
	"os/signal"
	"time"

	"github.com/twstokes/rover/go/pkg/mcu"
)

type config struct {
	safeWait time.Duration // duration of not receiving UDP data before resetting servos
}

type udpServer struct {
	config *config
	mcu    *mcu.Controller
	udp    *net.UDPConn
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
