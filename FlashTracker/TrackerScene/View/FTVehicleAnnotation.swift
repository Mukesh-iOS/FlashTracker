//
//  FTVehicleAnnotation.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import MapKit

class FTVehicleAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var vehicleID: Int?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
