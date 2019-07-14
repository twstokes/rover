import Foundation
import CoreMotion

class AttitudeProcessor {
    let motion = CMMotionManager()

    init(updateInterval: TimeInterval) {
        motion.deviceMotionUpdateInterval = updateInterval
    }

    func start() {
        guard motion.isDeviceMotionAvailable else {
            print("Error: Motion unavailable on device.")
            return
        }

        motion.startDeviceMotionUpdates()
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
    }
}

extension AttitudeProcessor: RoverCameraDelegate {
    // returns a float from -1 to 1 for half of the axis (π/2 to -π/2)
    func getPanValue() -> Float? {
        let limit = Double.pi / 2
        let validRange = (-limit ... limit)

        guard
            let yaw = motion.deviceMotion?.attitude.yaw,
            validRange.contains(yaw)
        else {
            return nil
        }

        return -Float(yaw / limit)
    }

    // returns a float from -1 to 1 for half of the axis (0 to π)
    // this is roll because we're in a landscape orientation
    func getTiltValue() -> Float? {
        let limit = Double.pi / 2
        let validRange = (-limit ... limit)

        guard let pitch = motion.deviceMotion?.attitude.roll else {
            return nil
        }

        // shift to make math easier and match up with pi / 2
        let shiftedPitch = pitch + limit
        guard validRange.contains(shiftedPitch) else {
            return nil
        }

        return -Float(shiftedPitch / limit)
    }
}
