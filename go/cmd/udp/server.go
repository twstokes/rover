package main

import (
	"errors"
	"log"
	"net"
	"sync"
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

func (u *udpServer) start(stopChan chan bool) {
	// create our safety timer
	t := time.NewTimer(u.config.safeWait)

	waitGroup := &sync.WaitGroup{}

	for {
		select {
		case <-t.C:
			log.Print("Safety timeout reached.")
			u.mcu.ResetServos()
			u.mcu.ResetLeds()
			t.Reset(u.config.safeWait)
		case <-stopChan:
			log.Print("Stopping...")
			log.Print("Waiting for routines to finish...")
			waitGroup.Wait()
			return
		default:
			// timeout for reading new data
			u.udp.SetReadDeadline(time.Now().Add(time.Millisecond * 10))
			// 24 bytes is arbitrary, current payloads are all < mcu.MaxPayload
			buf := make([]byte, 24)
			n, _, err := u.udp.ReadFrom(buf)
			if err != nil {
				// may be a timeout
				log.Print(err)
				continue
			}

			// this is purely for the current implementation
			// where the two are tightly coupled
			if n > mcu.MaxPayload {
				log.Print("Warning: More bytes read from UDP than max MCU payload.")
			}

			// figure out what command this is
			cmd, err := u.processCommandByte(buf[0])
			if err != nil {
				log.Print(err)
			}

			// get the rest of the data needed for the command
			data := buf[1:]

			// using waitgroups so that we can send remaining
			// MCU data before closing out the serial port during a shutdown

			// warning: if we overload serial writes by sending too much data
			// and the MCU gets backed up, we may end up waiting when we really want things to
			// stop immediately
			waitGroup.Add(1)
			go func() {
				defer waitGroup.Done()
				_, err = cmd(data)

				if err != nil {
					log.Print(err)
				}
			}()

			t.Reset(u.config.safeWait)
		}
	}
}

// takes in a raw byte, determines if it's a supported command
func (u *udpServer) processCommandByte(raw byte) (func([]byte) (bool, error), error) {
	cmd := mcu.Command(raw)

	switch cmd {
	case mcu.SetServos:
		return u.setServos, nil
	case mcu.SetServo:
		return u.setServo, nil
	case mcu.SetLights:
		return u.setLights, nil
	default:
		return nil, errors.New("command not recognized")
	}
}

func (u *udpServer) stop() {
	log.Print("Cleaning up.")

	u.udp.Close()
	u.mcu.Close()
}

// pull the light data out and send it to the MCU
func (u *udpServer) setLights(buf []byte) (bool, error) {
	id := int(buf[0])
	mode := mcu.LightMode(buf[1])
	r := int(buf[2])
	g := int(buf[3])
	b := int(buf[4])

	return u.mcu.SetLights(id, mode, r, g, b)
}

// pull the servo data out and send it to the MCU
func (u *udpServer) setServo(buf []byte) (bool, error) {
	id := int(buf[0])
	val := int(buf[1])

	return u.mcu.SetServo(id, val)
}

// pass the data straight through to set all servos
func (u *udpServer) setServos(buf []byte) (bool, error) {
	return u.mcu.SetServos(buf)
}
