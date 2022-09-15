//
//  ImageTagsView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI

struct ItemTagsView: View {
	@Binding var items:[TagItem]

	var body: some View {

		VStack{
			Text("Select Tag")
			.font(.headline)
			.padding()

			ScrollView {
				ForEach( items ) {  element in
					let index = items.firstIndex { item in
						item.id == element.id
					} ?? 0

					Toggle(isOn: self.$items[index].isSelected) {
						Label(self.items[index].tag.name, systemImage: self.items[index].tag.systemImage)
					}
					.toggleStyle(.switch)
					.padding(.horizontal)
				}

			}
		}

	}
}

struct ItemTagsView_Previews: PreviewProvider {

	static  var  tags:[TagItem] = TagItem.tags

	static var previews: some View {
		ItemTagsView(items: .constant(tags))
	}
}
