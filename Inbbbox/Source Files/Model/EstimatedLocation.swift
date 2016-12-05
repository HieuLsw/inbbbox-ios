//
//  EstimatedLocation.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EstimatedLocation {
    let latitude: Double
    let longitude: Double
    let cityName: String
    let country: String
}

extension EstimatedLocation: Mappable {
    
    static var map: (JSON) -> EstimatedLocation {
        return { json in
            
            let latitude = json[Key.latitude.rawValue].doubleValue
            let longitude = json[Key.longitude.rawValue].doubleValue
            let city = json[Key.city.rawValue].stringValue
            let country = json[Key.country.rawValue].stringValue
            
            return EstimatedLocation(latitude: latitude, longitude: longitude, cityName: city, country: country)
        }
    }
    
    fileprivate enum Key: String {
        case latitude = "lat"
        case longitude = "lon"
        case city = "city"
        case country = "country"
    }
}
