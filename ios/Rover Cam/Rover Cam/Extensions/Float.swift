import Foundation

extension Float {
    // maps a float in a given range to another range
    func mapped(from: ClosedRange<Float>, to: ClosedRange<Float>) -> Float {
        return (self - from.lowerBound) * (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound) + to.lowerBound
    }
}
