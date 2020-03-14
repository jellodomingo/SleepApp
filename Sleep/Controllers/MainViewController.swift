//
//  MainViewController.swift
//  Sleep
//
//  Created by Angelo Domingo on 3/6/20.
//  Copyright © 2020 Angelo Domingo. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var avgHoursVar: Double = 0.0
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avgHours: UILabel!
    @IBOutlet weak var weatherSuggestion: UILabel!
    @IBOutlet weak var sleepSuggestion: UILabel!
    @IBOutlet weak var foodSuggestions: UILabel!
    @IBOutlet weak var bTime: UILabel!
    @IBOutlet weak var ltime: UILabel!
    @IBOutlet weak var dTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: "name") {
            name.text = saved
        } else {
            name.text = ""
        }

        weatherSuggestion.text = "Fetching from Database..."
        sleepSuggestion.text = "Fetching from Database..."
        avgHours.text = ""
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
        
        getWeatherSuggestions()
        getSleepSuggestions()
        getFoodSuggestion()
        getAvgHours()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getWeatherSuggestions()
        getSleepSuggestions()
        getFoodSuggestion()
        getAvgHours()
    }
    
    func getAvgHours() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        
        let url = BackendUrl.url.rawValue + Endpoints.getAvgHours.rawValue
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseString {
            (response) in
            print(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("example success")
                    if let result = response.result.value {
                        
                        var r = result
                        r.removeLast()
                        let final = r
                        let components = final.split { $0 == ":" } .map { (x) -> Int in return Int(String(x))! }
                        
                        let hours = components[0]
                        let minutes = components[1]
                        
                        self.avgHoursVar = Double(hours*60 + minutes) / 60.0
                        
                        self.avgHours.text = String(format: "%.2f", self.avgHoursVar)
                    }
 
                case 201:
                    let alert = UIAlertController(title: "Sleep Average Unavailable", message: "You don't have any sleep data for the past 5 days. No sleep average available.", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

                    self.present(alert, animated: true)
                    
                    self.avgHours.text = "N/A"
                    
                    
                    self.avgHours.text = "N/A"
                default:
                    print("error with response status: \(status)")
                    
                    let alert = UIAlertController(title: "Error", message: "Internal Server Error", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

                    self.present(alert, animated: true)
                    
                    
                    self.avgHours.text = "N/A"
                }
            }
        }
    }
    
    func getLocation() -> Location {
        var currentLoc: CLLocation!
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways{
                currentLoc = locationManager.location
                print(currentLoc.coordinate.latitude)
                print(currentLoc.coordinate.longitude)
                
                let latString = "\(currentLoc.coordinate.latitude)"
                let lngString = "\(currentLoc.coordinate.longitude)"
            
                return Location(lat: latString, lon: lngString)
        }
        else
        {
            print("nothing")
            return Location(lat: "0", lon: "0")
        }
    }
    
    func getWeatherSuggestions() {
        var recommendation: NSDictionary = [:]
        
        let request = getLocation()
        
        let url = BackendUrl.url.rawValue + Endpoints.weather.rawValue
        
        Alamofire.request(url, method: .post, parameters: request.dictionary, encoding: JSONEncoding.default).responseJSON {
            (response) in
            print(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("example success")
                    if let result = response.result.value {
                        recommendation = result as! NSDictionary
                        
                        //print(recommendation)
                        //print(recommendation["recommendation"] as! String? ?? nil)
                        self.weatherSuggestion.text = recommendation["recommendation"] as! String?
                    }
                    
                default:
                    print("error with response status: \(status)")
                    self.weatherSuggestion.text = "Cannot connect to Database..."
                }
            }
        }
        
    }
    
    func getSleepSuggestions() {
        
        var recommendation: NSDictionary = [:]
        
        var age: String
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: "age") {
            age = saved
        } else {
            age = "10"
        }
        
        let request = SleepSuggestionRequest(age: age)
               
               
       let url = BackendUrl.url.rawValue + Endpoints.sleepSuggestion.rawValue
       
       Alamofire.request(url, method: .post, parameters: request.dictionary, encoding: JSONEncoding.default).responseJSON {
           (response) in
           print(response)
           
           if let status = response.response?.statusCode {
               switch(status){
               case 200:
                   print("example success")
                   if let result = response.result.value {
                        recommendation = result as! NSDictionary

                        print(recommendation)
                        
                    let minApp = recommendation["min_sleep_appropriate"] as! Int
                    let maxApp = recommendation["max_sleep_appropriate"] as! Int
                    
                    self.sleepSuggestion.text = "According to your age, you should be getting from sleep \(minApp) to \(maxApp) hours of sleep." + " " + self.getAdviceOffAvg(min: minApp, max: maxApp)
                   }
                   
               default:
                   print("error with response status: \(status)")
                   self.sleepSuggestion.text = "Cannot connect to Database..."
               }
           }
        }
    }

    func getAdviceOffAvg(min: Int, max: Int) -> String
    {
        var response: String = ""
        
        if avgHoursVar == 0.0 {
            response = ""
        } else if self.avgHoursVar > Double(max) {
            response = "You are currently sleeping more than the recommended hours of sleep."
        } else if self.avgHoursVar < Double(min) {
            response = "You are currently sleeping less than the recommended hours of sleep."
        } else {
            response = "You are currently meeting the recommended hours of sleep."
        }
        
        return response
    }
    
    func getFoodSuggestion() {
        
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm:ss"
        
        let reformat = DateFormatter()
        reformat.dateFormat = "hh a"
        
        var recommendation: NSDictionary = [:]
                
        let url = BackendUrl.url.rawValue + Endpoints.foodSuggestion.rawValue
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON {
            (response) in
            print(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("example success")
                    if let result = response.result.value {
                         recommendation = result as! NSDictionary

                         print(recommendation)
                        
                        let bStart = timeFormat.date(from: recommendation["b_start"] as! String)
                        let dStart = timeFormat.date(from: recommendation["d_start"] as! String)
                        let lStart = timeFormat.date(from: recommendation["l_start"] as! String)
                        
                        let bString = reformat.string(from: bStart!)
                        let dString = reformat.string(from: dStart!)
                        let lString = reformat.string(from: lStart!)
                        
                    
                    /*
                    let bStart = recommendation["b_start"] as! String
                    let bEnd = recommendation["b_end"] as! String
                    let lStart = recommendation["l_start"] as! String
                    let lEnd = recommendation["l_end"] as! String
                    let dStart = recommendation["d_start"] as! String
                    let dEnd = recommendation["d_end"] as! String
                    */
                     
                        self.foodSuggestions.text = "According to your most recent wake up time. The best times to eat are:"
                        
                        self.bTime.text = bString
                        self.ltime.text = lString
                        self.dTime.text = dString
                    }
                    
                default:
                    print("error with response status: \(status)")
                    self.sleepSuggestion.text = "Cannot connect to Database..."
                }
            }
         }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
