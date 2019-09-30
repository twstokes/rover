package main

import "time"

type beacon struct {
	id          int
	mac         string // we could also decode major and minor IDs if desired
	description string
}

type measurement struct {
	beacon beacon
	time   time.Time
	rssi   int
}
