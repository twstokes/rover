import Foundation
import UIKit

struct Light {
    let id: Int
    let mode: Int
    let color: UIColor

    var payload: UDPPayload {
        let (red, green, blue) = color.rgb
        let colorArray = [red, green, blue]

        let payload = UDPPayload(
            command: 2,
            values: [id, mode] + colorArray
        )

        return payload
    }
}
