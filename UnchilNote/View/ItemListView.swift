//
//  ItemListView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import SwiftUI
import CoreLocation
import CoreData

struct ItemListView: View {

	@Environment(\.managedObjectContext)
	private var viewContext

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)])
	private var entity_memo: FetchedResults<Entity_Memo>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_File.writetime, ascending: false)])
	private var entity_memo_files: FetchedResults<Entity_Memo_File>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Tag.writetime, ascending: false)])
	private var entity_memo_tags: FetchedResults<Entity_Memo_Tag>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Weather.writetime, ascending: false)])
	private var entity_memo_weather: FetchedResults<Entity_Memo_Weather>

	let locationService = LocationService.service
	
	@StateObject var markerController = GMSMarkerController()
	@StateObject var weatherController = WeatherController.controller
	@StateObject var listController  = ItemListController()

	@State var isSearch:Bool = false
	@State var showDelConfirmDialog = false
	@State var currentItem:Double = 0
	@State var orientation:UIDeviceOrientation = .portrait
	@State var tags = TagItem.searchAll()


	var body: some View {

		NavigationView{

			HStack(spacing:0){

				if orientation.isLandscape {
					WeatherView(controller: self.weatherController)
				}

				VStack{
					if !orientation.isLandscape {
						WeatherView(controller: self.weatherController)
					}
					List {
						ForEach( listController.memoItems) { item in

							ItemHeaderView(writetime: item.id)
								.font(.system(size: 12, weight: .light, design: .default))
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {

									Button{
										self.currentItem = item.id
										self.showDelConfirmDialog.toggle()
									} label: {
										Label("delete", systemImage: "trash.circle")
									}.tint(.red)

									Button{
										self.currentItem = item.id
										self.makeShareItem()
									} label: {
										Label("share", systemImage: "square.and.arrow.up")
									}.tint(.indigo)
								}

							NavigationLink{
								ItemDetailView(writetime: item.id)
							//	.navigationBarBackButtonHidden(true)
							//	.navigationBarHidden(true)

							}label: {
								ImageView(url:ConstVar.DocumentPath.appendingPathComponent(item.snapshotFileName))
								.aspectRatio(3/2 , contentMode: .fill)
								.previewContextMenu(
									preview: ImageView(url:ConstVar.DocumentPath.appendingPathComponent(item.snapshotFileName)),
									destination: ItemDetailView(writetime: item.id).navigationBarBackButtonHidden(true).navigationBarHidden(true),
									presentAsSheet: false
								)
							}

						}
					}.refreshable {
						self.startJob()
					}
					.listStyle(.plain)

				}
			}

			.onAppear() {
				self.startJob()
			}
			.toolbar {

				ToolbarItem(placement: .navigationBarLeading){
                
					NavigationLink{
						
						MapContainerView(markerController: self.markerController)
							.edgesIgnoringSafeArea(.vertical)
							.onAppear{ self.markerController.setMarkers(results: entity_memo.filter {
								$0.isPin == true }){_ in

								}
							}
							.onDisappear { self.markerController.markers.removeAll() }

					}label: { Label("지도", systemImage: "map") }
				}

				ToolbarItemGroup(placement: .navigationBarTrailing) {
					HStack(spacing:0){

						Button {
							self.isSearch.toggle()
						}label: { Label("검색", systemImage: "magnifyingglass") }

						NavigationLink{
							ItemWriteView()
							//.navigationBarBackButtonHidden(true)
							//.navigationBarHidden(true)
						}label: { Label("Write Memo", systemImage: "note.text.badge.plus") }
                        
					}
				}
			}
			.sheet(isPresented: self.$isSearch,onDismiss: searchItems) {
				ItemTagsView(items: self.$tags)
			}
			.navigationBarTitle("GIS Memo", displayMode: .inline)
			.confirmationDialog( ConstVar.ITEMDELETEMESSAGE, isPresented: self.$showDelConfirmDialog ,titleVisibility: .visible) {
				 Button("Delete Memo", role: .destructive) {
					 self.deleteMemo()
				 }
			 }
			 .statusBar(hidden: false)

		}
	}
}


extension ItemListView {

	private func startJob(){

		self.setMemoItems()
		self.locationService.requestLocation { location in
			self.weatherController.setListWeather(context: self.viewContext)
			self.markerController.setCurrentMarker(location: location)
		}
	}

	private func deleteMemo(){
		self.listController.deleteItem(
			viewContext: self.viewContext,
			writetime:self.currentItem,
			entity_memo:self.entity_memo,
			entity_memo_files:self.entity_memo_files,
			entity_memo_tags:self.entity_memo_tags,
			entity_memo_weather:self.entity_memo_weather )
	}

	private func searchItems(){

		self.listController.searchItems(
			tags: self.tags,
			entity_memo: self.entity_memo,
			entity_memo_tags: self.entity_memo_tags
		){
				self.tags = TagItem.searchAll()
		}
	}

	private func setMemoItems(){
		self.listController.setMemoItems(
			entity_memo: self.entity_memo )
	}

	private func makeShareItem(){
		self.listController.shareItem(
			writetime: self.currentItem,
			entity_memo: self.entity_memo,
			entity_memo_files: self.entity_memo_files ) { shareObject in
				let viewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
				let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
				if let window = windowScene?.windows.first {
					window.rootViewController?.present(viewController, animated: true, completion: nil)
				}
		}
	}

}


struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
