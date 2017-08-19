//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather" // Where the weather data from
    let APP_ID = "e72ca729af228beabd5d20e3b7749713" // Our own App ID - for weather website's using
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var degreeSwitch: UISwitch!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var fahrenheitLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        initialDegreeSwitchUI()
    }
    
    
    
    
    //MARK: - Networking
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameter: [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON {
            
            response in
            
            switch response.result {
                
            case .success:
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            case .failure(let error):
                print(error)
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    //MARK: - JSON Parsing
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        
        guard let tempResult = json["main"]["temp"].double else { return cityLabel.text = "Weather Unavailable" }
        
        
        weatherDataModel.temperatureInCelsius = Int(tempResult - 273.15)
        
        weatherDataModel.temperatureInFahrenheit = Int((tempResult - 273.15) * 1.8 + 32)
    
        
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIWithWeatherData()
        
    }

    
    
    
    //MARK: - UI Updates
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        
        temperatureLabel.text = String(weatherDataModel.temperatureInCelsius) + "°"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    @IBAction func degreeSwitchPressed(_ sender: UISwitch) {
        
        if degreeSwitch.isOn {
            temperatureLabel.text = String(weatherDataModel.temperatureInCelsius) + "°"
            celsiusLabel.textColor = UIColor.white
            fahrenheitLabel.textColor = UIColor.darkGray
            
        } else {
            temperatureLabel.text = String(weatherDataModel.temperatureInFahrenheit) + "°"
            celsiusLabel.textColor = UIColor.darkGray
            fahrenheitLabel.textColor = UIColor.white
        }
    }
    
    func initialDegreeSwitchUI() {
        degreeSwitch.setOn(true, animated: true)
        celsiusLabel.textColor = UIColor.white
        fahrenheitLabel.textColor = UIColor.darkGray
    }
    

    
    
    //MARK: - Location Manager Delegate Methods
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1] // Get the last - most accuracy location data
        
        if location.horizontalAccuracy > 0 {
        
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameter: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameter: params)
        
        initialDegreeSwitchUI()
        
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destivationVC = segue.destination as! ChangeCityViewController
            
            destivationVC.delegate = self
            
        }
    }
    
    
    
    
}


