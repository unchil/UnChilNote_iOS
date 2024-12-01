//
//  WeatherView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import SwiftUI

struct WeatherView: View {

/*
	@Environment(\.managedObjectContext)
	private var viewContext
*/
	@StateObject var controller: WeatherController

	var body: some View {

		VStack {
				Text(self.controller.weatherData.dt.formatCollectTime() + " " +
					 self.controller.weatherData.name + "/" +
					 self.controller.weatherData.sys.country)
				.font(.system(size: 16, weight: .bold, design: .default))

				Text( "\(self.controller.weatherData.weather[0].main) : \(self.controller.weatherData.weather[0].description)")
				.font(.headline)

				HStack {
					Spacer()
					self.controller.weatherData.weather[0].icon.getIconImage()
					Spacer()

					VStack(alignment: .leading){
						Label("sunrise   " +  self.controller.weatherData.sys.sunrise.formatHHmm(), systemImage: "sunrise")
						Label("sunset    " +  self.controller.weatherData.sys.sunset.formatHHmm(), systemImage: "sunset")
						Label("   temp       " + String(self.controller.weatherData.main.temp) + " ºC", systemImage: "thermometer")
						Label("  min          " + String(self.controller.weatherData.main.temp_min) + " ºC", systemImage: "thermometer.snowflake")
						Label("  max         " + String(self.controller.weatherData.main.temp_max) + " ºC", systemImage: "thermometer.sun")
						Label("   pressure " + String(self.controller.weatherData.main.pressure) + " hPa", systemImage: "tropicalstorm") // bolt.horizontal.icloud
						Label(" humidity  " + String(self.controller.weatherData.main.humidity) + " %" , systemImage: "humidity")
						Label(" wind         " + String(self.controller.weatherData.wind.speed) + " m/s", systemImage: "wind")
						Label(" deg           " + String(self.controller.weatherData.wind.deg) + " º", systemImage: "flag")
						Label("visibility   " + String(self.controller.weatherData.visibility / 1000) + " Km", systemImage: "eye")
					}
					.font(.system(size: 12, weight: .light, design: .rounded))

					Spacer()
				}
			}
			.onAppear(){

			}
	}
}


struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(controller: WeatherController())
      //  .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
