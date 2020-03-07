//
//  DataInputViewController.swift
//  Sleep
//
//  Created by Angelo Domingo on 3/6/20.
//  Copyright © 2020 Angelo Domingo. All rights reserved.
//

import UIKit
import Alamofire

class DataInputViewController: UIViewController {

    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    @IBOutlet weak var savedTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: "timeLabelSaved") {
            savedTime.text = saved
        } else {
            savedTime.text = ""
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: "timeLabelSaved") {
            savedTime.text = saved
        } else {
            savedTime.text = ""
        }
    }
    
    @IBAction func saveStart(_ sender: Any) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss"
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm a"
        timeFormat.amSymbol = "AM"
        timeFormat.pmSymbol = "PM"

        let strDate = dateFormatterGet.string(from: startTime.date)
        let savedTime = timeFormat.string(from: startTime.date)
        
        let defaults = UserDefaults.standard
        defaults.set(strDate, forKey: "starTimeSaved")
        defaults.set(savedTime, forKey: "timeLabelSaved")
            
        print(defaults.string(forKey: "starTimeSaved"))
        
        self.viewWillAppear(true)
    }
    
    func createTimeToSubmit() -> StoreSleepRequest {
        let timeFormatterGet = DateFormatter()
        timeFormatterGet.dateFormat = "HH:mm:ss"
        
        let today = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormat.string(from: today)
        
        let defaults = UserDefaults.standard
        var startDate: String
        if let saved = defaults.string(forKey: "starTimeSaved") {
            startDate = saved
        } else {
            startDate = timeFormatterGet.string(from: startTime.date)
        }
    
        let endDate = timeFormatterGet.string(from: endTime.date)
        
        print(formattedDate)
        print(startDate)
        print(endDate)
        
        let request = StoreSleepRequest(date: formattedDate, start: startDate, end: endDate)
        
        return request
    }
    
    @IBAction func submit(_ sender: Any) {
        
        let request = createTimeToSubmit()
        let url = BackendUrl.url.rawValue + Endpoints.storeSleep.rawValue
        
        //MIGHT NEED TO CHANGE repsponseString DEPENDING ON THE RETURN
        Alamofire.request(url, method: .post, parameters: request.dictionary, encoding: JSONEncoding.default).responseString {
            (response) in
            print(response)
        }
    
        
        //defaults.removeObject(forKey: "timeLabelSaved")
        self.viewWillAppear(true)
        
        
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
