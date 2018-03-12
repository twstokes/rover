/*
  Input: Three bytes via serial.
    Byte 1: ID (1-SERVO_COUNT)
    Byte 2: Byte 0-255 (only 0-180 is acceptable)
    Byte 3: Comma character (delimter)
  

  Output: 1 for success, 0 for failure
    Failure conditions: ID out of range (0 or > SERVO_COUNT), integer higher than 180
*/
#include <Servo.h>

#define SERVO_COUNT 4

// instantiate servos
Servo servos[SERVO_COUNT];
// output pins
const byte pins[SERVO_COUNT] = {5, 6, 10, 11};

struct servoData
{
  byte id;
  byte val;
};

enum processCode
{
  success, // data read in was valid and written to the servo
  readFailure, // couldn't read data coming in
  badId, // a bad id was referenced
  badVal // a bad value was passed in
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
  if (Serial.available() > 0)
  {
    processCode result = processData();
    Serial.write(result);
  }

  delay(10);
}

// reads in new serial data for one servo
// returns whether setting this new data was successful or not
processCode processData()
{
  byte buf[3] = {0, 0, 0};

  // must be three so that the delimiter is read in
  // and isn't left over in the buffer
  if (Serial.readBytesUntil(',', buf, 3))
  {
    // element 0 is the servo id, element 1 is the servo value
    servoData data = {buf[0], buf[1]};
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
void initServos()
{
  for (int x = 0; x < SERVO_COUNT; x++)
  {
    servos[x].write(90);
  }
}
