//  TodayViewController.swift

import UIKit
import NotificationCenter
import KeychainSwift
import Alamofire

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
		
		guard let username = keychain.get("username"), let password = keychain.get("password") else {
			self.label.text = "Please provide credentials."
			completionHandler(.failed)
			return
		}
		
		// ## Step 1: get the authenticity_token from https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in
		Alamofire.request("https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in").responseData { response in
			if let data = response.data, let html = String(data: data, encoding: .utf8) {
				// ## Step 2: sign in with the token to https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in
				let needle = "name=\"authenticity_token\" value=\""
				let parameters = [
					"authenticity_token": self.extract(from: html, between: needle, and: "\""),
					"user[id]": username,
					"user[password]":	password,
					"user[reseller]":	"33",
				]
				
				Alamofire.request("https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in", method: .post, parameters: parameters, encoding: URLEncoding.default).responseData { response in
					switch response.result {
					case .success:
						if let data = response.data, let html = String(data: data, encoding: .utf8) {
							if (html.contains("error__title")) {
								self.label.text = "Invalid username or password"
								completionHandler(.failed)
								return
							}
							
							let needle = "ecareLib.Animation.ProgressBar.COLOR_GREEN,"
							let usageWidgetData = self.extract(from: html, between: needle, and: ");")
							let parts = usageWidgetData.components(separatedBy: ",")
							let usedFloat = Double(parts[1].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
							let used = Int64(usedFloat * 1024 * 1024)
							let totalFloat = Double(parts[2].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
							let total = Int64(totalFloat * 1024 * 1024)
							let bcf = ByteCountFormatter()
							bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
							bcf.countStyle = .binary
							let usedMB = bcf.string(fromByteCount: used)
							let totalMB = bcf.string(fromByteCount: total)
							let remainingMB = bcf.string(fromByteCount: total-used)
							// print("Data Used: \(usedMB) of \(totalMB)")
							// self.usedField.stringValue = "Used \(usedMB) of \(totalMB)"
							
							// self.progressBar.maxValue = totalFloat
							// self.progressBar.doubleValue = usedFloat
							
							// Calculate remaining days, by getting this months range
							let interval = Calendar.current.dateInterval(of: .month, for: Date())!
							let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: interval.end).day!
							// self.remainingField.stringValue = "\(remainingMB) remaining for \(remainingDays) Days"
							
							self.label.text = "Used \(usedMB) of \(totalMB)"
							completionHandler(NCUpdateResult.newData)
							DispatchQueue.main.async {
								spinner.stopAnimating()
							}
						}
					case .failure(let error):
						print(error)
						completionHandler(.failed)
					}
				}
			}
		}
		
		print("widgetPerformUpdate")
	}

	func extract(from: String, between: String, and: String) -> String {
		if let range = from.range(of: between) {
			let substring = from[range.upperBound..<from.endIndex]
			if let range2 = substring.range(of: and) {
				let s = substring[..<range2.lowerBound]
				return String(s)
			}
		}
		return ""
	}
	
}
