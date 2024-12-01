//
//  MapContainerView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//


import SwiftUI
import GoogleMaps

struct MapContainerView: View {

	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)] )
	private var entity_memo: FetchedResults<Entity_Memo>


	@StateObject  var markerController:GMSMarkerController

	var isWriteMemo:Bool = false
	@State private var isDidTap:Bool = false
	@State private var isMarkerInfo = false
	@State private var zoomLevel:Float = 12

	var body: some View {


		GeometryReader { geometry in
			ZStack {
				GoogleMapControllerBridge(	markers: self.$markerController.markers,
											selectedMarker: self.$markerController.currentMarker,
											isDidTap: self.$isDidTap,
										//	zoomLevel:self.zoomLevel,
											zoomLevel:self.$zoomLevel,
											isWriteMemo:self.isWriteMemo
				).onAppear {
					self.zoomLevel = self.markerController.markers.isEmpty ? 17 : 12
				}

				if	self.isDidTap,
					let marker = self.markerController.currentMarker,
					let userData = marker.userData as? GMSMarkerUserData  {
						self.previewContextFunc(userData)
				}
			}

			.sheet(isPresented: self.$isMarkerInfo){
				if	let marker = self.markerController.currentMarker,
					let userData = marker.userData as? GMSMarkerUserData {

					let markerInfoController =  MarkerInfoController( writeTime: userData.id)

					NavigationView {
						NavigationLink{
							 ItemDetailView(writetime: userData.id, markerInfoController: markerInfoController)
							 .onDisappear(){
								self.refreshMarkers()
							 }
							 .navigationBarBackButtonHidden(true)
							 .navigationBarHidden(true)
						}label: {
							MarkerInfoView( controller: MarkerInfoController( writeTime: userData.id) )
						}
					}
				}

			}
			.statusBar(hidden: false)

		}
	}
}

extension MapContainerView {

	private func refreshMarkers() {
		self.markerController.setMarkers(results: self.entity_memo.filter { $0.isPin == true }) { _ in
			if let userData =  (self.markerController.currentMarker?.userData as? GMSMarkerUserData) {
				self.markerController.currentMarker =
					self.markerController.markers.first{ gMSMarker in
						 (gMSMarker.userData as! GMSMarkerUserData).id == userData.id
					}
			}
		}
	}

	fileprivate func previewContextFunc(_ userData: GMSMarkerUserData) -> some View {

		return VStack {

			Spacer()

			RoundedRectangle(cornerRadius: 10)
				.stroke(Color.white.opacity(0.8), lineWidth: 2)
				.frame(width: 120, height: 120)
				.foregroundColor(.secondary)
				.overlay(content: {
					ImageView(url: ConstVar.DocumentPath.appendingPathComponent(userData.snapshotFileName))
				})
				.onTapGesture(perform: {
					self.isDidTap.toggle()
				})
				.previewContextMenu(
					preview: ImageView(url:ConstVar.DocumentPath.appendingPathComponent(userData.snapshotFileName)),
					destination: ItemDetailView(writetime: userData.id, markerInfoController: MarkerInfoController( writeTime: userData.id))
						.navigationBarBackButtonHidden(true)
						.navigationBarHidden(true)
						.onDisappear(){
							self.refreshMarkers()
						},
					presentAsSheet: true
				){
					PreviewContextAction(title: "Marker Information", systemImage: "doc.plaintext") {
						self.isMarkerInfo.toggle()
					}

					PreviewContextAction(title: "Close", systemImage: "xmark.circle", attributes: .destructive) {
						self.isDidTap.toggle()
					}
				}

		}
		.padding(.bottom, 20)
	}

}




struct MapContainerView_Previews: PreviewProvider {

	static var previews: some View {
		MapContainerView(markerController: GMSMarkerController())
	}
}

