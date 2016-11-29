//
//  UserSpecExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import SwiftyJSON

@testable import Inbbbox

extension User {
    
    static func fixtureUser() -> User {
        let json = JSONSpecLoader.sharedInstance.jsonWithResourceName("User")
        return User.map(json)
    }
    
    static func fixtureUserForAccountType(_ type: UserAccountType) -> User {
        var json = JSONSpecLoader.sharedInstance.jsonWithResourceName("User")
        json["type"].stringValue = type.rawValue
        
        return User.map(json)
    }
}
