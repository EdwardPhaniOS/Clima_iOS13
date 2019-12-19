//
//  WeatherControl.swift
//  Clima
//
//  Created by Tan Vinh Phan on 10/30/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate: class {
    func didUpdateWeather(_ weatherVC: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var weatherURL: String = ""
    
    init() {
        guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
            else { print("Error: Can't find secret API Key"); return }
        
        if let keysDict = NSDictionary(contentsOfFile: path),
            let apiKey = keysDict["apiKey"] as? String {
            self.weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
        } else {
            print("Error: Can't find secret API Key")
        }
    }
    
    weak var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longtitude: CLLocationDegrees) {
        
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        //create url
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                    
                } else {
                    
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData) {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                            
                        }
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let weatherId = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: weatherId, cityName: name, temperature: temp)
            return weather
        
        } catch {
            print(error)
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
}
