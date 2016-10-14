//
//  OpenWeatherMapAPI.swift
//  OpenWeather
//
//  Created by Nikolas Burk on 21/09/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//


import Foundation
import Result

typealias CurrentWeathercompletionHandler  = (Result<Weather, Reason>) -> ()
typealias ForecastcompletionHandler        = (Result<[Weather], Reason>) -> ()

extension Reason: Error {
  
}

final class OpenWeatherMapAPI {
  
  let urlSession: URLSession
  
  init(apiKey: String, urlSession: URLSession = URLSession.shared) {
    self.apiKey = apiKey
    self.urlSession = urlSession
  }
  
  // MARK: API Info
  
  fileprivate let apiKey: String
  fileprivate let baseURL = "http://api.openweathermap.org/data/2.5"
  
  
  // MARK: Custom Types
  
  fileprivate enum Endpoint: String {
    case weather = "weather"
    case forecast = "forecast/daily"
  }
  
  fileprivate enum GeneralParameters: String {
    case appId
    case q
    case units
  }
  
  fileprivate enum ForecastParameters: String {
    case cnt
  }
  
  enum TemperatureUnit: String {
    case fahrenheit = "imperial"
    case celsius = "metric"
    case kelvin
  }
  
  public static let maxForecastDays = 16
  enum ForecastPeriod: String {
    case oneDay = "1"
    case twoDays = "2"
    case threeDays = "3"
    case fourDays = "4"
    case fiveDays = "5"
    case sixDays = "6"
    case sevenDays = "7"
    case eightDays = "8"
    case nineDays = "9"
    case tenDays = "10"
    case elevenDays = "11"
    case twelveDays = "12"
    case thirteenDays = "13"
    case fourteenDays = "14"
    case fifteenDays = "15"
    case sixteenDays = "16"
  }
  
  
  // MARK: Build URLS
  
  fileprivate func buildGeneralURLArguments(for city: String, temperatureUnit: OpenWeatherMapAPI.TemperatureUnit) -> String {
    let q = OpenWeatherMapAPI.GeneralParameters.q.rawValue + "=" + city
    let appId = OpenWeatherMapAPI.GeneralParameters.appId.rawValue + "=" + apiKey
    var urlArguments = [q, appId]
    if temperatureUnit != .kelvin {
      let units = OpenWeatherMapAPI.GeneralParameters.units.rawValue + "=" + temperatureUnit.rawValue
      urlArguments.append(units)
    }
    return concatURLArguments(urlArguments) //"" // q + "&" + units + "&" + appId
  }
  
  fileprivate func buildForecastURLArguments(for forecastPeriod: OpenWeatherMapAPI.ForecastPeriod) -> String {
    return OpenWeatherMapAPI.ForecastParameters.cnt.rawValue + "=" + forecastPeriod.rawValue
  }
  
  fileprivate func concatURLArguments(_ arguments: [String]) -> String {
    return arguments.joined(separator: "&")
  }
  
  
  // MARK: Public API
  
  public func getForecast(for city: String,
                          temperatureUnit: OpenWeatherMapAPI.TemperatureUnit = OpenWeatherMapAPI.TemperatureUnit.fahrenheit,
                          forecastPeriod: OpenWeatherMapAPI.ForecastPeriod = OpenWeatherMapAPI.ForecastPeriod.sevenDays,
                          completionHandler: @escaping ForecastcompletionHandler) {
    
    let path = OpenWeatherMapAPI.Endpoint.forecast.rawValue //getPath(for: OpenWeatherMapAPI.Endpoint.forecast)
    let generalURLArguments = buildGeneralURLArguments(for: city, temperatureUnit: temperatureUnit)
    let forecastURLArguments = buildForecastURLArguments(for: forecastPeriod)
    let queryString = concatURLArguments([generalURLArguments, forecastURLArguments])
    
    let forecastResource: Resource<[JSONWeather]> = Resource(
      baseURL: baseURL,
      path: path,
      queryString: queryString,
      method: .GET,
      requestBody: nil,
      headers: nil,
      parse: [JSONWeather].parse
    )
    
    let client = HTTPClient()
    client.apiRequest(urlSession, resource: forecastResource, failure: { (reason: Reason, data: Data?) in
      print("request failed with: \(reason)")
      completionHandler(.failure(reason))
      })
    { (forecast: [JSONWeather]) in
      let curried = self.jsonWeatherConverter(temperatureUnit)
      let weatherForecast = forecast.map(curried)
      let result: Result<[Weather], Reason> = .success(weatherForecast)
      completionHandler(result)
    }
    
  }
  
  public func getCurrentWeather(for city: String,
                                temperatureUnit: OpenWeatherMapAPI.TemperatureUnit = OpenWeatherMapAPI.TemperatureUnit.fahrenheit,
                                completionHandler: @escaping CurrentWeathercompletionHandler) {
    
    let path = OpenWeatherMapAPI.Endpoint.weather.rawValue //getPath(for: OpenWeatherMapAPI.Endpoint.weather)
    let queryString = buildGeneralURLArguments(for: city, temperatureUnit: temperatureUnit)
    
    let currentWeatherResource: Resource<JSONWeather> = Resource(
      baseURL: baseURL,
      path: path,
      queryString: queryString,
      method: .GET,
      requestBody: nil,
      headers: nil,
      parse: JSONWeather.parse
    )
    
    let client = HTTPClient()
    client.apiRequest(resource: currentWeatherResource, failure: { (reason: Reason, data: Data?) in
      print("request failed with: \(reason)")
      completionHandler(.failure(reason))
    }) { (jsonWeather: JSONWeather) in
      let weather = self.jsonWeatherConverter(temperatureUnit)(jsonWeather)
      let result: Result<Weather, Reason> = .success(weather)
      completionHandler(result)

    }
    
  }
  

  // MARK: Helpers
  
  fileprivate func jsonWeatherConverter(_ temperatureUnit: OpenWeatherMapAPI.TemperatureUnit)  -> (JSONWeather) -> Weather {
    return { (jsonWeather: JSONWeather) in
      let temperature = Temperature(avg: jsonWeather.avgTemperature, min: jsonWeather.minTemperature, max: jsonWeather.maxTemperature, unit: temperatureUnit)
      let weather = Weather(date: jsonWeather.date, description: jsonWeather.description, temperature: temperature)
      return weather
    }
  }

}









