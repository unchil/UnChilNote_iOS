//
//  NoDataView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Label("No Data Found", systemImage: "exclamationmark.triangle")
				.font(.system(size: 16, weight: .bold, design: .serif))
				.scaleEffect(1.5, anchor: .center)
				Spacer()
			}
			Spacer()
		}
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}

