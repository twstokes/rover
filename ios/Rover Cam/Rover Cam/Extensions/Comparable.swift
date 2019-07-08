import Foundation

extension Comparable {
    func clampedTo(min: Self, max: Self) ->  Self {
        if self < min { return min }
        if self > max { return max }

        return self
    }
}

