//
//  ProjectsQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct ProjectsQuery: Query {
    
    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .URL)
    
    /// Initialize query for list of shot's projects.
    ///
    /// - parameter shot: Shot to list projects for.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/projects"
    }
}
