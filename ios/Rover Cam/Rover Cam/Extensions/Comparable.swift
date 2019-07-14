import Foundation

extension Comparable {
    // clamps a comparable to a min and max value
    func clampedTo(min: Self, max: Self) ->  Self {
        if self < min { return min }
        if self > max { return max }

        return self
    }

    // clamps a comparable to a closed range
    func clampedTo(range: ClosedRange<Self>) -> Self {
        return clampedTo(min: range.lowerBound, max: range.upperBound)
    }
}
