//
//  ItemDetailController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import Foundation
import CoreData
import SwiftUI
import LocalAuthentication

class ItemDetailController: ObservableObject {

	var writetime:Double = 0
	var isLock:Bool = true
	var delItemType:WriteDataType = .snapshot


	@Published var memoData = MemoData.makeDefaultValue()
	@Published var detailHeaderData = DetailHeaderData.makeDefaultValue()
	@Published var recordTexts:[TextFieldData] = []
	@Published var snapshots:[ImageView] = []
	@Published var records:[RecordView] = []
	@Published var photos:[ImageView] = []


	func checkAuthentication() {
		let authContext = LAContext()
		authContext.localizedCancelTitle = "Cancel"
		var error: NSError?
		if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authContext.biometryType.description) { success, err in
				DispatchQueue.main.async {
					if success {
						self.isLock = false
					} else {
						self.isLock = true
					}
				}
			}
		} else {
			print(#function,  error?.localizedDescription ?? "")
			self.isLock = true
		}
	}

	func deleteFile( viewContext: NSManagedObjectContext,
						index: Int,
						entity_memo:FetchedResults<Entity_Memo> ,
						entity_memo_files: FetchedResults<Entity_Memo_File> ) {

		var fileName = ""

		switch self.delItemType {
			case .snapshot: fileName = self.snapshots[index].url?.lastPathComponent ?? ""
			case .record: do {
					self.updateRecordText(viewContext: viewContext, entity_memo_files: entity_memo_files)
					fileName = self.records[index].fileURL.lastPathComponent
				}
			case .photo: fileName = self.photos[index].url?.lastPathComponent ?? ""
		}

		if let entityMemoFile = entity_memo_files.first(where: { row in
				row.writetime == self.writetime &&
				row.fileName == fileName }) {

			viewContext.delete(entityMemoFile)

			if let entityMemo = entity_memo.first (where: { row in
				row.writetime == self.writetime
			}){
				switch self.delItemType {
					case .snapshot: entityMemo.snapshotCnt = entityMemo.snapshotCnt - 1
					case .record: entityMemo.recordCnt = entityMemo.recordCnt - 1
					case .photo: entityMemo.photoCnt = entityMemo.photoCnt - 1
				}
				commitTrans(context: viewContext)
			}

			self.refreshHeaderData(entity_memo: entity_memo)

			CommonController.deleteFile(fileName: fileName)


			switch self.delItemType {
				case .snapshot: do {
					self.snapshots.removeAll()
					entity_memo_files.filter { entityMemoFile in
						entityMemoFile.writetime == self.writetime &&
						entityMemoFile.type == WriteDataType.snapshot.rawValue
					}.forEach { item in
						self.snapshots.append(
							ImageView( url: ConstVar.DocumentPath.appendingPathComponent(item.fileName!) ) )
					}
				}
				case .record: do {
					self.records.removeAll()
					self.recordTexts.removeAll()
					entity_memo_files.filter { entityMemoFile in
						entityMemoFile.writetime == self.writetime &&
						entityMemoFile.type == WriteDataType.record.rawValue
					}.forEach { item in
						let fieldData = TextFieldData(data: item.text ?? "")
						self.recordTexts.append(fieldData)
						self.records.append(
							RecordView(	fileURL: ConstVar.DocumentPath.appendingPathComponent(item.fileName!), recordText: fieldData)
						)
					}
				}
				case .photo: do {
					self.photos.removeAll()
					entity_memo_files.filter { entityMemoFile in
						entityMemoFile.writetime == self.writetime &&
						entityMemoFile.type == WriteDataType.photo.rawValue
					}.forEach { item in
						self.photos.append(
							ImageView( url: ConstVar.DocumentPath.appendingPathComponent(item.fileName!) ) )
					}
				}
			}


		}
	}

	func updateTag( viewContext: NSManagedObjectContext,
					entity_memo: FetchedResults<Entity_Memo>,
					entity_memo_tags: FetchedResults<Entity_Memo_Tag>,
					tags: [TagItem] ,
					completionHandler: @escaping () -> Void ) {

		if let entity = entity_memo_tags.first(where: { row in
					row.writetime == self.writetime }) {

			var  snippet = ""

			tags.forEach { item in
				let value:Bool = item.isSelected
				if value {
					snippet +=  " \(item.tag.name)"
				}
				switch item.tag {
					case .shopping : entity.shopping = value
					case .tracking : entity.tracking = value
					case .travel : entity.travel = value
				}
			}
			commitTrans(context: viewContext)

			if let entityMemo = entity_memo.first(where: { row in
				row.writetime == self.writetime
			}) {
				entityMemo.snippets = snippet
			}

			commitTrans(context: viewContext)

		}

		self.refreshHeaderData(entity_memo: entity_memo)

		completionHandler()
	}



	private func refreshHeaderData(entity_memo: FetchedResults<Entity_Memo>) {
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime }) {
			self.detailHeaderData = result.toDetailHeaderData()
		}
	}



	func updatePrefrences( viewContext: NSManagedObjectContext,
							entity_memo: FetchedResults<Entity_Memo>,
							prefrences:[PrefrencesItem]) {
							
		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == self.writetime }) {

			prefrences.forEach { item in
				switch item.prefrences {
					case .secret:  entityMemo.isSecret = item.isSelected
					case .pin: entityMemo.isPin = item.isSelected
				}
			}
			commitTrans(context: viewContext)
		}
	}

	func refreshMemoData( viewContext: NSManagedObjectContext,
							entity_memo: FetchedResults<Entity_Memo>,
							entity_memo_tag: FetchedResults<Entity_Memo_Tag>,
							entity_memo_files: FetchedResults<Entity_Memo_File>,
							prefrences: Binding<[PrefrencesItem]> ,
							tags: Binding<[TagItem]> ) {

		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == self.writetime
		}) {
			self.memoData = entityMemo.toMemoData()
			self.detailHeaderData = entityMemo.toDetailHeaderData()
		}

		prefrences.forEach { memoPrefrences in
			switch memoPrefrences.prefrences.wrappedValue {
				case .secret: memoPrefrences.isSelected.wrappedValue = self.memoData.isSecret
				case .pin: memoPrefrences.isSelected.wrappedValue = self.memoData.isPin
			}
		}

		tags.wrappedValue.removeAll()


		if let entityMemoTag = entity_memo_tag.first(where: { row in
			row.writetime == self.writetime
		}) {
			TagItem.tags.forEach { tagItem in
				switch tagItem.tag {
					case .shopping: tags.wrappedValue.append(TagItem(tag: Tag.shopping, isSelected: entityMemoTag.shopping))
					case .tracking: tags.wrappedValue.append(TagItem(tag: Tag.tracking, isSelected: entityMemoTag.tracking))
					case .travel : tags.wrappedValue.append(TagItem(tag: Tag.travel, isSelected: entityMemoTag.travel))
				}
			}
		}

		self.snapshots.removeAll()
		self.recordTexts.removeAll()
		self.records.removeAll()
		self.photos.removeAll()

		entity_memo_files.filter({ entity_Memo_File in
			entity_Memo_File.writetime == self.writetime
		}).forEach { item in

			if let fileType = item.type {

				if fileType == WriteDataType.snapshot.rawValue {
					self.snapshots.append(
						ImageView( url: ConstVar.DocumentPath.appendingPathComponent(item.fileName!) ) )
				} else if fileType == WriteDataType.record.rawValue {

					let fieldData = TextFieldData(data: item.text ?? "")
					self.recordTexts.append(fieldData)
					self.records.append(
						RecordView(	fileURL: ConstVar.DocumentPath.appendingPathComponent(item.fileName!), recordText: fieldData)
					)
				} else if fileType == WriteDataType.photo.rawValue {
					self.photos.append(
						ImageView( url: ConstVar.DocumentPath.appendingPathComponent(item.fileName!) ) )
				} else {

				}
			}
		}
	}

	func  updateRecordText(viewContext: NSManagedObjectContext,entity_memo_files: FetchedResults<Entity_Memo_File>)  {
		let memoFiles = entity_memo_files.filter { entityMemoFile in
			entityMemoFile.writetime == self.writetime &&
			entityMemoFile.type == WriteDataType.record.rawValue
		}
		for (index, recordFile) in memoFiles.enumerated() {
			recordFile.text = self.recordTexts[index].data
			commitTrans(context: viewContext)
		}
	}


}
