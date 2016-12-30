//
//  APIShotsProviderConfiguration.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 22/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum ShotsSource: String {
    
    case newToday = "NewToday"
    case popularToday = "PopularToday"
    case debuts = "Debuts"
    case following = "Following"
    case mySet = "MySet"
    
    var isActive: Bool {
        switch self {
        case .newToday: return Settings.StreamSource.NewToday
        case .popularToday: return Settings.StreamSource.PopularToday
        case .debuts: return Settings.StreamSource.Debuts
        case .following: return Settings.StreamSource.Following
        case .mySet: return false
        }
    }
    
}

class APIShotsProviderConfiguration {

    var sources: [ShotsSource] {
        if Settings.StreamSource.SelectedStreamSource == .mySet {
            return [.newToday, .popularToday, .debuts, .following].filter { $0.isActive }
        }
        return [Settings.StreamSource.SelectedStreamSource]
    }

    func queryByConfigurationForQuery(_ query: ShotsQuery, source: ShotsSource) -> ShotsQuery {
        var resultQuery = query
        switch source {
            case .newToday:
                resultQuery.parameters["sort"] = "recent" as AnyObject?
            case .popularToday, .mySet:
                break
            case .debuts:
                resultQuery.parameters["list"] = "debuts" as AnyObject?
                resultQuery.parameters["sort"] = "recent" as AnyObject?
            case .following:
                resultQuery.followingUsersShotsQuery = true
        }

        resultQuery.date = Date()

        return resultQuery
    }
}
