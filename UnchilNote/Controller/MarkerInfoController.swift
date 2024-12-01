//
//  MarkerInfoController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import Foundation
import GoogleMaps
import CoreData
import SwiftUI

class MarkerInfoController: ObservableObject {

	@Environment(\.managedObjectContext) private var viewContext

	var writetime:Double

	@Published var detailHeaderData = DetailHeaderData.makeDefaultValue()


	init( writeTime:Double) {
		self.writetime = writeTime
	}


	func refreshHeaderData(entity_memo: FetchedResults<Entity_Memo> ) {
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime }) {
			self.detailHeaderData = result.toDetailHeaderData()
		}
	}

}
