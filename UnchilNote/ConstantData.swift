//
//  ConstantData.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//

import Foundation
import SwiftUI



struct ConstVar {
	static let OpenWeatherURL = "https://api.openweathermap.org/data/2.5/weather"
	static let OpenWeatherUnits = "metric"
	static let DocumentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	static let NODATA:String = "No Data"
	static let TITLEFORMAT:String = "YYYY/MM/dd HH:mm EEEE"
	static let FILENAMEFORMAT:String = "YYYYMMdd-HHmmssSSS"
	static let IMAGEFILEEXE:String = "jpg"
	static let CURRENTLOCALE =  Locale(identifier: "ko-KR")
	static let RECORDINGFILEEXE:String = "wav"
	static let ITEMDELETEMESSAGE: String = "Are you sure you want to clear the Memo?"
}



