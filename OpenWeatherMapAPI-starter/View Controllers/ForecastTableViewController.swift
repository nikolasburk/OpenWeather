//
//  ForecastTableViewController.swift
//  OpenWeatherMapAPI-starter
//
//  Created by Nikolas Burk on 01/10/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import Result

class ForecastTableViewController: UITableViewController {
  
  var openWeatherMapAPI: OpenWeatherMapAPI!
  var city: String!
  var forecastPeriodDays: Int!
  
  var weatherForecast: [Weather] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Forecast"
    
    let completionHandler = { (result: Result<[Weather], Reason>) in
      switch result {
      case .failure(let reason):
        print("could not retrieve forecast info: \(reason)")
      case .success(let forecast):
        self.weatherForecast = forecast
      }
    }
    
    if let forecastPeriod = OpenWeatherMapAPI.ForecastPeriod(rawValue: String(forecastPeriodDays)) {
      openWeatherMapAPI.getForecast(for: city, forecastPeriod: forecastPeriod, completionHandler: completionHandler)
    }
    else {
      print("could not read forecast period, use default: 7 days")
      openWeatherMapAPI.getForecast(for: city, completionHandler: completionHandler)
    }
    

    
  }
  
  // MARK: - Table view data source
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return weatherForecast.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let weather = weatherForecast[indexPath.row]
    let title = "\(weather.description) (\(weather.temperature.avg)°, \(weather.temperature.min)° - \(weather.temperature.max)°)"
    cell.textLabel!.text = title
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: weather.date)
    cell.detailTextLabel!.text = dateString
    
    return cell
  }
  
  
}
