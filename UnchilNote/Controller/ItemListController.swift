//
//  ItemListController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation
import SwiftUI
import CoreData
import CoreLocation
import GoogleMaps


class ItemListController: ObservableObject {

	@Published var memoItems = [MemoHeaderData]()
	@Published var resultSet = [Double]()


	func setMemoItems( entity_memo:FetchedResults<Entity_Memo> ){
		self.memoItems = entity_memo.map { entityMemo in
			entityMemo.toMemoHeaderData()
		}
	}

	func searchItems(	tags:[TagItem],
						entity_memo:FetchedResults<Entity_Memo>,
						entity_memo_tags:FetchedResults<Entity_Memo_Tag>,
						completionHandler: @escaping () -> Void ) {

		var isTagsState:Bool = false

		tags.forEach { item in
			if item.isSelected {
				isTagsState = item.isSelected
				switch item.tag {
					case .shopping : searchTag(tag: .shopping, entity_memo_tags: entity_memo_tags)
					case .tracking : searchTag(tag: .tracking, entity_memo_tags: entity_memo_tags)
					case .travel : searchTag(tag: .travel, entity_memo_tags: entity_memo_tags)
				}
			}
		}

		if isTagsState {
			if self.resultSet.isEmpty {
				self.memoItems.removeAll()
			} else {
				self.memoItems = entity_memo.filter { entity_memo in
					self.resultSet.contains(entity_memo.writetime) == true
				}.map { Entity_Memo in
					Entity_Memo.toMemoHeaderData()
				}
			}
			self.resultSet.removeAll()
		} else {
		
			self.memoItems = entity_memo.filter { entity_memo in
				entity_memo.snippets?.isEmpty == true
			}.map { Entity_Memo in
					Entity_Memo.toMemoHeaderData()
			}
		}


		completionHandler()
		
	}

	private func searchTag(tag:Tag, entity_memo_tags:FetchedResults<Entity_Memo_Tag> ) {
		let _ = entity_memo_tags.filter { memo_tag in
			switch tag {
				case .travel:
					return ( memo_tag.travel == true ) ? true : false
				case .shopping:
					return ( memo_tag.shopping == true ) ? true : false
				case .tracking:
					return ( memo_tag.tracking == true ) ? true : false
			}
		}.map { EntityMemoTag in
			if !self.resultSet.contains( EntityMemoTag.writetime) {
				self.resultSet.append(EntityMemoTag.writetime)
			}
		}
	}
	


	func shareItem( writetime:Double,
					entity_memo:FetchedResults<Entity_Memo>,
					entity_memo_files:FetchedResults<Entity_Memo_File>,
					completionHandler: @escaping ([Any])->Void ) {

		if let entityMemo = entity_memo.first(where: { $0.writetime == writetime }) {

			var shareObject = [Any]()
			var shareText = "\n  UnChil's GIS Memo"
			let headerInfo = entityMemo.toMemoHeaderData()
			shareText += "\n DATE# \(headerInfo.title)"
			shareText += "\n DESC# \(headerInfo.desc)"
			shareText += "\n TAG# \(headerInfo.snippets)"
			shareText += "\n ATTACH#  Snapshot:\(headerInfo.snapshotCnt)  Record:\(headerInfo.recordCnt)  Photo:\(headerInfo.photoCnt)"
			shareText += "\n"

			shareObject.append(shareText)

			entity_memo_files.filter { entity_Memo_File in
				entity_Memo_File.writetime == writetime
			}.forEach { memoFile in
				if memoFile.type == WriteDataType.record.rawValue {
					let shareText = " MEMO# \( memoFile.text ?? "")\n"
					shareObject.append(shareText)
				}
				shareObject.append(ConstVar.DocumentPath.appendingPathComponent(memoFile.fileName ?? ""))
			}

			completionHandler(shareObject)
		}

	}

	func deleteItem(viewContext: NSManagedObjectContext,
					writetime:Double,
					entity_memo:FetchedResults<Entity_Memo>,
					entity_memo_files:FetchedResults<Entity_Memo_File>,
					entity_memo_tags:FetchedResults<Entity_Memo_Tag>,
					entity_memo_weather:FetchedResults<Entity_Memo_Weather> ) {

		if let index = self.memoItems.firstIndex(where: { row in
			row.id == writetime
		}){
			if let entityMemo = entity_memo.first(where: { row in
				row.writetime == writetime })
			{
				viewContext.delete(entityMemo)
			}

			entity_memo_files.filter { entity_Memo_File in
				entity_Memo_File.writetime == writetime
			}.forEach { entity_Memo_File in
				CommonController.deleteFile(fileName:entity_Memo_File.fileName!)
				viewContext.delete(entity_Memo_File)
			}

			entity_memo_tags.filter { entity_Memo_Tag in
				entity_Memo_Tag.writetime == writetime
			}.forEach { entity_Memo_Tag in
				viewContext.delete(entity_Memo_Tag)
			}

			if let entityWeather = entity_memo_weather.first(where: { row in
				row.writetime == Int64(writetime)
			}) {
				viewContext.delete(entityWeather)
			}

			commitTrans(context: viewContext)
			self.memoItems.remove(at: index)
		}
	}


}
