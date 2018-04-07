package mcu

import (
	"errors"
	"time"

	"github.com/tarm/serial"
)

// Controller is what handles MCU operations on the Rover
type Controller struct {
	servos int
	leds   int
	serial *serial.Port
}

// MaxPayload is the maximum serial payload size in bytes
// this should match what's defined on the MCU
const MaxPayload = 8

// Command is a command that the MCU supports
type Command byte

// LightMode handles different modes for lights
type LightMode byte

// commands
const (
	// SetServo command
	SetServo Command = iota
	// SetServos command
	SetServos
	// SetLights command
	SetLights
)

// light modes
const (
	// Single LED mode
	Single LightMode = iota
	// Row of LEDs mode
	Row
)

// Connect connects to the MCU
func Connect(port string, baud int, servos int, leds int) (c *Controller, err error) {
	conf := &serial.Config{Name: port, Baud: baud}
	s, err := serial.OpenPort(conf)
	if err != nil {
		return nil, err
	}

	c = &Controller{
		servos: servos,
		leds:   leds,
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

// ResetLeds resets the LEDs to red
func (c *Controller) ResetLeds() {
	c.SetLights(1, Row, 127, 0, 0)
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

	data := []byte{byte(SetServo), byte(id), byte(val)}
	return c.write(data)
}

// SetServos is a more efficient way to set all servos at once
func (c *Controller) SetServos(vals []byte) (success bool, err error) {
	if len(vals) < c.servos {
		return false, errors.New("servo count mismatch")
	}

	data := append([]byte{byte(SetServos)}, vals...)
	return c.write(data)
}

// SetLights sends a value to change the LEDs
func (c *Controller) SetLights(id int, mode LightMode, r int, g int, b int) (success bool, err error) {
	switch mode {
	case Row:
		if id != 1 {
			return false, errors.New("id out of range for row")
		}
	case Single:
		if id < 1 || id > c.leds {
			return false, errors.New("id out of range for led")
		}
	default:
		return false, errors.New("unknown light mode")
	}

	data := []byte{byte(SetLights), byte(id), byte(mode), byte(r), byte(g), byte(b)}
	return c.write(data)
}

// writes data to the MCU
func (c *Controller) write(data []byte) (success bool, err error) {
	if len(data) > MaxPayload {
		return false, errors.New("payload too large")
	}

	// pads data to fit expected payload
	payload := make([]byte, MaxPayload)
	copy(payload, data)

	_, err = c.serial.Write(payload)
	if err != nil {
		return false, err
	}
	return true, nil
}
