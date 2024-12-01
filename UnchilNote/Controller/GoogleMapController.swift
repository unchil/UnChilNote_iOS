//
//  GoogleMapController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import Foundation
import SwiftUI
import GoogleMaps

class GoogleMapController: UIViewController {

	let map =  GMSMapView(frame: .zero)
	var isAnimating: Bool = false

	override func loadView() {
		super.loadView()
		map.isMyLocationEnabled = true
		self.view = map
	}
}

struct GoogleMapControllerBridge : UIViewControllerRepresentable {

	@Binding var markers: [GMSMarker]
	@Binding var selectedMarker: GMSMarker?
	@Binding var isDidTap:Bool
	//var zoomLevel:Float
	@Binding var zoomLevel:Float
	var isWriteMemo:Bool

//	var onAnimationEnded: () -> ()
//	var mapViewWillMove: (Bool) -> ()

	func makeUIViewController(context: Context) -> GoogleMapController {

	  let uiViewController = GoogleMapController()
		uiViewController.map.delegate = context.coordinator
	  return uiViewController

	}

	func updateUIViewController(_ uiViewController: GoogleMapController, context: Context) {

		self.markers.forEach { $0.map = uiViewController.map }
		self.selectedMarker?.map = uiViewController.map

		if self.isWriteMemo {
			uiViewController.map.clear()
			self.selectedMarker?.map = uiViewController.map
		}

		self.updateSelectedMarker(viewController: uiViewController)
	}


	private func updateSelectedMarker(viewController: GoogleMapController) {

		guard let selectedMarker = self.selectedMarker else { return }


		if viewController.map.selectedMarker != selectedMarker {
			viewController.map.selectedMarker = selectedMarker
			viewController.map.moveCamera(GMSCameraUpdate.setTarget(selectedMarker.position, zoom: self.zoomLevel))
/*
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				map.animate(toZoom: kGMSMinZoomLevel)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					map.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
						map.animate(toZoom: self.zoomLevel)
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
						// Invoke onAnimationEnded() once the animation sequence completes
						 onAnimationEnded()
						})
					})
				}
			}
*/
		}
	}


	final class MapViewCoordinator: NSObject, GMSMapViewDelegate {

		var mapViewControllerBridge: GoogleMapControllerBridge

		init(_ mapViewControllerBridge: GoogleMapControllerBridge) {
			self.mapViewControllerBridge = mapViewControllerBridge
		}

		func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
		//  self.mapViewControllerBridge.mapViewWillMove(gesture)
		}

		func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
			if self.mapViewControllerBridge.isWriteMemo {
				self.mapViewControllerBridge.selectedMarker = GMSMarker(position: position.target)
				 self.mapViewControllerBridge.zoomLevel = mapView.camera.zoom
			 }
		}

		func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
			self.mapViewControllerBridge.isDidTap = false
		}

		func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
			self.mapViewControllerBridge.isDidTap.toggle()
		}

		func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		//	print("You tapped at \(marker.position.latitude), \(marker.position.longitude)")
			self.mapViewControllerBridge.selectedMarker = marker
			self.mapViewControllerBridge.isDidTap.toggle()

			return false
		}

		func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
			if self.mapViewControllerBridge.isWriteMemo {
				mapView.clear()
				self.mapViewControllerBridge.selectedMarker = GMSMarker(position: coordinate)
			}

		//	print("You longPress at \(coordinate.latitude), \(coordinate.longitude)")
		}

	}

	func makeCoordinator() -> MapViewCoordinator {
	  return MapViewCoordinator(self)
	}

}
