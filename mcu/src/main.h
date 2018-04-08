typedef uint8_t servoId, servoVal, ledId, ledRowId, colorIntensity;

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
    colorIntensity r, g, b;
};

struct lightData
{
    ledId id;
    ledColor color;
};

enum command
{
    SetServo,  // setting a servo
    SetServos, // setting all servos
    SetLight,  // setting an LEDs
    SetLights, // setting all the LEDs
};

enum processCode
{
    Success,     // data read in was valid and written to the servo
    ReadFailure, // malformed data read in
    BadId,       // a bad id was referenced
    BadVal       // a bad value was passed in
};