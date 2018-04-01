package mcu

import (
	"errors"
	"time"

	"github.com/tarm/serial"
)

// Controller is what handles MCU operations on the Rover
type Controller struct {
	servos int
	serial *serial.Port
}

// Connect connects to the MCU
func Connect(port string, baud int, servos int) (c *Controller, err error) {
	conf := &serial.Config{Name: port, Baud: baud}
	s, err := serial.OpenPort(conf)
	if err != nil {
		return nil, err
	}

	c = &Controller{
		servos: servos,
		serial: s,
	}
	// add a slight delay in case we need to wait on the MCU
	time.Sleep(time.Second * 2)
	return c, nil
}

// ResetServos resets the servos
func (c *Controller) ResetServos() {
	// send idle values for all ids
	// this could be cleaned up with a new command for the MCU
	// this isn't great because it doesn't respect a trim
	for i := 1; i <= c.servos; i++ {
		_, _ = c.SetServo(i, 90)
	}
}

// Close closes the serial connection and cleans up
func (c *Controller) Close() {
	c.serial.Close()
}

// SetServo sends a value to a servo id. Ids start at 1 and values must be between 0 and 180.
func (c *Controller) SetServo(id int, val int) (success bool, err error) {
	if id < 1 || id > c.servos {
		return false, errors.New("id out of range")
	}

	if val < 0 || val > 180 {
		return false, errors.New("value out of range")
	}

	data := []byte{255, byte(id), byte(val)} // delimiter, id, and value bytes
	_, err = c.serial.Write(data)
	if err != nil {
		return false, err
	}

	// if we wanted to read a confirmation value back from the MCU here we could
	return true, nil
}
