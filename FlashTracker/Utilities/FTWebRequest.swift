//
//  FTWebRequest.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

private struct StatusCode {
    
    static let Success = 200
}

struct FTWebRequest {

    static func fetchDetailsWith(serviceURL: URL?,
                               completionHandler:@escaping ((Any?, String?) -> Void )) {
        
        if Reachability().isConnectedToNetwork() {
            
            URLSession.shared.dataTask(with: serviceURL!, completionHandler: {
                (data, response, error) in
                
                guard error == nil else {
                    
                    completionHandler(nil, error?.localizedDescription)
                    return
                }
                
                // Check if data is available
                
                guard let _ = data, let httpResponse = response as? HTTPURLResponse else {
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, "No data in response")
                    }
                    return
                }
                
                switch (httpResponse.statusCode) {
                    
                case StatusCode.Success:
                    
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                        
                        // This code will be executed for a response json of dictionary format
                        if response is [String: Any] {
                            
                            let decoder = JSONDecoder()
                            
                            let resultantModel = try decoder.decode(VehicleInfo.self, from: data!)
                            DispatchQueue.main.async {
                                completionHandler(resultantModel, nil)
                            }
                        }
                        
                        // This code will be executed for a response json of array format
                        if let jsonArray = response as? [[String: Any]] {

                            var vehiclesInfo = [VehicleInfo]() //Initialising Model Array
                            for vehicleDetails in jsonArray{
                                vehiclesInfo.append(VehicleInfo(vehicleDetails)) // now adding value in Model array
                            }
                            
                            DispatchQueue.main.async {
                                completionHandler(vehiclesInfo, nil)
                            }
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completionHandler(nil, error.localizedDescription)
                        }
                    }
                    break
                default:
                    // Failure case
                    DispatchQueue.main.async {
                        completionHandler(nil, "Unsuccessfull process")
                    }
                    break
                }
            }).resume()
        }
        else {
            completionHandler(nil, "Bad spot!! No network available")
        }
    }
}
