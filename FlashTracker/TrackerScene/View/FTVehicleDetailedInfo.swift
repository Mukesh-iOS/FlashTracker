//
//  FTVehicleDetailedInfo.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class FTVehicleDetailedInfoView: UIView {

    static let reusableId = "FTVehicleDetailedInfoView"
    
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var batteryLevel: UILabel!
    @IBOutlet weak var vehicleTime: UILabel!
    @IBOutlet weak var price: UILabel!
}
