/*
  Input:  A serial payload of size PAYLOAD_SIZE bytes. 
          Commands that don't utilize all bytes must be padded to fill the serial buffer.
  
  Output: int value of processCode enum if WRITE_RESULT is true, otherwise nothing.
*/

#include <main.h>
#include <Servo.h>
#include <Adafruit_NeoPixel.h>

// the size of a serial payload
// this includes the command and any accompanying data for it
#define PAYLOAD_SIZE 8
// number of servos
#define SERVO_COUNT 4
// pin used for NeoPixels
#define NEOPIN 8
// number of NeoPixels
#define LED_COUNT 8
// if the MCU should write the result back via serial
#define WRITE_RESULT false

// instantiate servos
Servo servos[SERVO_COUNT];
// servo output pins
const byte pins[SERVO_COUNT] = {2, 3, 4, 5};
// instantiate NeoPixel strip
Adafruit_NeoPixel strip = Adafruit_NeoPixel(LED_COUNT, NEOPIN);

void setup()
{
  Serial.setTimeout(100);
  Serial.begin(115200);
  // servos
  attachServos();
  initServos();
  // leds
  strip.begin();
  strip.show();
}

void loop()
{
  // waiting for a full payload adds stability with a short timeout
  if (Serial.available() >= PAYLOAD_SIZE)
  {
    // entire payloads via serial are PAYLOAD_SIZE bytes
    uint8_t buf[PAYLOAD_SIZE] = {0};
    Serial.readBytes(buf, PAYLOAD_SIZE);

    payload p = {
        .cmd = buf[0],
        .data = &buf[1]};

    processCode result = processData(&p);
    // write the result back over serial
    // warning: the receiver must make sure this doesn't clog up the pipe
    if (WRITE_RESULT)
      Serial.write(result);
  }

  delay(10);
}

// processes new payload
// returns whether setting this new data was successful or not
processCode processData(payload *p)
{
  // setting a single servo
  if (p->cmd == SetServo)
  {
    servoData s;
    memcpy(&s, p->data, sizeof(s));
    return setServo(&s);
  }

  // setting multiple servos at once
  if (p->cmd == SetServos)
  {
    servoVal s[4];
    memcpy(&s, p->data, sizeof(s));
    return setServos(s);
  }

  // setting a single LED
  if (p->cmd == SetLight)
  {
    lightData l;
    memcpy(&l, p->data, sizeof(l));
    return setLight(&l);
  }

  // setting all LEDs
  if (p->cmd == SetLights)
  {
    ledColor c;
    memcpy(&c, p->data, sizeof(c));
    return setLights(&c);
  }

  return ReadFailure;
}

// sets a single servo
processCode setServo(servoData *s)
{
  // the id can't be less than 1 or greater than number of servos
  if (s->id < 1 || s->id > SERVO_COUNT)
    return BadId;

  // it's not valid to send higher than 180 to a servo
  if (s->val > 180)
    return BadVal;

  // write the new value
  servos[s->id - 1].write(s->val);
  return Success;
}

// for setting all servos at once
// this is more efficient than setServo for constant data streams
processCode setServos(servoVal *s)
{
  for (servoId id = 1; id <= SERVO_COUNT; id++)
  {
    servoData d = {.id = id, .val = s[id - 1]};
    processCode status = setServo(&d);

    if (status != Success)
      return status;
  }

  return Success;
}

// for setting an individual LED
processCode setLight(lightData *l)
{
  // the id can't be less than 1 or greater than the number of lights
  if (l->id < 1 || l->id > LED_COUNT)
    return BadId;

  // set the pixel color
  strip.setPixelColor(l->id - 1, l->color.r, l->color.g, l->color.b);
  strip.show();
  return Success;
}

// for setting all LEDs at once
processCode setLights(ledColor *c)
{
  for (uint8_t x = 0; x < LED_COUNT; x++)
  {
    // set the pixel color
    strip.setPixelColor(x, c->r, c->g, c->b);
  }

  strip.show();
  return Success;
}

// assign pins to servos
void attachServos()
{
  for (int x = 0; x < SERVO_COUNT; x++)
  {
    servos[x].attach(pins[x]);
  }
}

// sets all servos to middle position (90)
// if we wanted to set a trim via the MCU
// we could detect passing in a new type of message
// and it could be stored in persistent memory see issue #1
void initServos()
{
  for (int x = 0; x < SERVO_COUNT; x++)
  {
    servos[x].write(90);
  }
}
