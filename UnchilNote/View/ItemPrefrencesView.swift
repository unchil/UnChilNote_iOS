//
//  ItemPrefrencesView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI

struct ItemPrefrencesView: View {


	@Binding var items:[PrefrencesItem]

	var body: some View {
		VStack{
			Text("Setting Prefrences")
			.font(.headline)
			.padding()

			ScrollView {
				ForEach( items ) {  element in
					let index = items.firstIndex { item in
						item.id == element.id
					} ?? 0

					Toggle(isOn: self.$items[index].isSelected) {
						Label(self.items[index].prefrences.name, systemImage: self.items[index].prefrences.systemImage)
					}
					.toggleStyle(.switch)
					.padding(.horizontal)
				}
			}
		}

	}
}

struct ItemPrefrencesView_Previews: PreviewProvider {


	static var items:[PrefrencesItem] = PrefrencesItem.all()

	static var previews: some View {
		ItemPrefrencesView(items: .constant(items))
	}
}
