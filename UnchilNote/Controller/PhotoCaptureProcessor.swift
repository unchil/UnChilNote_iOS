//
//  PhotoCaptureProcessor.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//


import Foundation
import AVFoundation
import Photos


class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {

	private(set) var requestedPhotoSettings: AVCapturePhotoSettings

	private let willCapturePhotoAnimation: () -> Void
	private let completionHandler: (PhotoCaptureProcessor) -> Void
	private let photoProcessingHandler: (Bool) -> Void

	private var maxPhotoProcessingTime: CMTime?

	var photoData: Data?

	init (requestedPhotoSettings: AVCapturePhotoSettings,
		  willCapturePhotoAnimation: @escaping () -> Void,
		  completionHandler: @escaping(PhotoCaptureProcessor) -> Void,
		  photoProcessingHandler: @escaping(Bool) -> Void ) {

		self.requestedPhotoSettings = requestedPhotoSettings
		self.willCapturePhotoAnimation = willCapturePhotoAnimation
		self.completionHandler = completionHandler
		self.photoProcessingHandler = photoProcessingHandler
	}

}

extension PhotoCaptureProcessor {

	func saveToPhotoLibrary(_ photoData: Data) {
		PHPhotoLibrary.requestAuthorization { status in
			if status == .authorized {
				PHPhotoLibrary.shared().performChanges {
					let options = PHAssetResourceCreationOptions()
					options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map{$0.rawValue}
					PHAssetCreationRequest.forAsset().addResource(with: .photo, data: photoData, options: options)
				} completionHandler: { _, error in
					if let error = error {
						print("Error occurred while saving photo to photo library: \(error)")
					}
					DispatchQueue.main.async {
						self.completionHandler(self)
					}
				}
			} else {
				DispatchQueue.main.async {
					self.completionHandler(self)
				}
			}
		}
	}

	func photoOutput( _ output: AVCapturePhotoOutput,
					 willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		self.maxPhotoProcessingTime = resolvedSettings.photoProcessingTimeRange.start
								+ resolvedSettings.photoProcessingTimeRange.duration
	}

	func photoOutput(_ output: AVCapturePhotoOutput,
					 willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		DispatchQueue.main.async {
			self.willCapturePhotoAnimation()
		}

		guard let maxPhotoProcessingTime = self.maxPhotoProcessingTime else { return }

		let oneSecond = CMTime(seconds: 2, preferredTimescale: 1)
		if maxPhotoProcessingTime > oneSecond {
			DispatchQueue.main.async {
				self.photoProcessingHandler(true)
			}
		}
	}

	func photoOutput(_ output: AVCapturePhotoOutput,
					 didFinishProcessingPhoto photo: AVCapturePhoto,
					 error: Error?) {

		DispatchQueue.main.async {
			self.photoProcessingHandler(false)
		}

		if let error = error {
			print("Error didFinishProcessingPhoto: \(error)")
		} else {
			self.photoData = photo.fileDataRepresentation()
		}
	}

	func photoOutput(_ output: AVCapturePhotoOutput,
					 didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
					 error: Error?) {

		if let error = error {
			print("Error didFinishCaptureFor: \(error)")
			DispatchQueue.main.async {
				self.completionHandler(self)
			}
		} else {

			DispatchQueue.main.async {
				self.completionHandler(self)
			}
			/*
			guard let data = self.photoData else {
			   DispatchQueue.main.async {
				   self.completionHandler(self)
			   }
			   return
			}
			self.saveToPhotoLibrary(data)
			*/
		}
	}

}
