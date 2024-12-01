//
//  ItemDetailView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI


/*
struct FilterScope: Equatable {
    var filter: String?
    var predicate: NSPredicate? {
        guard let filter = filter else { return nil }
        return NSPredicate(format: "writetime == %@", filter)
    }
}
*/

struct ItemDetailView: View {

	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) var dismiss

	var writetime:Double

//	@State private var filterScope: FilterScope = FilterScope(filter: nil)

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)] )
	private var entity_memo: FetchedResults<Entity_Memo>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_File.writetime, ascending: false)])
	private var entity_memo_files: FetchedResults<Entity_Memo_File>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Tag.writetime, ascending: false)])
	private var entity_memo_tags: FetchedResults<Entity_Memo_Tag>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Weather.writetime, ascending: false)])
	private var entity_memo_weather: FetchedResults<Entity_Memo_Weather>

	@StateObject var controller = ItemDetailController()

	var markerInfoController:MarkerInfoController?

	let weatherController = WeatherController.controller


	@State var showDelConfirmDialog = false
	@State var showAlertDialog = false
	@State var snapshotIndex:Int = 0
	@State var recordIndex:Int = 0
	@State var photoIndex:Int = 0
	@State var isTag: Bool = false
	@State  var isPrefrences = false

	@State var tags:[TagItem] = TagItem.all()
	@State var prefrences:[PrefrencesItem] = PrefrencesItem.all()


	var isSecret:Bool {
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime })
		{ return result.isSecret } else { return false }
	}

    var body: some View {
        ZStack{
			if controller.isLock {
				LockView()
			} else {
				NavigationView {
					HStack {
						VStack(spacing:0){
							ScrollView {

								WeatherView(controller: self.weatherController )

								Divider()

								ItemDetailHeaderView(controller: self.controller)
								.font(.subheadline)
								.padding()

								Divider()

								GroupBox(label:Label(WriteDataType.snapshot.name, systemImage: WriteDataType.snapshot.systemImage)){
									if self.controller.snapshots.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {

										NavigationLink {
											ImagePageView(selected:$snapshotIndex, controllers: self.controller.snapshots, displayMode: .full)
											.edgesIgnoringSafeArea(.all)
										} label: {
											ImagePageView(selected:$snapshotIndex, controllers: self.controller.snapshots, displayMode: .frame)
											.aspectRatio(3 / 2, contentMode: .fit)
											.onAppear{
												self.snapshotIndex = self.controller.snapshots.count - 1
											}
										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									self.controller.delItemType = .snapshot
									if ( self.controller.snapshots.count > 1 && self.snapshotIndex != 0 ){
										self.showDelConfirmDialog.toggle()
									}else { self.showAlertDialog.toggle() }
								}))

								Divider()

								GroupBox(label: Label(WriteDataType.record.name, systemImage: WriteDataType.record.systemImage)){
									if self.controller.records.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {
										RecordPageView(selected:self.$recordIndex, controllers: self.controller.records)
										.aspectRatio(3 / 2, contentMode: .fit)
										.onAppear{
											self.recordIndex = self.controller.records.count - 1
										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									if !self.controller.records.isEmpty {
										self.controller.delItemType = .record
										self.showDelConfirmDialog.toggle()
									}
								}))

								Divider()

								GroupBox(label:Label(WriteDataType.photo.name, systemImage: WriteDataType.photo.systemImage)){
									if self.controller.photos.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {
										NavigationLink {
											ImagePageView(selected:$photoIndex, controllers: self.controller.photos, displayMode: .full)
											.edgesIgnoringSafeArea(.all)
										} label: {
											ImagePageView(selected:$photoIndex, controllers: self.controller.photos, displayMode: .frame)
											.aspectRatio(3 / 2, contentMode: .fit)
											.onAppear{
												self.photoIndex = self.controller.photos.count - 1
											}

										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									if !self.controller.photos.isEmpty {
										self.controller.delItemType = .photo
										self.showDelConfirmDialog.toggle()
									}
								}))

								Divider()

							}
						}
					}
					.confirmationDialog(self.controller.delItemType.deleteMessage, isPresented: self.$showDelConfirmDialog ,titleVisibility: .visible) {
						Button( self.controller.delItemType.deleteTitle, role: .destructive) {

							self.deleteItem()
						}
					}
					.alert(self.controller.delItemType.deleteTitle, isPresented: $showAlertDialog, actions: {
						Button("Dismiss", role: .cancel) {} }, message: {  Text(self.controller.delItemType.alertMessage) })
					.background(Color.clear)
					.toolbar {
						ToolbarItem(placement: .navigationBarLeading){
                            
                            
							Button {
								self.updateRecordText()
								dismiss.callAsFunction()
							} label: { Label("저장", systemImage: "externaldrive.badge.plus") }
                             
                            
						}

						ToolbarItemGroup(placement: .navigationBarTrailing) {
							Button{
								self.isTag.toggle()
							}label: { Label("태그", systemImage: "tag") }

							Button{
								self.isPrefrences.toggle()
							}label: { Label("설정", systemImage: "gearshape") }
						}
					}
					.sheet(isPresented: self.$isTag, onDismiss: self.updateTag) {
						ItemTagsView(items: $tags)
					//	ItemTagsView(items: self.$controller.tags)
					}
					.sheet(isPresented: $isPrefrences, onDismiss: self.updatePrefrences) {
						ItemPrefrencesView(items: $prefrences)
						//ItemPrefrencesView(items: self.$controller.prefrences)
					}
					.onAppear{
						self.refreshMemoData()
						self.weatherController.getMemoWeather( context: self.viewContext,
															  writetime: self.writetime,
															  entity_memo_weather: self.entity_memo_weather)
					}
					.navigationBarTitle("Detail Memo", displayMode: .inline)
				}
			}
		}
		.onAppear {

/*
			self.filterScope.filter = String(self.writetime)
			self.entity_memo.nsPredicate =  filterScope.predicate
			self.entity_memo_files.nsPredicate =  filterScope.predicate
			self.entity_memo_tags.nsPredicate =  filterScope.predicate
			self.entity_memo_weather.nsPredicate =  filterScope.predicate
*/
			self.controller.writetime = self.writetime

			AppDelegate.orientationLock = .all

			if self.isSecret  {
				self.controller.checkAuthentication()
			} else {
				self.controller.isLock = false
			}

		}
		.statusBar(hidden: false)

    }
}

extension ItemDetailView {

	private func refreshMemoData(){
		self.controller.refreshMemoData (
			viewContext: self.viewContext,
			entity_memo: self.entity_memo,
			entity_memo_tag: self.entity_memo_tags,
			entity_memo_files:  self.entity_memo_files,
			prefrences: self.$prefrences,
			tags: self.$tags )
	}

	private func updateTag() {
		self.controller.updateTag (
			viewContext: self.viewContext,
			entity_memo: self.entity_memo,
			entity_memo_tags: self.entity_memo_tags,
			tags: self.tags ) {
				self.markerInfoController?.refreshHeaderData(entity_memo: self.entity_memo)

			}
	}

	private func updatePrefrences() {
		self.controller.updatePrefrences(
			viewContext: self.viewContext,
			entity_memo: self.entity_memo,
			prefrences: self.prefrences)
	}


	private func deleteItem() {
		var index:Int = 0
		switch self.controller.delItemType {
			case .snapshot: index = self.snapshotIndex
			case .record: index = self.recordIndex
			case .photo: index = self.photoIndex
		}

		self.controller.deleteFile(
			viewContext: self.viewContext,
			index: index,
			entity_memo: self.entity_memo,
			entity_memo_files: self.entity_memo_files)
	}

	private func updateRecordText() {
		self.controller.updateRecordText(
			viewContext: self.viewContext,
			entity_memo_files: self.entity_memo_files)
	}


}


struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(writetime: 0)
    }
}
