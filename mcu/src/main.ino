/*
  Input: Three bytes via Serial.
    Byte 1: 255
    Byte 2: ID (1-SERVO_COUNT)
    Byte 3: Byte 0-255 (only 0-180 is acceptable)
  
  Output: int value of processCode enum
*/

#include <Servo.h>

#define SERVO_COUNT 4

// instantiate servos
Servo servos[SERVO_COUNT];
// output pins
const byte pins[SERVO_COUNT] = {2, 3, 4, 5};

struct servoData
{
  int id;
  int val;
};

enum processCode
{
  success,     // data read in was valid and written to the servo
  readFailure, // malformed data read in
  badId,       // a bad id was referenced
  badVal       // a bad value was passed in
};

void setup()
{
  Serial.setTimeout(100);
  Serial.begin(115200);
  attachServos();
  initServos();
}

void loop()
{
  // waiting for three adds stability with a short timeout
  if (Serial.available() >= 3)
  {
    processCode result = processData();
    Serial.write(result);
  }

  delay(10);
}

// reads in new Serial data for one servo
// returns whether setting this new data was successful or not
processCode processData()
{
  int newByte = Serial.read();

  if (newByte == 255)
  {
    // this is the start of a transmission
    servoData data = {Serial.read(), Serial.read()};
    return writeData(&data);
  }

  return readFailure;
}

// does sanity checking and sets servo's new value if tests pass
processCode writeData(servoData *data)
{
  // the id can't be less than 1 or greater than number of servos
  if (data->id < 1 || data->id > SERVO_COUNT)
    return badId;

  // it's not valid to send higher than 180 to a servo
  if (data->val > 180)
    return badVal;

  // write the new value
  servos[data->id - 1].write(data->val);
  return success;
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
// something like 254, 1, 110
void initServos()
{
  for (int x = 0; x < SERVO_COUNT; x++)
  {
    servos[x].write(90);
  }
}
