//
//  WriteContainerView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import SwiftUI

struct WriteContainerView: View {

	@ObservedObject var controller:WriteController
	@Binding var selectedType: WriteDataType

	@State var snapshotIndex:Int = 0
	@State var recordIndex:Int = 0
	@State var photoIndex:Int = 0
	@State var showDelConfirmDialog = false
	@State var delItemType:WriteDataType = .snapshot

	var body: some View {

		NavigationView{

			VStack{

				Text("Write Data Container")
				.font(.headline)
				.padding()

				Picker( "WriteDataType", selection: $selectedType) {
				  ForEach(WriteDataType.allCases) { dataType in
					  Text(dataType.rawValue.capitalized)
				  }
				}
				.pickerStyle(.segmented)

				switch self.selectedType {
					case .snapshot: do {
						GroupBox(label:Label(WriteDataType.snapshot.name, systemImage: WriteDataType.snapshot.systemImage)){
							if self.controller.snapshots.isEmpty { NoDataView() } else {
								NavigationLink {
									ImagePageView(selected:$snapshotIndex, controllers: self.controller.snapshots, displayMode: .full)
									.edgesIgnoringSafeArea(.all)
								} label: {
									ImagePageView(selected:$snapshotIndex, controllers: self.controller.snapshots, displayMode: .frame)
									.onAppear{
										snapshotIndex = self.controller.snapshots.count - 1
									}
								}
							}
						}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							self.delItemType = .snapshot
							if !self.controller.snapshots.isEmpty {
								self.delItemType = .snapshot
								self.showDelConfirmDialog.toggle()
							}
						}))
					}
					case .record: do {
						GroupBox(label: Label(WriteDataType.record.name, systemImage: WriteDataType.record.systemImage)){
							if self.controller.records.isEmpty { NoDataView() } else {
								RecordPageView(selected:$recordIndex, controllers: self.controller.records)
								.onAppear{
									recordIndex = self.controller.records.count - 1
								}
							}
						}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							if !self.controller.records.isEmpty {
								self.delItemType = .record
								self.showDelConfirmDialog.toggle()
							}
						}))
					}
					case .photo: do {
						GroupBox(label:Label(WriteDataType.photo.name, systemImage: WriteDataType.photo.systemImage)){
							if self.controller.photos.isEmpty { NoDataView() } else {
								NavigationLink {
									ImagePageView(selected:$photoIndex, controllers: self.controller.photos, displayMode: .full)
									.edgesIgnoringSafeArea(.all)
								} label: {
									ImagePageView(selected:$photoIndex, controllers: self.controller.photos, displayMode: .frame)
									.onAppear{
										photoIndex = self.controller.photos.count - 1
									}
								}
							}
						}
						.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							if !self.controller.photos.isEmpty {
								self.delItemType = .photo
								self.showDelConfirmDialog.toggle()
							}
						}))
					}
				}
			}
			.confirmationDialog(delItemType.deleteMessage, isPresented: $showDelConfirmDialog ,titleVisibility: .visible) {
				Button(delItemType.deleteTitle, role: .destructive) {
					var index = 0
					switch self.delItemType {
						case .snapshot: index = self.snapshotIndex
						case .record: index = self.recordIndex
						case .photo: index = self.photoIndex
					}
					self.controller.deleteItem(deleteItemType: self.delItemType, index: index)
				}
			}
			.navigationBarHidden(true)
		} // NavigationView
	} // body
}



struct WriteContainerView_Previews: PreviewProvider {

	static var controller = WriteController()

    static var previews: some View {
		WriteContainerView(controller:controller, selectedType: .constant(WriteDataType.snapshot))
    }
}
