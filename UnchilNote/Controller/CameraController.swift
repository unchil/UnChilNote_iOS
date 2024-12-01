//
//  Camera.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI


class CameraController: ObservableObject {


	@Published var photo: Photo!
	@Published var photos:[Photo] = []
	@Published var showAlertError = false
	@Published var isFlashOn = false

	var alertError: AlertError!

	var session: AVCaptureSession
	private let service = CameraService()


	private var subscriptions = Set<AnyCancellable>()

	init() {

		self.session = service.session

		service.$photo.sink{ [weak self] (photo) in
			guard let pic = photo else { return }
			self?.photo = pic
		}.store(in: &self.subscriptions)

		service.$photos.sink { [weak self] (photos) in
			self?.photos = photos
		}.store(in: &self.subscriptions)

		service.$shouldShowAlertView.sink{ [weak self] (val) in
			self?.alertError = self?.service.alertError
			self?.showAlertError = val
		}.store(in: &self.subscriptions)

		service.$flashMode.sink { [weak self] (mode) in
			self?.isFlashOn = mode == .on
		}.store(in: &self.subscriptions)

		self.configure()


	}


	func configure() {
		service.checkForPermissions()
		service.configureSession()
	}

	func capturePhoto() {
		service.capturePhoto()
	}

	func flipCamera() {
		service.changeCamera()
	}

	func zoom(with factor: CGFloat) {
		service.set(zoom: factor)
	}

	func switchFlash(){
		service.flashMode = service.flashMode == .on ? .off : .on
	}

	func getPhotos() -> [ImageView] {
		self.photos.map { photo in
			ImageView(image: photo.image )
		}
	}

	func getPhoto() -> ImageView {
		ImageView(image: self.photo.image )
	}

	func setOrientation(orientatiion: AVCaptureVideoOrientation){
		service.orientation = orientatiion
	}

}

