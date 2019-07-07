import Foundation
import UIKit

class Rover {
    private let config: RoverConfig

    private let client: UDPClient
    private var poller: Timer?

    private let steering = Servo()
    private let drivetrain = Servo()

    private let camPan = Servo()
    private let camTilt = Servo()

    private(set) var isRunning = false

    var controlDelegate: RoverControlDelegate?
    var cameraDelegate: RoverCameraDelegate?

    var subscriber: RoverSubscriber?

    private var data: RoverData {
        return RoverData(
            controls: (drivetrain.value, steering.value),
            camera: (camPan.value, camTilt.value)
        )
    }

    init(config: RoverConfig) {
        self.config = config

        client = UDPClient(host: config.host, port: config.port)
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
                self.steering.setValue(steering)
            }

            if let drivetrain = controlDelegate.getDrivetrainValue() {
                self.drivetrain.setValue(drivetrain)
            }
        }

        if let cameraDelegate = self.cameraDelegate {
            if let pan = cameraDelegate.getPanValue() {
                self.camPan.setValue(pan)
            }

            if let tilt = cameraDelegate.getTiltValue() {
                self.camTilt.setValue(tilt)
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
    func getSteeringValue() -> Int?
    func getDrivetrainValue() -> Int?
}

protocol RoverCameraDelegate {
    func getPanValue() -> Int?
    func getTiltValue() -> Int?
}

protocol RoverSubscriber {
    func receivedLatest(_ roverData: RoverData)
}
