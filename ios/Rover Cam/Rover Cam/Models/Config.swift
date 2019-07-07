import Foundation


struct RoverConfig: Decodable {
    static let pollRate: TimeInterval = 1/60
    
    let host: String
    let port: String
    
    let camera: CameraConfig
    let servos: [DrivetrainServo]
    let lights: [LightConfig]
}

struct CameraConfig: Decodable {
    let mjpegUrl: URL
    let servos: [CameraServo]
}

struct ServoConfig: Decodable {
    let id: Int
    let min: Int
    let max: Int
    let center: Int
}

struct LightConfig: Decodable {
    let id: Int
    let numLights: Int
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
