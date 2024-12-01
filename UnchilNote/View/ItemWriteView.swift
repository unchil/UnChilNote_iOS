//
//  ItemWriteView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import SwiftUI
import CoreLocation
import GoogleMaps

struct ItemWriteView: View {

	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) private var dismiss


	@StateObject var weatherController = WeatherController.controller
	@StateObject var markerController = GMSMarkerController()
	@StateObject var writeController = WriteController()


	@State private var selectedMapType: MapType = .normal
	@State private var expandList: Bool = false
	@State private var isTag = false
	@State private var isCamera:Bool = false
	@State private var selectedType: WriteDataType = .snapshot
	@State private var isPrefrences = false
	@State private var isEraser = false
	@State private var isSnapshot = false
	@State private var isRecord = false
	@State private var isDraw = false
	@State var note:String = "Test Note"
	@State private var isSave:Bool = false
	@State var tags:[TagItem] = TagItem.all()
	@State var prefrences:[PrefrencesItem] = PrefrencesItem.all()

	private var micColor = Color(#colorLiteral(red: 0.1087540463, green: 0.1835740805, blue: 0.2116059959, alpha: 1))

    var body: some View {
        
        NavigationView {
            
			GeometryReader { geometry in
                
				ZStack(alignment:.topLeading) {

					MapContainerView(markerController: self.markerController, isWriteMemo: true)

					Picker( "MapType", selection: $selectedMapType) {
						ForEach(MapType.allCases) { mapType in
							Text(mapType.rawValue.capitalized)
						}
					}
					.onChange(of: selectedMapType) { newMapType in

						self.writeController.mapTypeProcess (markerController: self.markerController, selectedMapType: newMapType)
					}
					.pickerStyle(.segmented)

					HStack{
						Spacer()
						Button{
							if let location = self.writeController.locationService.cLLocationManager.location {
								self.markerController.setCurrentMarker(location: location)
							}
						} label: { Label("", systemImage:"location.circle.fill") }
						.scaleEffect(2)
						.padding(.trailing, 30)
					}
					.padding(.vertical, 90)

				}
				.sheet(isPresented: $expandList, content: {
					WriteContainerView(controller: writeController, selectedType: $selectedType)
				})
				.sheet(isPresented: $isTag) {
					ItemTagsView(items: $tags)
				}
				.sheet(isPresented: $isPrefrences) {
					ItemPrefrencesView(items: $prefrences)
				}
				.sheet(isPresented: $isCamera, onDismiss: photoProcess){
					PhotoCapture(controller: writeController)
					//.navigationBarBackButtonHidden(true)
				}
				.toolbar{

					ToolbarItemGroup(placement:.navigationBarLeading){
						HStack(spacing:0){
                            
                            
							 Button{
								isTag.toggle()
							}label: { Label("태그", systemImage: "tag") }

							Button{
								isPrefrences.toggle()
							}label: { Label("설정", systemImage: "gearshape") }

							Button{
								expandList.toggle()
							 }label: { Label("Data", systemImage: "tray") }
						}
					}

					ToolbarItemGroup(placement: .navigationBarTrailing) {

						HStack(spacing:0){

							Button { }
							label: { Label("DrawMenu", systemImage: "scribble") }

							.contextMenu{

								Button { self.isDraw.toggle() }
								label: { Label("draw",  systemImage: "hand.draw") }

								 Button {
									self.isEraser.toggle()
									 self.writeController.eraserProcess(markerController:self.markerController) { result in
										 if result && self.isDraw {
											//if self.isDraw {
												self.isDraw.toggle()
										//	}
										 }
									 }
								} label: { Label("eraser", systemImage: "hand.tap" ) }

								 Button {
									self.isSnapshot.toggle()
									 self.writeController.snapShotProcess(markerController:self.markerController) { result in
										 if result {
											self.selectedType = .snapshot
											self.expandList = true
										 }
										self.isSnapshot.toggle()
										if self.isDraw {
											self.isDraw.toggle()
										}
									}
								} label: {Label("snapshot", systemImage: "camera.viewfinder" ) }
							}

							Button {
								self.isRecord.toggle()
								self.writeController.recordProcess(isRecord: self.isRecord, note: self.$note) { result in
									if result {
										self.selectedType = .record
										self.expandList = true
									}
								}
							} label: { Label("Record", systemImage:  isRecord ? "waveform.and.mic" : "mic" ) }

							Button {
								self.isCamera.toggle()
							} label: { Label("Camera", systemImage:"camera") }


							Button{
								self.isSave.toggle()

								self.weatherController.setMemoWeather(context: self.viewContext, writetime: self.writeController.id) { _ in
									self.weatherController.makeWeatherDesc { weatherDesc in
										self.writeController.weatherDesc = weatherDesc
										self.writeController.saveMemo(	viewContext: self.viewContext,
																		markerController: self.markerController,
																		tags:self.tags,
																		prefrences:self.prefrences){
                         
                                            self.isSave.toggle()
                                            dismiss()
                                            
										}
									}
                                    
                                    
								}
                                


							}label: { Label("저장", systemImage: "externaldrive.badge.plus") }
						}
					}

				}
				.overlay {

					if self.isSave {
						ProgressView()
						.scaleEffect(1.5, anchor: .center)
					}

					if self.isRecord {
						Label("", systemImage: "mic")
							.foregroundColor(self.micColor)
							.labelStyle(.iconOnly)

						Label("", systemImage: "circle")
							.foregroundColor(self.micColor)
							.scaleEffect(1.5, anchor: .center)
							.labelStyle(.iconOnly)
							.shadow(radius: 6)

						ProgressView()
							.scaleEffect(3, anchor: .center)
							.progressViewStyle(CircularProgressViewStyle(tint: self.micColor))

					}

					if self.isDraw {
						Color.secondary
							.gesture(
								DragGesture()
								.onChanged({ value in

									let firstCoordinate:CLLocationCoordinate2D =
										(self.markerController.currentMarker?.map?.projection.coordinate(for: value.startLocation))!

									self.writeController.path.insert(firstCoordinate, at: 0)

									let coordinate:CLLocationCoordinate2D =
										(self.markerController.currentMarker?.map?.projection.coordinate(for: value.location))!

									self.writeController.path.add(coordinate)

									self.writeController.drawPolylineToMap(markerController: self.markerController)
								})
								.onEnded({ value in
									self.writeController.path.removeAllCoordinates()
								})
							)
					}
				}
				.onAppear(){

					if let location = self.writeController.locationService.cLLocationManager.location {
						self.markerController.setCurrentMarker(location: location)
					}

					UIToolbar.appearance().backgroundColor = UIColor(Color.white)
					AudioSessionController.audioSessionSet()
					AudioSessionController.audioSessionActivate()
				}
				.onDisappear(){
					AudioSessionController.audioSessionDeactivate()
				}
				.navigationBarTitle("Write Memo", displayMode: .inline)
				.statusBar(hidden: false)

			}
        }
    }
}

extension ItemWriteView {

	func mapTypeProcess(){
		var mapType: GMSMapViewType = .normal
		switch selectedMapType {
			case .normal: do { mapType = GMSMapViewType.normal}
			case .hybrid : do { mapType = GMSMapViewType.hybrid }
			case .terrain : do { mapType = GMSMapViewType.terrain }
		}
		self.markerController.currentMarker?.map?.mapType = mapType
	}


	private func photoProcess(){
		if !self.writeController.photos.isEmpty {
			self.selectedType = .photo
			self.expandList = true
		}
	}

}

struct ItemWriteView_Previews: PreviewProvider {
    static var previews: some View {
        ItemWriteView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
