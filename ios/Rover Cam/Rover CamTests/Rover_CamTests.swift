import XCTest
@testable import Rover_Cam

class Rover_CamTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClamping() {
        // top
        XCTAssertEqual(200.clampedTo(min: 0, max: 180), 180)
        // bottom
        XCTAssertEqual(0.clampedTo(min: 0, max: 180), 0)
        XCTAssertEqual((-200).clampedTo(min: 0, max: 180), 0)
        // within range
        XCTAssertEqual(50.clampedTo(min: 0, max: 180), 50)
    }

    func testMapping() {
        let range1: ClosedRange<Float> = 0 ... 100
        let range2: ClosedRange<Float> = -100 ... 255

        XCTAssertEqual(Float(50).mapped(from: range1, to: range2), 77.5)
        XCTAssertEqual(Float(0).mapped(from: range1, to: range2), -100)
        XCTAssertEqual(Float(100).mapped(from: range1, to: range2), 255)
    }

    func testServo() {
        let servo = Servo()

        // start at zero
        servo.setValue(0)
        XCTAssertEqual(servo.value, 0)
        XCTAssertEqual(servo.valueInDegrees, 90)

        // try to set a value out of range
        servo.setValue(-1.1)
        XCTAssertEqual(servo.value, 0)
        XCTAssertEqual(servo.valueInDegrees, 90)

        servo.setValue(1.1)
        XCTAssertEqual(servo.value, 0)
        XCTAssertEqual(servo.valueInDegrees, 90)

        // try to set a valid value
        servo.setValue(0.5)
        XCTAssertEqual(servo.value, 0.5)
        XCTAssertEqual(servo.valueInDegrees, 135)

        servo.setValue(1)
        XCTAssertEqual(servo.value, 1)
        XCTAssertEqual(servo.valueInDegrees, 180)

        // set trim
        servo.setTrim(0.5)
        servo.setValue(0)
        XCTAssertEqual(servo.value, 0.5)
        XCTAssertEqual(servo.valueInDegrees, 135)

        // trim all the way left
        servo.setTrim(-1)
        XCTAssertEqual(servo.value, -1)
        XCTAssertEqual(servo.valueInDegrees, 0)

        // test trim and value
        servo.setTrim(0.5)
        servo.setValue(0.5)
        XCTAssertEqual(servo.value, 1)
        XCTAssertEqual(servo.valueInDegrees, 180)

        // test exceeding value
        servo.setValue(1)
        XCTAssertEqual(servo.value, 1)
        XCTAssertEqual(servo.valueInDegrees, 180)

        // test initializing with a trim that exceeds allowable values
        let servo2 = Servo(min: -0.5, max: 0.5, trim: 0.6)
        servo2.setValue(0)
        // the trim has no effect
        XCTAssertEqual(servo2.value, 0)

        // test initializing with a min and max that exceed servo values
        let servo3 = Servo(min: -2, max: 2)
        servo3.setValue(-1)
        XCTAssertEqual(servo3.value, -1)
    }

    func testMinMax() {
        // test that values are clamped and normalized to our min and max
        let servo = Servo(min: -0.5, max: 0.5, trim: 0, inverted: false)

        servo.setValue(-1)
        XCTAssertEqual(servo.value, -0.5)
        servo.setValue(1)
        XCTAssertEqual(servo.value, 0.5)

        // crank the trim all the way to the right
        servo.setTrim(1)
        XCTAssertEqual(servo.value, 0.5)
    }

    func testInversion() {
        let servo = Servo(inverted: true)

        servo.setValue(1)
        XCTAssertEqual(servo.value, -1)
    }

    func testControls() {
        let servo = Servo(min: -0.5, max: 0.5, trim: 0)

        // test middle position
        servo.setValue(0)
        XCTAssertEqual(servo.valueInDegrees, 90)

        // test far left
        servo.setValue(-1)
        XCTAssertEqual(servo.valueInDegrees, 45)

        // test far right
        servo.setValue(1)
        XCTAssertEqual(servo.valueInDegrees, 135)

        // test in between
        servo.setValue(0.5)
        XCTAssertEqual(servo.valueInDegrees, 112)

        // default servo
        let servo2 = Servo()

        // test middle position
        servo2.setValue(0)
        XCTAssertEqual(servo2.valueInDegrees, 90)

        // test far left
        servo2.setValue(-1)
        XCTAssertEqual(servo2.valueInDegrees, 0)

        // test far right
        servo2.setValue(1)
        XCTAssertEqual(servo2.valueInDegrees, 180)
    }
}
