//
//  ViewController.swift
//  FolledoWeather
////  Created by Samuel Folledo on 4/26/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cityTextField: UITextField!
    
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    
    var counter = 0
    
    //getWeather method
    
    @IBAction func getWeather(_ sender: Any) {
    
        if let url = URL(string: "https://www.weather-forecast.com/locations/" + cityTextField.text! .replacingOccurrences(of: " ", with: "-") + "/forecasts/latest") { //if let to only run if URL works. And replace all occurences of " " to "-" in order to follow the website's formatting
            
            let request = NSMutableURLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                var message = ""
                
                if error != nil {
                    print(error!)
                } else { //if error does not exist
                    if let unwrappedData = data {
                        let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue) //dataString get the rawValue (Page Source) of unwrappedData
                        //print(dataString)
                        var stringSeparator = "Weather Today </h2>(1&ndash;3 days)</span><p class=" //Start reading the website's code and look for the current stringSeparator. Use \ on "
                        //var stringSeparator = "Weather Forecast Summary:</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">"
                        
                        if let contentArray = dataString?.components(separatedBy: stringSeparator) {
                            if contentArray.count > 1 {
                                
                                //print(contentArray)
                                
                                stringSeparator = "</span>" //which is the characters right after the description
                                let newContentArray = contentArray[1].components(separatedBy: stringSeparator)
                                
                                if newContentArray.count > 0 {
                                    
                                    //                                    let mStartIndex = message.startIndex
                                    //                                    let mEndIndex = message.index(mStartIndex, offsetBy: 60)
                                    //                                    let range = Range(uncheckedBounds: (lower: mStartIndex, upper: mEndIndex))
                                    //                                    message[range]
                                    
                                    //                                    let endOfDomain = message.index(message.startIndex, offsetBy: 60)
                                    //                                    let rangeOfDomain = message.startIndex ..< endOfDomain
                                    //                                    message[rangeOfDomain]
                                    //
                                    message = newContentArray[0].replacingOccurrences(of: "&deg", with: "°" )
                                    //
                                    let indexStart = message.index(message.startIndex, offsetBy: 61)
                                    message = String(message[indexStart...])
                                    print(message)
                                }
                            }
                        }
                    }
                    if message == "" {
                        message = "The weather there couldn't be found. Please try again"
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        self.resultLabel.text = message //have to use self
                    })
                }
            }
            task.resume() //resumes the task if suspended
        } //end of if let url
        else {
            resultLabel.text = "The URL for the city typed could not be found. Please try again"
        }
        
        resultLabel.alpha = 0 //make it invisible
        UIView.animate(withDuration: 1, animations: {
            self.resultLabel.alpha = 1 //make it visible in 1 second
        })
        
        self.view.endEditing(true) //to remove the keyboard
    }
    //end of getWeather
    
    //viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.backgroundAnimation), userInfo: nil, repeats: true) //to run and change the background every 0.1 seconds
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func backgroundAnimation() {
        backgroundImage.image = UIImage(named: "frame_\(counter)_delay-0.1s")
        //print("+++++current image counter is \(counter)+++++")
        counter+=1
        if counter == 20 { counter = 0 }
    }
    
}

