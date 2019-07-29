//  TodayViewController.swift

import UIKit
import NotificationCenter
import KeychainSwift

let spinner = UIActivityIndicatorView(style: .whiteLarge)

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet weak var label: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("viewdidload")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		spinner.hidesWhenStopped = true
		// spinner.startAnimating()
		self.view.addSubview(spinner)
		spinner.center = self.view.center
		print("viewDidAppear")
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		let keychain = KeychainSwift()
		keychain.accessGroup = "NDJHDNKXD6.dev.yannick.MigrosUsage"
		
		guard let username = keychain.get("username"), let password = keychain.get("username") else {
			self.label.text = "Please provide credentials."
			completionHandler(.failed)
			return
		}
		
		print(username, password)
		
		// Perform any setup necessary in order to update the view.
	
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
	
		DispatchQueue.main.async {
			spinner.stopAnimating()
		}
		
		
		print("widgetPerformUpdate")
		completionHandler(NCUpdateResult.newData)
	}
	func getData() {
		
		
		
		
		
	}
    
}
