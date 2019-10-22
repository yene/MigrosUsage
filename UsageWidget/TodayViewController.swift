//  TodayViewController.swift

import UIKit
import NotificationCenter
import KeychainSwift
import Alamofire


let spinner = UIActivityIndicatorView(style: .whiteLarge)

/* For disabling Alamofire certificate check
let serverTrustPolicies: [String: ServerTrustPolicy] = [
"selfcare.m-budget.migros.ch": .disableEvaluation
]
let sessionManager = SessionManager(
serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
)
*/

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet weak var label: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		spinner.hidesWhenStopped = true
		self.view.addSubview(spinner)
		spinner.center = self.view.center
		spinner.startAnimating()
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		self.label.text = ""
		self.label.textAlignment = .left
		spinner.startAnimating()
		
		let keychain = KeychainSwift()
		keychain.accessGroup = "NDJHDNKXD6.dev.yannick.MigrosUsage"
		
		guard let username = keychain.get("username"), let password = keychain.get("password") else {
			self.label.text = NSLocalizedString("Please provide credentials.", comment: "")
			completionHandler(.failed)
			return
		}
		getMigrosUsage(username: username, password: password) { error, data in
			if (error != "") {
				self.label.textAlignment = .center
				self.label!.text = error
				spinner.stopAnimating()
				completionHandler(.failed)
				return
			}
			DispatchQueue.main.async {
				let percentage = Int(round((data.used / data.total) * 100))
				self.label!.text = "\(percentage)% " + usageTextGB(totalFloat: data.total, usedFloat: data.used)
				spinner.stopAnimating()
				completionHandler(.newData)
			}
		}
	}
}
