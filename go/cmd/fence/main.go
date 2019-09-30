package main

// TODO - break out BLE library to an interface in case we need to swap it out
// since it's a wrapper, the chance of something breaking over time is high

// TODO - gatt:
// maybe fork the repo to disable the "DATA: " output to stdout (or just throw away stdout)

// TODO - we probably only want to send a full packet (all values coupled together) if all beacons responded
// there's no use sending data that's incorrect / stale

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/paypal/gatt"
)

var beacons = []beacon{}

var rawMeasurements = make(chan measurement)

func onStateChanged(d gatt.Device, s gatt.State) {
	fmt.Println("State:", s)
	switch s {
	case gatt.StatePoweredOn:
		fmt.Println("Scanning...")
		// filtering by UUID / Mac was never implemented by the library for Linux
		d.Scan([]gatt.UUID{}, true)
	default:
		d.StopScanning()
	}
}

func onPeriphDiscovered(p gatt.Peripheral, a *gatt.Advertisement, rssi int) {
	for _, beacon := range beacons {
		if strings.ToUpper(p.ID()) == beacon.mac {
			rawMeasurements <- measurement{
				beacon: beacon,
				time:   time.Now(),
				rssi:   rssi,
			}
		}
	}
}

func startMonitoring() (chan measurement, error) {
	opt := []gatt.Option{
		gatt.LnxMaxConnections(1),
		gatt.LnxDeviceID(-1, true),
	}

	d, err := gatt.NewDevice(opt...)
	if err != nil {
		log.Println("Failed to open device.")
		return nil, err
	}

	// handle discovery
	d.Handle(
		gatt.PeripheralDiscovered(onPeriphDiscovered),
	)

	d.Init(onStateChanged)

	return rawMeasurements, nil
}

func main() {
	rawMeasurements, err := startMonitoring()
	if err != nil {
		log.Fatalf("Fatal: %s\n", err)
		return
	}

	processed := processRawMeasurements(beacons, rawMeasurements)

	for {
		p := <-processed
		fmt.Println(p)
	}
}
