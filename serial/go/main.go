package main

import (
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"time"

	"github.com/tarm/serial"
)

func main() {
	if len(os.Args) < 2 {
		panic(fmt.Errorf("expected an argument for serial port"))
	}

	portString := os.Args[1]

	// connect to the MCU
	c := &serial.Config{Name: portString, Baud: 115200}
	s, err := serial.OpenPort(c)
	if err != nil {
		panic(err)
	}

	// create a UDP server to receive data
	udpconn, err := net.ListenPacket("udp", ":8000")
	if err != nil {
		panic(err)
	}

	stopchan := make(chan os.Signal, 1)
	signal.Notify(stopchan, os.Interrupt)

	defer func() {
		log.Print("Cleaning up.")
		udpconn.Close()
		s.Close()
	}()

	// the arduino seemed to need a small delay
	// before sending data
	time.Sleep(time.Second * 2)

	for {
		select {
		case <-stopchan:
			log.Print("Stopping...")
			return
		default:
			// 500 ms timeout for reading new data
			udpconn.SetReadDeadline(time.Now().Add(time.Millisecond * 500))

			buf := make([]byte, 3)
			n, _, err := udpconn.ReadFrom(buf)
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

				id := buf[1]
				val := buf[2]

				success, err := sendData(s, id, val, true)

				if err != nil {
					log.Print(err)
				}

				if success {
					log.Print("Successfully wrote to MCU!")
				} else {
					log.Print("Failed to send new data to MCU.")
				}
			}
		}
	}
}

func sendData(s *serial.Port, id byte, val byte, verify bool) (success bool, err error) {
	data := []byte{255, id, val} // delimiter, id, and value bytes

	_, err = s.Write(data)
	if err != nil {
		return false, err
	}

	// TODO - how many servos needs to be configurable
	if id < 1 || id > 4 {
		return false, errors.New("id out of range")
	}

	if val > 180 {
		return false, errors.New("value out of range")
	}

	// if we want to get feedback from the MCU of success / failure
	if verify {
		buf := make([]byte, 1)
		// this assumes the byte waiting to be read corresponds directly
		// with the byte we wrote - not sure how often that's a lie and if we
		// need to flush a buffer or something
		n, err := s.Read(buf)
		if err != nil {
			return false, err
		}

		if n < 1 {
			return false, errors.New("didn't get a response from the mcu")
		}

		if buf[0] != 0 {
			return false, fmt.Errorf("mcu reported error code: %v", buf[0])
		}
	}

	return true, nil
}
