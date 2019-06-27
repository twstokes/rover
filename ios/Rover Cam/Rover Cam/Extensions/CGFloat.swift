import Foundation
import UIKit

extension CGFloat {
    func clampedTo(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min { return min }
        if self > max { return max }

        return self
    }
}
