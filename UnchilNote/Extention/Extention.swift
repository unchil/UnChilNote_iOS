//
//  Extention.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import Foundation
import SwiftUI
import LocalAuthentication


extension View {

	func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void)  -> some View {
		self.modifier(DeviceRotationViewModifier(action: action))
	}
}



extension Double {
	func formatmmss() -> String {
		let date = Date(timeIntervalSince1970: self)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "mm:ss"
		return dateFormatter.string(from: date)
	}
}



extension LABiometryType {

	var description:String {
		switch self {
			case .none:
				return "보안설정된 메모를 열람하기 위해서 비밀번호로 인증 합니다."
			case .touchID:
				return "보안설정된 메모를 열람하기 위해서 TouchID로 인증 합니다."
			case .faceID:
				return "보안설정된 메모를 열람하기 위해서 FaceID로 인증 합니다."
			@unknown default:
				return ""
		}
	}

}

extension CLong {
	func formatHHmmss() -> String {
		let time = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: time)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		return dateFormatter.string(from: date)
	}

		func formatHHmm() -> String {
		let time = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: time)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.string(from: date)
	}

	func formatCollectTime() -> String {
		let collectTime = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: collectTime)
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "kr_KR")
		dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
		return dateFormatter.string(from: date)
	}

	func formatYYYYMMdd_HHmmssSSS() -> String {
		let collectTime = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: collectTime)
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "kr_KR")
		dateFormatter.dateFormat = "YYYYMMdd-HHmmssSSS"
		return dateFormatter.string(from: date)
	}
}


extension String {

	func getIconImage() -> Image {
		switch (self) {
			case "01d" :  return Image("ic_openweather_01d")
			case "01n" : return Image("ic_openweather_01n")
			case "02d" : return Image("ic_openweather_02d")
			case "02n" : return Image("ic_openweather_02n")
			case "03d" : return Image("ic_openweather_03d")
			case "03n" : return Image("ic_openweather_03n")
			case "04d" : return Image("ic_openweather_04d")
			case "04n" : return Image("ic_openweather_04n")
			case "09d" : return Image("ic_openweather_09n")
			case "09n" : return Image("ic_openweather_09n")
			case "10d" : return Image("ic_openweather_10d")
			case "10n" : return Image("ic_openweather_10n")
			case "11d" : return Image("ic_openweather_11d")
			case "11n" : return Image("ic_openweather_11n")
			case "13d" : return Image("ic_openweather_13d")
			case "13n" : return Image("ic_openweather_13n")
			case "50d" : return Image("ic_openweather_50d")
			case "50n" : return Image("ic_openweather_50n")
			default: return Image("ic_openweather_unknown")
		}
	}
}


extension Date
{
	func toString( dateFormat format  : String ) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}
