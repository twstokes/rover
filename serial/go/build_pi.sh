#!/bin/sh

env GOOS=linux GOARCH=arm GOARM=6 go build -o rover