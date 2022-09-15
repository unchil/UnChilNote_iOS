//
//  LockView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/11.
//
import SwiftUI

struct LockView: View {

	@Environment(\.dismiss) var dismiss

	var body: some View {

		VStack{
			Button{
				dismiss.callAsFunction()
			}label: {
				Label("이전", systemImage: "chevron.backward")
			}
			Spacer()
			Label("보안 설정된 메모 입니다.", systemImage: "lock.fill")

		}.padding(.vertical, 100)
	}
}

struct LockView_Previews: PreviewProvider {
	static var previews: some View {
		LockView()
			.previewInterfaceOrientation(.portraitUpsideDown)
	}
}
