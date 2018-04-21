#include "Rover.h"

using namespace rover;

// the size of a serial payload
// this includes the command and any accompanying data for it
#define PAYLOAD_SIZE 8

// a generic serial payload
struct payload
{
    uint8_t cmd;   // first serial byte
    uint8_t *data; // caution - accessing this shouldn't exceed PAYLOAD_SIZE - 1
};

enum command
{
    SetServo,  // setting a servo
    SetServos, // setting all servos
    SetLight,  // setting an LEDs
    SetLights, // setting all the LEDs
};

processCode processPayload(uint8_t *);