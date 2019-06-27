import Foundation

extension Int {
    func clampedTo(min: Int, max: Int) -> Int {
        if self < min { return min }
        if self > max { return max }

        return self
    }
}
