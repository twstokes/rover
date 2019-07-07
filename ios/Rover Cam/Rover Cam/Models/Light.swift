import Foundation
import UIKit

struct Light {
    let color: UIColor

    var payload: UDPPayload {
        let (red, green, blue) = color.rgb

        let payload = UDPPayload(
            command: 3,
            values: [red, green, blue]
        )

        return payload
    }
}
