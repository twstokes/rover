import Foundation
import UIKit

class Rover {
    private let config: RoverConfig
    private let client: UDPClient
    private var poller: Timer?

    private var frontSteering: Servo?
    private var rearSteering: Servo?
    private var drivetrain: Servo?

    private var camPan: Servo?
    private var camTilt: Servo?

    private(set) var isRunning = false

    var controlDelegate: RoverControlDelegate?
    var cameraDelegate: RoverCameraDelegate?

    var subscriber: RoverSubscriber?

    private var steeringMode: RoverSteeringMode = .front

    var hasLights: Bool {
        return config.lights.count > 0
    }

    var hasRearSteering: Bool {
        return config.servos.contains { $0.type == .steeringRear }
    }

    var canPanTiltCamera: Bool {
        return config.camera.canPan && config.camera.canTilt
    }


    init(config: RoverConfig) {
        self.config = config
        client = UDPClient(host: config.host, port: config.port)
        initServos()
    }

    private func initServos() {
        for servo in config.servos {
            switch servo.type {
            case .forwardReverse:
                drivetrain = Servo(with: servo.config)
            case .steeringFront:
                frontSteering = Servo(with: servo.config)
            case .steeringRear:
                rearSteering = Servo(with: servo.config)
            }
        }

        for servo in config.camera.servos {
            switch servo.type {
            case .pan:
                camPan = Servo(with: servo.config)
            case .tilt:
                camTilt = Servo(with: servo.config)
            }
        }
    }

    func startPolling() {
        guard !isRunning else {
            return
        }

        isRunning = true

        print("Starting Rover client.")
        client.start()

        // this can be better - we want to set the light bar to the
        // initial color of the UI
        setLightBar(to: getColorFromHueValue(0.5))

        poller = Timer.scheduledTimer(withTimeInterval: config.pollRate, repeats: true) { _ in
            let latestData = self.fetchNewValues()
            self.client.send(latestData)
            self.subscriber?.received(latestData)
        }
    }

    private func fetchNewValues() -> RoverData {
        if let steering = controlDelegate?.getSteeringValue() {
            let frontValue: Float
            let rearValue: Float

            switch steeringMode {
            case .front:
                frontValue = steering
                rearValue = 0
            case .frontAndRear:
                frontValue = steering
                rearValue = steering
            case .rear:
                frontValue = 0
                rearValue = steering
            }

            self.frontSteering?.setValue(frontValue)
            self.rearSteering?.setValue(rearValue)
        }

        if let drivetrain = controlDelegate?.getDrivetrainValue() {
            self.drivetrain?.setValue(drivetrain)
        }


        if let pan = cameraDelegate?.getPanValue() {
            self.camPan?.setValue(pan)
        }

        if let tilt = cameraDelegate?.getTiltValue() {
            self.camTilt?.setValue(tilt)
        }


        return RoverData(
            controls: (drivetrain: drivetrain, frontSteering: frontSteering, rearSteering: rearSteering),
            camera: (pan: camPan, tilt: camTilt)
        )
    }

    func stopPolling() {
        guard isRunning else {
            return
        }

        isRunning = false

        print("Stopping Rover client.")
        client.stop()
        poller?.invalidate()
    }

    func setLightBar(to color: UIColor) {
        let lightBar = Light(color: color)
        client.send(lightBar)
    }

    func changeSteeringMode(to mode: RoverSteeringMode) {
        switch mode {
        case .front:
            steeringMode = .front
        case .frontAndRear where hasRearSteering == true:
            steeringMode = .frontAndRear
        case .rear where hasRearSteering == true:
            steeringMode = .rear
        default:
            print("Invalid steering mode!")
            break
        }
    }
}

struct RoverData {
    let controls: (drivetrain: Servo?, frontSteering: Servo?, rearSteering: Servo?)
    let camera: (pan: Servo?, tilt: Servo?)

    func toServoArray() -> [Servo] {
        return [
            controls.drivetrain,
            controls.frontSteering,
            controls.rearSteering,
            camera.pan,
            camera.tilt
        ].compactMap { $0 }
    }
}

enum RoverSteeringMode: CaseIterable {
    case front, frontAndRear, rear
}

protocol RoverControlDelegate {
    // functions should return values -1.0 to 1.0
    // left should be the negative value
    func getSteeringValue() -> Float?
    // reverse should be the negative value
    func getDrivetrainValue() -> Float?
}

protocol RoverCameraDelegate {
    // functions should return values -1.0 to 1.0
    // left should be the negative value
    func getPanValue() -> Float?
    // down should be the negative value
    func getTiltValue() -> Float?
}

protocol RoverSubscriber {
    func received(_ roverData: RoverData)
}
