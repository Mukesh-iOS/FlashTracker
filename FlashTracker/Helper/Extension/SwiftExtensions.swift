//
//  SwiftExtensions.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showSimpleAlert ( message: String , inViewController: UIViewController){
        let title = "Flash Tracker"
        let okayButtonTitle = "Okay"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: okayButtonTitle, style: .default, handler: nil))
        
        inViewController.present(alert, animated: true , completion: nil)
    }
}

extension Date {
    
     func UTCToLocalWithTimeStamp(timestamp:String) -> String {
        
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: timestamp)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        guard let convertedDate = date else {
            
            return ""
        }
        
        let localTime = dateFormatter.string(from: convertedDate)
        return localTime
    }
    
    func minutesToHoursMinutes (minutes : Int) -> String {
        
        let minuteToHour = minutes / 60
        let leftOverMinutes = minutes % 60
        
        let durationHours = (minuteToHour > 0 && minuteToHour < 2) ? ("Hr ") : minuteToHour > 0 ? ("\(minuteToHour)Hrs ") : ""
        let durationMinutes = leftOverMinutes > 0 ? leftOverMinutes < 2 ? ("\(leftOverMinutes)Min") : ("\(leftOverMinutes)Mins") : ""
        
        let totalDuration = durationHours + (leftOverMinutes > 0 ? ": " : "") + durationMinutes
        
        return totalDuration
    }
}

extension UIActivityIndicatorView {
        
    func showActivityIndicator() {
        self.startAnimating()
        self.isHidden = false
    }
    
    func hideActivity() {
        
        DispatchQueue.main.async {
            self.stopAnimating()
            self.isHidden = true
        }
    }
}
