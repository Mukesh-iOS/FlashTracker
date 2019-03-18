//
//  FlashTrackerTests.swift
//  FlashTrackerTests
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import XCTest
@testable import FlashTracker

class FlashTrackerTests: XCTestCase {

    var sessionUnderTest: URLSession!
    
    override func setUp() {
        super.setUp()
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }

    override func tearDown() {
        sessionUnderTest = nil
        super.tearDown()
    }
    
    // Asynchronous test: faster fail
    func testVehiclesInfoFromREST() {
        // given
        guard let url = URL(string: "https://my-json-server.typicode.com/FlashScooters/Challenge/vehicles") else {
            
            XCTFail("URL not available")
            return
        }
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        if Reachability().isConnectedToNetwork() {
            let dataTask = sessionUnderTest.dataTask(with: url) { data, response, error in
                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseError = error
                promise.fulfill()
                
                // then
                XCTAssertNil(responseError)
                XCTAssertEqual(statusCode, 200)
                
                guard let responseData = data else {
                    
                    XCTFail("Data not available")
                    return
                }
                
                do {
                    let response = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments)
                    
                    XCTAssertNotNil(response, "Parsed json is empty")
                    
                    if let jsonArray = response as? [[String: Any]] {
                        
                        for (index, vehicleDetails) in jsonArray.enumerated(){
                            
                            XCTAssertNotNil(vehicleDetails["id"], "Vehicle id not available for index \(index)")
                            XCTAssertNotNil(vehicleDetails["latitude"], "Vehicle latitude not available for index \(index)")
                            XCTAssertNotNil(vehicleDetails["longitude"], "Vehicle longitude not available for index \(index)")
                        }
                    }
                }
                catch {
                    XCTAssertNil(error, "\(error.localizedDescription)")
                }
            }
            dataTask.resume()
            waitForExpectations(timeout: 5, handler: nil)
        } else {
            
            XCTFail("Internet conntection not available")
        }
    }
    
    // Asynchronous test: faster fail
    func testDetailedVehicleInfoFromREST() {
        // given
        guard let url = URL(string: "https://my-json-server.typicode.com/FlashScooters/Challenge/vehicles/1") else {
            
            XCTFail("URL not available")
            return
        }
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        if Reachability().isConnectedToNetwork() {
           
            let dataTask = sessionUnderTest.dataTask(with: url) { data, response, error in
                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseError = error
                promise.fulfill()
                
                // then
                XCTAssertNil(responseError)
                XCTAssertEqual(statusCode, 200)
                
                guard let responseData = data else {
                    
                    XCTFail("Data not available")
                    return
                }
                
                do {
                    let response = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments)
                    
                    XCTAssertNotNil(response, "Parsed json is empty")
                    
                    if let jsonDictionary = response as? [String: Any] {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        let resultantModel = try decoder.decode(VehicleInfo.self, from: jsonData)
                        
                        XCTAssertNotNil(resultantModel, "Unexpected data type or missing values for the requested URL")
                        XCTAssertNotNil(resultantModel.id, "Vehicle id not available")
                        XCTAssertNotNil(resultantModel.latitude, "Vehicle latitude not available")
                        XCTAssertNotNil(resultantModel.longitude, "Vehicle longitude not available")
                        XCTAssertNotNil(resultantModel.name, "Vehicle name not available")
                        XCTAssertNotNil(resultantModel.batteryLevel, "Vehicle battery level not available")
                    }
                }
                catch {
                    XCTAssertNil(error, "\(error.localizedDescription)")
                }
            }
            dataTask.resume()
            waitForExpectations(timeout: 5, handler: nil)
        } else {
            
            XCTFail("Internet conntection not available")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
