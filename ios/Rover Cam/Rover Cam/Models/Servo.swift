import Foundation

class Servo {
    private var trim = 0
    private(set) var value = 90
    let min: Int
    let max: Int
    let inverted: Bool

    init(min: Int = 0, max: Int = 180, inverted: Bool = false) {
        self.min = min
        self.max = max
        self.inverted = inverted
    }

    func setValue(_ degrees: Int) {
        guard degrees >= min && degrees <= max else {
            print("Servo value out of range!")
            return
        }

        var newValue = (degrees + trim).clampedTo(min: min, max: max)

        if inverted {
            newValue = abs(180 - newValue)
        }

        value = newValue
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
