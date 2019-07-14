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

    private var data: RoverData {
        return RoverData(
            controls: (drivetrain?.valueInDegrees ?? 90, frontSteering?.valueInDegrees ?? 90),
            camera: (camPan?.valueInDegrees ?? 90, camTilt?.valueInDegrees ?? 90)
        )
    }

    init(config: RoverConfig) {
        self.config = config

        client = UDPClient(host: config.host, port: config.port)

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

        poller = Timer.scheduledTimer(withTimeInterval: RoverConfig.pollRate, repeats: true) { _ in
            self.fetchNewValues()

            self.client.send(self.data)
            self.subscriber?.receivedLatest(self.data)
        }
    }

    private func fetchNewValues() {
        if let controlDelegate = self.controlDelegate {
            if let steering = controlDelegate.getSteeringValue() {
                self.frontSteering?.setValue(steering)
            }

            if let drivetrain = controlDelegate.getDrivetrainValue() {
                self.drivetrain?.setValue(drivetrain)
            }
        }

        if let cameraDelegate = self.cameraDelegate {
            if let pan = cameraDelegate.getPanValue() {
                self.camPan?.setValue(pan)
            }

            if let tilt = cameraDelegate.getTiltValue() {
                self.camTilt?.setValue(tilt)
            }
        }
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
}

struct RoverData {
    let controls: (drivetrain: Int, steering: Int)
    let camera: (pan: Int, tilt: Int)
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
    func receivedLatest(_ roverData: RoverData)
}
