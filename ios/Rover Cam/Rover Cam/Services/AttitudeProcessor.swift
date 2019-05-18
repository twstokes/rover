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
    func getPanValue() -> Int? {
        guard let yaw = motion.deviceMotion?.attitude.yaw else {
            return nil
        }

        // center at 90
        let deg = radToDeg(rad: yaw) + 90
        return Int(deg)
    }

    func getTiltValue() -> Int? {
        // this is roll because we're in a landscape orientation
        guard let pitch = motion.deviceMotion?.attitude.roll else {
            return nil
        }

        let deg = radToDeg(rad: pitch)
        // invert the axis
        return Int(180 - deg)
    }
}
