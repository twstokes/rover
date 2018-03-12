package main

import (
	"errors"
	"log"
	"net"
	"os"
	"os/signal"
	"time"

	"github.com/tarm/serial"
)

func main() {
	// connect to the MCU
	c := &serial.Config{Name: "/dev/cu.usbmodem1431", Baud: 115200}
	s, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal(err)
	}

	// create a UDP server to receive data
	udpconn, err := net.ListenPacket("udp", ":8000")
	if err != nil {
		log.Fatal(err)
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
				id := buf[0]
				val := buf[1]

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
		case <-stopchan:
			log.Print("Stopping...")
			return
		}
	}
}

func sendData(s *serial.Port, id byte, val byte, verify bool) (success bool, err error) {
	data := []byte{id, val} // id and value bytes
	comma := []byte(",")    // delimiter

	payload := append(data, comma...)

	_, err = s.Write(payload)
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
			return false, errors.New("didn't get a byte response")
		}

		if buf[0] != 1 {
			return false, errors.New("mcu reported write failure")
		}
	}

	return true, nil
}
