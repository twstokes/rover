#include <Arduino.h>
#include <Rover.h>
#include <unity.h>

using namespace rover;

// number of servos
#define SERVO_COUNT 4
// pin used for NeoPixels
#define NEO_PIN 8
// number of NeoPixels
#define LED_COUNT 8

// pin used for each servo
const uint8_t servoPins[SERVO_COUNT] = {2, 3, 4, 5};

// initialize a rover
Rover r = Rover(SERVO_COUNT, servoPins, LED_COUNT, NEO_PIN);

int main(int argc, char **argv)
{

    UNITY_BEGIN();
    TEST_ASSERT_EQUAL(BadId, r.setServo(0, 0));
    UNITY_END();

    return 0;
}
