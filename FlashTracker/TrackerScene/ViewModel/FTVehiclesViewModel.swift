//
//  FTVehiclesViewModel.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

enum FTError: Error {
    
    case Invalid(String)
}

class FTVehiclesViewModel: NSObject {
    
    var infoList: Variable<[VehicleInfo]> = Variable<[VehicleInfo]>()
    var info: Variable<VehicleInfo> = Variable<VehicleInfo>()
    var error: Variable<FTError> = Variable<FTError>()
    
    var vehicleTime: String?
    var cost: String?
    var batteryPercentage: String?
    
    func getVehicles() {
        
        FTWebRequest.fetchDetailsWith(serviceURL: URL(string: FTServiceHelper.listOfVehicles), resultStruct: VehicleInfo.self) { [weak self] (info, errorInfo) in
            
            self?.infoList.value = info as? [VehicleInfo]
            if let errorDescription = errorInfo {
                
                self?.error.value = FTError.Invalid(errorDescription)
            }
        }
    }
    
    func getVehicleInfo(withVehicleId: Int?, completion: @escaping (() -> ())) {

        guard let vehicleId = withVehicleId else {

            self.error.value = FTError.Invalid("Vehicle id not available")

            return
        }

        let serviceURL = FTServiceHelper.vehicleDetail(vehicleId)
        
        FTWebRequest.fetchDetailsWith(serviceURL: URL(string: serviceURL), resultStruct: VehicleInfo.self) { [weak self] (info, errorInfo) in
            
            self?.info.value = info as? VehicleInfo
            self?.vehicleInfoDataPreparation()
            
            if let errorDescription = errorInfo {
                
                self?.error.value = FTError.Invalid(errorDescription)
            } else {
                
                completion()
            }
        }
    }
    
    // MARK: Data handlers
    
    private func vehicleInfoDataPreparation() {
        
        var vehicleDuration: String?
        
        if let timestamp = info.value?.timestamp {
         
            vehicleTime = Date().UTCToLocalWithTimeStamp(timestamp: timestamp)
        }
        
        if let priceTime = info.value?.priceTime {
            
            vehicleDuration = Date().minutesToHoursMinutes(minutes: priceTime)
        }
        
        cost = "Not available"
        if let price = info.value?.price {
            
            let usagePrice = "\(price) " + (info.value?.currency ?? "")
            cost = usagePrice + " / " + (vehicleDuration ?? "")
        }
        
        batteryPercentage = "0%"
        if let battery = info.value?.batteryLevel {
         
            batteryPercentage = "\(battery)" + "%"
        }
    }
}
