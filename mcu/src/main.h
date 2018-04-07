typedef uint8_t servoId, servoVal, ledId, ledRowId, color;

// a generic serial payload
struct payload
{
    uint8_t cmd;   // first serial byte
    uint8_t *data; // caution - accessing this shouldn't exceed PAYLOAD_SIZE - 1
};

// used for commanding a single servo
struct servoData
{
    servoId id;
    servoVal val;
};

struct ledColor
{
    color r, g, b;
};

struct lightData
{
    ledId id;
    uint8_t mode; // this isn't of type lightMode to make serialization simpler
    ledColor color;
};

enum lightMode
{
    Single, // single led
    Row,    // an entire row
};

enum command
{
    SetServo,  // setting a servo
    SetServos, // setting all servos
    SetLights, // setting the LEDs
};

enum processCode
{
    Success,     // data read in was valid and written to the servo
    ReadFailure, // malformed data read in
    BadId,       // a bad id was referenced
    BadVal       // a bad value was passed in
};