//
//  ImagePageView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//

import SwiftUI


struct ImagePageView: View {

	@Environment(\.dismiss) var dismiss
	@Binding var selected:Int
	var controllers:[ImageView]
	var displayMode:ImageViewMode

	@State private var currentScale:CGFloat = 1
	@State private var lastScale:CGFloat = 0
	@State private var currentPosition: CGSize = .zero
	@GestureState private var dragOffset:CGSize = .zero
	@State private var swipeMode:CustomSwipeMode = .hold
	@State private var translationWidth:CGFloat = 0

	var swipeMarginValue:CGFloat = 100

	var body: some View {

		ZStack{

			TabView (selection: $selected) {

				ForEach(controllers, id:\.id) { viewController in

					let index = controllers.firstIndex { view in
						viewController.id == view.id
					} ?? 0


					if displayMode == ImageViewMode.full {

						viewController
							.tabItem {
								Label("", systemImage: "circle.fill")
								//	.labelStyle(.iconOnly)
							}.tag(index)
							.scaleEffect(currentScale)
							.offset(x: currentPosition.width + dragOffset.width, y: currentPosition.height + dragOffset.height)
							.animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: dragOffset)
							.gesture(
								MagnificationGesture()
								.onChanged({ value in
									currentScale = value.magnitude + lastScale
								})
								.onEnded({ value in
									if  value.isLess(than: 1)  {
										lastScale = 1
									} else {
										lastScale =  value.magnitude
									}
								})
									/*
									.simultaneously(with: DragGesture())
									.updating($dragOffset, body: { value, state, transaction in

										guard let location = value.second else { return }

										let startLocationX =  location.startLocation.x

										if startLocationX < swipeMarginValue {
											swipeMode = .previous
										} else if startLocationX > UIScreen.main.bounds.size.width - swipeMarginValue {
											swipeMode = .next
										}else{
											swipeMode = .hold
											state = value.second?.translation ?? .zero
										}
									})
									.onEnded({ value in

										translationWidth = value.second?.translation.width ?? 0

										switch swipeMode {

											case .previous:
												if selected == 0 {
													if controllers.count > 1 {
														selected =  controllers.endIndex
													}
												} else {
													selected = selected - 1
												}
											case .next:
												if selected + 1 == controllers.count {
													if controllers.count > 1 {
														selected =  controllers.startIndex
													}
												} else {
													selected = selected + 1
												}
											case .hold:
												self.currentPosition.width += value.second?.translation.width ?? 0
												self.currentPosition.height += value.second?.translation.height ?? 0
										}
										swipeMode = .hold
									})
									*/
							)
							.gesture(
								TapGesture(count: 2)
								.onEnded({ () in
									currentScale = 1
									currentPosition = .zero
								})
							)
							.onAppear {
								currentScale = 1
								currentPosition = .zero
							}

					} else {

						viewController
						.previewContextMenu( preview: viewController )
						.tabItem {
							Label("", systemImage: "circle.fill")
							//	.labelStyle(.iconOnly)
						}.tag(index)

					}

				}
			}
			.onAppear{
			//	UIPageControl.appearance().currentPageIndicatorTintColor = .red
			}
			.modifier( PageViewModifier())
			.animation(.easeInOut, value: translationWidth)



		}
		/*
		.overlay {

			if displayMode == ImageViewMode.full {
				VStack{
					HStack {
						Button{
							dismiss.callAsFunction()
						}label: { Label("", systemImage: "chevron.backward")}
						Spacer()
					}
					.padding(30)
					//.scaleEffect(1.8)
					Spacer()
				}
			}

		}
		*/
	}
}



struct ImagePageView_Previews: PreviewProvider {


	static var pages:[ImageView] = [ImageView(url: Bundle.main.url(forResource: "sample_map", withExtension: "jpg")!),
									ImageView(url: Bundle.main.url(forResource: "screenshot", withExtension: "jpeg")!),
									ImageView(url: Bundle.main.url(forResource: "sample_map", withExtension: "jpg")!)]



    static var previews: some View {
		ImagePageView(selected: .constant(0), controllers: pages, displayMode: .full)
    }
}
