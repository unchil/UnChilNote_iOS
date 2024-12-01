//
//  MemoWriteModel.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/12.
//

import Foundation
import CoreLocation
import SwiftUI
import CoreData
import GoogleMaps


class WriteController: ObservableObject{

	@Published var id:Double = Date().timeIntervalSince1970
	@Published var snapshots:[ImageView] = []
	@Published var photos:[ImageView] = []
	@Published var records:[RecordView] = []
	@Published var recordTexts:[TextFieldData] = []
	@Published var isSecret:Bool = false
	@Published var isPin:Bool = false
	@Published var latitude:Double = 0
	@Published var longitude:Double = 0
	@Published var altitude:Double = 0
	@Published var weatherDesc:String = ""

	var memoFilesInfo:[MemoFileInfo] = []

	var path = GMSMutablePath()
	var speechRecognizer = SpeechRecognizer()
	var locationService = LocationService.service
	//let netService = NetService()
	var fileURL:URL? = nil


	private func setPrefrences(prefrences: [PrefrencesItem] ) {
		prefrences.forEach { item in
			switch item.prefrences {
				case .secret: self.isSecret = item.isSelected
				case .pin: self.isPin = item.isSelected
			}
		}
	}


	func setCurrentLocation(location: CLLocation) {
		self.latitude = location.coordinate.latitude
		self.longitude = location.coordinate.longitude
		self.altitude = location.altitude
	}




	private func makeTitle() -> String {
		//"2022/5/4 10:27 수"
		return Date(timeIntervalSince1970: self.id).toString(dateFormat: ConstVar.TITLEFORMAT)
	}

	private func makeSnippet(tags:[TagItem]) -> String {
		// "Climbing, Tracking"
		var  snippet = ""
		tags.forEach { item in
			if item.isSelected {
				snippet +=  " \(item.tag.name)"
			}
		}
		return snippet
	}

	private func saveImageToFile() {

		for index in 0..<self.snapshots.count {
			let url = ConstVar.DocumentPath.appendingPathComponent("\(Date().toString(dateFormat: ConstVar.FILENAMEFORMAT))_\(index).\(ConstVar.IMAGEFILEEXE)" )
			imageToFile (image:self.snapshots[index].image!, url:url)
			self.memoFilesInfo.append( MemoFileInfo(type:WriteDataType.snapshot , fileURL: url))
		}

		for index in 0..<self.photos.count {
			let url = ConstVar.DocumentPath.appendingPathComponent("\(Date().toString(dateFormat: ConstVar.FILENAMEFORMAT))_\(index).\(ConstVar.IMAGEFILEEXE)" )
			imageToFile (image:self.photos[index].image!, url:url)
			self.memoFilesInfo.append( MemoFileInfo(type: WriteDataType.photo ,  fileURL: url))
		}

		for index in 0..<self.records.count {
			self.memoFilesInfo.append(
				MemoFileInfo(type:WriteDataType.record, fileURL:self.records[index].fileURL, text:self.recordTexts[index].data)
			)
		}
	}

	private func imageToFile (image:UIImage, url:URL) {
		guard let data: Data = image.jpegData(compressionQuality: 1) else { return }
		do {
			try data.write(to: url)
		} catch {
			fatalError("Unresolved error \(error)")
		}
	}

	private func setMemo(
		context: NSManagedObjectContext,
		tags:[TagItem]) {
		let entity = Entity_Memo(context: context)

		entity.writetime =  self.id
		entity.altitude = self.altitude
		entity.latitude = self.latitude
		entity.longitude = self.longitude
		entity.isPin = self.isPin
		entity.isSecret = self.isSecret
		entity.snapshotCnt = Int16( self.snapshots.count )
		entity.recordCnt = Int16( self.records.count )
		entity.photoCnt = Int16 ( self.photos.count )
		entity.snapshotFileName = self.memoFilesInfo.first(where: { memoInfo in
			memoInfo.type == WriteDataType.snapshot
		})?.fileURL.lastPathComponent
		entity.desc = self.weatherDesc
		entity.title = self.makeTitle()
		entity.snippets = self.makeSnippet(tags: tags)
		commitTrans(context: context)
	}

	private func setMemoTag(
		context: NSManagedObjectContext,
		tags:[TagItem]) {
		let entity = Entity_Memo_Tag(context: context)
		entity.writetime = self.id
		tags.forEach { item in
			let value:Bool = item.isSelected
			switch item.tag {
				case .shopping : entity.shopping = value
				case .tracking : entity.tracking = value
				case .travel : entity.travel = value
			}
		}
		commitTrans(context: context)
	}



	private func setMemoFile(context: NSManagedObjectContext) {

		for index in 0..<self.memoFilesInfo.count {
			let entity = Entity_Memo_File(context: context)
			entity.writetime = self.id
			entity.fileName = memoFilesInfo[index].fileURL.lastPathComponent
			entity.type = memoFilesInfo[index].type.rawValue
			entity.text = memoFilesInfo[index].text
			commitTrans(context: context)
		}

	}



	private func makeDefaultSnapshot(markerController: GMSMarkerController) {
		if let map = markerController.currentMarker?.map {
			let snapshot = UIGraphicsImageRenderer(size: map.bounds.size).image { _ in
				map.drawHierarchy(in: map.bounds, afterScreenUpdates: true)
			}
			self.snapshots.append(ImageView( image: snapshot))
		}
	}


	func eraserProcess(markerController: GMSMarkerController, completion: @escaping (Bool) -> (Void) ) {

		if let map = markerController.currentMarker?.map {
			self.path.removeAllCoordinates()
			map.clear()
			completion(true)
		} else {
			completion(false)
		}

	}

	func drawPolylineToMap (markerController: GMSMarkerController){
		if let map = markerController.currentMarker?.map {
			let polyline = GMSPolyline(path: self.path)
			polyline.strokeWidth = 5
			polyline.strokeColor = UIColor(Color.blue)
			polyline.geodesic = true
			polyline.map = map
		}
	}


	func mapTypeProcess(markerController: GMSMarkerController, selectedMapType:MapType){
		var mapType: GMSMapViewType = .normal
		switch selectedMapType {
			case .normal: do { mapType = GMSMapViewType.normal}
			case .hybrid : do { mapType = GMSMapViewType.hybrid }
			case .terrain : do { mapType = GMSMapViewType.terrain }
		}
		markerController.currentMarker?.map?.mapType = mapType
	}

	func snapShotProcess(markerController: GMSMarkerController, completion: @escaping (Bool) -> (Void) ) {
		if let map = markerController.currentMarker?.map {
			let snapshot = UIGraphicsImageRenderer(size: map.bounds.size).image { _ in
				map.drawHierarchy(in: map.bounds, afterScreenUpdates: true)
			}
			self.snapshots.append(ImageView( image: snapshot))

			map.clear()
			self.path.removeAllCoordinates()
			completion(true)
		}else {
			completion(false)
		}
	}


	func recordProcess(isRecord:Bool, note: Binding<String>,  completion: @escaping (Bool) -> (Void)) {

		if isRecord {
			self.fileURL = ConstVar.DocumentPath.appendingPathComponent("\(Date().toString(dateFormat: ConstVar.FILENAMEFORMAT)).\(ConstVar.RECORDINGFILEEXE)" )
			guard let url = self.fileURL else { return }
			self.speechRecognizer.speechToText(To: note, isRecordingToFile: true, isRecognizeFromFile: false, URL:  url, Locale: ConstVar.CURRENTLOCALE)
			completion(false)

		} else {
			self.speechRecognizer.stopSpeechToText()
			guard let url = self.fileURL else { return }

			if FileManager.default.fileExists(atPath: url.path) {
				let fieldData = TextFieldData(data: note.wrappedValue)

				self.recordTexts.append(fieldData)
				self.records.append( RecordView( fileURL: url, recordText: fieldData) )
				completion(true)
			}
		}
	}

	func deleteItem(deleteItemType: WriteDataType, index:Int) {
		switch deleteItemType {
			case .snapshot:
				self.snapshots.remove(at: index)
			case .record:
				self.records.remove(at: index)
				self.recordTexts.remove(at: index)
			case .photo:
				self.photos.remove(at: index)
		}
	}



	func saveMemo(
		viewContext:NSManagedObjectContext,
		markerController: GMSMarkerController ,
		tags:[TagItem],
		prefrences:[PrefrencesItem],
		completion: @escaping () -> (Void) ) {


		// location selected
		if let location = markerController.currentMarker?.position {
			self.setCurrentLocation(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
		}

		if self.snapshots.isEmpty {
			self.makeDefaultSnapshot(markerController: markerController)
		}

		self.saveImageToFile()
		self.setPrefrences(prefrences: prefrences)


		self.setMemo(context: viewContext,  tags: tags)
		self.setMemoTag(context: viewContext, tags: tags)
		self.setMemoFile(context: viewContext)



		completion()
	}

}

struct MemoFileInfo {
	var type:WriteDataType
	var fileURL:URL
	var text:String?
}

