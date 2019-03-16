//
//  FTServiceHelper.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class FTServiceHelper: NSObject {
    
    private static let baseURL = "https://my-json-server.typicode.com/FlashScooters/Challenge"
    
    static let listOfVehicles = FTServiceHelper.baseURL + "/vehicles"
    
    class func vehicleDetail(_ vehicleId: Int) -> String {
        
        return FTServiceHelper.listOfVehicles + "/\(vehicleId)"
    }
}
