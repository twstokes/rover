import UIKit
import WebKit

class MainViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    @IBOutlet weak var steering: UILabel!
    @IBOutlet weak var drivetrain: UILabel!

    @IBOutlet weak var cameraStack: UIStackView!
    @IBOutlet weak var cameraPan: UILabel!
    @IBOutlet weak var cameraTilt: UILabel!

    @IBOutlet weak var outputView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSlider: UISlider!

    var rover: Rover?
    var attitude: AttitudeProcessor?
    let joystick = JoystickProcessor()

    var powerOn = false {
        didSet {
            if powerOn {
                startRover()
            } else {
                stopRover()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        steering.text = ""
        drivetrain.text = ""
        cameraPan.text = ""
        cameraTilt.text = ""

        webView.isUserInteractionEnabled = false
        webView.isOpaque = false
        webView.isHidden = true

        let color = getColorFromHueValue(colorSlider.value)
        colorView.layer.cornerRadius = 8.0
        colorView.backgroundColor = color

        outputView.alpha = 0
        powerOn = false
    }

    func startRover() {
        let config = loadConfig()
        let rover = Rover(config: config)

        if rover.canPanTiltCamera {
            attitude = AttitudeProcessor(updateInterval: config.pollRate)
            // only set this delegate if we have pan and tilt servos
            rover.cameraDelegate = attitude
            attitude?.start()
        } else {
            cameraStack.isHidden = true
        }

        if !rover.hasLights {
            colorView.isHidden = true
            colorSlider.isHidden = true
        }

        rover.controlDelegate = joystick
        rover.subscriber = self

        webView.load(URLRequest(url: config.camera.mjpegUrl))
        webView.isHidden = false

        rover.startPolling()

        self.rover = rover

        UIView.animate(withDuration: 0.5) {
            self.outputView.alpha = 1.0
        }
    }

    func stopRover() {
        webView.stopLoading()
        // prevent a reload flicker when toggling back on
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        webView.isHidden = true
        attitude?.stop()
        rover?.stopPolling()
        
        rover = nil

        UIView.animate(withDuration: 0.5) {
            self.outputView.alpha = 0
        }
    }

    @IBAction func steeringModeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            rover?.setSteeringMode(to: .front)
        case 1:
            rover?.setSteeringMode(to: .frontAndRear)
        case 2:
            rover?.setSteeringMode(to: .rear)
        default:
            rover?.setSteeringMode(to: .front)
        }
    }

    @IBAction func powerToggled(_ toggle: UISwitch) {
        powerOn = toggle.isOn
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func hueChanged(_ slider: UISlider) {
        let color = getColorFromHueValue(slider.value)

        colorView.backgroundColor = color
        rover?.setLightBar(to: color)
    }
}

extension MainViewController: RoverSubscriber {
    func received(_ roverData: RoverData) {
        if let frontSteering = roverData.controls.frontSteering?.valueInDegrees {
            self.steering.text = frontSteering.description + "°"
        }

        if let drivetrain = roverData.controls.drivetrain?.valueInDegrees {
            self.drivetrain.text = (-Int((Float(drivetrain) - 90) / 90 * 100)).description + "%"
        }

        if let camPan = roverData.camera.pan?.valueInDegrees {
            self.cameraPan.text = camPan.description + "°"
        }

        if let camTilt = roverData.camera.tilt?.valueInDegrees {
            self.cameraTilt.text = camTilt.description + "°"
        }
    }
}
