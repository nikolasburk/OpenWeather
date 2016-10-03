//
//  ViewController.swift
//  OpenWeatherMapAPI-starter
//
//  Created by Nikolas Burk on 28/09/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit
import Result

let apiKey = "76206cd3a7796e7db880c8385c0786ef"

class ViewController: UIViewController {
  
  private let displayForecastSegueIdentifier = "displayForecastSegue"
  
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var minTemperatureLabel: UILabel!
  @IBOutlet weak var maxTemperatureLabel: UILabel!
  @IBOutlet weak var avgTemperatureLabel: UILabel!
  @IBOutlet weak var daysTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let openWeatherMapAPI = OpenWeatherMapAPI(apiKey: apiKey)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Weather"
  }
  
  @IBAction func goButtonPressed() {
    if let city = cityTextField.text {
      activityIndicator.startAnimating()
      openWeatherMapAPI.getCurrentWeather(for: city) { (result: Result<Weather, Reason>) in
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
        }
        switch result {
        case .failure(let error):
          print("couldn't retrieve result: \(error)")
        case .success(let weather):
          DispatchQueue.main.async {
            self.updateUI(with: weather)
          }
        }
      }
    }
  }
  
  func updateUI(with weather: Weather) {
    descriptionLabel.text = "Description: \(weather.description)"
    minTemperatureLabel.text = "Min: \(weather.temperature.min)°"
    maxTemperatureLabel.text = "Max: \(weather.temperature.max)°"
    avgTemperatureLabel.text = "Avg: \(weather.temperature.avg)°"
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == displayForecastSegueIdentifier {
      // check for number of days (max: 16)
      if let numberOfDays = Int(daysTextField.text!),
        numberOfDays <= OpenWeatherMapAPI.maxForecastDays,
        numberOfDays > 0 {
        // check for city
        if let city = cityTextField.text,
          city.characters.count > 0 {
          return true
        }
        else {
          print("error: provide city")
        }
      }
      else {
        print("error: provide number of days for forecast (max 16)")
      }
      return false
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == displayForecastSegueIdentifier {
      let forecastTableViewController = segue.destination as! ForecastTableViewController
      forecastTableViewController.forecastPeriodDays = Int(daysTextField.text!)!
      forecastTableViewController.city = cityTextField.text!
      forecastTableViewController.openWeatherMapAPI = openWeatherMapAPI
    }
  }
  
  
}



