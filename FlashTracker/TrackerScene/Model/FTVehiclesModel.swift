//
//  FTVehiclesModel.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit
import MapKit

struct VehicleInfo: Codable {
    
    let id: Int?
    let name: String?
    let description: String?
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
    let batteryLevel: Int?
    let timestamp: String?
    let price: Int?
    let priceTime: Int?
    let currency: String?
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int ?? nil
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? CLLocationDegrees ?? nil
        self.longitude = dictionary["longitude"] as? CLLocationDegrees ?? nil
        self.batteryLevel = dictionary["batteryLevel"] as? Int ?? 0
        self.timestamp = dictionary["timestamp"] as? String ?? ""
        self.price = dictionary["price"] as? Int ?? 0
        self.priceTime = dictionary["priceTime"] as? Int ?? 0
        self.currency = dictionary["currency"] as? String ?? ""
    }
}
