//  LoginViewController.swift

import UIKit
import KeychainSwift

class LoginViewController: UIViewController {
	@IBOutlet weak var usernameInput: UITextField?
	@IBOutlet weak var passwordInput: UITextField?

	@IBAction func login(sender: UIButton) {
		let keychain = KeychainSwift()
		if let username = usernameInput!.text, let password = passwordInput!.text {
			keychain.set(username, forKey: "username")
			keychain.set(password, forKey: "password")
			print(username, password)
			self.navigationController?.popViewController(animated: true)
		} else {
			// TODO: improve error handling
			print("show error dialog")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.usernameInput?.becomeFirstResponder()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
			// Get the new view controller using segue.destination.
			// Pass the selected object to the new view controller.
	}
	*/
}
