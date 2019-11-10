import Foundation
import Alamofire

let useGB = true // We display only GB, so to not confuse older people.

struct Usage {
	let total: Double
	let used: Double
}

// NOTE: with Alamofire 5 the errors should be AFError
let manager: SessionManager = {
	let config = URLSessionConfiguration.default
	config.timeoutIntervalForRequest = 10
	config.timeoutIntervalForResource = 30
	return Alamofire.SessionManager(configuration: config)
}()

// getUsageFromPortal
// Logs into the ISPs portal and extracts the usage data from HTML.
// completion is a closure with first parameter Error string (empty if no error), second parameter is the data.
func getUsageFromPortal(username: String, password: String, completion: @escaping (String, Usage) -> Void) {
	
	// Step 1: Extract the authenticity_token from HTML
	manager.request("https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in").responseData { response in
		switch response.result {
		case .success:
			()
		case .failure(let error):
			let nserr = error as NSError
			completion(nserr.localizedDescription, Usage(total: 0.0, used: 0.0))
			return
		}
		
		if let data = response.data, let html = String(data: data, encoding: .utf8) {
			// Step 2: sign in with the token to https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in
			let needle = "name=\"authenticity_token\" value=\""
			let parameters = [
				"authenticity_token": extract(from: html, between: needle, and: "\""),
				"user[id]": username,
				"user[password]":	password,
				"user[reseller]":	"33",
			]
			
			// Step 1: Log-in and extract usage from HTML.
			manager.request("https://selfcare.m-budget.migros.ch/eCare/de/users/sign_in", method: .post, parameters: parameters, encoding: URLEncoding.default).responseData { response in
				switch response.result {
				case .success:
					if let data = response.data, let html = String(data: data, encoding: .utf8) {
						if (html.contains("error__title")) {
							completion("Invalid username or password", Usage(total: 0.0, used: 0.0))
							return
						}
						
						let needle = "ecareLib.Animation.ProgressBar.COLOR_GREEN,"
						let usageWidgetData = extract(from: html, between: needle, and: ");")
						let parts = usageWidgetData.components(separatedBy: ",")
						let usedFloat = Double(parts[1].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
						let totalFloat = Double(parts[2].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
						let u = Usage(total: totalFloat, used: usedFloat)
						completion("", u)
					}
				case .failure(let error):
					let nserr = error as NSError
					completion(nserr.localizedDescription, Usage(total: 0.0, used: 0.0))
				}
			}
		}
	}
}

// new version of usage which returns GB with one fraction
// Example Values: total: 3072.0, used: 2162.4
func usageTextGB(totalFloat: Double, usedFloat: Double) -> String {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 1
	
	let totalGB = formatter.string(from: NSNumber(value: (totalFloat / 1024)))! + " GB"
	let usedGB = formatter.string(from: NSNumber(value: (usedFloat / 1024)))! + " GB"
	let remainingGB = formatter.string(from:  NSNumber(value:(totalFloat-usedFloat) / 1024))! + " GB"
	
	// Calculate remaining days, by getting this months range
	let interval = Calendar.current.dateInterval(of: .month, for: Date())!
	let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: interval.end).day!
	
	if remainingDays == 0 {
		return String(format: NSLocalizedString("usage-today", comment: ""), usedGB, totalGB, remainingGB)
	} else {
		return String(format: NSLocalizedString("usage-other", comment: ""), usedGB, totalGB, remainingGB, remainingDays)
	}
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
