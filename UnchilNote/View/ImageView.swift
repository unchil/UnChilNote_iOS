//
//  ImageView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import SwiftUI

struct ImageView: View {

	var id:UUID = UUID()
	@State var url:URL?
	var image:UIImage?
	@State var content:UIImage = {
		let url:URL = Bundle.main.url(forResource: "exclamationmark.triangle", withExtension: "jpg")!
		let data = try! Data(contentsOf: url)
		return UIImage(data: data)!
	}()

	var body: some View {

		Image(uiImage: content)
			.resizable()
			//.resizable(capInsets:  EdgeInsets(), resizingMode: .tile)
			.onAppear{
				if let url = self.url {
					do {
						let data = try Data(contentsOf: url)
						content = UIImage(data: data) ?? content
					} catch {
						//fatalError("Couldn't load \(url.path) \n\(error)")
					}
				} else {
					content = image ?? content
				}
			}
	}
}

struct ImageView_Previews: PreviewProvider {

	static let url:URL = Bundle.main.url(forResource: "exclamationmark.triangle", withExtension: "jpg")!
	static let image:UIImage = UIImage(named: "sample_map.jpg")!
    static var previews: some View {

		Group{
			ImageView( image: image)
			ImageView( url: url)
		}
    }
}
