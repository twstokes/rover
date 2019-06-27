import Foundation
import UIKit

// expects value to be from 0.0 to 1.0
func getColorFromHueValue(_ value: Float) -> UIColor {
    let hue = CGFloat(value).clampedTo(min: 0.0, max: 1.0)

    let color = UIColor(
        hue: hue,
        saturation: 1.0,
        brightness: 1.0,
        alpha: 1.0
    )

    return color
}
