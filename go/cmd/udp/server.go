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
			u.mcu.ResetLeds()
			t.Reset(u.config.safeWait)
		case <-stopchan:
			log.Print("Stopping...")
			return
		default:
			// timeout for reading new data
			u.udp.SetReadDeadline(time.Now().Add(time.Millisecond * 10))

			// note: sending data via UDP doesn't need to be the exact MCU payload size
			buf := make([]byte, mcu.MaxPayload)
			_, _, err := u.udp.ReadFrom(buf)
			if err != nil {
				// may be a timeout
				continue
			}

			command := mcu.Command(buf[0])
			data := buf[1:]

			switch command {
			case mcu.SetServo:
				u.servoCommand(data)
			case mcu.SetLights:
				u.setLights(data)
			default:
				log.Print("Command not recognized.")
				continue
			}

			t.Reset(u.config.safeWait)
		}
	}
}

func (u *udpServer) stop() {
	log.Print("Cleaning up.")
	u.udp.Close()
	u.mcu.Close()
}

// pull the light data out and send it to the MCU
func (u *udpServer) setLights(buf []byte) {
	id := int(buf[0])
	mode := mcu.LightMode(buf[1])
	r := int(buf[2])
	g := int(buf[3])
	b := int(buf[4])

	go func() {
		_, err := u.mcu.SetLights(id, mode, r, g, b)
		if err != nil {
			log.Print(err)
		}
	}()
}

// pull the servo data out and send it to the MCU
func (u *udpServer) servoCommand(buf []byte) {
	id := int(buf[0])
	val := int(buf[1])

	go func() {
		_, err := u.mcu.SetServo(id, val)
		if err != nil {
			log.Print(err)
		}
	}()
}
