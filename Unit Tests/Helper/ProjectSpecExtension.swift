//
//  ProjectSpecExtension.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import SwiftyJSON

@testable import Inbbbox

extension Project {

    static func fixtureProject() -> Project {
        let json = JSONSpecLoader.sharedInstance.jsonWithResourceName("Project")
        return Project.map(json)
    }
}
