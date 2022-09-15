//
//  PhotoCapture.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import SwiftUI
import AVFoundation
import GoogleMaps


struct PhotoCapture: View {

	@Environment(\.dismiss) var dismiss
	@ObservedObject var controller:WriteController
	@StateObject var cameraController = CameraController()
	
	@State var currentZoomFactor: CGFloat = 1.0
	@State var orientation:AVCaptureVideoOrientation = .portrait
	@State var degrees:Double = 0
	@State var photoIndex = 0


	var body: some View {


		NavigationView {
			GeometryReader { reader in
				ZStack(alignment: .topLeading) {
					Color.black.edgesIgnoringSafeArea(.all)

					CameraPreview(orientation: self.$orientation, session: self.cameraController.session)
						.onRotate( perform: { newOrientation in
							self.setOrientation(orientation:newOrientation)
						})


						.gesture(
							DragGesture().onChanged({ value in
								//  Get the percentage of vertical screen space covered by drag
								let percentage: CGFloat = -(value.translation.height / reader.size.height)
								//  Calculate new zoom factor
								let calc = self.currentZoomFactor + percentage
								//  Limit zoom factor to a maximum of 5x and a minimum of 1x
								let zoomFactor: CGFloat = min(max(calc, 1), 5)
								//  Store the newly calculated zoom factor
								self.currentZoomFactor = zoomFactor
								//  Sets the zoom factor to the capture device session
								self.cameraController.zoom(with: zoomFactor)
							})
						)
						.alert(self.cameraController.alertError.title, isPresented: self.$cameraController.showAlertError) {
							Button(self.cameraController.alertError.primaryButtonTitle , role: .destructive) {
								self.cameraController.alertError.primaryAction?()
							}
						} message: { Text(self.cameraController.alertError.message) }
						.edgesIgnoringSafeArea(.all)



					VStack {

						Button {
							self.cameraController.switchFlash()
						} label: {
							Image(systemName: self.cameraController.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
						}
						.rotationEffect(.degrees(self.degrees))
						.animation(.default, value: self.degrees)
							.accentColor(self.cameraController.isFlashOn ? .orange : .white)
							.scaleEffect(1.5)


						Spacer()

						HStack(alignment:.center) {

							if self.cameraController.getPhotos().isEmpty {
								RoundedRectangle(cornerRadius: 10)
								.stroke(Color.white.opacity(0.8), lineWidth: 2)
								.frame(width: 90, height: 90)
								.foregroundColor(.secondary)
							} else {
								NavigationLink {
									ImagePageView(selected: $photoIndex, controllers: self.cameraController.getPhotos(), displayMode: .full)
									.edgesIgnoringSafeArea(.all)
								} label: {
									RoundedRectangle(cornerRadius: 10)
									.stroke(Color.white.opacity(0.8), lineWidth: 2)
									.frame(width: 90, height: 90)
									.foregroundColor(.secondary)
									.overlay {
										Image(uiImage: self.cameraController.photo.image)
										.resizable( resizingMode: .stretch)
										.cornerRadius(10)
										.rotationEffect(.degrees(self.degrees))
										.animation(.default, value: self.degrees)
									}
								}
							}

							Spacer()

							Button(action: {
								self.cameraController.capturePhoto()
							}, label: {
								Circle()
								.foregroundColor(.white)
								.frame(width: 80, height: 80, alignment: .center)
								.overlay(
									Circle()
									.stroke(Color.black.opacity(0.8), lineWidth: 2)
									.frame(width: 65, height: 65, alignment: .center)
								)
							})


							Spacer()

							Button{
								self.cameraController.flipCamera()
							} label: { Label("Camera Rotate", systemImage: "camera.rotate") }
							.rotationEffect(.degrees(self.degrees))
							.animation(.default, value: self.degrees)
							.scaleEffect(2)
							.tint(.white)

							Spacer()

							Button {
								self.cameraController.getPhotos().forEach { imageView in
									self.controller.photos.append(imageView)
								}
								dismiss.callAsFunction()

							} label: { Label("Save", systemImage: "tray.and.arrow.down")}
							.rotationEffect(.degrees(self.degrees))
							.animation(.default, value: self.degrees)
							.scaleEffect(2)
							.tint(.white)
						}
						.padding()
					}
				}
				.labelStyle(.iconOnly)
				.navigationBarTitleDisplayMode(.inline)
			}
		}
		.onAppear {
			// Forcing the rotation to portrait
			UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
			// And making sure it stays that way
			AppDelegate.orientationLock = .portrait

		}
		.onDisappear {
			AppDelegate.orientationLock = .all
		}



	} // body
}

extension PhotoCapture {
	func setOrientation(orientation: UIDeviceOrientation) {

		switch orientation {
			case .portrait :
				self.orientation = .portrait
				self.degrees = 0
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .portraitUpsideDown:
				self.orientation = .portraitUpsideDown
				self.degrees = 180
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portraitUpsideDown)
			case .landscapeLeft:
				self.orientation = .landscapeLeft
				self.degrees = 90
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.landscapeRight)
			case .landscapeRight:
				self.orientation = .landscapeRight
				self.degrees = -90
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.landscapeLeft)
			case .unknown:
				self.orientation = .portrait
				self.degrees = 0
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .faceUp:
				self.orientation = .portrait
				self.degrees = 0
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .faceDown:
				self.orientation = .portrait
				self.degrees = 0
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			@unknown default:
				self.orientation = .portrait
				self.degrees = 0
				self.cameraController.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
		}
	}

}

struct PhotoCapture_Previews: PreviewProvider {
	static var controller = WriteController()

	static var previews: some View {
		PhotoCapture(controller: controller)
	}
}
