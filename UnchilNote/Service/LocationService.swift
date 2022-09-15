//
//  LocationController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

	static let service = LocationService()

	private override init() {
		super.init()
		self.cLLocationManager.delegate = self
		self.cLLocationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.cLLocationManager.requestWhenInUseAuthorization()
	}

	var cLLocationManager  = CLLocationManager()
	var completionHandler: ((CLLocation) -> (Void))?

	func requestLocation(completion: @escaping ((CLLocation) -> (Void))) {
		self.completionHandler = completion
		self.cLLocationManager.requestLocation()
	}


	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
			case .notDetermined, .restricted, .denied:
				return
			case .authorizedAlways, .authorizedWhenInUse:
				self.cLLocationManager.startUpdatingLocation()
			@unknown default:
				self.cLLocationManager.requestWhenInUseAuthorization()
		}

	//	print(#function, status.name)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }

		if let completion = self.completionHandler {
				completion(location)
		}

		self.cLLocationManager.stopUpdatingLocation()
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(#function, error.localizedDescription)
	}



}
