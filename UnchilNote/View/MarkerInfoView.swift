//
//  MarkerInfoView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/13.
//

import SwiftUI
import GoogleMaps

struct MarkerInfoView: View {

	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)])
	private var entity_memo: FetchedResults<Entity_Memo>

	@StateObject var controller:MarkerInfoController

	var marker:GMSMarker?

	var body: some View {
/*
		if self.controller.writetime == 0 {
			VStack(alignment: .center, spacing: 10){
				Text("Current Location")
				.font(.title)

				GroupBox(label: Label("Description:", systemImage: "info.circle")){
					if let marker = self.marker {
						VStack(alignment: .leading){
							Text("Latitude: \(marker.position.latitude)")
							Text("Longitude:\(marker.position.longitude)")
						}
						.padding(.vertical,6)
					}
				}
			}
		} else {
			self.markerInfoFunc()
		}
*/
		self.markerInfoFunc()
	}
}

extension MarkerInfoView {

	fileprivate func markerInfoFunc() -> some View {
		return VStack(alignment: .center, spacing: 10){

			Text("Marker Infomation")
				.font(.title)

			Text("\(self.controller.detailHeaderData.title)")
				.font(.headline)

			Text("\(self.controller.detailHeaderData.desc)")
				.font(.headline)

			GroupBox(label: Label("Description:", systemImage: "info.circle")){
				VStack(alignment: .leading){
					Text("Tag: \(self.controller.detailHeaderData.snippets)")
					Text("Attach: Snapshot:\(self.controller.detailHeaderData.snapshotCnt) Record:\(self.controller.detailHeaderData.recordCnt)  Photo:\(self.controller.detailHeaderData.photoCnt)")
					Text("Latitude: \(self.controller.detailHeaderData.latitude)")
					Text("Longitude:\(self.controller.detailHeaderData.longitude)")
				}.padding(.vertical,6)
			}

			Spacer()

		}
		.onAppear(){
			self.controller.refreshHeaderData(entity_memo: self.entity_memo)
		}
	}

}

struct MarkerInfoView_Previews: PreviewProvider {

	static var previews: some View {
		MarkerInfoView( controller: MarkerInfoController(writeTime: 0), marker: GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0)) )
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
