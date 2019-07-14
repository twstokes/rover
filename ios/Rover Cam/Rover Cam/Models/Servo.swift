import Foundation

class Servo {
    // default range that cannot be exceeded
    static let defaultRange: ClosedRange<Float> = (-1 ... 1)
    // can be equal to or less than the default range to limit a servo
    private let allowedRange: ClosedRange<Float>
    private var trim: Float = 0
    private(set) var value: Float = 0

    let inverted: Bool

    var valueInDegrees: Int {
        // clamping shouldn't be necessary here, but for good measure
        return Int(90 * (value + 1)).clampedTo(min: 0, max: 180)
    }

    init(min: Float = -1, max: Float = 1, trim: Float = 0, inverted: Bool = false) {
        self.allowedRange = Servo.defaultRange.clamped(to: min ... max)

        if allowedRange.contains(trim) {
            self.trim = trim
        } else {
            print("Warning: Trim was set to a value outside of the allowed range.")
        }

        self.inverted = inverted
    }

    convenience init(with config: ServoConfig) {
        self.init(min: config.min, max: config.max, trim: config.trim, inverted: config.inverted)
    }

    func setValue(_ value: Float) {
        guard Servo.defaultRange.contains(value) else {
            print("Servo input value out of range!")
            return
        }

        // apply trim
        var newValue = value + trim
        // map to min and max
        newValue = newValue.mapped(from: Servo.defaultRange, to: allowedRange)
        // clamp to min and max
        newValue = newValue.clampedTo(range: allowedRange)
        // handle inversion
        if inverted {
            newValue *= -1
        }

        self.value = newValue
    }

    func setTrim(_ value: Float) {
        guard allowedRange.contains(value) else {
            print("Servo trim value out of range!")
            return
        }

        trim = value
        // recompute servo value
        setValue(value)
    }
}
