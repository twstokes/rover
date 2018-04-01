#!/bin/sh

source env.sh
mkdir -p output
cd output
echo "Building for ARM $GOARM..."
env GOOS=linux GOARCH=arm go build github.com/twstokes/rover/go/cmd/udp
echo 'Done.'