#include <Servo.h>

#define SERVO_COUNT 4

// instantiate servos
Servo servos[SERVO_COUNT];
// output pins
const byte pins[SERVO_COUNT] = {12, 13, 14, 15};

struct servoData
{
  byte id;
  byte val;
};

void setup()
{
  Serial.begin(9600);
  attachServos();
  initServos();
}

void loop()
{
  if (Serial.available() > 0)
  {
    int result = processData();
    // 1 is success, 0 is failure
    // this could be expanded to more codes / data
    Serial.write(result);
  }

  delay(10);
}

// reads in new serial data for one servo
// returns whether setting this new data was successful or not
bool processData()
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

  return false;
}

// does sanity checking and sets servo's new value if tests pass
bool writeData(servoData *data)
{
  // the id can't be less than 1 or greater than number of servos
  if (data->id < 1 || data->id > SERVO_COUNT)
    return false;

  // it's not valid to send higher than 180 to a servo
  if (data->val > 180)
    return false;

  // write the new value
  servos[data->id - 1].write(data->val);
  return true;
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
