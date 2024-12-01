//
//  NetService.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation
import UIKit


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




class URLSessionService {

    static let service = URLSessionService()
    
    var session:URLSession?

    init(){
        self.session = URLSession(configuration: .default)
    }

    deinit{
        if self.session != nil {
            self.session = nil
        }
    }


    func sessionImageLoad( urlRequest:URLRequest, completion:@escaping (UIImage?, String?) -> ()) {

        self.session?.dataTask(with: urlRequest, completionHandler: { data, response, error in

            if let error = error {
                DispatchQueue.global(qos: .background).async {
                    completion( nil, "sessionImageLoad dataTask error: \(error.localizedDescription) \n")
                }

            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let result =  UIImage(data: data)
                DispatchQueue.global(qos: .background).async {
                    completion( result, nil)
                }

            } else {
                 if let response = response as? HTTPURLResponse {
                    DispatchQueue.global(qos: .background).async {
                        completion( nil, "sessionImageLoad response error: \(response.description) \n")
                    }
                 }
            }
        }).resume()

    }

    func sessionLoad<T:Decodable> (
            urlRequest:URLRequest,
            resultType:T ,
            completion:@escaping (T?, String?) -> ()) {

            self.session?.dataTask(with: urlRequest, completionHandler: { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion( nil, "sessionLoad dataTask error: \(error.localizedDescription) \n")
                    }
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion( result, nil)
                        }
                    } catch let error as NSError {

                        DispatchQueue.main.async {
                            completion( nil, "sessionLoad JSONSerialization error:[ \(error.code) ]\(error.localizedDescription) \n")
                        }
                    }
                } else {
                     if let response = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            completion( nil, "sessionLoad response error: \(response.description) \n")
                        }
                     }
                }
            }).resume()

    }


    static func load<T: Decodable>(_ filename: String) -> T {

        let data: Data

        guard let file =  Bundle.main.url(forResource: filename, withExtension: nil)
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
