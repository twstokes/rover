#include <Adafruit_NeoPixel.h>
#include <Servo.h>

namespace rover
{
typedef uint8_t servoId, servoVal, ledId, colorIntensity;

enum processCode
{
    Success,     // data read in was valid and written to the servo
    ReadFailure, // malformed data read in
    BadId,       // a bad id was referenced
    BadVal       // a bad value was passed in
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

class Rover
{
public:
    processCode
        setServo(servoId, servoVal),
        setServos(servoVal *),
        setLight(ledId, ledColor),
        setLights(ledColor);

    String getServoValues();

    void
        initLeds(uint8_t, uint8_t),
        initServos(uint8_t, const uint8_t *);

protected:
    uint8_t
        numServos,
        numLeds;
    Servo *servos;
    Adafruit_NeoPixel *strip;
};
} // namespace rover
