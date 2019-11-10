//  TodayViewController.swift

import UIKit
import NotificationCenter
import KeychainSwift
import Alamofire

/* # notes on today widget
* Since iOS 10 extension's height is 110 pixels
*/

let spinner = UIActivityIndicatorView(style: .whiteLarge)

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet weak var label: UILabel!
	var labelHeight: CGFloat = 0.0;
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		spinner.hidesWhenStopped = true
		self.view.addSubview(spinner)
		spinner.center = self.view.center
		spinner.startAnimating()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		labelHeight = self.label.frame.size.height
		if (labelHeight > 110) {
			extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
		}
	}
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		
		if (activeDisplayMode == NCWidgetDisplayMode.compact) {
			self.preferredContentSize = maxSize;
		} else {
			self.preferredContentSize = CGSize(width: 0, height: labelHeight + 5.0);
		}
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
		getUsageFromPortal(username: username, password: password) { error, data in
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
