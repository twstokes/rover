// the size of a serial payload
// this includes the command and any accompanying data for it
#define PAYLOAD_SIZE 8

struct payload
{
    uint8_t cmd;   // first serial byte
    uint8_t *data; // caution - accessing this shouldn't exceed PAYLOAD_SIZE - 1
};

struct servoData
{
    uint8_t id, val;
};

struct ledColor
{
    uint8_t r, g, b;
};

struct lightData
{
    uint8_t id;
    uint8_t mode; // this isn't of type lightMode to make serialization easier
    ledColor color;
};

enum lightMode
{
    Single, // single led
    Row,    // an entire row
};

enum command
{
    SetServo,           // setting a servo
    SetLights,          // setting the LEDs
};

enum processCode
{
    Success,     // data read in was valid and written to the servo
    ReadFailure, // malformed data read in
    BadId,       // a bad id was referenced
    BadVal       // a bad value was passed in
};