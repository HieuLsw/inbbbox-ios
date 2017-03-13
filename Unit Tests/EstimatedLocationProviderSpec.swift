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
            self.removeAllStubs()
        }
        
        describe("when server responds with proper data") {
            
            beforeEach {
                let fileURL = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "UserLocation", ofType:"json")!)
                let data = try! Data(contentsOf: fileURL)
                self.stub(uri("http://ip-api.com/json"), jsonData(data))
            }
            
            it("data should be returned properly") {
                let promise = sut.obtainLocationBasedOnIp()
                
                expect(promise).to(resolveWithValueMatching { location in
                    expect(location.longitude).to(beCloseTo(16.9999))
                    expect(location.latitude).to(beCloseTo(52.9999))
                })
            }
        }
        
        describe("when server responds with broken data") {
            
            beforeEach {
                self.stub(uri("http://ip-api.com/json"), jsonData(Data()))
            }
            
            it("proper error should be returned") {
                let promise = sut.obtainLocationBasedOnIp()
                expect(promise).to(resolveWithError(type: EstimatedLocationProviderError.self))
            }
        }
        
        describe("when API call fail") {
            
            beforeEach {
                let error = NSError(domain: "fixture.domain", code: 0, message: "fixture.message")
                self.stub(uri("http://ip-api.com/json"), failure(error))
            }
            
            it("error should be returned") {
                let promise = sut.obtainLocationBasedOnIp()
                expect(promise).to(resolveWithError())
            }
        }
    
    }
}
