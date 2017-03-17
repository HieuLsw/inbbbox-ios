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
            sut = NightModeHoursProvider(locationProvider: locationMock, timeZone: TimeZone(abbreviation: "GMT")!)
        }
        
        describe("When checking next sun state hours") {
            
            
            it("should return proper dates") {
                let date = Date(timeIntervalSince1970: 0)
                let promise = sut.sunStateHours(for: date)
                    
                expect(promise).to(resolveWithValueMatching { hours in
                    
                    let timeZone = TimeZone(abbreviation: "GMT")!
                    
                    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    calendar.timeZone = timeZone
                    
                    let sunriseComponents = calendar.dateComponents([.hour, .minute, .second], from: hours.nextSunrise)
                    let sunsetComponents = calendar.dateComponents([.hour, .minute, .second], from: hours.nextSunset)
                    
                    //correct sunrise time at 01.01.1970 is 07:02:45
                    expect(sunriseComponents.hour).to(equal(7))
                    expect(sunriseComponents.minute).to(equal(2))
                    expect(sunriseComponents.second).to(equal(45))
                    
                    //correct sunset time at 01.01.1970 is 14:49:11
                    expect(sunsetComponents.hour).to(equal(14))
                    expect(sunsetComponents.minute).to(equal(49))
                    expect(sunsetComponents.second).to(equal(11))
                })
            }
        }
    }
    
    
}
