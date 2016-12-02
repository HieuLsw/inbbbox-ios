//
//  ShotSpecExtension.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 1/26/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import SwiftyJSON

@testable import Inbbbox

extension Shot {
    
    static func fixtureShot() -> Shot {
        let json = JSONSpecLoader.sharedInstance.jsonWithResourceName("Shot")
        return Shot.map(json)
    }
    
    static func fixtureShotWithIdentifier(_ identifier: String) -> Shot {
        var json = JSONSpecLoader.sharedInstance.jsonWithResourceName("Shot")
        json["id"].string = identifier
        return Shot.map(json)
    }
}
