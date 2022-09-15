//
//  NetService.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation


class NetService {

	//var completionHandler: ((WeatherData) -> (Void))?

	func requestCurrentWeather(url:String, completion: @escaping ((WeatherData) -> (Void))) {
		let currentWeather:WeatherData = self.load(url,  false)
		completion(currentWeather)
	}

	private func load<T: Decodable>(_ filename: String,_ local: Bool) -> T {

		let data: Data

		guard let file = local ? Bundle.main.url(forResource: filename, withExtension: nil) :  URL(string:filename)
		else {
			fatalError("Couldn't find \(filename) in main bundle.")
		}

		do {
			data = try Data(contentsOf: file)
		} catch {
			fatalError("Couldn't load \(filename) in main bundle:\n\(error)")
		}

		do{
			let decoder = JSONDecoder()
			return try decoder.decode(T.self, from: data)
		} catch {
			fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
		}

	}
}
