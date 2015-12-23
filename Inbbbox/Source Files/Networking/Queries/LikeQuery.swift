//
//  LikeQuery.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 17/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct LikeQuery: Query {
    
    let method = Method.POST
    let path: String
    let service: SecureNetworkService = DribbbleNetworkService()
    var parameters = Parameters(encoding: .URL)
    
    init(shotID: String) {
        path = "/shots/" + shotID + "/like"
    }
}