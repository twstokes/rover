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

        // try to set a value out of range
        servo.setValue(-1)
        XCTAssertEqual(servo.value, 0)

        servo.setValue(181)
        XCTAssertEqual(servo.value, 0)

        // try to set a valid value
        servo.setValue(85)
        XCTAssertEqual(servo.value, 85)

        servo.setValue(15)
        XCTAssertEqual(servo.value, 15)

        // set back to middle
        servo.setTrim(from90: 0)
        servo.setValue(90)

        // trim all the way left
        servo.setTrim(from90: -90)
        XCTAssertEqual(servo.value, 0)

        // set back to middle
        servo.setTrim(from90: 0)
        servo.setValue(90)

        // trim all the way right
        servo.setTrim(from90: 90)
        XCTAssertEqual(servo.value, 180)

        // centered position with high trim
        servo.setValue(90)
        XCTAssertEqual(servo.value, 180)

        // set back to middle
        servo.setTrim(from90: 0)
        servo.setValue(90)

        // set a value higher than what's possible
        servo.setValue(190)
        XCTAssertEqual(servo.value, 90)

        // set a trim that's out of range
        servo.setValue(90)
        servo.setTrim(from90: 0)
        servo.setTrim(from90: 91)
        XCTAssertEqual(servo.value, 90)
    }
}
