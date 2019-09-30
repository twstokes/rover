package main

import (
	"log"
	"time"
)

type measureCollection map[int][]measurement

func rawMeasurementHandler(m chan measurement, measuredBeacons measureCollection) {
	for {
		measurement := <-m

		id := measurement.beacon.id
		startIdx := 0

		if len(measuredBeacons[id]) >= 10 {
			// pop the first
			startIdx = 1
		}

		measuredBeacons[id] = append(measuredBeacons[id][startIdx:], measurement)
	}
}

func generateProcessedMeasurements(m measureCollection, p chan []measurement) {
	for {
		<-time.After(1 * time.Second)

		processed := []measurement{}

		for _, val := range m {
			// make sure we have at least one value
			count := len(val)

			if count == 0 {
				log.Println("NO VALUES")
				break
			}

			// make sure latest value came within the last second
			if val[count-1].time.Before(time.Now().Add(-1 * time.Second)) {
				log.Println("DATA TOO STALE")
				break
			}

			avg := 0
			for _, measurement := range val {
				avg += measurement.rssi
			}

			// average rssi for this beacon
			avg = avg / count
			now := time.Now()

			processed = append(processed, measurement{
				beacon: val[0].beacon,
				time:   now,
				rssi:   avg,
			})
		}

		// only if the number we successfully processed equal the number
		// of IDs in the map do we send the value
		if len(processed) == len(m) {
			p <- processed
		}
	}

}

func processRawMeasurements(b []beacon, m chan measurement) chan []measurement {
	measurements := make(measureCollection, len(b))
	// prepopulate collection with beacon keys
	for _, val := range b {
		measurements[val.id] = make([]measurement, 0, 10)
	}

	processed := make(chan []measurement)

	go rawMeasurementHandler(m, measurements)
	go generateProcessedMeasurements(measurements, processed)

	return processed
}
