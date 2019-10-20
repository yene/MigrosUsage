//  ViewController.swift

import UIKit
import KeychainSwift
import UICircularProgressRing

class ViewController: UIViewController {
	@IBOutlet weak var removeCredentialsButton: UIButton?
	@IBOutlet weak var circleView: UICircularProgressRing?
	@IBOutlet weak var errorLabel: UILabel?
	@IBOutlet weak var usageLabel: UILabel?
	
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
		cv.style = .ontop
		cv.isHidden = false
		cv.font = UIFont.systemFont(ofSize: 70.0, weight: .bold)
		
		
		let keychain = KeychainSwift()
		guard let username = keychain.get("username"), let password = keychain.get("password") else {
			self.performSegue(withIdentifier: "gotoLogin", sender:self)
			return
		}
			
		getMigrosUsage(username: username, password: password) { error, data in
			if (error != "") {
				self.errorLabel!.isHidden = false
				self.errorLabel!.text = error
				self.circleView!.isHidden = true
				return
			}
			
			self.usageLabel!.text = usageTextGB(totalFloat: data.total, usedFloat: data.used)
			

			let percentage = round((data.used / data.total) * 100)
			cv.startProgress(to: CGFloat(percentage), duration: 2.0)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}
