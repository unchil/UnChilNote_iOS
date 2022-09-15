//
//  MemoHeaderModel.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//

import Foundation

struct MemoHeaderData: Identifiable, Equatable {
    static func == (lhs: MemoHeaderData, rhs: MemoHeaderData) -> Bool {
        lhs.id == rhs.id
    }
	var id: Double
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var isSecret: Bool
    var isPin: Bool
    var title: String
    var snippets: String
    var desc: String
    var snapshotFileName: String
    var snapshotCnt: Int16
    var recordCnt: Int16
    var photoCnt: Int16

}

extension MemoHeaderData {
	static func makeDefaultValue() -> MemoHeaderData {
		return MemoHeaderData (
					id: Double(0),
					latitude: 37.38575,
					longitude: 126.93407,
					altitude: 100.0,
					isSecret: false,
					isPin: false,
					title: "2022/3/15 10:27 화",
					snippets: "여행 쇼핑 트레킹",
					desc: "Clear Anyang-si/KR",
					snapshotFileName: "sample_map.jpg",
					snapshotCnt: 1,
					recordCnt: 1,
					photoCnt: 1
				)
	}
}

extension Entity_Memo {

	func toMemoHeaderData() -> MemoHeaderData {
		return MemoHeaderData( id: self.writetime, latitude: self.latitude, longitude: self.longitude, altitude: self.altitude, isSecret: self.isSecret, isPin: self.isPin, title: self.title ?? ConstVar.NODATA, snippets: self.snippets ?? ConstVar.NODATA, desc: self.desc ?? ConstVar.NODATA, snapshotFileName: self.snapshotFileName ?? "exclamationmark.triangle", snapshotCnt: self.snapshotCnt, recordCnt: self.recordCnt, photoCnt: self.photoCnt)
	}
/*
	func toDetailHeaderData() -> DetailHeaderData {
		return DetailHeaderData( id: self.writetime, latitude: self.latitude, longitude: self.longitude, altitude: self.altitude, isSecret: self.isSecret, isPin: self.isPin, title: self.title ?? noData, snippets: self.snippets ?? noData, desc: self.desc ?? noData, snapshotFileName: self.snapshotFileName ?? "exclamationmark.triangle", snapshotCnt: self.snapshotCnt, recordCnt: self.recordCnt, photoCnt: self.photoCnt)
	}

	func toMemoData() -> MemoData {
		let records:[RecordView] = []
		let snapshots:[ImageView] = []
		let photos:[ImageView] = []
		let tags:[TagItem] = []

		return MemoData(writeTime: self.writetime, records: records, snapshots: snapshots, photos: photos, tags: tags, isSecret: self.isSecret, isPin: self.isPin, latitude: self.latitude, longitude: self.longitude, altitude: self.altitude)
	}
*/
}
