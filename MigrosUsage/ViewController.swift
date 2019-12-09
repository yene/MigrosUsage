//  ViewController.swift

import UIKit
import KeychainSwift
import UICircularProgressRing
import AVFoundation
import AVKit

class ViewController: UIViewController {
	@IBOutlet weak var removeCredentialsButton: UIButton?
	@IBOutlet weak var circleView: UICircularProgressRing?
	@IBOutlet weak var errorLabel: UILabel?
	@IBOutlet weak var usageLabel: UILabel?
	
	@IBAction func removeCredentials(sender: UIButton) {
		let alertController = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .alert)
		
		let removeAction = UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .destructive, handler: { (action) -> Void in
			let keychain = KeychainSwift()
			keychain.clear()
			self.performSegue(withIdentifier: "gotoLogin", sender:self)
		})
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default)
		alertController.addAction(cancelAction)
		alertController.addAction(removeAction)
		alertController.preferredAction = removeAction
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func unwindToVC(segue: UIStoryboardSegue) {
		// how to make an unwind... https://stackoverflow.com/questions/12509422/how-to-perform-unwind-segue-programmatically
		let result = getData()
		if !result {
			self.performSegue(withIdentifier: "gotoLogin", sender:self)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.errorLabel!.isHidden = true
		self.circleView!.isHidden = false
		let cv = self.circleView!
		cv.style = .ontop
		cv.isHidden = false
		cv.font = UIFont.systemFont(ofSize: 70.0, weight: .bold)
		
		let result = getData()
		if !result {
			self.performSegue(withIdentifier: "gotoLogin", sender:self)
		}
	}
	
	func getData() -> Bool {
		let keychain = KeychainSwift()
		guard let username = keychain.get("username"), let password = keychain.get("password") else {
			return false
		}
		
		if username == "" || password == "" {
			return false
		}
		
		let cv = self.circleView!
		cv.startProgress(to: 100, duration: 10.0) { // NOTE: use a similar timeout as Alamofire
		}
		
		getUsageFromPortal(username: username, password: password) { error, data in
			if (error != "") {
				self.errorLabel!.isHidden = false
				self.errorLabel!.text = error
				self.circleView!.isHidden = true
				return
			}
			
			self.usageLabel!.text = usageTextGB(totalFloat: data.total, usedFloat: data.used)
			let dataRemaing = data.total - data.used
			let percentage = round((dataRemaing / data.total) * 100)
			cv.shouldShowValueText = true
			cv.startProgress(to: CGFloat(percentage), duration: 2.0)
		}
		return true
	}
	
	let playerController = AVPlayerViewController()
	
	private func playVideo() {
		// Mix audio with others, to prevent stopping them
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [AVAudioSession.CategoryOptions.mixWithOthers])
		guard let path = Bundle.main.path(forResource: "how-to-add-widget", ofType: "mp4") else { return }
		let player = AVPlayer(url: URL(fileURLWithPath: path))
		player.isMuted = true
		playerController.player = player
		playerController.showsPlaybackControls = true
		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
		
		present(playerController, animated: true) {
			player.play()
		}
	}
	
	@objc func playerDidFinishPlaying(note: NSNotification) {
		playerController.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func playTutorial(sender: UIButton) {
		playVideo()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}
