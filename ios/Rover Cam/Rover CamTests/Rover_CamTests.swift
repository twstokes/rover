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
    }

    func testMinMax() {
        // test that values are clamped to our min and max
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
}
