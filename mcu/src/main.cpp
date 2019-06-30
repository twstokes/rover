#include <Arduino.h>
#include "main.h"

// number of servos
#define SERVO_COUNT 4
// pin used for NeoPixels
#define NEO_PIN 8
// number of NeoPixels
#define LED_COUNT 8
// if the MCU should write the result back via serial
#define WRITE_RESULT false

// pin used for each servo
const uint8_t servoPins[SERVO_COUNT] = {2, 3, 4, 5};

// initialize a rover
Rover r = Rover();

void setup()
{
  Serial.setTimeout(100);
  Serial.begin(115200);

  r.initServos(SERVO_COUNT, servoPins);
  r.initLeds(LED_COUNT, NEO_PIN);
}

void loop()
{
  // waiting for a full payload adds stability with a short timeout
  if (Serial.available() >= PAYLOAD_SIZE)
  {
    // entire payloads via serial are PAYLOAD_SIZE bytes
    uint8_t buf[PAYLOAD_SIZE] = {0};
    Serial.readBytes(buf, PAYLOAD_SIZE);

    processCode result = processPayload(buf);
    // write the result back over serial
    // warning: the receiver must make sure this doesn't clog up the pipe
    if (WRITE_RESULT)
      Serial.write(result);
  }

  delay(10);
}

// returns whether setting this new data was successful or not
processCode processPayload(uint8_t *buf)
{
  payload p = {
      .cmd = buf[0],
      .data = &buf[1]};

  switch (p.cmd)
  {
  case SetServo:
    servoData s;
    memcpy(&s, p.data, sizeof(s));
    return r.setServo(s.id, s.val);
  case SetServos:
    return r.setServos(p.data);
  case SetLight:
    lightData l;
    memcpy(&l, p.data, sizeof(l));
    return r.setLight(l.id, l.color);
  case SetLights:
    ledColor c;
    memcpy(&c, p.data, sizeof(c));
    return r.setLights(c);
  }

  return ReadFailure;
}