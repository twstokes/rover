#include <Servo.h>

#define SERVO_COUNT 4

// instantiate four servos
Servo servos[SERVO_COUNT];
// output pins
const byte pins[SERVO_COUNT] = {12, 13, 14, 15};
// store current servo values
byte servoVals[SERVO_COUNT] = {0, 0, 0, 0};

struct servoData
{
  byte id;
  byte val;
};

void setup()
{
  Serial.begin(9600);
  attachServos();
}

void loop()
{
  if (Serial.available() > 0)
  {
    // process new data and respond with success or failure
    Serial.write(readNewData() ? 1 : 0);
  }

  writeToServos();
  delay(10);
}

// reads in new serial data for one servo
// returns whether setting this new data was successful or not
bool readNewData()
{
  // this is a bit arbitrary, but may protect against some junk
  // two bytes should be all that's needed
  byte buf[20];

  if (Serial.readBytesUntil(',', buf, 2) == 2)
  {
    // element 0 is the servo id, element 1 is the servo value
    servoData data = {buf[0], buf[1]};

    return setServoData(data);
  }
}

// does sanity checking and sets servo's new value
bool setServoData(servoData data)
{
  // the id can't be less than 1 or greater than number of servos
  if (data.id < 1 || data.id > SERVO_COUNT)
    return false;

  // it's not valid to send higher than 180 to a servo
  if (data.val > 180)
    return false;

  // set the new value
  servoVals[data.id - 1] = data.val;
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

// writes the current value to the servo
void writeToServos()
{
  for (int x = 0; x < SERVO_COUNT; x++)
  {
    servos[x].write(servoVals[x]);
  }
}