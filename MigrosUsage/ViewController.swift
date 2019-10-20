//  ViewController.swift

import UIKit
import KeychainSwift
import UICircularProgressRing

class ViewController: UIViewController {
	@IBOutlet weak var removeCredentialsButton: UIButton?
	@IBOutlet weak var circleView: UICircularProgressRing?
	@IBOutlet weak var errorLabel: UILabel?
	@IBOutlet weak var valueLabel: UILabel?
	
	@IBAction func removeCredentials(sender: UIButton) {
		let dialogMessage = UIAlertController(title: NSLocalizedString("Confirm", comment: ""), message: NSLocalizedString("Are you sure?", comment: ""), preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) -> Void in
			let keychain = KeychainSwift()
			keychain.clear()
			self.performSegue(withIdentifier: "gotoLogin", sender:self)
		})
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
		dialogMessage.addAction(okAction)
		dialogMessage.addAction(cancelAction)
		self.present(dialogMessage, animated: true, completion: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.errorLabel!.isHidden = true
		let cv = self.circleView!
		cv.style = .dashed(pattern: [10.0, 10.0])
		cv.isHidden = false
		
		let keychain = KeychainSwift()
		if let username = keychain.get("username"), let password = keychain.get("password") {
			print("found username in Keychain")
			getMigrosUsage(username: username, password: password) { error, data in
				if (error != "") {
					self.errorLabel!.isHidden = false
					self.errorLabel!.text = error
					self.circleView!.isHidden = true
					return
				}
				
				let percentage = round((data.used / data.total) * 100)
				let percentageInt = Int(percentage) // remove trailing .0
				self.valueLabel!.text = "\(percentageInt)%"
				print(percentage)
				cv.startProgress(to: CGFloat(percentage), duration: 2.0)
			}
			
			return
		}
		print("username does not exist in keychain")
		self.performSegue(withIdentifier: "gotoLogin", sender:self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//let progressRing = UICircularProgressRing()
		// Change any of the properties you'd like
		//progressRing.maxValue = 50
		//progressRing.style = .dashed(pattern: [7.0, 7.0])
		//self.view.addSubview(progressRing)
		//progressRing.center = self.view.center
		// topLeftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		// topLeftLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
	}
}
