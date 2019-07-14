import Foundation

class Servo {
    private let validRange: ClosedRange<Float> = (-1 ... 1)
    private var trim: Float = 0
    private(set) var value: Float = 0

    var valueInDegrees: Int {
        // clamping shouldn't be necessary here, but for good measure
        return Int(90 * (value + 1)).clampedTo(min: 0, max: 180)
    }

    let min: Float
    let max: Float
    let inverted: Bool

    init(min: Float = -1, max: Float = 1, trim: Float = 0, inverted: Bool = false) {
        self.min = validRange.contains(min) ? min : -1
        self.max = validRange.contains(max) ? max : 1
        self.trim = validRange.contains(trim) ? trim : 0
        self.inverted = inverted
    }


    func setValue(_ value: Float) {
        guard validRange.contains(value) else {
            print("Servo value out of range!")
            return
        }

        // apply trim
        var newValue = value + trim
        // clamp to min and max
        newValue = newValue.clampedTo(min: min, max: max)
        // handle inversion
        if inverted {
            newValue *= -1
        }

        self.value = newValue
    }

    func setTrim(_ value: Float) {
        guard validRange.contains(value) else {
            print("Servo trim value out of range!")
            return
        }

        trim = value
        // recompute servo value
        setValue(value)
    }
}
