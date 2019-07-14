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
    func getSteeringValue() -> Float? {
        return controller?.extendedGamepad?.leftThumbstick.xAxis.value
    }

    func getDrivetrainValue() -> Float? {
        guard let gamepad = controller?.extendedGamepad else { return nil }
        return -gamepad.leftTrigger.value + gamepad.rightTrigger.value
    }
}
