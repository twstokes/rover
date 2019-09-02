#include <Arduino.h>
#include "main.h"

int operationMode = operationMode.Stopped;

void setup()
{
  Serial.setTimeout(100);
  Serial.begin(115200);
}

void loop()
{

  if (Serial.available())
  {
    // read in a single byte to process a command
    uint8_t buf;
    Serial.readBytes(buf, PAYLOAD_SIZE);

    processCode result = processPayload(buf);

    if (WRITE_RESULT && Serial.availableForWrite() >= sizeof(result))
      Serial.println(result);

    if (Serial.availableForWrite())
      Serial.println(r.getServoValues());
  }
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
