import Foundation
import UIKit

extension UIColor {
    // returns RGB from 0-255
    var rgb: (red: Int, green: Int, blue: Int) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: nil)

        return (Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
