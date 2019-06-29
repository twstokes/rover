#include "Rover.h"

using namespace rover;

// rover with no lights
Rover::Rover(uint8_t numServos, const uint8_t *servoPins) : numLeds(0)
{
  initServos(numServos, servoPins);
}

// rover with lights
Rover::Rover(uint8_t numServos, const uint8_t *servoPins, uint8_t numLeds, uint8_t ledPin)
{
  initLeds(numLeds, ledPin);
  initServos(numServos, servoPins);
}

// deconstructor
Rover::~Rover()
{
}

void Rover::initLeds(uint8_t n, uint8_t l)
{
  strip = Adafruit_NeoPixel(n, l);

  strip.begin();
  strip.show();

  numLeds = n;
}

// sets all servos to middle position (90)
// if we wanted to set a trim via the MCU
// we could detect passing in a new type of message
// and it could be stored in persistent memory see issue #1
void Rover::initServos(uint8_t n, const uint8_t *p)
{
  for (int x = 0; x < n; x++)
  {
    servos[x].attach(p[x]);
    servos[x].write(90);
  }

  numServos = n;
}

// sets a single servo
processCode Rover::setServo(servoId id, servoVal val)
{
  // the id can't be less than 1 or greater than number of servos
  if (id < 1 || id > numServos)
    return BadId;

  // it's not valid to send higher than 180 to a servo
  if (val > 180)
    return BadVal;

  // write the new value
  servos[id - 1].write(val);
  return Success;
}

// for setting all servos at once
// this is more efficient than setServo for constant data streams
processCode Rover::setServos(servoVal *s)
{
  for (servoId id = 1; id <= numServos; id++)
  {
    processCode status = setServo(id, s[id - 1]);

    if (status != Success)
      return status;
  }

  return Success;
}

// for setting an individual LED
processCode Rover::setLight(ledId id, ledColor c)
{
  // the id can't be less than 1 or greater than the number of lights
  if (id < 1 || id > numLeds)
    return BadId;

  // set the pixel color
  strip.setPixelColor(id - 1, c.r, c.g, c.b);
  strip.show();
  return Success;
}

// for setting all LEDs at once
processCode Rover::setLights(ledColor c)
{
  for (uint8_t x = 0; x < numLeds; x++)
  {
    // set the pixel color
    strip.setPixelColor(x, c.r, c.g, c.b);
  }

  strip.show();
  return Success;
}