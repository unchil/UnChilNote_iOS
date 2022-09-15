//
//  Record{PageView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//


import SwiftUI
import AVFoundation

struct RecordPageView: View {

	var id:UUID = UUID()
	@Binding var selected:Int
	var controllers:[RecordView]
///	@State var prevSelected:Int = 0

	var body: some View {
		VStack(spacing:0){
			TabView(selection: $selected) {
				ForEach(controllers, id:\.id) { viewController in
					let index = controllers.firstIndex { recordView in
						viewController.id == recordView.id
					} ?? 0

					viewController.tabItem {
						Label("", systemImage: "circle.fill")
					}.tag(index)
				}
			}
			.modifier(PageViewModifier())
			.onAppear{
				//UIPageControl.appearance().currentPageIndicatorTintColor = .red
			}
		}
	}
}


struct RecordPageView_Previews: PreviewProvider {

	@ObservedObject static var recordText:TextFieldData = TextFieldData(data: "test")


	static var pages:[RecordView] = [RecordView( fileURL: Bundle.main.url(forResource: "test", withExtension: "wav")! , recordText: recordText),
									  RecordView( fileURL: Bundle.main.url(forResource: "test2", withExtension: "wav")!, recordText: recordText),
									  RecordView( fileURL: Bundle.main.url(forResource: "test", withExtension: "wav")!, recordText: recordText)]
	@State static var recordIndex = 0
    static var previews: some View {
		RecordPageView(selected:$recordIndex, controllers: pages)
    }
}
