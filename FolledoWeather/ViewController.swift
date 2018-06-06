//
//  ViewController.swift
//  FolledoWeather
//  Created by Samuel Folledo on 4/26/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

/*
5/8/18 THIS LATEST VERSION, THIS APP USES OPENWEATHERMAP API IN OUR APP AND PARSE ITS JSON FILE
1) get the URL and go to info.plist and allow the domain
*/

import UIKit

class ViewController: UIViewController, UITextFieldDelegate { //UITextFieldDelegate is added in order to run weatherDescription method when pressing return in the keyboard
  

    @IBOutlet var cityTextField: UITextField!
    
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    var nameOfWeather: String = "rain"
    var counter = 0
    
    
    @IBAction func getWeather(_ sender: Any) {
        weatherDescription()
    }
 
    
//viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.backgroundAnimation), userInfo: nil, repeats: true) //to run and change the background every 0.1 seconds

        self.cityTextField.delegate = self
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func backgroundAnimation() {
        var maxCounter: Int = 0
        //print(self.nameOfWeather)
        let weather = String(self.nameOfWeather)
        if weather == "sunny" { maxCounter = 10 }
        else if weather == "clear" { maxCounter = 47 }
        else { maxCounter = 20 }
        
        backgroundImage.image = UIImage(named: "\(weather)\(counter)")
        //print("+++++current image counter is \(counter)+++++")
        counter+=1
        
        if counter == maxCounter { counter = 0 }
    }
    
//weatherDescription method
    func weatherDescription() {

        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=" + cityTextField.text!.replacingOccurrences(of: " ", with: "%20") + "&appid=a8d45e0155d745e7ae0c57539dcae2ea") { //replacingOccurences of a whitespace to %20 because that is what the API does with whitespace character
        
        //create a task from a URL without having to create a request
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in //from the url
            
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data { //this url content is going to be JSON
                    
                    do { //JSONSerialization is something that can go wrong if your data is malformed, so we need to surround it with do-try-catch
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject //JSONSerialization is an object that converts between JSON and the equivalent Foundation objects. You use the JSONSerialization class to convert JSON to Foundation objects and convert Foundation objects to JSON.
                        print(jsonResult)
                        
                        print(jsonResult["name"]) //to print out the name
                        
                        //simplest way to extract description
                        if let description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String {//0 because weather is considered as an array with only one object, and that object is a dictionary from which we can grab the description
                            
                            DispatchQueue.main.sync(execute: { //Dispatch the queue in order to avoid waiting, sync and execute the following code
                                
                                self.resultLabel.text = description
                                
                            })
                            /*
                            let message = newContentArray[0].replacingOccurrences(of: "&deg;", with: "° " )
                            let indexStart = message.index(message.startIndex, offsetBy: 61)
                            message = String(message[indexStart...])
                            */
                            let messageArr = description.components(separatedBy: [" ", "."]) //separate each words in the message by whitespace or period
 
                            for word in messageArr {
                                print(word)
                                if word == "dry" || word == "clear" || word == "sunny" {
                                    self.nameOfWeather = "sunny"
                                    break
                                } else if word == "rain" {
                                    self.nameOfWeather = "rain"
                                    break
                                } else if word == "cloud" || word == "cloudy" {
                                    self.nameOfWeather = "clear"
                                    break
                                } else {
                                    continue
                                }
                            }
                            
                            print(description)
                        }
                        
                    } catch { print("JSON Processing failed") }
                }
            }
            
        }
        task.resume()


    /* //this way is extracting from an HTML. UPDATED IN ORDER TO USE API INSTEAD which is less
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
                        var stringSeparator = "Weather (4&ndash;7 days)</h2></span><p class=" //Start reading the website's code and look for the current stringSeparator. Use \ on "
                        
                        if let contentArray = dataString?.components(separatedBy: stringSeparator) {
                            if contentArray.count > 1 {
                                
                                stringSeparator = "</span>" //which is the characters right after the description
                                let newContentArray = contentArray[1].components(separatedBy: stringSeparator)
                                
                                if newContentArray.count > 0 {
                                    
                                    message = newContentArray[0].replacingOccurrences(of: "&deg;", with: "° " )
                                    let indexStart = message.index(message.startIndex, offsetBy: 61)
                                    message = String(message[indexStart...])
                                    
                                    let messageArr = message.components(separatedBy: [" ", "."]) //separate each words in the message by whitespace or period
                                    for word in messageArr {
                                        print(word)
                                        if word == "dry" {
                                            self.nameOfWeather = "sunny"
                                            break
                                        } else if word == "rain" {
                                            self.nameOfWeather = "rain"
                                            break
                                        } else {
                                            continue
                                        }
                                    }
                                    
                                    //print("+++name of weather is \(self.nameOfWeather)+++")
                                    //print(message)
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
        } //end of if let url HERE WE USED THE SAME ELSE
*/
        } else {
            resultLabel.text = "The URL for the city typed could not be found. Please try again"
        }
 
        resultLabel.alpha = 0 //make it invisible
        UIView.animate(withDuration: 1, animations: {
            self.resultLabel.alpha = 1 //make it visible in 1 second
        })
        self.view.endEditing(true) //to remove the keyboard
    }
    
//textfield delegate method for return in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weatherDescription()
        return true
    }
    
    
 
}

