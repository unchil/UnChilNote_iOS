//
//  WeatherController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/14.
//


import Foundation
import CoreData
import CoreLocation
import SwiftUI

class WeatherController: ObservableObject {

	static let controller = WeatherController()

	let locationService = LocationService.service
    
//	let openWeatherService = NetService()
  
    let netQueryService = URLSessionService.service
    let timeoutInterval = TimeInterval(60)
    var completionHandler:((Bool, String)->())?

    
	@Published var weatherData: WeatherData = WeatherData.makeDefaultValue()


	func setListWeather(context: NSManagedObjectContext) {
		//self.locationService.requestLocation { location in
		if let location = locationService.cLLocationManager.location {
            
			let openWeatherURL =
			 "\(ConstVar.OpenWeatherURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(KeyVar.OpenWeatherSdkApiKey)&units=\(ConstVar.OpenWeatherUnits)"

            
        /*
			self.openWeatherService.requestCurrentWeather(url: openWeatherURL) { result in
				truncateEntity(context: context,  entityName: Entity_Current_Weather.entity().name!)
				result.toEntity_Current_Weather(context: context)
				commitTrans(context: context)
				self.weatherData = result

			}
          */
            
            guard let url =  URL(string: openWeatherURL) else { return }
            var urlRequest = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: self.timeoutInterval)
            
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.netQueryService.sessionLoad(
                urlRequest: urlRequest,
                resultType: WeatherData.makeDefaultValue()
            ){ result,error in

                if let result = result {
                    truncateEntity(context: context,  entityName: Entity_Current_Weather.entity().name!)
                    result.toEntity_Current_Weather(context: context)
                    commitTrans(context: context)
                    self.weatherData = result

                }
 
            }
            
		}
	}


	func setMemoWeather(context: NSManagedObjectContext, writetime: Double, completion: @escaping (WeatherData) -> (Void)? ) {
		if let location = locationService.cLLocationManager.location {
            
			let openWeatherURL =
			"\(ConstVar.OpenWeatherURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(KeyVar.OpenWeatherSdkApiKey)&units=\(ConstVar.OpenWeatherUnits)"
            
            guard let url =  URL(string: openWeatherURL) else { return }
            var urlRequest = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: self.timeoutInterval)
            
            /*
			self.openWeatherService.requestCurrentWeather(url: openWeatherURL) { result in
				result.toEntity_Memo_Weather(context: context, writeTime: writetime)
				commitTrans(context: context)
				self.weatherData = result
				completion(result)
			}
             */
            
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.netQueryService.sessionLoad(
                urlRequest: urlRequest,
                resultType: WeatherData.makeDefaultValue()
            ){ result,error in
                
                if let result = result {
                    result.toEntity_Memo_Weather(context: context, writeTime: writetime)
                    commitTrans(context: context)
                    self.weatherData = result
                    completion(result)
                }
            }
            
            
		}
	}

	func getMemoWeather(	context:NSManagedObjectContext,
							writetime:Double,
							entity_memo_weather:FetchedResults<Entity_Memo_Weather>) {

		if let result = entity_memo_weather.first(where: { row in
			row.writetime == Int64(writetime) }){
			self.weatherData = result.toWeatherData
		}
	}



	func makeWeatherDesc(completion: @escaping (String) -> (Void) ) {
		let weatherDesc =
		"\(self.weatherData.weather.first!.main):\(self.weatherData.weather.first!.description)" +
		"  \(self.weatherData.name) / \(self.weatherData.sys.country)"

		completion(weatherDesc)
	}


}


