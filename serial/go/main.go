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

type config struct {
	port   int
	baud   int
	servos int
	// duration of not receiving UDP data
	// before resetting servos
	udpWait time.Duration
}

func main() {
	if len(os.Args) < 2 {
		panic(fmt.Errorf("expected an argument for serial port"))
	}
	portString := os.Args[1]

	conf := config{
		port:    8000,
		baud:    115200,
		servos:  4,
		udpWait: time.Second,
	}

	// connect to the MCU
	c := &serial.Config{Name: portString, Baud: conf.baud}
	s, err := serial.OpenPort(c)
	if err != nil {
		panic(err)
	}

	addr := net.UDPAddr{
		Port: conf.port,
	}

	// create a UDP server to receive data
	udpconn, err := net.ListenUDP("udp", &addr)
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

	// a safety timer - if no input has been sent,
	// go back to "idle" values
	t := time.NewTimer(conf.udpWait)

	for {
		select {
		case <-t.C:
			log.Print("Input timeout reached.")

			// send idle values for all ids
			// this could be cleaned up with a new command for the MCU
			// this isn't great because it doesn't respect a trim
			for i := 1; i <= conf.servos; i++ {
				_, _ = sendData(s, i, 90, conf)
			}

			t.Reset(conf.udpWait)
		case <-stopchan:
			log.Print("Stopping...")
			return
		default:
			// timeout for reading new data
			udpconn.SetReadDeadline(time.Now().Add(time.Millisecond * 10))

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

				id := int(buf[1])
				val := int(buf[2])

				go func() {
					_, err := sendData(s, id, val, conf)

					if err != nil {
						log.Print(err)
						return
					}
				}()

				t.Reset(conf.udpWait)
			}
		}
	}
}

func sendData(s *serial.Port, id int, val int, c config) (success bool, err error) {
	data := []byte{255, byte(id), byte(val)} // delimiter, id, and value bytes

	if id < 1 || id > c.servos {
		return false, errors.New("id out of range")
	}

	if val > 180 {
		return false, errors.New("value out of range")
	}

	_, err = s.Write(data)
	if err != nil {
		return false, err
	}

	return true, nil
}
