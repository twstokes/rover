import Foundation
import GameController

class JoystickProcessor {
    var controller: GCController?
    let controllerQueue = DispatchQueue(label: "controllerQueue")

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    @objc func controllerDidConnect() {
        print("Controller connected!")
        if let controller = GCController.controllers().first {
            print("Controller type: \(controller.vendorName ?? "Unknown")")
            self.controller = controller
            controller.handlerQueue = self.controllerQueue
        }
    }

    @objc func controllerDidDisconnect() {
        print("Controller disconnected!")
    }
}

extension JoystickProcessor: RoverControlDelegate {
    func getSteeringValue() -> Int? {
        if let value = controller?.extendedGamepad?.leftThumbstick.xAxis.value {
            return Int(value * 90) + 90
        }

        return nil
    }

    func getDrivetrainValue() -> Int? {
        if
            let lValue = controller?.extendedGamepad?.leftTrigger.value,
            let rValue = controller?.extendedGamepad?.rightTrigger.value
        {

            let sumDegrees = Int((-1 * lValue + rValue) * 90) + 90
            return sumDegrees
        }

        return nil
    }


}
