//
//  Weather.swift
//  OpenWeather
//
//  Created by Nikolas Burk on 21/09/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import Foundation
import SwiftyJSON


struct Weather {
  
  let date: Date
  let description: String
  let temperature: Temperature
  
}

// helper struct to represent the weather data after being parsed from JSON
struct JSONWeather {
  
  let description: String
  let minTemperature: Float
  let maxTemperature: Float
  let avgTemperature: Float
  let date: Date

  // JSON properties for current weather
  enum PropertiesCurrent: String {
    // level 1
    case weather
    case main
    case dt
    
    // level 2
    case temp
    case temp_min
    case temp_max
    case description
  }

  // JSON properties for forecast
  enum PropertiesForecast: String {
    // level 1
    case list
    
    // level 2
    case temp
    case weather
    case dt
    
    // level 3
    case day
    case min
    case max
    case description
  }
  
}

// makes it so that [JSONWeather] gets its own parse function (for HTTPClient)
extension Collection where Iterator.Element == JSONWeather {

  static func parse(_ jsonData: Data) -> [JSONWeather]? {
    let json = JSON(data: jsonData)
    
    let forecastArray = json[JSONWeather.PropertiesForecast.list.rawValue].arrayValue
    let forecast: [JSONWeather] = forecastArray.reduce([]) { (result: [JSONWeather], weatherInfo: JSON) in
      let description = weatherInfo[JSONWeather.PropertiesForecast.weather.rawValue][0][JSONWeather.PropertiesForecast.description.rawValue].stringValue
      let minTemperature = weatherInfo[JSONWeather.PropertiesForecast.temp.rawValue][JSONWeather.PropertiesForecast.min.rawValue].floatValue
      let maxTemperature = weatherInfo[JSONWeather.PropertiesForecast.temp.rawValue][JSONWeather.PropertiesForecast.max.rawValue].floatValue
      let avgTemperature = weatherInfo[JSONWeather.PropertiesForecast.temp.rawValue][JSONWeather.PropertiesForecast.day.rawValue].floatValue
      let timestamp = weatherInfo[JSONWeather.PropertiesForecast.dt.rawValue].doubleValue
      let date = Date(timeIntervalSince1970: timestamp)
      let weather = JSONWeather(description: description, minTemperature: minTemperature, maxTemperature: maxTemperature, avgTemperature: avgTemperature, date: date)
      var newResult = result
      newResult.append(weather)
      return newResult
    }

    return forecast
  }
  

}


extension JSONWeather {
  
  static func parse(_ jsonData: Data) -> JSONWeather? {
    let json = JSON(data: jsonData)
    return parseCurrentWeather(json)
   }
  
  static func parseCurrentWeather(_ json: JSON) -> JSONWeather? {
    let description = json[JSONWeather.PropertiesCurrent.weather.rawValue][0][JSONWeather.PropertiesCurrent.description.rawValue].stringValue
    let minTemperature = json[JSONWeather.PropertiesCurrent.main.rawValue][JSONWeather.PropertiesCurrent.temp_min.rawValue].floatValue
    let maxTemperature = json[JSONWeather.PropertiesCurrent.main.rawValue][JSONWeather.PropertiesCurrent.temp_max.rawValue].floatValue
    let avgTemperature = json[JSONWeather.PropertiesCurrent.main.rawValue][JSONWeather.PropertiesCurrent.temp.rawValue].floatValue
    let timestamp = json[JSONWeather.PropertiesCurrent.dt.rawValue].doubleValue
    let date = Date(timeIntervalSince1970: timestamp)
    
    let jsonWeather = JSONWeather(description: description, minTemperature: minTemperature, maxTemperature: maxTemperature, avgTemperature: avgTemperature, date: date)
    return jsonWeather
  }

}



