//
//  EstimatedLocationProviderMock.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 05.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby
import PromiseKit

@testable import Inbbbox

class EstimatedLocationProviderMock: EstimatedLocationProvider {

    override func obtainLocationBasedOnIp() -> Promise<EstimatedLocation> {
        return Promise<EstimatedLocation> { fulfill, _ in
            fulfill(EstimatedLocation(latitude: 52.41, longitude: 16.93, cityName: "Poznań", country: "Poland"))
            
        }
    }
}
