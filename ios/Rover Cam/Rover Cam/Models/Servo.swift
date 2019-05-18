import Foundation

class Servo {
    private var trim = 0
    private(set) var value = 90

    func setValue(_ degrees: Int) {
        guard degrees >= 0 && degrees <= 180 else {
            print("Servo value out of range!")
            return
        }

        value = (degrees + trim).clampedTo(min: 0, max: 180)
    }

    func setTrim(from90: Int) {
        guard from90 >= -90 && from90 <= 90 else {
            print("Servo trim value out of range!")
            return
        }

        trim = from90
        setValue(value)
    }
}
