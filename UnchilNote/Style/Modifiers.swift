//
//  Modifiers.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/20.
//

import Foundation
import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
	let action: (UIDeviceOrientation) -> Void

	func body(content: Content) -> some View {
		content
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				action(UIDevice.current.orientation)
			}
	}
}
