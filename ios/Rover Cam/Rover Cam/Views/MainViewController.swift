import UIKit
import WebKit

class MainViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    @IBOutlet weak var steering: UILabel!
    @IBOutlet weak var drivetrain: UILabel!

    @IBOutlet weak var cameraPan: UILabel!
    @IBOutlet weak var cameraTilt: UILabel!

    @IBOutlet weak var outputView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSlider: UISlider!

    var rover: Rover?
    let attitude = AttitudeProcessor(updateInterval: RoverConfig.pollRate)

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

        if config.camera.canPan && config.camera.canTilt {
            // only set this delegate if we have pan and tilt servos
            rover.cameraDelegate = attitude
        }

        rover.subscriber = self

        webView.load(URLRequest(url: config.camera.mjpegUrl))
        webView.isHidden = false
        attitude.start()
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
        attitude.stop()
        rover?.stopPolling()
        rover = nil

        UIView.animate(withDuration: 0.5) {
            self.outputView.alpha = 0
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
    func receivedLatest(_ roverData: RoverData) {
        steering.text = roverData.controls.steering.description + "°"
        drivetrain.text = ((90 - roverData.controls.drivetrain) / 90 * 100).description + "%"

        cameraPan.text = roverData.camera.pan.description + "°"
        cameraTilt.text = roverData.camera.tilt.description + "°"
    }
}
