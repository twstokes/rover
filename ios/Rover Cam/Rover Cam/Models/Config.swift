import Foundation


struct RoverConfig: Decodable {
    var pollRate: TimeInterval {
        return 1 / pollHz
    }
    
    let host: String
    let port: String
    private let pollHz: Double
    
    let camera: CameraConfig
    let servos: [DrivetrainServo]
    let lights: [LightConfig]
}

struct CameraConfig: Decodable {
    let mjpegUrl: URL
    let servos: [CameraServo]

    var canPan: Bool {
        return servos.contains { $0.type == .pan }
    }

    var canTilt: Bool {
        return servos.contains { $0.type == .tilt }
    }
}

struct ServoConfig: Decodable {
    let id: Int
    let min: Float
    let max: Float
    let trim: Float
    let inverted: Bool
}

struct LightConfig: Decodable {
    let id: Int
    let numLights: Int
    let description: String
}

struct DrivetrainServo: Decodable {
    let type: DrivetrainServoType
    let config: ServoConfig
}

struct CameraServo: Decodable {
    let type: CameraServoType
    let config: ServoConfig
}

enum DrivetrainServoType: String, Decodable {
    case forwardReverse, steeringFront, steeringRear
}

enum CameraServoType: String, Decodable {
    case pan, tilt
}

func loadConfig() -> RoverConfig {
    guard
        let url = Bundle.main.url(forResource: "config", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let config = try? JSONDecoder().decode(RoverConfig.self, from: data)
    else {
        fatalError()
    }

    return config
}
