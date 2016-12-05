//
//  NightModeHoursProviderSpec.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 05.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Dobby
import Quick
import Nimble
import Mockingjay

@testable import Inbbbox

class NightModeHoursProviderSpec: QuickSpec {

    override func spec() {
        var locationMock: EstimatedLocationProviderMock!
        var sut: NightModeHoursProvider!
        
        beforeEach {
            locationMock = EstimatedLocationProviderMock()
            sut = NightModeHoursProvider(locationProvider: locationMock)
        }
        
        describe("When checking next sun state hours") {
            
            
            it("should return proper dates") {
                let date = Date(timeIntervalSince1970: 0)
                var sunriseComponents: DateComponents?
                var sunsetComponents: DateComponents?
                _ = sut.sunStateHours(for: date).then { hours -> Void in
                    sunriseComponents = NSCalendar.current.dateComponents([.hour, .minute, .second], from: hours.nextSunrise)
                    sunsetComponents = NSCalendar.current.dateComponents([.hour, .minute, .second], from: hours.nextSunset)
                }
                //correct sunrise time at 01.01.1970 is 08:02:45
                expect(sunriseComponents).toNotEventually(beNil())
                expect(sunriseComponents!.hour).toEventually(equal(8))
                expect(sunriseComponents!.minute).toEventually(equal(2))
                expect(sunriseComponents!.second).toEventually(equal(45))
                
                //correct sunset time at 01.01.1970 is 14:49:11
                expect(sunsetComponents!.hour).toEventually(equal(15))
                expect(sunsetComponents!.minute).toEventually(equal(49))
                expect(sunsetComponents!.second).toEventually(equal(11))
            }
        }
    }
    
    
}
