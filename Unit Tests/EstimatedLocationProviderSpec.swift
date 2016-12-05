//
//  EstimatedLocationProviderSpec.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Dobby
import Quick
import Nimble
import Mockingjay

@testable import Inbbbox

class EstimatedLocationProviderSpec: QuickSpec {
    
    override func spec() {
        
        var sut: EstimatedLocationProvider!
        
        beforeEach {
            sut = EstimatedLocationProvider()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when server responds with proper data") {
            
            it("data should be returned properly") {
                let fileURL = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "UserLocation", ofType:"json")!)
                let data = try! Data(contentsOf: fileURL)
                self.stub(uri("http://ip-api.com/json"), jsonData(data))
                
                var longitude: Double?
                var latitude: Double?
                _ = sut.obtainLocationBasedOnIp().then { location -> Void in
                    longitude = location.longitude
                    latitude = location.latitude
                }
                
                expect(longitude).toEventually(beCloseTo(16.9999))
                expect(latitude).toEventually(beCloseTo(52.9999))
            }
        }
        
        describe("when server responds with broken data") {
            
            it("proper error should be returned") {
                self.stub(uri("http://ip-api.com/json"), jsonData(Data()))
                
                var errorValue: Error?
                _ = sut.obtainLocationBasedOnIp().then { _ -> Void in }.catch { error in
                    errorValue = error
                }
                
                expect(errorValue).toEventually(matchError(EstimatedLocationProviderError.couldNotParseData))
            }
        }
        
        describe("when API call fail") {
            
            it("error should be returned") {
                let error = NSError(domain: "fixture.domain", code: 0, message: "fixture.message")
                self.stub(uri("http://ip-api.com/json"), failure(error))
                
                var errorValue: Error?
                _ = sut.obtainLocationBasedOnIp().then { _ -> Void in }.catch { error in
                    errorValue = error
                }
                
                expect(errorValue).toNotEventually(beNil())
            }
        }
    
    }
}
