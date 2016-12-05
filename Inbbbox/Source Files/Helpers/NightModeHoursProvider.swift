//
//  NightModeHoursProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import CoreLocation
import SwiftyJSON
import Solar

enum NightModeHoursProviderError: Error {
    case couldNotCalculate
}

struct SunStateHours {
    let nextSunrise: Date
    let nextSunset: Date
}

// Provides informations about estimated time of
// sunrise and sundown in users location
final class NightModeHoursProvider {
    
    private static let secondsInDay = 24 * 60 * 60
    let locationProvider: EstimatedLocationProvider
    
    init(locationProvider: EstimatedLocationProvider = EstimatedLocationProvider()) {
        self.locationProvider = locationProvider
    }
    
    ///
    /// Provides you with information about next sunrise and 
    /// sunset time in users estimated location.
    ///
    /// - Returns: Promise resolved with SunStateHours object
    ///
    func nextSunStateHours() -> Promise<SunStateHours> {
        return sunStateHours(for: Date())
    }
    
    ///
    /// Provides you with information about sunrise and
    /// sunset time in users estimated location at given date.
    ///
    /// - Returns: Promise resolved with SunStateHours object
    ///
    func sunStateHours(for date: Date) -> Promise<SunStateHours> {
        return Promise<SunStateHours> { fulfill, reject in
            firstly {
                locationProvider.obtainLocationBasedOnIp()
            }.then { location -> Void in
                let latitude = location.latitude
                let longitude = location.longitude
                    
                let solar = Solar(forDate:date, withTimeZone: TimeZone.autoupdatingCurrent, latitude: latitude, longitude: longitude)
                let solarTomorrow = Solar(forDate: date.addingTimeInterval(TimeInterval(NightModeHoursProvider.secondsInDay)), withTimeZone: TimeZone.autoupdatingCurrent, latitude: latitude, longitude: longitude)
                
                let nextSunrise = solar?.sunrise?.compare(date) == .orderedDescending ? solar?.sunrise : solarTomorrow?.sunrise
                
                let nextSunset = solar?.sunset?.compare(date) == .orderedDescending ? solar?.sunset : solarTomorrow?.sunset
                
                if let sunrise = nextSunrise, let sunset = nextSunset {
                    fulfill(SunStateHours(nextSunrise: sunrise, nextSunset: sunset))
                } else {
                    reject(NightModeHoursProviderError.couldNotCalculate)
                }

            }.catch(execute: reject)
        }
    }
}
