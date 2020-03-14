//
//  SleepDataViewController.swift
//  Sleep
//
//  Created by Angelo Domingo on 3/9/20.
//  Copyright © 2020 Angelo Domingo. All rights reserved.
//

import UIKit
import Alamofire

class SleepDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var sleepData = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }

    func getData() {
        
        let url = BackendUrl.url.rawValue + Endpoints.pastData.rawValue
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON {
            (response) in
            print(response)
            
            if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("example success")
                        
                        let result = response.result.value as! NSDictionary
                        
                        //print(self.sleepData["result"] ?? "")
                        let dateArr = result["days"] as! NSArray
                        
                        for date in dateArr {
                            self.sleepData.append(date as! NSDictionary)
                        }
                        
                        self.tableView.reloadData()
                        
                    default:
                        print("error with response status: \(status)")
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sleepData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DataCell") as! DataTableViewCell
        
        let dateObj = self.sleepData[indexPath.row]
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let reformat = DateFormatter()
        reformat.dateFormat = "yyyy-MM-dd hh:mm a"
        
        let startDate = timeFormat.date(from: (dateObj["start"] as? String)!)
        let endDate = timeFormat.date(from: (dateObj["end"] as? String)!)
        
        
        let startTime = reformat.string(from: startDate!)
        let endTime = reformat.string(from: endDate!)
        let hoursString = (dateObj["diff"] as? String)!
        
        let components = hoursString.split { $0 == ":" } .map { (x) -> Int in return Int(String(x))! }
        
        let hours = components[0]
        let minutes = components[1]
        
        let finalHours = Double(hours*60 + minutes) / 60.0
        
        cell.startTime.text = startTime
        cell.endTime.text = endTime
        cell.hours.text = String(format: "%.1f", finalHours)
        
        return cell
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
