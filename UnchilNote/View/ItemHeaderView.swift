//
//  ItemHeaderView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import SwiftUI

class ItemHeaderController:ObservableObject {
	@Published var memoHeader:MemoHeaderData = MemoHeaderData.makeDefaultValue()
}


struct ItemHeaderView: View {

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)])
	private var entity_memo: FetchedResults<Entity_Memo>

	var writetime:Double
	
	@StateObject var controller = ItemHeaderController()

	var body: some View {

		HStack{

			Label("secret", systemImage: self.controller.memoHeader.isSecret ? "lock" : "lock.open")
			.scaleEffect(1.5, anchor: .center)
			.padding(.horizontal)

			VStack( alignment: .leading) {
				Text("\(self.controller.memoHeader.title)\n\(self.controller.memoHeader.desc)")
				Text("snapshot:\(self.controller.memoHeader.snapshotCnt)  record:\(self.controller.memoHeader.recordCnt)  photo:\(self.controller.memoHeader.photoCnt)")
				Text(self.controller.memoHeader.snippets)
			}

			Label("pin", systemImage: self.controller.memoHeader.isPin ? "mappin.and.ellipse" : "mappin.slash")
			.scaleEffect(1.5, anchor: .center)
			.padding(.horizontal)

		}
		.labelStyle(.iconOnly)
		.onAppear(){
			if let entityMemo = self.entity_memo.first(where: { entity_Memo in
				entity_Memo.writetime == self.writetime}) {
				self.controller.memoHeader = entityMemo.toMemoHeaderData()
			}
		}
	}
}

struct ItemHeader_Previews: PreviewProvider {

	static var previews: some View {
		ItemHeaderView(writetime: 0)
	}
}
