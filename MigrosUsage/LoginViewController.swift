//  LoginViewController.swift

import UIKit
import KeychainSwift
import NotificationCenter

class LoginViewController: UIViewController {
	@IBOutlet weak var usernameInput: UITextField?
	@IBOutlet weak var passwordInput: UITextField?
	
	@IBAction func login(sender: UIButton) {
		let keychain = KeychainSwift()
		
		if let username = usernameInput!.text, let password = passwordInput!.text {
			keychain.set(username, forKey: "username")
			keychain.set(password, forKey: "password")
			// inform widget to load
			NCWidgetController().setHasContent(true, forWidgetWithBundleIdentifier: "dev.yannick.MigrosUsage.UsageWidget")
			self.performSegue(withIdentifier: "closeLogin", sender:self)
		} else {
			// TODO: improve error handling
			print("username or password not valid")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.usernameInput?.becomeFirstResponder()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

}
