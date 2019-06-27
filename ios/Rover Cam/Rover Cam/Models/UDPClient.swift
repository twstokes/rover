import Foundation
import Network

struct UDPClient {
    private let connection: NWConnection
    private let maxPayload = 8

    private let udpQueue = DispatchQueue(label: "udpQueue", attributes: [], autoreleaseFrequency: .workItem)


    init(host: String, port: String) {
        let nwHost = NWEndpoint.Host(host)
        guard let nwPort = NWEndpoint.Port(port) else {
            fatalError("Invalid port defined.")
        }

        connection = NWConnection(host: nwHost, port: nwPort, using: .udp)
    }

    func start() {
        connection.start(queue: udpQueue)
    }

    func stop() {
        connection.cancel()
    }

    static func controlsAndCameraPayload(from roverData: RoverData) -> UDPPayload {
        let payload = UDPPayload(
            command: 1,
            values: [
                roverData.controls.steering,
                roverData.controls.drivetrain,
                roverData.camera.pan,
                roverData.camera.tilt
            ]
        )

        return payload
    }

    func send(_ roverData: RoverData) {
        // controls and camera payload
        let payload = UDPClient.controlsAndCameraPayload(from: roverData)

        send(payload) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }

    func send(_ light: Light) {
        send(light.payload) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }

    private func send(_ payload: UDPPayload, completion: @escaping (Error?) -> Void) {
        let data = payload.toData()

        guard data.count <= maxPayload else {
            print("Error! Maximum payload would be exceeded when trying to send!")
            completion(UDPError.maxPayloadExceeded)
            return
        }

        connection.send(content: data, completion: .contentProcessed(completion))
    }
}

// payload processed by the rover
struct UDPPayload {
    let command: UInt8
    let values: [Int]

    func toData() -> Data {
        let uint8Values = values.map { UInt8($0) }
        return Data([command] + uint8Values)
    }
}

enum UDPError: Error {
    case maxPayloadExceeded
}
