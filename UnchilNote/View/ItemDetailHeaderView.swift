//
//  ItemDetailHeaderView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI

struct ItemDetailHeaderView: View {

	@StateObject var controller: ItemDetailController

    var body: some View {
        VStack (alignment: .leading) {
			Text("Attach : Snapshot:\(controller.detailHeaderData.snapshotCnt)  Record:\(controller.detailHeaderData.recordCnt)  Photo:\(controller.detailHeaderData.photoCnt)")
			Text("Tag : \(controller.detailHeaderData.snippets)")
		}
    }
}

struct ItemDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailHeaderView(controller:ItemDetailController())
    }
}
