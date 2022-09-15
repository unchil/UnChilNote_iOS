//
//  GMSModel.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//

import Foundation
import GoogleMaps

class GMSMarkerController: ObservableObject {

	@Published var currentMarker: GMSMarker?
	@Published var markers: [GMSMarker] = []

	func setMarkers(results:[Entity_Memo], completionHandler: @escaping (Bool) -> Void ){
		self.markers.removeAll()
		results.forEach { item in
			let headerInfo = item.toMemoHeaderData()
			let location = CLLocationCoordinate2D(latitude: headerInfo.latitude ,longitude: headerInfo.longitude )
			let marker = GMSMarker(position:location)
			marker.snippet = headerInfo.snippets
			marker.title = headerInfo.title
			marker.userData = GMSMarkerUserData(id: item.writetime, snapshotFileName: item.snapshotFileName!)
			self.markers.append(marker)
		}
		completionHandler(true)
	}


	func setCurrentMarker(location:CLLocation){
		self.currentMarker = GMSMarker(position: location.coordinate)
	}
}

struct GMSMarkerUserData {
	var id: Double = 0
	var snapshotFileName: String = ""
}
