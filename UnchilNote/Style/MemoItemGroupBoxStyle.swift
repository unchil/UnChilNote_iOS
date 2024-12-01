//
//  ViewExtention.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI

struct MemoItemGroupBoxStyle: GroupBoxStyle {

	let deleteAction: () -> Void

	var bgColor = Color(#colorLiteral(red: 0.9161612391, green: 0.9279718399, blue: 0.9720409513, alpha: 1))

    func makeBody(configuration: Configuration) -> some View {

        VStack(alignment: .leading) {

			HStack {

				configuration.label.foregroundColor(.secondary)

				Spacer()

				Button {
					deleteAction()
				} label: {
					Label("", systemImage: "trash")
				}.tint(.secondary)

            }

            configuration.content
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
    //    .background( bgColor )
    }
}



struct GroupBoxStyle_Previews: PreviewProvider {

	static let action = {}
    static var previews: some View {

        GroupBox(label: Label("GroupBox", systemImage: "folder")){

          //  Text("MemoItemGroupBoxStyle")
            ImageView( image: UIImage(named: "sample_map.jpg")!)
            .aspectRatio(3 / 2, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

        }.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: action))


    }
}


struct PageViewModifier: ViewModifier {
	//let bgColor:UIColor
	func body(content: Content) -> some View {
		content
			.tabViewStyle(.page)
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
	}
}

