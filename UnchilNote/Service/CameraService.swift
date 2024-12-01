//
//  CameraService.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

public class CameraService: ObservableObject {

	@Published public var shouldShowAlertView = false
	@Published public var shouldShowSpinner = false
	@Published public var willCapturePhoto = false
	@Published public var isCameraButtonDisabled = true
	@Published public var isCameraUnavailable = true
	@Published public var flashMode: AVCaptureDevice.FlashMode = .off
	@Published public var photo: Photo?
	@Published public var photos: [Photo] = []

	@Published public var orientation = AVCaptureVideoOrientation.portrait

	private let sessionQueue = DispatchQueue(label: "camera session queue")

	var sessionStatus: SessionStatus =
		.success( title: "Camera Accept",
				  message: "Camera Session Ready",
				  buttonTitle: "")

	var alertError = AlertError()

	let session = AVCaptureSession()

	@objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
	private let photoOutput = AVCapturePhotoOutput()
	private var isSessionRunning = false
	private var isConfigured = false


	private let videoDeviceDiscoverySession =
		AVCaptureDevice.DiscoverySession(
			deviceTypes: [.builtInWideAngleCamera],
			mediaType: .video,
			position: .unspecified )



	private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()

}

extension CameraService {

	func checkForPermissions() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .authorized:
				return
			case .notDetermined:
				sessionQueue.suspend()
				AVCaptureDevice.requestAccess(for: .video) { granted in
					if !granted {
						self.sessionStatus =
							.notAuthorized(title:"Permission Failed",
										   message:"Permission Not Authorized",
										   buttonTitle:"Accept")
					}
					self.sessionQueue.resume()
				}
			default:
				self.sessionStatus = .notAuthorized(title:"Permission Failed",
													message: "Permission Not Authorized",
													buttonTitle: "Accept")
				DispatchQueue.main.async {
					self.shouldShowAlertView = true
					self.isCameraUnavailable = true
					self.isCameraButtonDisabled = true
					self.alertError = AlertError(title:"Permission Failed",
												 message: "Permission Not Authorized",
												 primaryButtonTitle: "Accept",
												 secondaryButtonTitle: nil,
												 primaryAction: {
													UIApplication.shared.open(
														URL(string: UIApplication.openSettingsURLString)!,
														options: [:], completionHandler: nil)},
												 secondaryAction: nil)
				}
		}

	}
}

extension CameraService {

	func configureSession() {
		switch self.sessionStatus {
			case .success( _, _, _):
				ConfigurationTrans()
			default:
				return
		}
	}

	private func ConfigurationTrans(){
		self.session.beginConfiguration()

		self.session.sessionPreset = .photo


		guard let videoDevice: AVCaptureDevice =  {
			if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
				return backCameraDevice
			} else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
				return  frontCameraDevice
			} else {
				return nil
			}
		}() else {
			ConfigurationError(message: "Default video device is unavailable")
			return
		}

		do {
			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
			if self.session.canAddInput(videoDeviceInput) {
				self.session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
			} else {
				ConfigurationError(message: "Couldn't add video device input to the session.")
				return
			}
		} catch {
			ConfigurationError(message: "Couldn't add video device input to the session.")
			return
		}

		if self.session.canAddOutput(self.photoOutput) {
			self.session.addOutput(self.photoOutput)
			self.photoOutput.isHighResolutionCaptureEnabled = true
			self.photoOutput.maxPhotoQualityPrioritization = .quality
		} else {
			ConfigurationError(message: "Could not add photo output to the session.")
			return
		}

		self.session.commitConfiguration()
		self.isConfigured = true
		self.start()
	}


	private func ConfigurationError(message: String) {
		self.sessionStatus = .configurationFailed(title: "Configuration Failed", message: message, buttonTitle: "Accept")
		self.session.commitConfiguration()
	}

}


extension CameraService {

	func start() {
		if !self.isSessionRunning && self.isConfigured {
				switch self.sessionStatus {
					case .success( _, _, _):
						sessionQueue.async {
							self.session.startRunning()
							self.isSessionRunning = self.session.isRunning
							if self.session.isRunning {
								DispatchQueue.main.async {
									self.isCameraButtonDisabled = false
									self.isCameraUnavailable = false
								}
							 }
						} // sessionQueue.async
					case .notAuthorized(let title, let message, let buttonTitle),
						 .configurationFailed(let title, let message, let buttonTitle):
					DispatchQueue.main.async {
							self.shouldShowAlertView = true
							self.isCameraButtonDisabled = true
							self.isCameraUnavailable = true
							self.alertError = AlertError(title: title,
														 message: message,
														 primaryButtonTitle: buttonTitle,
														 secondaryButtonTitle: nil,
														 primaryAction: nil,
														 secondaryAction: nil)

					}
				} // switch

		}
	}// start

	func stop(completion: (()->())? = nil) {
		if self.isSessionRunning {
			switch self.sessionStatus {
				case .success( _, _, _):
					self.sessionQueue.async {
						self.session.stopRunning()
						self.isSessionRunning = self.session.isRunning

						if !self.session.isRunning {
							DispatchQueue.main.async {
								self.isCameraButtonDisabled = true
								self.isCameraUnavailable = true
								completion?()
							}
						}
					}
				default :
					return
			} // switch
		}
	}// stop

	func changeCamera() {

		DispatchQueue.main.async {
			self.isCameraButtonDisabled = true
		}

		sessionQueue.async {

			let avCaptureDeviceInfo :( preferredPosition:AVCaptureDevice.Position,
									   preferredDeviceType:AVCaptureDevice.DeviceType ) = {
				switch self.videoDeviceInput.device.position {
				case .unspecified, .front :
				   return ( AVCaptureDevice.Position.back, AVCaptureDevice.DeviceType.builtInWideAngleCamera )
				case .back :
				   return (AVCaptureDevice.Position.front, AVCaptureDevice.DeviceType.builtInWideAngleCamera )
				@unknown default :
				   return (AVCaptureDevice.Position.back, AVCaptureDevice.DeviceType.builtInWideAngleCamera )
				}
			} ()

			guard let videoDevice: AVCaptureDevice = {
				if let device = self.videoDeviceDiscoverySession.devices.first(where: {
					$0.position == avCaptureDeviceInfo.preferredPosition &&
					$0.deviceType == avCaptureDeviceInfo.preferredDeviceType
				}) {
					return device
				} else if let device = self.videoDeviceDiscoverySession.devices.first(where: {
					$0.position == avCaptureDeviceInfo.preferredPosition
				}) {
					return device
				} else {
					return nil
				}
			}() else {
				return
			}

			do {
				let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

				self.session.beginConfiguration()
				self.session.removeInput(self.videoDeviceInput)

				if self.session.canAddInput(videoDeviceInput) {
					self.session.addInput(videoDeviceInput)
					self.videoDeviceInput = videoDeviceInput
				} else {
					self.session.addInput(self.videoDeviceInput)
				}

				if let connection = self.photoOutput.connection(with: .video) {
					if connection.isVideoStabilizationSupported {
						connection.preferredVideoStabilizationMode = .auto
					}
				}
				self.photoOutput.maxPhotoQualityPrioritization = .quality
				self.session.commitConfiguration()


			} catch {
				self.ConfigurationError(message: "Couldn't add video device input to the session.")
				return
			}

			 DispatchQueue.main.async {
				 self.isCameraButtonDisabled = false
			 }
		}

	}

	public func set(zoom: CGFloat){
		let factor = zoom < 1 ? 1 : zoom
		do {
			try self.videoDeviceInput.device.lockForConfiguration()
			self.videoDeviceInput.device.videoZoomFactor = factor
			self.videoDeviceInput.device.unlockForConfiguration()
		} catch {
			print(error.localizedDescription)
		}
	}




}

extension CameraService {

	public func capturePhoto() {
		switch self.sessionStatus {
		case .configurationFailed(_,_,_):
			self.ConfigurationTrans()
			capture()
		default :
			capture()
		}
	}

	private func photoProcessingHandler(animate: Bool) {
		if animate {
			self.shouldShowSpinner = true
		} else {
			self.shouldShowSpinner = false
		}
	}

	private func willCapturePhotoAnimation() {
		DispatchQueue.main.async {
			self.willCapturePhoto.toggle()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
			self.willCapturePhoto.toggle()
		}
	}


	private func capture() {

		DispatchQueue.main.async {
			self.isCameraButtonDisabled = true
		}

		if let photoOutputConnection = self.photoOutput.connection(with: .video) {
			photoOutputConnection.videoOrientation = self.orientation
		}


		var photoSettings = AVCapturePhotoSettings()
		if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
			photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
		}
		if self.videoDeviceInput.device.isFlashAvailable {
			photoSettings.flashMode = self.flashMode
		}

		photoSettings.isHighResolutionPhotoEnabled = true
		if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
			photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String:
													photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
		}
		photoSettings.photoQualityPrioritization = .quality

		let photoCaptureProcessor = PhotoCaptureProcessor(
			requestedPhotoSettings: photoSettings,
			willCapturePhotoAnimation: self.willCapturePhotoAnimation,
			completionHandler: { (photoCaptureProcessor) in
				if let data = photoCaptureProcessor.photoData {
					self.photo = Photo(originalData: data)
					self.photos.append(self.photo!)
				}
				DispatchQueue.main.async {
					self.isCameraButtonDisabled = false
				}
				self.sessionQueue.async {
					self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
				}
			},
			photoProcessingHandler: self.photoProcessingHandler
		)
		self.sessionQueue.async {
			self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
			self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
		}
	}

}


